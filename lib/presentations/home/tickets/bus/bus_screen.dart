import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:payfussion/core/theme/theme.dart';
import '../../../../logic/blocs/tickets/bus/bus_bloc.dart';
import '../../../../logic/blocs/tickets/bus/bus_event.dart';
import '../../../../logic/blocs/tickets/bus/bus_state.dart';
import '../../../widgets/background_theme.dart';
import 'bus_detail_screen.dart';

class BusListScreen extends StatefulWidget {
  const BusListScreen({super.key});

  @override
  State<BusListScreen> createState() => _BusListScreenState();
}

class _BusListScreenState extends State<BusListScreen> with TickerProviderStateMixin {
  late AnimationController _refreshController;
  late Animation<double> _refreshRotation;
  late AnimationController _backgroundAnimationController;

  @override
  void initState() {
    super.initState();
    _backgroundAnimationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
    _refreshController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _refreshRotation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _refreshController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _backgroundAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOutBack,
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: const Text("US Bus Services"),
            );
          },
        ),
        actions: [
          AnimatedBuilder(
            animation: _refreshRotation,
            builder: (context, child) {
              return Transform.rotate(
                angle: _refreshRotation.value * 2 * 3.14159,
                child: IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    _refreshController.forward().then((_) {
                      _refreshController.reset();
                    });
                    context.read<BusBloc>().add(InitializeBuses());
                  },
                ),
              );
            },
          ),
        ],
        iconTheme: const IconThemeData(color: MyTheme.secondaryColor),
      ),
      body: Stack(
        children: [
          AnimatedBackground(
            animationController: _backgroundAnimationController,
          ),
          BlocBuilder<BusBloc, BusState>(
            builder: (BuildContext context, BusState state) {
              if (state is BusLoading) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 600),
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: value,
                            child: const CircularProgressIndicator(),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 800),
                        builder: (context, value, child) {
                          return Opacity(
                            opacity: value,
                            child: const Text(
                              "Loading buses...",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              }

              if (state is BusError) {
                return TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.elasticOut,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error, size: 64, color: Colors.red.shade400),
                            const SizedBox(height: 16),
                            Text(state.message, textAlign: TextAlign.center),
                            const SizedBox(height: 16),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              child: ElevatedButton(
                                onPressed: () {
                                  context.read<BusBloc>().add(LoadBuses());
                                },
                                child: const Text('Retry'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }

              if (state is BusLoaded) {
                return AnimatedList(
                  padding: const EdgeInsets.all(8),
                  initialItemCount: state.buses.length,
                  itemBuilder: (context, index, animation) {
                    if (index >= state.buses.length) return const SizedBox.shrink();

                    final bus = state.buses[index];
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(1.0, 0.0),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                      )),
                      child: FadeTransition(
                        opacity: animation,
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 300 + (index * 100)),
                          curve: Curves.easeOutBack,
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
                          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          child: Hero(
                            tag: 'bus_${bus.companyName}_${index}',
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
                                      return BusDetailScreen(bus: bus);
                                    },
                                    transitionDuration: const Duration(milliseconds: 400),
                                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                      return SlideTransition(
                                        position: Tween<Offset>(
                                          begin: const Offset(1.0, 0.0),
                                          end: Offset.zero,
                                        ).animate(CurvedAnimation(
                                          parent: animation,
                                          curve: Curves.easeOutCubic,
                                        )),
                                        child: FadeTransition(
                                          opacity: animation,
                                          child: child,
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    TweenAnimationBuilder<double>(
                                      tween: Tween<double>(begin: 0.0, end: 1.0),
                                      duration: Duration(milliseconds: 600 + (index * 100)),
                                      curve: Curves.elasticOut,
                                      builder: (BuildContext context, double value, Widget? child) {
                                        return Transform.scale(
                                          scale: value,
                                          child: const Icon(
                                            Icons.directions_bus,
                                            color: MyTheme.secondaryColor,
                                            size: 28,
                                          ),
                                        );
                                      },
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          AnimatedDefaultTextStyle(
                                            duration: const Duration(milliseconds: 300),
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color: Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white,
                                            ),
                                            child: Text(bus.companyName),
                                          ),
                                          const SizedBox(height: 4),
                                          AnimatedDefaultTextStyle(
                                            duration: const Duration(milliseconds: 300),
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white,
                                            ),
                                            child: Text(bus.route),
                                          ),
                                          if (bus.via.isNotEmpty) ...[
                                            const SizedBox(height: 2),
                                            AnimatedOpacity(
                                              duration: const Duration(milliseconds: 400),
                                              opacity: 1.0,
                                              child: Text(
                                                "Via: ${bus.via}",
                                                style: TextStyle(
                                                  color: Colors.grey.shade500,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ],
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.access_time,
                                                size: 16,
                                                color: MyTheme.secondaryColor,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                "${bus.duration.inHours}h ${bus.duration.inMinutes % 60}m",
                                                style: TextStyle(
                                                  color: Colors.grey.shade600,
                                                  fontSize: 12,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              AnimatedContainer(
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
                                                  bus.busType,
                                                  style: const TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    TweenAnimationBuilder<double>(
                                      tween: Tween<double>(begin: 0.0, end: 1.0),
                                      duration: Duration(milliseconds: 800 + (index * 100)),
                                      curve: Curves.bounceOut,
                                      builder: (context, value, child) {
                                        return Transform.scale(
                                          scale: value,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                "\$${bus.approxCostUSD.toStringAsFixed(0)}",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.green.shade600,
                                                  fontSize: 18,
                                                ),
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
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              }

              return TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 600),
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: const Center(child: Text('No buses available')),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Color _getBusTypeColor(String busType) {
    switch (busType.toLowerCase()) {
      case 'premium':
        return Colors.purple.shade600;
      case 'express':
        return Colors.blue.shade600;
      default:
        return Colors.grey.shade600;
    }
  }
}