import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import '../../../core/constants/fonts.dart';
import '../../../core/theme/theme.dart';

class BoxWidget extends StatelessWidget {
  const BoxWidget({super.key, required this.title, required this.imageURL, required this.onTap,this.backgroundColor = MyTheme.primaryColor});
  final String title;
  final String imageURL;
  final VoidCallback onTap;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 95.h,
        width: 80.h,
        padding: EdgeInsets.all(5.w),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(5.r),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Theme.of(context).brightness == Brightness.light ? Colors.grey.withOpacity(0.3) : Colors.black.withOpacity(0.3),
              blurRadius: 5,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          // spacing: 10,
          children: <Widget>[
            SvgPicture.asset(imageURL, height: 27.h, width: 30.w,color: backgroundColor,),
            Text(title,style: Font.montserratFont(fontSize: 10,fontWeight: FontWeight.w500),textAlign: TextAlign.center,),
          ],
        ),
      ),
    );
  }
}
