import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:payfussion/core/constants/image_url.dart';


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
  });

  final String cardNumber, cvc, cardId, cardBrand, cardHolder, expiryDate, balance;
  final List<Color> cardColor;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 200.h,
        width: 350.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          gradient: LinearGradient(
            colors: cardColor.isNotEmpty ? cardColor : [
              Color(0xFF0a3d3d),
              Color(0xFF1a5555),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          // boxShadow: [
          //   BoxShadow(
          //     color: Colors.black.withOpacity(0.3),
          //     blurRadius: 20,
          //     offset: const Offset(0, 10),
          //   ),
          // ],
        ),
        child: Stack(
          children: [
            // Diagonal stripes overlay
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20.r),
                child: CustomPaint(
                  painter: DiagonalStripesPainter(),
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.all(24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top section - Balance and Logo
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Balance
                      Image.asset("assets/images/cards/sim-card.png",height: 40,width: 40,),
                      // Card brand logo (VISA)
                      TImageUrl.getCardBrandLogo(cardBrand),
                    ],
                  ),

                  // Middle section - Card number
                  Text(
                    cardNumber,
                    style: TextStyle(
                      fontFamily: 'Courier New',
                      fontSize: 20.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 3.0,
                    ),
                  ),

                  // Bottom section - Card holder and expiry
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Card holder
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Card Holder",
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 9.sp,
                              color: Colors.white.withOpacity(0.6),
                              fontWeight: FontWeight.w400,
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            cardHolder,
                            style: TextStyle(
                              fontFamily: 'Montserrat',
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
                        children: [
                          Text(
                            "Expires",
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 9.sp,
                              color: Colors.white.withOpacity(0.6),
                              fontWeight: FontWeight.w400,
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            expiryDate,
                            style: TextStyle(
                              fontFamily: 'Montserrat',
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

// Custom painter for diagonal stripes
class DiagonalStripesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.black.withOpacity(0.1)
      ..strokeWidth = 100
      ..style = PaintingStyle.stroke;

    // Draw diagonal stripes
    for (double i = -size.height; i < size.width + size.height; i += 150) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}