import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:payfussion/core/constants/image_url.dart';

class SignUpHeader extends StatelessWidget {
  const SignUpHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 50.h),
        Hero(
          tag: 'logo',
          child: Image.asset(TImageUrl.iconLogo, height: 90.h),
        ),
        15.verticalSpace,
        Text(
          'Welcome to PayFussion',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        5.verticalSpace,
        Text(
          'Sign up to your account to continue.',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12.sp,
          ),
        ),
        30.verticalSpace,
      ],
    );
  }
}
