import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../core/constants/image_url.dart';
import '../../core/theme/theme.dart';
import '../../data/models/card/card_model.dart';
import '../widgets/background_theme.dart';
import '../widgets/payment_selector_widget.dart';

class CurrencyExchangeHistoryView extends StatefulWidget {
  const CurrencyExchangeHistoryView({super.key});

  @override
  State<CurrencyExchangeHistoryView> createState() => _CurrencyExchangeHistoryViewState();
}

class _CurrencyExchangeHistoryViewState extends State<CurrencyExchangeHistoryView> with TickerProviderStateMixin{
  late AnimationController _backgroundAnimationController;

  @override
  void initState() {
    super.initState();
    _backgroundAnimationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _backgroundAnimationController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? MyTheme.darkBackgroundColor : MyTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: isDark ? MyTheme.darkBackgroundColor : MyTheme.backgroundColor,
        centerTitle: true,
        title: Text(
          'Currency Exchange History',
          style: theme.textTheme.bodyLarge,
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            AnimatedBackground(
              animationController: _backgroundAnimationController,
            ),
            Column(
              children: <Widget>[
                30.verticalSpace,
                // Payment Card Selector and Icons
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5.w),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: PaymentCardSelector(
                          userId: FirebaseAuth.instance.currentUser?.uid ?? '',
                          onCardSelect: (CardModel card) {},
                        ),
                      ),
                      _buildIcon(TImageUrl.iconSearch, isDark),
                      SizedBox(width: 5.w),
                      _buildIcon(TImageUrl.iconFilter, isDark),
                    ],
                  ),
                ),

                // Empty State Section
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
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
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(String icon, bool isDark) {
    return Container(
      width: 50.w,
      height: 50.h,
      decoration: BoxDecoration(
        color: MyTheme.primaryColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.white30),
      ),
      child: Image.asset(icon, color: Colors.white),
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