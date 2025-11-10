// lib/presentations/widgets/community_forum/input_field_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/fonts.dart';

class InputFieldWidget extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final int maxLines;

  const InputFieldWidget({
    super.key,
    required this.controller,
    required this.label,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: Font.montserratFont(fontSize: 16.sp),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: Font.montserratFont(
          fontSize: 16.sp,
          color: Colors.grey[600],
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(
            color: Color(0xff2D9CDB),
            width: 2,
          ),
        ),
      ),
    );
  }
}