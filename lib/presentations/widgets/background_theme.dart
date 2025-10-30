import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';

class AnimatedBackground extends StatelessWidget {
  final AnimationController animationController;

  const AnimatedBackground({
    super.key,
    required this.animationController,
  });

  @override
  Widget build(BuildContext context) {
    print("rebuild");
    return AnimatedBuilder(
      animation: animationController,
      builder: (context, child) {
        return Stack(
          children: List.generate(8, (index) {
            /// Calculate movement path for each circle with slower rotation
            /// Changed from * 2 * pi to * 0.5 * pi for 4x slower motion
            final double angle = (animationController.value * 0.5 * pi) + (index * pi / 4);

            /// Reduced radius for smaller circular paths
            final double radiusX = 80 + (index * 15);
            final double radiusY = 100 + (index * 20);

            /// Adjusted offset for smaller ball sizes
            final double left = MediaQuery.of(context).size.width / 2 + cos(angle) * radiusX - 40;
            final double top = MediaQuery.of(context).size.height / 2 + sin(angle) * radiusY - 40;

            /// Significantly reduced ball sizes
            /// Base size: 60-270 instead of 150-360
            final double baseSize = 60 + (index * 30);
            final double pulseEffect = sin(animationController.value * 0.5 * pi) * 10; // Reduced pulse
            final double size = baseSize + pulseEffect;

            final Color circleColor = index % 3 == 0 ? MyTheme.primaryColor.withOpacity(0.15) : index % 3 == 1 ? MyTheme.secondaryColor.withOpacity(0.15) : MyTheme.primaryColor.withOpacity(0.15);

            return Positioned(
              left: left,
              top: top,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: circleColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: circleColor.withOpacity(0.3),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ],
                ),
              ),
            );
          }),
        );
      },
    );
  }
}