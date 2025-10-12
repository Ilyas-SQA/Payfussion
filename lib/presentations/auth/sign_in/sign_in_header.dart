import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:payfussion/core/constants/image_url.dart';

class SignInHeader extends StatefulWidget {
  const SignInHeader({super.key});

  @override
  State<SignInHeader> createState() => _SignInHeaderState();
}

class _SignInHeaderState extends State<SignInHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _logoScaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Fade animation
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    // Slide animation
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    // Logo scale animation
    _logoScaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );

    // Start animation
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 60.h),

        // Animated Logo
        ScaleTransition(
          scale: _logoScaleAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Hero(
              tag: 'logo',
              child: Image.asset(TImageUrl.iconLogo, height: 100.h),
            ),
          ),
        ),

        25.verticalSpace,

        // Animated Welcome Text
        SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Text(
              'Welcome to PayFussion',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        5.verticalSpace,

        // Animated Subtitle
        SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.5),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: _controller,
              curve: const Interval(0.4, 1.0, curve: Curves.easeOutCubic),
            ),
          ),
          child: FadeTransition(
            opacity: Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(
              CurvedAnimation(
                parent: _controller,
                curve: const Interval(0.4, 1.0, curve: Curves.easeIn),
              ),
            ),
            child: Text(
              'Sign in to your account to continue.',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12.sp,
              ),
            ),
          ),
        ),

        30.verticalSpace,
      ],
    );
  }
}