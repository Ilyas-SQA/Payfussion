import 'package:flutter/material.dart';
import 'package:payfussion/core/theme/theme.dart';

class AppColors {
  static const Color primaryBlue = Color(0xff0054D2);
  static const Color secondaryBlue = Color(0xff8CB7FF);
  static const Color textPrimary = Color(0xff333333);
  static const Color textSecondary = Color(0xff666666);
  static const Color shimmerBase = Color(0xFFEBEBF4);
  static const Color shimmerHighlight = Color(0xFFF4F4F4);
  static const Color errorRed = Color(0xFFE53935);
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF1E1E1E);
  static const Color borderLight = Color(0xFFE0E0E0);
  static const Color borderDark = Color(0xFF424242);
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color warningYellow = Color(0xFFFFC107);
  static const Color infoCyan = Color(0xFF00BCD4);
  static const Color disabledGrey = Color(0xFFBDBDBD);
  static const Color shadowLight = Color(0xFFBDBDBD);
  static const Color shadowDark = Color(0xFF424242);
  static const Color warningOrange = Color(0xFFFF9800);
  static const Color linkBlue = Color(0xFF2196F3);

  static final List<List<Color>> cardColor = [
    [MyTheme.primaryColor, MyTheme.primaryColor],
    [MyTheme.secondaryColor, MyTheme.secondaryColor],
  ];
}

class AppDurations {
  static const Duration searchDebounce = Duration(milliseconds: 300);
  static const Duration quickAnimation = Duration(milliseconds: 200);
  static const Duration pageTransition = Duration(milliseconds: 300);
}

class AppStrings {
  static const String sendMoney = 'Send Money';
  static const String addNew = 'Add New';
  static const String searchRecipients = 'Search recipients';
  static const String noRecipientsYet = 'No recipients yet';
  static const String addRecipientPrompt =
      'Add a recipient to send money quickly';
  static const String addRecipient = 'Add Recipient';
  static const String noMatchingRecipients = 'No matching recipients';
  static const String tryDifferentSearch = 'Try a different search term';
  static const String somethingWentWrong = 'Something went wrong';
  static const String unableToLoad = 'Unable to load your recipients';
  static const String tryAgain = 'Try Again';
}

class AppStyles {
  static TextStyle get title => const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
  );

  static TextStyle get subtitle => const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  static TextStyle get body => const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static TextStyle get caption => const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );
}
