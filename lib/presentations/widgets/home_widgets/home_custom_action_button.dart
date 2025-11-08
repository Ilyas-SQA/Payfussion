import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomActionButton extends StatelessWidget {
  final Color backgroundColor;
  final String iconPath;
  final Color iconBackgroundColor;
  final String text;
  final VoidCallback onPressed;

  const CustomActionButton({
    super.key,
    required this.backgroundColor,
    required this.iconPath,
    required this.iconBackgroundColor,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 52.h,
        width: 177.w,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: <BoxShadow>[
            const BoxShadow(
              color: Colors.black26,
              blurRadius: 5,
              offset: Offset(1, 1),
            ),
          ],
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 47.w,
              height: 52.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.r),
                color: iconBackgroundColor,
              ),
              child: Center(
                child: SvgPicture.asset(iconPath, height: 30.h, width: 30.w,color: Colors.white,),
              ),
            ),
            Flexible(
              child: Padding(
                padding: EdgeInsets.only(left: 15.0.w),
                child: Text(
                  text,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
