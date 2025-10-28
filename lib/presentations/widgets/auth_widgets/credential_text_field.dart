import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:payfussion/core/theme/theme.dart';

class AppTextFormField extends StatelessWidget {
  final bool isPasswordField;
  final String helpText;
  final TextEditingController controller;
  final void Function(String)? onChanged;
  final Widget? prefixIcon;
  final String? Function(String?)? validator;
  final bool useGreenColor;
  final TextInputType? keyboardType;

  const AppTextFormField({
    super.key,
    this.isPasswordField = false,
    required this.helpText,
    required this.controller, this.onChanged,
    this.prefixIcon,
    this.validator,
    this.useGreenColor = false,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PasswordVisibilityCubit(),
      child: BlocBuilder<PasswordVisibilityCubit, bool>(
        builder: (BuildContext context, bool isObscure) {
          return TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            cursorColor:  useGreenColor ? MyTheme.secondaryColor : MyTheme.primaryColor,
            textAlignVertical: TextAlignVertical.center,
            obscureText: isPasswordField ? isObscure : false,
            cursorHeight: 18,
            style: TextStyle(
              fontSize: 14.sp,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
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
              suffixIcon: isPasswordField ? InkWell(
                onTap: () => context.read<PasswordVisibilityCubit>().toggle(),
                child: Icon(
                  isObscure ? CupertinoIcons.eye_slash_fill : Icons.remove_red_eye_outlined,
                  color: useGreenColor ? MyTheme.secondaryColor : MyTheme.primaryColor,
                ),
              ) : const SizedBox(),
            ),
            onChanged: onChanged,
            validator: validator,
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
