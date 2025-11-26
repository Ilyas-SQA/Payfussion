import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import 'package:payfussion/core/constants/image_url.dart';

import '../../../core/constants/fonts.dart';


class CustomCreditCard extends StatelessWidget {
  const CustomCreditCard({
    required this.cardColor,
    required this.cardId,
    required this.cardNumber,
    required this.cvc,
    required this.cardBrand,
    required this.cardHolder,
    required this.expiryDate,
    required this.balance,
    super.key,
    required this.imageUrl,
  });

  final String cardNumber, cvc, cardId, cardBrand, cardHolder, expiryDate, balance;
  final String imageUrl;
  final List<Color> cardColor;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 200.h,
        width: 350.w,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Positioned.fill(
              child: SvgPicture.asset(
                imageUrl,
                fit: BoxFit.cover,
              ),
            ),

            Padding(
              padding: EdgeInsets.all(40.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      // Balance
                      Image.asset(
                        "assets/images/cards/sim-card.png",
                        height: 40.h,
                        width: 40.w,
                      ),
                      // Card brand logo (VISA)
                      TImageUrl.getCardBrandLogo(cardBrand,context),
                    ],
                  ),

                  // Middle section - Card number
                  Text(
                    cardNumber,
                    style: Font.montserratFont(
                      fontSize: 20.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 3.0,
                    ),
                  ),

                  // Bottom section - Card holder and expiry
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      // Card holder
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "Card Holder",
                            style: Font.montserratFont(
                              fontSize: 9.sp,
                              color: Colors.white.withOpacity(0.6),
                              fontWeight: FontWeight.w400,
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            cardHolder,
                            style: Font.montserratFont(
                              fontSize: 14.sp,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),

                      // Expiry date
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Text(
                            "Expires",
                            style: Font.montserratFont(
                              fontSize: 9.sp,
                              color: Colors.white.withOpacity(0.6),
                              fontWeight: FontWeight.w400,
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            expiryDate,
                            style: Font.montserratFont(
                              fontSize: 14.sp,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.8,
                            ),
                          ),
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