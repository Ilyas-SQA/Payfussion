import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:payfussion/core/theme/theme.dart';

import '../../../../logic/blocs/tickets/car/car_bloc.dart';
import '../../../../logic/blocs/tickets/car/car_event.dart';
import '../../../../logic/blocs/tickets/car/car_state.dart';
import 'car_detail_screen.dart';

class RideServiceListScreen extends StatefulWidget {
  const RideServiceListScreen({super.key});

  @override
  State<RideServiceListScreen> createState() => _RideServiceListScreenState();
}

class _RideServiceListScreenState extends State<RideServiceListScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _refreshController;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _refreshController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  void _handleRefresh() {
    _refreshController.forward().then((_) {
      context.read<RideBloc>().add(InitializeRides());
      _refreshController.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(-1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: _controller,
            curve: Curves.elasticOut,
          )),
          child: const Text("US Ride Services"),
        ),
        actions: [
          RotationTransition(
            turns: _refreshController,
            child: IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _handleRefresh,
            ),
          ),
        ],
        iconTheme: const IconThemeData(color: MyTheme.secondaryColor),
      ),
      body: BlocBuilder<RideBloc, RideState>(
        builder: (context, state) {
          if (state is RideLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.8, end: 1.2),
                    duration: const Duration(milliseconds: 1000),
                    builder: (context, scale, child) {
                      return Transform.scale(
                        scale: scale,
                        child: const CircularProgressIndicator(),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  FadeTransition(
                    opacity: _controller,
                    child: const Text('Loading rides...'),
                  ),
                ],
              ),
            );
          }

          if (state is RideError) {
            return FadeTransition(
              opacity: _controller,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 600),
                      builder: (context, scale, child) {
                        return Transform.scale(
                          scale: scale,
                          child: Icon(Icons.error, size: 64, color: Colors.red.shade400),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    Text(state.message, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.read<RideBloc>().add(LoadRides()),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is RideLoaded) {
            return FadeTransition(
              opacity: _controller,
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: state.rides.length,
                itemBuilder: (context, index) {
                  final ride = state.rides[index];
                  return TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: Duration(milliseconds: 300 + (index * 80)),
                    curve: Curves.easeOutBack,
                    builder: (context, value, child) {
                      final clampedValue = value.clamp(0.0, 1.0);
                      return Transform.translate(
                        offset: Offset(0, 30 * (1 - clampedValue)),
                        child: Opacity(
                          opacity: clampedValue,
                          child: AnimatedRideCard(
                            ride: ride,
                            index: index,
                            onTap: () => Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, animation, _) => RideDetailScreen(ride: ride),
                                transitionsBuilder: (context, animation, _, child) {
                                  return SlideTransition(
                                    position: Tween<Offset>(
                                      begin: const Offset(1.0, 0.0),
                                      end: Offset.zero,
                                    ).animate(animation),
                                    child: child,
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            );
          }

          return FadeTransition(
            opacity: _controller,
            child: const Center(child: Text('No rides available')),
          );
        },
      ),
    );
  }
}

class AnimatedRideCard extends StatefulWidget {
  final dynamic ride;
  final int index;
  final VoidCallback onTap;

  const AnimatedRideCard({
    super.key,
    required this.ride,
    required this.index,
    required this.onTap,
  });

  @override
  State<AnimatedRideCard> createState() => _AnimatedRideCardState();
}

class _AnimatedRideCardState extends State<AnimatedRideCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        if (mounted) {
          setState(() => _isHovered = true);
          _hoverController.forward();
        }
      },
      onExit: (_) {
        if (mounted) {
          setState(() => _isHovered = false);
          _hoverController.reverse();
        }
      },
      child: AnimatedBuilder(
        animation: _hoverController,
        builder: (context, child) {
          final double scale = 1.0 + (_hoverController.value * 0.02);
          final double elevation = 4.0 + (_hoverController.value * 4.0);

          return Transform.scale(
            scale: scale,
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              elevation: elevation,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: widget.onTap,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(5.r),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).brightness == Brightness.light ? Colors.grey.withOpacity(0.3) : Colors.black.withOpacity(0.3),
                        blurRadius: 5,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Hero(
                          tag: 'service_icon_${widget.index}',
                          child: TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: 1),
                            duration: const Duration(milliseconds: 500),
                            builder: (context, value, child) {
                              return Transform.rotate(
                                angle: value * 2 * 3.14159,
                                child: Icon(
                                  _getServiceIcon(widget.ride.serviceType),
                                  color: MyTheme.secondaryColor,
                                  size: 28,
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Hero(
                                tag: 'driver_name_${widget.index}',
                                child: Material(
                                  color: Colors.transparent,
                                  child: Text(
                                    widget.ride.driverName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${widget.ride.carMake} ${widget.ride.carModel}",
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).scaffoldBackgroundColor,
                                      borderRadius: BorderRadius.circular(5.r),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Theme.of(context).brightness == Brightness.light ? Colors.grey.withOpacity(0.3) : Colors.black.withOpacity(0.3),
                                          blurRadius: 5,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      widget.ride.serviceType,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  TweenAnimationBuilder<double>(
                                    tween: Tween(begin: 0, end: 1),
                                    duration: const Duration(milliseconds: 600),
                                    builder: (context, scale, child) {
                                      return Transform.scale(
                                        scale: scale,
                                        child: const Icon(Icons.star, size: 16, color: Colors.amber),
                                      );
                                    },
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    "${widget.ride.rating}",
                                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "${widget.ride.totalRides} rides",
                                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Available in: ${widget.ride.serviceAreas.take(2).join(', ')}",
                                style: const TextStyle(color: MyTheme.secondaryColor, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Hero(
                              tag: 'price_${widget.index}',
                              child: Text(
                                "\$${widget.ride.baseRate.toStringAsFixed(2)}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: MyTheme.secondaryColor,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "per mile",
                              style: TextStyle(color: Colors.grey.shade300, fontSize: 10),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: widget.ride.isAvailable ? Colors.green : Colors.red,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                widget.ride.isAvailable ? "Available" : "Busy",
                                style: const TextStyle(color: Colors.white, fontSize: 8),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getServiceColor(String serviceType) {
    switch (serviceType.toLowerCase()) {
      case 'uber': return MyTheme.primaryColor;
      case 'lyft': return MyTheme.primaryColor;
      case 'taxi': return MyTheme.primaryColor;
      case 'limousine': return MyTheme.primaryColor;
      case 'shuttle': return MyTheme.primaryColor;
      default: return MyTheme.primaryColor;
    }
  }

  IconData _getServiceIcon(String serviceType) {
    switch (serviceType.toLowerCase()) {
      case 'uber':
      case 'lyft': return Icons.directions_car;
      case 'taxi': return Icons.local_taxi;
      case 'limousine': return Icons.airport_shuttle;
      case 'shuttle': return Icons.directions_bus;
      default: return Icons.directions_car;
    }
  }
}