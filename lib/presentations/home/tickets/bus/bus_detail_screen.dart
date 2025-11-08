import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:payfussion/core/theme/theme.dart';
import 'package:payfussion/core/widget/appbutton/app_button.dart';
import '../../../../core/constants/fonts.dart';
import '../../../../data/models/tickets/bus_model.dart';
import '../../../widgets/background_theme.dart';
import 'bus_payment_screen.dart';

class BusDetailScreen extends StatefulWidget {
  final BusModel bus;

  const BusDetailScreen({super.key, required this.bus});

  @override
  State<BusDetailScreen> createState() => _BusDetailScreenState();
}

class _BusDetailScreenState extends State<BusDetailScreen> with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _buttonController;
  late AnimationController _backgroundAnimationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _buttonScaleAnimation;

  @override
  void initState() {
    super.initState();
    _backgroundAnimationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );

    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _buttonScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _buttonController,
      curve: Curves.easeInOut,
    ));

    // Start animations
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _slideController.forward();
    });
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _fadeController.forward();
    });
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _scaleController.forward();
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    _buttonController.dispose();
    _backgroundAnimationController.dispose();
    super.dispose();
  }

  // Safe clamp function for opacity values
  double _safeOpacity(double value) {
    return value.clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.bus.companyName),
        iconTheme: const IconThemeData(color: MyTheme.secondaryColor),
      ),
      body: Stack(
        children: <Widget>[
          AnimatedBackground(
            animationController: _backgroundAnimationController,
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Hero(
                      tag: 'bus_detail_${widget.bus.companyName}',
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(5.r),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: Theme.of(context).brightness == Brightness.light ? Colors.grey.withOpacity(0.3) : Colors.black.withOpacity(0.3),
                              blurRadius: 5,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                ScaleTransition(
                                  scale: _scaleAnimation,
                                  child: const Icon(
                                    Icons.directions_bus,
                                    size: 32,
                                    color: MyTheme.secondaryColor,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      TweenAnimationBuilder<double>(
                                        tween: Tween<double>(begin: 0.0, end: 1.0),
                                        duration: const Duration(milliseconds: 600),
                                        builder: (BuildContext context, double value, Widget? child) {
                                          return Transform.translate(
                                            offset: Offset(0, 20 * (1 - value)),
                                            child: Opacity(
                                              opacity: _safeOpacity(value),
                                              child: Text(
                                                widget.bus.companyName,
                                                style: Font.montserratFont(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                      AnimatedContainer(
                                        duration: const Duration(milliseconds: 500),
                                        margin: const EdgeInsets.only(top: 4),
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).scaffoldBackgroundColor,
                                          borderRadius: BorderRadius.circular(5.r),
                                          boxShadow: <BoxShadow>[
                                            BoxShadow(
                                              color: Theme.of(context).brightness == Brightness.light ? Colors.grey.withOpacity(0.3) : Colors.black.withOpacity(0.3),
                                              blurRadius: 5,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Text(
                                          widget.bus.busType,
                                          style: Font.montserratFont(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            ..._buildAnimatedDetailRows(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Description Card
                if (widget.bus.description.isNotEmpty) ...<Widget>[
                  _buildAnimatedCard(
                    delay: 400,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "Description",
                          style: Font.montserratFont(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: 800),
                          builder: (BuildContext context, double value, Widget? child) {
                            return Opacity(
                              opacity: _safeOpacity(value),
                              child: Text(
                                widget.bus.description,
                                style: Font.montserratFont(
                                  fontSize: 14,
                                  height: 1.5,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Amenities Card
                if (widget.bus.amenities.isNotEmpty) ...<Widget>[
                  _buildAnimatedCard(
                    delay: 600,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "Amenities",
                          style: Font.montserratFont(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...widget.bus.amenities.asMap().entries.map(
                              (MapEntry<int, String> entry) => TweenAnimationBuilder<double>(
                            tween: Tween<double>(begin: 0.0, end: 1.0),
                            duration: Duration(milliseconds: 600 + (entry.key * 100)),
                            curve: Curves.easeOutBack,
                            builder: (BuildContext context, double value, Widget? child) {
                              return Transform.translate(
                                offset: Offset(-50 * (1 - value), 0),
                                child: Opacity(
                                  opacity: _safeOpacity(value),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                    child: Row(
                                      children: <Widget>[
                                        Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: Colors.green.shade100,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.check,
                                            size: 16,
                                            color: MyTheme.secondaryColor,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            entry.value,
                                            style: Font.montserratFont(
                                              fontSize: 14,
                                              height: 1.4,
                                            ),
                                          ),
                                        ),
                                      ],
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
                  const SizedBox(height: 20),
                ],

                // Book Now Button with Animation
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.bounceOut,
                  builder: (BuildContext context, double value, Widget? child) {
                    return Transform.scale(
                      scale: value.clamp(0.0, 1.0),
                      child: AnimatedBuilder(
                        animation: _buttonScaleAnimation,
                        builder: (BuildContext context, Widget? child) {
                          return Transform.scale(
                            scale: _buttonScaleAnimation.value.clamp(0.5, 1.0),
                            child: GestureDetector(
                              onTapDown: (_) => _buttonController.forward(),
                              onTapUp: (_) => _buttonController.reverse(),
                              onTapCancel: () => _buttonController.reverse(),
                              child: AppButton(
                                text: "Book Now",
                                color: MyTheme.secondaryColor,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
                                        return BusPaymentScreen(bus: widget.bus);
                                      },
                                      transitionDuration: const Duration(milliseconds: 400),
                                      transitionsBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
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
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedCard({required int delay, required Widget child}) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + delay),
      curve: Curves.easeOutCubic,
      builder: (BuildContext context, double value, _) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(
            opacity: _safeOpacity(value),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(5.r),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Theme.of(context).brightness == Brightness.light ? Colors.grey.withOpacity(0.3) : Colors.black.withOpacity(0.3),
                    blurRadius: 5,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildAnimatedDetailRows() {
    final List<(IconData, String, String)> details = <(IconData, String, String)>[
      (Icons.route, "Route", widget.bus.route),
      if (widget.bus.via.isNotEmpty) (Icons.location_on, "Via", widget.bus.via),
      (Icons.access_time, "Duration", "${widget.bus.duration.inHours}h ${widget.bus.duration.inMinutes % 60}m"),
      (Icons.attach_money, "Approximate Cost", "\$${widget.bus.approxCostUSD.toStringAsFixed(0)} per person"),
      (Icons.airline_seat_recline_normal, "Total Seats", "${widget.bus.totalSeats} seats"),
    ];

    return details.asMap().entries.map((MapEntry<int, (IconData, String, String)> entry) {
      return TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        duration: Duration(milliseconds: 800 + (entry.key * 150)),
        curve: Curves.easeOutBack,
        builder: (BuildContext context, double value, Widget? child) {
          return Transform.translate(
            offset: Offset(-30 * (1 - value), 0),
            child: Opacity(
              opacity: _safeOpacity(value),
              child: _buildDetailRow(
                entry.value.$1,
                entry.value.$2,
                entry.value.$3,
              ),
            ),
          );
        },
      );
    }).toList();
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(5.r),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Theme.of(context).brightness == Brightness.light ? Colors.grey.withOpacity(0.3) : Colors.black.withOpacity(0.3),
                  blurRadius: 5,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              icon,
              size: 20,
              color: MyTheme.secondaryColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label,
                  style: Font.montserratFont(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Font.montserratFont(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}