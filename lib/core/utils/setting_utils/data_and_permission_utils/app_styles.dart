import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../constants/fonts.dart';

class AppStyles {
  static TextStyle sectionTitleStyle(BuildContext context, {Color? color}) =>
      Font.montserratFont(
        fontSize: 22.sp,
        fontWeight: FontWeight.bold,
        color: color ?? Theme.of(context).textTheme.titleLarge?.color,
      );

  static TextStyle cardTitleStyle(BuildContext context) =>
      Font.montserratFont(
        fontSize: 18.sp,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).secondaryHeaderColor,
      );

  static TextStyle bodyTextStyle(BuildContext context) =>
      Font.montserratFont(
        fontSize: 16.sp,
        color: Theme.of(context).textTheme.bodyMedium?.color,
      );

  static TextStyle listItemTextStyle(BuildContext context) =>
      Font.montserratFont(
        fontSize: 16.sp,
        color: Theme.of(context).textTheme.bodyMedium?.color,
      );

  static TextStyle buttonTextStyle(context) =>
      Font.montserratFont(fontSize: 14.sp, fontWeight: FontWeight.bold,color: Theme.of(context).secondaryHeaderColor,);
}