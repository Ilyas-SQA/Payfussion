// lib/presentations/widgets/section_headers/section_header.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionText;
  final VoidCallback? onActionPressed;

  const SectionHeader({
    Key? key,
    required this.title,
    this.actionText,
    this.onActionPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.primaryColor != Colors.white
                ? const Color(0xffffffff)
                : const Color(0xff666666),
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        if (actionText != null && onActionPressed != null)
          TextButton(
            onPressed: onActionPressed,
            style: TextButton.styleFrom(
              foregroundColor: theme.primaryColor,
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Text(
              actionText!,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.primaryColor != Colors.white
                    ? const Color(0xffffffff)
                    : const Color(0xff666666),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }
}
