import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../../theme/theme.dart';

class PhoneCredentialsField extends StatelessWidget {
  final TextEditingController controller;
  final String helpText;
  final Function(String)? onPhoneChanged;

  const PhoneCredentialsField({
    Key? key,
    required this.controller,
    required this.helpText,
    this.onPhoneChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IntlPhoneField(
      controller: controller,
      cursorColor: MyTheme.primaryColor,
      textAlignVertical: TextAlignVertical.center,
      cursorHeight: 14,
      decoration: InputDecoration(
        hintText: helpText,
        contentPadding: EdgeInsets.only(bottom: 24.h, left: 15.w),
        /// Normal Border
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.r)),
          borderSide: BorderSide(
            color: Colors.grey.shade300,
            width: 1,
          ),
        ),
        /// Focused Border
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.r)),
          borderSide: const BorderSide(
            color: MyTheme.primaryColor,
            width: 1.5,
          ),
        ),
        /// Error Border
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.r)),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 1.2,
          ),
        ),
        /// Focused Error Border
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.r)),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 1.5,
          ),
        ),
        hintStyle: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.normal
        ),
      ),
      style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.normal
      ),
      initialCountryCode: 'PK', // Pakistan
      dropdownIconPosition: IconPosition.leading,
      showCountryFlag: true,
      showDropdownIcon: false,
      onChanged: (phone) {
        if (onPhoneChanged != null) {
          onPhoneChanged!(phone.completeNumber);
        }
      },
    );
  }
}