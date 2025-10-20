import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:payfussion/core/theme/theme.dart';
import 'package:payfussion/core/widget/appbutton/app_button.dart';
import '../../../../data/models/tickets/car_model.dart';
import '../../../widgets/custom_button.dart';
import 'car_payment_screen.dart';

class RideDetailScreen extends StatefulWidget {
  final RideModel ride;

  const RideDetailScreen({super.key, required this.ride});

  @override
  State<RideDetailScreen> createState() => _RideDetailScreenState();
}

class _RideDetailScreenState extends State<RideDetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _controller.forward();
    if (widget.ride.isAvailable) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _pulseController.dispose();
    super.dispose();
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
            curve: Curves.easeOutCubic,
          )),
          child: Text(widget.ride.driverName),
        ),
        iconTheme: const IconThemeData(color: MyTheme.secondaryColor),
      ),
      body: FadeTransition(
        opacity: _controller,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Driver Info Card
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutBack,
                builder: (context, value, child) {
                  final clampedValue = value.clamp(0.0, 1.0);
                  return Transform.translate(
                    offset: Offset(0, 30 * (1 - clampedValue)),
                    child: Transform.scale(
                      scale: 0.9 + (0.1 * clampedValue),
                      child: Opacity(
                        opacity: clampedValue,
                        child: _buildDriverCard(),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              // Service Areas Card
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutBack,
                builder: (context, value, child) {
                  final clampedValue = value.clamp(0.0, 1.0);
                  return Transform.translate(
                    offset: Offset(0, 30 * (1 - clampedValue)),
                    child: Opacity(
                      opacity: clampedValue,
                      child: _buildServiceAreasCard(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              // Special Services Card
              if (widget.ride.specialServices.isNotEmpty) ...[
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.easeOutBack,
                  builder: (context, value, child) {
                    final double clampedValue = value.clamp(0.0, 1.0);
                    return Transform.translate(
                      offset: Offset(0, 30 * (1 - clampedValue)),
                      child: Opacity(
                        opacity: clampedValue,
                        child: _buildSpecialServicesCard(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
              ],

              // Book Button
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 1200),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  final clampedValue = value.clamp(0.0, 1.0);
                  return Transform.translate(
                    offset: Offset(0, 50 * (1 - clampedValue)),
                    child: Opacity(
                      opacity: clampedValue,
                      child: _buildBookButton(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDriverCard() {
    return Container(
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
                // Avatar
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 600),
                  builder: (context, scale, child) {
                    return Transform.scale(
                      scale: scale,
                      child: Hero(
                        tag: 'driver_avatar_${widget.ride.driverName}',
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: _getServiceColor(widget.ride.serviceType).withOpacity(0.3),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 30,
                            backgroundColor: _getServiceColor(widget.ride.serviceType),
                            child: Text(
                              widget.ride.driverName.substring(0, 2).toUpperCase(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name
                      TweenAnimationBuilder<Offset>(
                        tween: Tween(
                          begin: const Offset(1, 0),
                          end: Offset.zero,
                        ),
                        duration: const Duration(milliseconds: 600),
                        builder: (context, offset, child) {
                          return Transform.translate(
                            offset: offset * 50,
                            child: Text(
                              widget.ride.driverName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                      ),

                      // Rating
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 800),
                        builder: (context, value, child) {
                          final clampedValue = value.clamp(0.0, 1.0);
                          return Row(
                            children: [
                              Transform.scale(
                                scale: clampedValue,
                                child: const Icon(Icons.star, size: 20, color: Colors.amber),
                              ),
                              const SizedBox(width: 4),
                              Opacity(
                                opacity: clampedValue,
                                child: Text(
                                  "${widget.ride.rating} (${widget.ride.totalRides} rides)",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),

                      // Service type and availability
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: 1),
                            duration: const Duration(milliseconds: 1000),
                            builder: (context, scale, child) {
                              return Transform.scale(
                                scale: scale,
                                child: Container(
                                  margin: const EdgeInsets.only(top: 4),
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _getServiceColor(widget.ride.serviceType),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    widget.ride.serviceType,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          if (widget.ride.isAvailable)
                            TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0, end: 1),
                              duration: const Duration(milliseconds: 1200),
                              builder: (context, scale, child) {
                                return Transform.scale(
                                  scale: scale,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: MyTheme.secondaryColor,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: MyTheme.primaryColor.withOpacity(0.3),
                                          blurRadius: 8,
                                          spreadRadius: 1,
                                        ),
                                      ],
                                    ),
                                    child: const Text(
                                      "Available Now",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Detail rows
            ...([
              [Icons.directions_car, "Vehicle", "${widget.ride.carMake} ${widget.ride.carModel} ${widget.ride.carYear}"],
              [Icons.palette, "Color", widget.ride.carColor],
              [Icons.confirmation_number, "License Plate", widget.ride.licensePlate],
              [Icons.phone, "Phone", widget.ride.phoneNumber],
              [Icons.attach_money, "Base Rate", "\$${widget.ride.baseRate.toStringAsFixed(2)} per mile"],
              [Icons.language, "Languages", widget.ride.languages.join(', ')],
            ].asMap().entries.map((entry) {
              final index = entry.key;
              final detail = entry.value;
              return TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: Duration(milliseconds: 400 + (index * 80)),
                builder: (BuildContext context, double value, Widget? child) {
                  final double clampedValue = value.clamp(0.0, 1.0);
                  return Transform.translate(
                    offset: Offset(20 * (1 - clampedValue), 0),
                    child: Opacity(
                      opacity: clampedValue,
                      child: _buildDetailRow(
                        detail[0] as IconData,
                        detail[1] as String,
                        detail[2] as String,
                      ),
                    ),
                  );
                },
              );
            }).toList()),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceAreasCard() {
    return Container(
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
            TweenAnimationBuilder<Offset>(
              tween: Tween(
                begin: const Offset(-1, 0),
                end: Offset.zero,
              ),
              duration: const Duration(milliseconds: 600),
              builder: (context, offset, child) {
                return Transform.translate(
                  offset: offset * 30,
                  child: const Text(
                    "Service Areas",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.ride.serviceAreas.asMap().entries.map((entry) {
                final index = entry.key;
                final area = entry.value;
                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: Duration(milliseconds: 300 + (index * 100)),
                  builder: (context, scale, child) {
                    return Transform.scale(
                      scale: scale,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: MyTheme.secondaryColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: MyTheme.secondaryColor),
                        ),
                        child: Text(
                          area,
                          style: const TextStyle(
                            color: MyTheme.secondaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecialServicesCard() {
    return Container(
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
            TweenAnimationBuilder<Offset>(
              tween: Tween(
                begin: const Offset(-1, 0),
                end: Offset.zero,
              ),
              duration: const Duration(milliseconds: 600),
              builder: (context, offset, child) {
                return Transform.translate(
                  offset: offset * 30,
                  child: const Text(
                    "Special Services",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            ...widget.ride.specialServices.asMap().entries.map((entry) {
              final index = entry.key;
              final service = entry.value;
              return TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: Duration(milliseconds: 400 + (index * 80)),
                builder: (context, value, child) {
                  final clampedValue = value.clamp(0.0, 1.0);
                  return Transform.translate(
                    offset: Offset(20 * (1 - clampedValue), 0),
                    child: Opacity(
                      opacity: clampedValue,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            Transform.scale(
                              scale: clampedValue,
                              child: const Icon(Icons.check, size: 16, color: Colors.green),
                            ),
                            const SizedBox(width: 8),
                            Text(service),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildBookButton() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (BuildContext context, Widget? child) {
        final double pulseValue = widget.ride.isAvailable ? 1.0 + (_pulseController.value * 0.05) : 1.0;
        return Transform.scale(
          scale: pulseValue,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(27),
              boxShadow: widget.ride.isAvailable ? [
                BoxShadow(
                  color: MyTheme.secondaryColor.withOpacity(0.3),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ] : null,
            ),
            child: AppButton(
              text: widget.ride.isAvailable ? "Book Ride" : "Driver Not Available",
              height: 54.h,
              color: widget.ride.isAvailable ? MyTheme.secondaryColor : Colors.grey.shade400,
              onTap: widget.ride.isAvailable ? () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, _) => RideBookingScreen(ride: widget.ride),
                    transitionsBuilder: (context, animation, _, child) {
                      return SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.0, 1.0),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      );
                    },
                  ),
                );
              } : null,
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: MyTheme.secondaryColor,),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14
                  ),
                ),
                Text(value, style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getServiceColor(String serviceType) {
    switch (serviceType.toLowerCase()) {
      case 'uber': return Colors.black;
      case 'lyft': return Colors.pink.shade600;
      case 'taxi': return Colors.yellow.shade700;
      case 'limousine': return Colors.purple.shade600;
      case 'shuttle': return Colors.blue.shade600;
      default: return Colors.grey.shade600;
    }
  }
}