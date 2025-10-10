// lib/presentations/screens/home/receive_money/widgets/note_input_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../payment_strings.dart';
import '../receive_money_payment_screen.dart';

class NoteInputWidget extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ReceiveMoneyPaymentProvider provider;

  const NoteInputWidget({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          ReceiveMoneyPaymentStrings.addNote,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 12.h),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                spreadRadius: -2,
              ),
            ],
            border: Border.all(color: Colors.grey[300]!, width: 1.0),
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            maxLength: 150,
            maxLines: 3,
            minLines: 2,
            textCapitalization: TextCapitalization.sentences,
            onChanged: (String value) => provider.setNote(value),
            style: TextStyle(fontSize: 16.sp, color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'What\'s this payment for?',
              hintStyle: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey.withOpacity(0.6),
              ),
              counter: const SizedBox.shrink(),
              contentPadding: EdgeInsets.all(16.r),
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
          ),
        ),
        SizedBox(height: 8.h),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '${provider.note.length}/150',
            style: TextStyle(
              fontSize: 12.sp,
              color: provider.note.length > 140
                  ? AppColors.warningOrange
                  : AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
