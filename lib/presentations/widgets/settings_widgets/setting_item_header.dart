import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/fonts.dart';

class SettingItemsHeader extends StatelessWidget {
  Widget? itemHeaderSideButton;
  String itemHeaderText;

  SettingItemsHeader({
    super.key,
    this.itemHeaderSideButton,
    required this.itemHeaderText,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          itemHeaderText,
          style: Font.montserratFont(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (itemHeaderSideButton == null) const SizedBox(),
        if (itemHeaderSideButton != null)
          Container(
            height: 30.h,
            width: 84.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13.r),
            ),
            child: Center(child: itemHeaderSideButton),
          ),
      ],
    );
  }
}
