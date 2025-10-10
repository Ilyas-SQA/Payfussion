import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
      children: [
        Text(
          itemHeaderText,
          style: TextStyle(
            fontFamily: 'Montserrat',
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
              color: const Color(0xff2D9CDB),
              borderRadius: BorderRadius.circular(13.r),
            ),
            child: Center(child: itemHeaderSideButton),
          ),
      ],
    );
  }
}
