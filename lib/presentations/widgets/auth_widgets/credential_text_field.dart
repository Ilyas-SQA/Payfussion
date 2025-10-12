import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:payfussion/core/theme/theme.dart';

class AppTextormField extends StatelessWidget {
  final bool isPasswordField;
  final String helpText;
  final TextEditingController controller;
  final void Function(String)? onChanged;
  final Widget? prefixIcon;

  const AppTextormField({
    super.key,
    required this.isPasswordField,
    required this.helpText,
    required this.controller, this.onChanged,
    this.prefixIcon,
  });

  TextInputType _getKeyboardType() {
    if (helpText.toLowerCase().contains("email")) {
      return TextInputType.emailAddress;
    } else if (helpText.toLowerCase().contains("phone")) {
      return TextInputType.phone;
    } else {
      return TextInputType.text;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PasswordVisibilityCubit(),
      child: BlocBuilder<PasswordVisibilityCubit, bool>(
        builder: (context, isObscure) {
          return TextField(
            controller: controller,
            keyboardType: _getKeyboardType(),
            cursorColor: MyTheme.primaryColor,
            textAlignVertical: TextAlignVertical.center,
            obscureText: isPasswordField ? isObscure : false,
            cursorHeight: 18,
            style: TextStyle(
              fontSize: 14.sp,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
            ),
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                vertical: 16.h,
                horizontal: 19.w,
              ),
              hintText: helpText,
              hintStyle: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 14.sp,
              ),
              prefixIcon: prefixIcon,
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
                borderSide: BorderSide(
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

              suffixIcon: isPasswordField
                  ? InkWell(
                onTap: () =>
                    context.read<PasswordVisibilityCubit>().toggle(),
                child: Icon(
                  isObscure
                      ? CupertinoIcons.eye_slash_fill
                      : Icons.remove_red_eye_outlined,
                  color: MyTheme.primaryColor,
                ),
              )
                  : const SizedBox(),
            ),
            onChanged: onChanged,
          );
        },
      ),
    );
  }
}

class PasswordVisibilityCubit extends Cubit<bool> {
  PasswordVisibilityCubit() : super(true);

  void toggle() => emit(!state);
}
