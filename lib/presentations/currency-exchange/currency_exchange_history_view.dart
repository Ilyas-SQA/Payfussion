import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:payfussion/core/constants/container_dec.dart';

import '../../core/constants/image_url.dart';
import '../../core/theme/theme.dart';
import '../widgets/payment_selector_widget.dart';

class CurrencyExchangeHistoryView extends StatelessWidget {
  const CurrencyExchangeHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? MyTheme.darkBackgroundColor : MyTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: isDark ? MyTheme.darkBackgroundColor : MyTheme.backgroundColor,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 16.sp,
            color: isDark ? Colors.white : Colors.black,
          ),
          onPressed: () => context.pop(),
        ),
        centerTitle: true,
        title: Text(
          'Currency Exchange History',
          style: theme.textTheme.bodyLarge,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            30.verticalSpace,
            // Payment Card Selector and Icons
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: Row(
                children: [
                  Expanded(
                    child: PaymentCardSelector(
                      userId: FirebaseAuth.instance.currentUser?.uid ?? '',
                      onCardSelect: (PaymentCard card) {},
                    ),
                  ),
                  _buildIcon(TImageUrl.iconSearch, isDark),
                  _buildIcon(TImageUrl.iconFilter, isDark),
                ],
              ),
            ),

            // Empty State Section
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Empty state icon
                    Container(
                      width: 120.w,
                      height: 120.w,
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withOpacity(0.1)
                            : MyTheme.primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.swap_horiz_rounded,
                        size: 60.sp,
                        color: isDark
                            ? Colors.white.withOpacity(0.6)
                            : MyTheme.primaryColor.withOpacity(0.6),
                      ),
                    ),

                    32.verticalSpace,

                    // No history title
                    Text(
                      'No Exchange History',
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),

                    16.verticalSpace,

                    // No history description
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 32.w),
                      child: Text(
                        'You haven\'t made any currency exchanges yet. Start exchanging to see your transaction history here.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w400,
                          color: isDark
                              ? Colors.white.withOpacity(0.7)
                              : Colors.black.withOpacity(0.6),
                          height: 1.5,
                        ),
                      ),
                    ),

                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(String icon, bool isDark) {
    return Container(
      width: 40.w,
      height: 40.h,
      margin: EdgeInsets.only(left: 8.w),
      decoration: BoxDecoration(
        color: isDark ? Colors.black : Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: isDark ? Colors.white30 : Colors.black12),
      ),
      child: Image.asset(icon, color: isDark ? Colors.white : Colors.black),
    );
  }

  String getCurrencySymbol(String code) {
    try {
      return NumberFormat.simpleCurrency(name: code).currencySymbol;
    } catch (_) {
      return 'Invalid';
    }
  }
}