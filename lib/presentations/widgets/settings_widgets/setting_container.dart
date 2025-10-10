import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SettingContainer extends StatelessWidget {
  final Widget child;

  const SettingContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        width: 362.w,
        padding: EdgeInsets.symmetric(
          vertical: 20.h,
          horizontal: 16.w,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            const BoxShadow(
              color: Colors.black26,
              blurRadius: 5,
              offset: Offset(1, 1),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}
