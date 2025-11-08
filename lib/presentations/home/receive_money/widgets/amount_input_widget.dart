// lib/presentations/screens/home/receive_money/widgets/amount_input_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
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
    return Column(
      children: <Widget>[
        // Amount input field
        TextField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textAlign: TextAlign.center,
          style: Font.montserratFont(
            fontSize: 42.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
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
            prefixIcon: Text(
              '\$',
              style: Font.montserratFont(
                fontSize: 42.sp,
                fontWeight: FontWeight.bold,
                color: provider.amount > 0
                    ? AppColors.textPrimary
                    : Colors.transparent,
              ),
            ),
            prefixIconConstraints: BoxConstraints(minWidth: 30.w, minHeight: 0),
          ),
          onChanged: (String value) {
            // Remove any currency symbol and then set the amount
            final String plainValue = value.replaceAll('\$', '');
            provider.setAmount(plainValue);
          },
        ),
        // Error message if any
        if (provider.amountError != null)
          Padding(
            padding: EdgeInsets.only(top: 8.h),
            child: Text(
              provider.amountError!,
              style: Font.montserratFont(color: AppColors.errorRed, fontSize: 14.sp),
            ),
          ),
      ],
    );
  }
}
