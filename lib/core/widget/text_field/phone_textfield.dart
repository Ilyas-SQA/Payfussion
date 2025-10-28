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
          fontWeight: FontWeight.normal,
        ),
        contentPadding: EdgeInsets.symmetric(
          vertical: 16.h,
          horizontal: 19.w,
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
