import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:payfussion/core/theme/theme.dart';

import '../../../core/constants/fonts.dart';

class AddCardButton extends StatefulWidget {
  final List cards;
  final Function(BuildContext) onAddCard;

  const AddCardButton({
    Key? key,
    required this.cards,
    required this.onAddCard,
  }) : super(key: key);

  @override
  State<AddCardButton> createState() => _AddCardButtonState();
}

class _AddCardButtonState extends State<AddCardButton> {
  bool _isLoading = false;

  Future<void> _handleAddCard() async {
    if (_isLoading) return; // Prevent multiple taps

    setState(() {
      _isLoading = true;
    });

    HapticFeedback.selectionClick();

    try {
      await widget.onAddCard(context);
    } finally {
      // Reset loading state after operation completes
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (widget.cards.length * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (BuildContext context, double buttonValue, Widget? child) {
        return Transform.translate(
          offset: Offset(50 * (1 - buttonValue), 0),
          child: Opacity(
            opacity: buttonValue,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: GestureDetector(
                onTap: _isLoading ? null : _handleAddCard,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 20.w),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: MyTheme.primaryColor,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 40.w,
                        height: 40.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: _isLoading ?
                        const Center(
                          child: SizedBox(
                            width: 30,
                            height: 30,
                              child: CircularProgressIndicator(),
                          ),
                        ) : Icon(
                          Icons.add,
                          size: 20.sp,
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Text(
                        'Add New Card',
                        style: Font.montserratFont(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color: _isLoading ? Colors.grey[600] : null,
                        ),
                      ),
                      const Spacer(),
                      if (!_isLoading)
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 16.sp,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}