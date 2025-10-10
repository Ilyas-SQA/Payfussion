import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

BoxDecoration kcDeco = BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(12.r),
  boxShadow: [
    BoxShadow(
      color: const Color(0xff868699).withOpacity(0.1),
      spreadRadius: 1,
      blurRadius: 10,
      offset: const Offset(-4, -4), // changes position of shadow
    ),
    BoxShadow(
      color: const Color(0xff868699).withOpacity(0.1),
      spreadRadius: 1,
      blurRadius: 10,
      offset: const Offset(4, 4), // changes position of shadow
    ),
  ],
);

BoxDecoration kcDecoRadius = BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(12.r),
);

BoxDecoration sampleDoc = BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(12.r),
  boxShadow: [
    BoxShadow(
      color: Colors.grey.withOpacity(0.1),
      spreadRadius: 1,
      blurRadius: 2,
      offset: Offset(0, 1), // changes position of shadow
    ),
  ],
);
