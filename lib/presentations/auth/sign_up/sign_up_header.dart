import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:payfussion/core/constants/image_url.dart';

import '../../../core/constants/fonts.dart';

class SignUpHeader extends StatefulWidget {
  const SignUpHeader({super.key});

  @override
  State<SignUpHeader> createState() => _SignUpHeaderState();
}

class _SignUpHeaderState extends State<SignUpHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  late Animation<Offset> _titleSlide;
  late Animation<double> _titleFade;
  late Animation<Offset> _subtitleSlide;
  late Animation<double> _subtitleFade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Logo animations
    _logoScale = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOutBack),
      ),
    );

    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
      ),
    );

    // Title animations
    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.6, curve: Curves.easeOut),
      ),
    );

    _titleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.6, curve: Curves.easeIn),
      ),
    );

    // Subtitle animations
    _subtitleSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 0.8, curve: Curves.easeOut),
      ),
    );

    _subtitleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 0.8, curve: Curves.easeIn),
      ),
    );

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
        SizedBox(height: 50.h),
        ScaleTransition(
          scale: _logoScale,
          child: FadeTransition(
            opacity: _logoFade,
            child: Hero(
              tag: 'logo',
              child: Image.asset(TImageUrl.iconLogo, height: 80.h),
            ),
          ),
        ),
        15.verticalSpace,
        SlideTransition(
          position: _titleSlide,
          child: FadeTransition(
            opacity: _titleFade,
            child: Text(
              'Welcome to PayFussion',
              style: Font.montserratFont(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        5.verticalSpace,
        SlideTransition(
          position: _subtitleSlide,
          child: FadeTransition(
            opacity: _subtitleFade,
            child: Text(
              'Sign up to your account to continue.',
              style: Font.montserratFont(
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