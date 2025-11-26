// lib/presentations/screens/home/receive_money/widgets/amount_input_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/fonts.dart';
import '../../../payment_strings.dart';
import '../receive_money_payment_screen.dart';

class AmountInputWidget extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ReceiveMoneyPaymentProvider provider;

  const AmountInputWidget({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textAlign: TextAlign.center,
      style: Font.montserratFont(
        fontSize: 42.sp,
        fontWeight: FontWeight.bold,
        letterSpacing: 1,
      ),
      decoration: InputDecoration(
        hintText: ReceiveMoneyPaymentStrings.enterAmount,
        hintStyle: Font.montserratFont(
          fontSize: 30.sp,
          fontWeight: FontWeight.w400,
          color: Colors.grey.withOpacity(0.6),
        ),
        border: InputBorder.none,
        errorBorder: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
      ),
      onChanged: (String value) {
        // Remove any currency symbol and then set the amount
        final String plainValue = value.replaceAll('\$', '');
        provider.setAmount(plainValue);
      },
      cursorHeight: 35,
    );
  }
}
