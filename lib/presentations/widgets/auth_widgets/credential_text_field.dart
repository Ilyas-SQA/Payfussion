import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:payfussion/core/constants/fonts.dart';
import 'package:payfussion/core/theme/theme.dart';

class AppTextFormField extends StatelessWidget {
  final bool isPasswordField;
  final String helpText;
  final TextEditingController controller;
  final void Function(String)? onChanged;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final bool useGreenColor;
  final TextInputType? keyboardType;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final void Function()? onEditingComplete;

  const AppTextFormField({
    super.key,
    this.isPasswordField = false,
    required this.helpText,
    required this.controller, this.onChanged,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.focusNode,
    this.useGreenColor = false,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.onEditingComplete,
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
            style: Font.montserratFont(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
            textInputAction: textInputAction,
            inputFormatters: inputFormatters,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                vertical: 16.h,
                horizontal: 19.w,
              ),
              hintText: helpText,
              hintStyle: Font.montserratFont(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold
              ),
              prefixIcon: prefixIcon,
              suffixIcon: suffixIcon == null ?
              isPasswordField ? InkWell(
                onTap: () => context.read<PasswordVisibilityCubit>().toggle(),
                child: Icon(
                  isObscure ? CupertinoIcons.eye_slash_fill : Icons.remove_red_eye_outlined,
                  color: useGreenColor ? MyTheme.secondaryColor : MyTheme.primaryColor,
                ),
              ) : const SizedBox() : suffixIcon,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(5.r),
                ),
                borderSide: BorderSide(
                  color: useGreenColor ? MyTheme.secondaryColor : MyTheme.primaryColor,
                  width: 1,
                ),
              ),

              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(5.r)),
                borderSide: BorderSide(
                  color: useGreenColor ? MyTheme.secondaryColor : MyTheme.primaryColor,
                  width: 1,
                ),
              ),

              /// Focused Border
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(5.r)),
                borderSide: BorderSide(
                  width: 1,
                  color: useGreenColor ? MyTheme.secondaryColor : MyTheme.primaryColor,
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
            onChanged: onChanged,
            validator: validator,
            onEditingComplete: onEditingComplete,
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
