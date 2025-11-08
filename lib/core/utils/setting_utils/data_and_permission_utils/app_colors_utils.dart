import 'package:flutter/material.dart';

class AppColors {
  final Color primary;
  final Color warning;
  final Color error;
  final Color success;
  final Color cardBackground;
  final Color textPrimary;
  final Color textSecondary;

  AppColors({
    required this.primary,
    required this.warning,
    required this.error,
    required this.success,
    required this.cardBackground,
    required this.textPrimary,
    required this.textSecondary,
  });

  factory AppColors.of(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return AppColors(
      primary: Theme.of(context).colorScheme.primary,
      warning: Colors.orange,
      error: Theme.of(context).colorScheme.error,
      success: const Color(0xFF27AE60),
      cardBackground: isDark ? const Color(0xFF252525) : Colors.white,
      textPrimary: isDark ? Colors.white : Colors.black87,
      textSecondary: isDark ? Colors.grey[300]! : Colors.grey[700]!,
    );
  }
}