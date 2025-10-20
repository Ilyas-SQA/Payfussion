import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:payfussion/core/theme/theme.dart';

import '../../../../data/models/tickets/flight_model.dart';
import '../../../../logic/blocs/tickets/flight/flight_bloc.dart';
import '../../../../logic/blocs/tickets/flight/flight_event.dart';
import '../../../../logic/blocs/tickets/flight/flight_state.dart';
import 'flight_detail_screen.dart';

class FlightListScreen extends StatelessWidget {
  const FlightListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("US Flight Services"),
        iconTheme: const IconThemeData(color: MyTheme.secondaryColor),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<FlightBloc>().add(InitializeFlights());
            },
          ),
        ],
      ),
      body: BlocBuilder<FlightBloc, FlightState>(
        builder: (BuildContext context, FlightState state) {
          if (state is FlightLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading flights...'),
                ],
              ),
            );
          }

          if (state is FlightError) {
            return Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 500),
                      tween: Tween(begin: 0.0, end: 1.0),
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Icon(
                            Icons.error,
                            size: 64,
                            color: Colors.red.shade400,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    FadeInWidget(
                      delay: const Duration(milliseconds: 300),
                      child: Text(
                        state.message,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 16),
                    FadeInWidget(
                      delay: const Duration(milliseconds: 500),
                      child: ElevatedButton(
                        onPressed: () {
                          context.read<FlightBloc>().add(LoadFlights());
                        },
                        child: const Text('Retry'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is FlightLoaded) {
            return AnimatedList(
              padding: const EdgeInsets.all(8),
              initialItemCount: state.flights.length,
              itemBuilder: (context, index, animation) {
                if (index >= state.flights.length) return const SizedBox.shrink();

                final FlightModel flight = state.flights[index];
                return SlideTransition(
                  position: animation.drive(
                    Tween(begin: const Offset(1.0, 0.0), end: Offset.zero).chain(CurveTween(curve: Curves.easeOutQuart)),
                  ),
                  child: FadeTransition(
                    opacity: animation,
                    child: AnimatedFlightCard(
                      flight: flight,
                      index: index,
                    ),
                  ),
                );
              },
            );
          }

          return const FadeInWidget(
            child: Center(
              child: Text('No flights available'),
            ),
          );
        },
      ),
    );
  }
}

class AnimatedFlightCard extends StatefulWidget {
  final FlightModel flight;
  final int index;

  const AnimatedFlightCard({
    super.key,
    required this.flight,
    required this.index,
  });

  @override
  State<AnimatedFlightCard> createState() => _AnimatedFlightCardState();
}

class _AnimatedFlightCardState extends State<AnimatedFlightCard> with TickerProviderStateMixin {
  late AnimationController _hoverController;
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeInOut,
    ));

    _elevationAnimation = Tween<double>(
      begin: 4.0,
      end: 8.0,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeInOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Start subtle pulse animation with delay based on index
    Future.delayed(Duration(milliseconds: widget.index * 100), () {
      if (mounted) {
        _pulseController.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _hoverController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_scaleAnimation, _elevationAnimation, _pulseAnimation]),
      builder: (BuildContext context, Widget? child) {
        return Transform.scale(
          scale: _scaleAnimation.value * _pulseAnimation.value,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
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
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                _hoverController.forward().then((_) {
                  _hoverController.reverse();
                });

                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => FlightDetailScreen(flight: widget.flight),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: animation.drive(
                            Tween(begin: const Offset(0.0, 0.3), end: Offset.zero).chain(CurveTween(curve: Curves.easeOutCubic)),
                          ),
                          child: child,
                        ),
                      );
                    },
                    transitionDuration: const Duration(milliseconds: 300),
                  ),
                );
              },
              onHover: (bool isHovering) {
                if (isHovering) {
                  _hoverController.forward();
                } else {
                  _hoverController.reverse();
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.all(12),
                          child: TweenAnimationBuilder<double>(
                            duration: Duration(milliseconds: 500 + (widget.index * 100)),
                            tween: Tween(begin: 0.0, end: 1.0),
                            builder: (context, value, child) {
                              return Transform.rotate(
                                angle: value * 2 * 3.14159, // Full rotation
                                child: const Icon(
                                  Icons.flight,
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
                              FadeInWidget(
                                delay: Duration(milliseconds: 100 + (widget.index * 50)),
                                child: Text(
                                  widget.flight.airline,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              FadeInWidget(
                                delay: Duration(milliseconds: 200 + (widget.index * 50)),
                                child: Text(
                                  "Flight ${widget.flight.flightNumber}",
                                ),
                              ),
                              const SizedBox(height: 4),
                              FadeInWidget(
                                delay: Duration(milliseconds: 300 + (widget.index * 50)),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
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
                                    widget.flight.flightType,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        FadeInWidget(
                          delay: Duration(milliseconds: 150 + (widget.index * 50)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              TweenAnimationBuilder<double>(
                                duration: Duration(milliseconds: 800 + (widget.index * 100)),
                                tween: Tween(begin: 0.0, end: widget.flight.basePrice),
                                builder: (context, value, child) {
                                  return Text(
                                    "\$${value.toStringAsFixed(0)}",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green.shade600,
                                      fontSize: 18,
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "per person",
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: FadeInWidget(
                            delay: Duration(milliseconds: 400 + (widget.index * 50)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.flight.departureTime,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  widget.flight.departureAirport,
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        FadeInWidget(
                          delay: Duration(milliseconds: 500 + (widget.index * 50)),
                          child: Column(
                            children: [
                              AnimatedRotation(
                                turns: _pulseAnimation.value * 0.1,
                                duration: const Duration(milliseconds: 1500),
                                child: Icon(
                                  Icons.flight_takeoff,
                                  color: Colors.grey.shade600,
                                  size: 20,
                                ),
                              ),
                              Text(
                                widget.flight.duration,
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),
                              if (widget.flight.stops > 0)
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  child: Text(
                                    "${widget.flight.stops} stop${widget.flight.stops > 1 ? 's' : ''}",
                                    style: TextStyle(
                                      color: Colors.orange.shade600,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: FadeInWidget(
                            delay: Duration(milliseconds: 600 + (widget.index * 50)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  widget.flight.arrivalTime,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  widget.flight.arrivalAirport,
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getFlightTypeColor(String flightType) {
    switch (flightType.toLowerCase()) {
      case 'international':
        return Colors.purple.shade600;
      case 'domestic':
        return Colors.blue.shade600;
      case 'regional':
        return Colors.green.shade600;
      default:
        return Colors.grey.shade600;
    }
  }
}

// Reusable fade-in widget
class FadeInWidget extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;

  const FadeInWidget({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 500),
  });

  @override
  State<FadeInWidget> createState() => _FadeInWidgetState();
}

class _FadeInWidgetState extends State<FadeInWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _opacityAnimation,
            child: widget.child,
          ),
        );
      },
    );
  }
}