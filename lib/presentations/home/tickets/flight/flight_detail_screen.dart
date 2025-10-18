import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:payfussion/core/theme/theme.dart';
import 'package:payfussion/core/widget/appbutton/app_button.dart';

import '../../../../data/models/tickets/flight_model.dart';
import 'flight_payment_screen.dart';

class FlightDetailScreen extends StatefulWidget {
  final FlightModel flight;

  const FlightDetailScreen({super.key, required this.flight});

  @override
  State<FlightDetailScreen> createState() => _FlightDetailScreenState();
}

class _FlightDetailScreenState extends State<FlightDetailScreen> with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _buttonController;
  late AnimationController _routeController;
  late AnimationController _priceController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _routeAnimation;
  late Animation<double> _priceCountAnimation;

  @override
  void initState() {
    super.initState();

    _mainController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _routeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _priceController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _mainController,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: Curves.easeOutCubic,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _buttonController,
      curve: Curves.easeInOut,
    ));

    _routeAnimation = CurvedAnimation(
      parent: _routeController,
      curve: Curves.easeOut,
    );

    _priceCountAnimation = Tween<double>(
      begin: 0.0,
      end: widget.flight.basePrice,
    ).animate(CurvedAnimation(
      parent: _priceController,
      curve: Curves.easeOut,
    ));

    // Start animations
    _mainController.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _routeController.forward();
      }
    });
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        _priceController.forward();
      }
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    _buttonController.dispose();
    _routeController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (BuildContext context, Widget? child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(-0.5, 0),
                  end: Offset.zero,
                ).animate(_fadeAnimation),
                child: Text("${widget.flight.airline} ${widget.flight.flightNumber}"),
              ),
            );
          },
        ),
        iconTheme: const IconThemeData(color: MyTheme.secondaryColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (BuildContext context, Widget? child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Main flight info card with hero animation
                    Hero(
                      tag: "flight_${widget.flight.flightNumber}",
                      child: StaggeredAnimationCard(
                        delay: const Duration(milliseconds: 100),
                        child: Container(
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
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    TweenAnimationBuilder<double>(
                                      duration: const Duration(milliseconds: 800),
                                      tween: Tween(begin: 0.0, end: 1.0),
                                      builder: (context, value, child) {
                                        return Transform.rotate(
                                          angle: value * 2 * 3.14159,
                                          child: Transform.scale(
                                            scale: 0.8 + (value * 0.2),
                                            child: const Icon(
                                              Icons.flight,
                                              size: 32,
                                              color: MyTheme.secondaryColor,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          AnimatedTextReveal(
                                            text: widget.flight.airline,
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            delay: const Duration(milliseconds: 300),
                                          ),
                                          AnimatedTextReveal(
                                            text: "Flight ${widget.flight.flightNumber}",
                                            style: const TextStyle(
                                              fontSize: 14,
                                            ),
                                            delay: const Duration(milliseconds: 500),
                                          ),
                                          const SizedBox(height: 4),
                                          DelayedAnimation(
                                            delay: const Duration(milliseconds: 700),
                                            child: AnimatedContainer(
                                              duration: const Duration(milliseconds: 300),
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                _buildAnimatedFlightRoute(),
                                const SizedBox(height: 16),
                                ..._buildAnimatedDetailRows(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Amenities section
                    if (widget.flight.amenities.isNotEmpty) ...[
                      StaggeredAnimationCard(
                        delay: const Duration(milliseconds: 600),
                        child: Container(
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
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const AnimatedTextReveal(
                                  text: "Amenities",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  delay: Duration(milliseconds: 700),
                                ),
                                const SizedBox(height: 8),
                                ...widget.flight.amenities.asMap().entries.map(
                                      (entry) => DelayedAnimation(
                                    delay: Duration(milliseconds: 800 + (entry.key * 100)),
                                    child: SlideInAnimation(
                                      direction: SlideDirection.left,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 2),
                                        child: Row(
                                          children: [
                                            TweenAnimationBuilder<double>(
                                              duration: Duration(milliseconds: 300 + (entry.key * 50)),
                                              tween: Tween(begin: 0.0, end: 1.0),
                                              builder: (BuildContext context, double value, Widget? child) {
                                                return Transform.scale(
                                                  scale: value,
                                                  child: const Icon(
                                                    Icons.check,
                                                    size: 16,
                                                    color: Colors.green,
                                                  ),
                                                );
                                              },
                                            ),
                                            const SizedBox(width: 8),
                                            Text(entry.value),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Book now button with pulse animation
                    DelayedAnimation(
                      delay: const Duration(milliseconds: 1000),
                      child: AnimatedBuilder(
                        animation: _scaleAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _scaleAnimation.value,
                            child: SizedBox(
                              width: double.infinity,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                child: AppButton(
                                  onTap: () {
                                    _buttonController.forward().then((_) {
                                      _buttonController.reverse();
                                    });

                                    Navigator.push(
                                      context,
                                      PageRouteBuilder(
                                        pageBuilder: (context, animation, secondaryAnimation) =>
                                            FlightPaymentScreen(flight: widget.flight),
                                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                          return FadeTransition(
                                            opacity: animation,
                                            child: SlideTransition(
                                              position: animation.drive(
                                                Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
                                                    .chain(CurveTween(curve: Curves.easeOutCubic)),
                                              ),
                                              child: child,
                                            ),
                                          );
                                        },
                                        transitionDuration: const Duration(milliseconds: 400),
                                      ),
                                    );
                                  },
                                  color: MyTheme.secondaryColor,
                                  text: "Book Now",
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAnimatedFlightRoute() {
    return AnimatedBuilder(
      animation: _routeAnimation,
      builder: (context, child) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(-1, 0),
                    end: Offset.zero,
                  ).animate(_routeAnimation),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.flight.departureTime,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        widget.flight.departureAirport,
                        style: const TextStyle(
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ScaleTransition(
                scale: _routeAnimation,
                child: Column(
                  children: [
                    RotationTransition(
                      turns: Tween<double>(begin: 0, end: 0.1).animate(_routeAnimation),
                      child: const Icon(
                        Icons.flight_takeoff,
                        color: MyTheme.secondaryColor,
                        size: 24,
                      ),
                    ),
                    Text(
                      widget.flight.duration,
                      style: const TextStyle(
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(1, 0),
                    end: Offset.zero,
                  ).animate(_routeAnimation),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        widget.flight.arrivalTime,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        widget.flight.arrivalAirport,
                        style: const TextStyle(
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildAnimatedDetailRows() {
    final details = [
      (Icons.flight_takeoff, "Aircraft", widget.flight.aircraft),
      (Icons.access_time, "Duration", widget.flight.duration),
      (Icons.airline_seat_recline_normal, "Total Seats", "${widget.flight.totalSeats} seats"),
      (Icons.attach_money, "Base Price", ""), // Special handling for price
    ];

    if (widget.flight.stops > 0) {
      details.add((Icons.connecting_airports, "Stops", "${widget.flight.stops} stop${widget.flight.stops > 1 ? 's' : ''}"));
    }

    return details.asMap().entries.map((entry) {
      final int index = entry.key;
      final (IconData, String, String) detail = entry.value;

      if (detail.$2 == "Base Price") {
        return DelayedAnimation(
          delay: Duration(milliseconds: 900 + (index * 150)),
          child: _buildAnimatedDetailRow(
            detail.$1,
            detail.$2,
            AnimatedBuilder(
              animation: _priceCountAnimation,
              builder: (BuildContext context, Widget? child) {
                return Text(
                  "\$${_priceCountAnimation.value.toStringAsFixed(0)} per person",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.green.shade600,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
          ),
        );
      }

      return DelayedAnimation(
        delay: Duration(milliseconds: 900 + (index * 150)),
        child: _buildAnimatedDetailRow(detail.$1, detail.$2, Text(detail.$3, style: const TextStyle(fontSize: 16))),
      );
    }).toList();
  }

  Widget _buildAnimatedDetailRow(IconData icon, String label, Widget valueWidget) {
    return SlideInAnimation(
      direction: SlideDirection.left,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 300),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Icon(icon, size: 20, color: MyTheme.secondaryColor),
                );
              },
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  valueWidget,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom Animation Widgets

class StaggeredAnimationCard extends StatefulWidget {
  final Widget child;
  final Duration delay;

  const StaggeredAnimationCard({
    super.key,
    required this.child,
    this.delay = Duration.zero,
  });

  @override
  State<StaggeredAnimationCard> createState() => _StaggeredAnimationCardState();
}

class _StaggeredAnimationCardState extends State<StaggeredAnimationCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
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
        return Card(
          elevation: 4 * _fadeAnimation.value,
          child: SlideTransition(
            position: _slideAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: widget.child,
              ),
            ),
          ),
        );
      },
    );
  }
}

class DelayedAnimation extends StatefulWidget {
  final Widget child;
  final Duration delay;

  const DelayedAnimation({
    super.key,
    required this.child,
    this.delay = Duration.zero,
  });

  @override
  State<DelayedAnimation> createState() => _DelayedAnimationState();
}

class _DelayedAnimationState extends State<DelayedAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: widget.child,
    );
  }
}

class AnimatedTextReveal extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final Duration delay;

  const AnimatedTextReveal({
    super.key,
    required this.text,
    this.style,
    this.delay = Duration.zero,
  });

  @override
  State<AnimatedTextReveal> createState() => _AnimatedTextRevealState();
}

class _AnimatedTextRevealState extends State<AnimatedTextReveal> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Text(widget.text, style: widget.style),
      ),
    );
  }
}

enum SlideDirection { left, right, up, down }

class SlideInAnimation extends StatefulWidget {
  final Widget child;
  final SlideDirection direction;
  final Duration duration;

  const SlideInAnimation({
    super.key,
    required this.child,
    this.direction = SlideDirection.left,
    this.duration = const Duration(milliseconds: 500),
  });

  @override
  State<SlideInAnimation> createState() => _SlideInAnimationState();
}

class _SlideInAnimationState extends State<SlideInAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    Offset beginOffset;
    switch (widget.direction) {
      case SlideDirection.left:
        beginOffset = const Offset(-1, 0);
        break;
      case SlideDirection.right:
        beginOffset = const Offset(1, 0);
        break;
      case SlideDirection.up:
        beginOffset = const Offset(0, -1);
        break;
      case SlideDirection.down:
        beginOffset = const Offset(0, 1);
        break;
    }

    _slideAnimation = Tween<Offset>(
      begin: beginOffset,
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: widget.child,
      ),
    );
  }
}