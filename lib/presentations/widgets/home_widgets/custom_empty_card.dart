import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:payfussion/core/constants/image_url.dart';
import 'package:payfussion/core/theme/theme.dart';
import '../../../services/payment_service.dart';

class CustomEmptyCard extends StatelessWidget {
  const CustomEmptyCard({super.key});


  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 208.h,
        width: 350.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: MyTheme.primaryColor,
          )
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Center(
              child: IconButton(
                icon: Image.asset(
                  TImageUrl.iconAddCard,
                  height: 50.h,
                  width: 50.w,
                  color: MyTheme.primaryColor,
                ),
                onPressed: () {
                  PaymentService().saveCard(context);
                },
              ),
            ),
            // text "No cards Added Yet?"
            Text(
              "No cards Added Yet?",
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            // text: "Add your debit or credit card to start sending and receiving money."
            Padding(
              padding: EdgeInsetsGeometry.symmetric(horizontal: 30.w),
              child: Text(
                "Add your debit or credit card to start sending and receiving money.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
