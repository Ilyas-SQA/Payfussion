import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppStyles {
  static TextStyle sectionTitleStyle(BuildContext context, {Color? color}) =>
      TextStyle(
        fontSize: 22.sp,
        fontWeight: FontWeight.bold,
        color: color ?? Theme.of(context).textTheme.titleLarge?.color,
      );

  static TextStyle cardTitleStyle(BuildContext context) =>
      TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).secondaryHeaderColor,
      );

  static TextStyle bodyTextStyle(BuildContext context) =>
      TextStyle(
        fontSize: 16.sp,
        color: Theme.of(context).textTheme.bodyMedium?.color,
      );

  static TextStyle listItemTextStyle(BuildContext context) =>
      TextStyle(
        fontSize: 16.sp,
        color: Theme.of(context).textTheme.bodyMedium?.color,
      );

  static TextStyle buttonTextStyle(context) =>
      TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold,color: Theme.of(context).secondaryHeaderColor,);
}