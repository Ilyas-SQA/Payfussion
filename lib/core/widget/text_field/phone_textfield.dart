import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';
import '../../theme/theme.dart';

class PhoneCredentialsField extends StatelessWidget {
  final TextEditingController controller;
  final String helpText;
  final Function(String)? onPhoneChanged;
  final FutureOr<String?> Function(PhoneNumber?)? validator;

  const PhoneCredentialsField({
    Key? key,
    required this.controller,
    required this.helpText,
    this.onPhoneChanged,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IntlPhoneField(
      controller: controller,
      cursorColor: MyTheme.primaryColor,
      cursorHeight: 18,
      validator: validator,
      decoration: InputDecoration(
        hintText: helpText,
        hintStyle: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.bold,
        ),
        contentPadding: EdgeInsets.symmetric(
          vertical: 16.h,
          horizontal: 19.w,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(5.r)),
          borderSide: const BorderSide(
            color: MyTheme.primaryColor,
            width: 1,
          ),
        ),

        /// Focused Border
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(5.r)),
          borderSide: const BorderSide(
            width: 1,
            color: MyTheme.primaryColor,
          ),
        ),

        /// Error Border
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(5.r)),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 1,
          ),
        ),

        /// Focused Error Border
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(5.r)),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 1,
          ),
        ),
      ),
      style: TextStyle(
        fontSize: 14.sp,
        fontFamily: 'Inter',
        fontWeight: FontWeight.w500,
      ),
      initialCountryCode: 'PK',
      dropdownIconPosition: IconPosition.leading,
      showCountryFlag: true,
      showDropdownIcon: false,
      flagsButtonPadding: const EdgeInsets.symmetric(horizontal: 10),
      onChanged: (PhoneNumber phone) {
        if (onPhoneChanged != null) {
          onPhoneChanged!(phone.completeNumber);
        }
      },
    );
  }
}
