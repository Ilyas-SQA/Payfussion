import 'package:flutter/material.dart';
import '../../theme/theme.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    required this.text,
    required this.onTap,
    this.height = 42,
    this.width = double.infinity,
    this.loading = false,
    this.color = MyTheme.primaryColor,
    this.textStyle = const TextStyle(
        fontWeight: FontWeight.w600,
        color: Colors.white,
        fontSize: 14
    ),
    this.isBorder = true,
    this.isIcon = false,
    this.icon,
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
    super.key});

  final String text;
  final double? height;
  final double? width;
  final bool loading;
  final VoidCallback onTap;
  final Color color;
  final TextStyle textStyle;
  final bool isBorder;
  final bool isIcon;
  final IconData? icon;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: color,
          borderRadius: borderRadius,
          border: Border.all(
            color: Colors.transparent,
          ),
        ),
        child: loading ?
        Center(child: SizedBox(height: 20,width: 20,child: CircularProgressIndicator(color: Colors.white,))) :
        isIcon ? Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 10,
          children: [
            Icon(icon,color: MyTheme.primaryColor,),
            Center(
              child: Text(
                  text,
                  style: textStyle
              ),
            ),
          ],
        ) :
        Center(
          child: Text(
            text,
            style: textStyle,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
