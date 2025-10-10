import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:payfussion/core/constants/app_colors.dart';
import 'package:payfussion/core/constants/image_url.dart';
import 'package:payfussion/core/constants/routes_name.dart';
import 'package:payfussion/core/theme/theme.dart';

class CustomCreditCard extends StatelessWidget {
  const CustomCreditCard({required this.cardColor,required this.cardId,required this.cardNumber,required this.cvc,super.key, required this.cardBrand});
  final String cardNumber,cvc,cardId,cardBrand;
  final List<Color> cardColor;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 200.h,
        width: 350.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          gradient: LinearGradient(
            colors: cardColor,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05), // 🔹 More transparent
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.02), // 🔹 Very subtle bottom layer
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background pattern (optional)
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.r),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.1),
                        Colors.transparent,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.center,
                    ),
                  ),
                ),
              ),
            ),
            Image.asset("assets/images/download.png"),
            Padding(
              padding: EdgeInsets.all(24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top row with NFC icon
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Bank name or card type
                      Text(
                        "DEBIT CARD",
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 14.sp,
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        ),
                      ),
                      // NFC icon
                      SvgPicture.asset(
                        TImageUrl.nfc,
                        height: 20.h,
                        width: 20.w,
                        color: Colors.white,
                      ),
                    ],
                  ),

                  // Chip icon
                  Row(
                    children: [
                      SvgPicture.asset(
                        TImageUrl.sim,
                        height: 28.h,
                        width: 32.w,
                      ),
                    ],
                  ),

                  // Card number and details
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Card number
                      Text(
                        cardNumber,
                        style: TextStyle(
                          fontFamily: 'Courier New',
                          fontSize: 18.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.0,
                        ),
                      ),

                      SizedBox(height: 16.h),

                      // Bottom row with CVC and card brand
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // CVC
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "CVC",
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 10.sp,
                                  color: Colors.white.withOpacity(0.7),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                cvc,
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 14.sp,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ],
                          ),

                          // Card brand logo
                          TImageUrl.getCardBrandLogo(cardBrand),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
