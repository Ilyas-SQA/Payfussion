import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AuthButton extends StatefulWidget {
  final List<Color> colors;
  final VoidCallback? onTap;
  final String text;

  const AuthButton({
    super.key,
    required this.colors,
    required this.onTap,
    required this.text,
  });

  @override
  State<AuthButton> createState() => _AuthButtonState();
}

class _AuthButtonState extends State<AuthButton> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      child: Material(
        elevation: 5,
        borderRadius: BorderRadius.all(
          Radius.circular(
            24.r,
          ),
        ),
        child: Container(
          height: 48.h,
          width: 193.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(
              Radius.circular(
                24.r,
              ),
            ),
            gradient: LinearGradient(colors: widget.colors, stops: const <double>[0.5, 1]),
          ),
          child: Align(
            alignment: Alignment.center,
            child: Text(
              widget.text,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 18.sp,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
