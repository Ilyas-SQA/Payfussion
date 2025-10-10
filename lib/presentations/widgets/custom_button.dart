import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isEnabled;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? disabledColor;
  final Color? textColor;
  final double? fontSize;
  final FontWeight? fontWeight;
  final double height;
  final double width;
  final EdgeInsetsGeometry? padding;
  final Widget? icon;
  final BorderRadius? borderRadius;
  final Color? borderColor;
  final double borderSize;
  final bool showShadow;
  final BoxShadow? shadowOptions;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isEnabled = true,
    this.isLoading = false,
    this.backgroundColor,
    this.disabledColor,
    this.textColor,
    this.fontSize,
    this.fontWeight,
    this.height = 50,
    this.width = double.infinity,
    this.padding,
    this.icon,
    this.borderRadius,
    this.borderColor,
    this.borderSize = 0,
    this.showShadow = false,
    this.shadowOptions,
  });

  @override
  Widget build(BuildContext context) {
    Widget button = ElevatedButton(
      onPressed: (isEnabled && !isLoading) ? onPressed : null,
      style: ButtonStyle(
        fixedSize: WidgetStateProperty.all(Size(width, height)),
        minimumSize: WidgetStateProperty.all(Size(width, height)),

        backgroundColor: WidgetStateProperty.resolveWith<Color>((
          Set<WidgetState> states,
        ) {
          if (states.contains(WidgetState.disabled)) {
            return disabledColor ?? const Color.fromRGBO(201, 206, 214, 1);
          }
          return backgroundColor ?? Theme.of(context).primaryColor;
        }),
        padding: WidgetStateProperty.all(
          padding ?? EdgeInsets.symmetric(horizontal: 16.w),
        ),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: borderRadius ?? BorderRadius.circular(12.r),
            side: borderColor != null
                ? BorderSide(color: borderColor!, width: borderSize)
                : BorderSide.none,
          ),
        ),
        elevation: WidgetStateProperty.all(0), // Remove default elevation
      ),
      child: isLoading
          ? SizedBox(
              width: 24.w,
              height: 24.h,
              child: CircularProgressIndicator(
                strokeWidth: 2.w,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Flexible(child: icon!),
                  8.horizontalSpace,
                ],
                Flexible(
                  child: Text(
                    text,
                    style: TextStyle(
                      color: textColor ?? Colors.white,
                      fontSize: fontSize ?? 16.sp,
                      fontWeight: fontWeight ?? FontWeight.w500,
                      overflow: TextOverflow.ellipsis,
                      fontFamily: "Roboto",
                    ),
                  ),
                ),
              ],
            ),
    );

    return showShadow
        ? Container(
            decoration: BoxDecoration(
              borderRadius: borderRadius ?? BorderRadius.circular(12.r),
              boxShadow: [
                shadowOptions ??
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 0,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
              ],
            ),
            child: button,
          )
        : button;
  }
}
