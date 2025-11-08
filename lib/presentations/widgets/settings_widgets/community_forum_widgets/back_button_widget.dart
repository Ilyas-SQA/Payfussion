import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

Widget createBackButton(String path, BuildContext context){
  return InkWell(
    onTap: (){
      context.go(path);
    },
    child: Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Icon(Icons.arrow_back_ios_new, color: const Color(0xff2D9CDB), size: 24.r),
        SizedBox(width: 2.w),
        Text(
          'Back',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 20.sp,
            color: const Color(0xff2D9CDB),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}