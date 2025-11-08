import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/fonts.dart';
import '../../../../core/theme/theme.dart';
import '../receive_money_payment_screen.dart';

class ExpirySelectorWidget extends StatelessWidget {
  final ReceiveMoneyPaymentProvider provider;
  final ValueChanged<int>? onExpiryChanged;

  const ExpirySelectorWidget({
    super.key,
    required this.provider,
    this.onExpiryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Request Expires In',
          style: Font.montserratFont(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 12.h),
        Wrap(
          spacing: 8.w, // horizontal spacing between chips
          runSpacing: 10.h, // vertical spacing between lines
          children: _buildExpiryOptions(),
        ),
      ],
    );
  }

  List<Widget> _buildExpiryOptions() {
    final List<Map<String, Object>> options = <Map<String, Object>>[
      <String, Object>{'days': 1, 'label': '1 Day'},
      <String, Object>{'days': 3, 'label': '3 Days'},
      <String, Object>{'days': 7, 'label': '7 Days'},
      <String, Object>{'days': 14, 'label': '14 Days'},
      <String, Object>{'days': 30, 'label': '30 Days'},
      <String, Object>{'days': 60, 'label': '60 Days'},
    ];

    return options.map((Map<String, Object> option) {
      final int days = option['days'] as int;
      final String label = option['label'] as String;
      final bool isSelected = provider.expiryDays == days;

      return IntrinsicWidth(
        child: ChoiceChip(
          label: Text(
            label,
            style: Font.montserratFont(
              fontSize: 14.sp,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? Colors.white : Colors.black87,
            ),
          ),
          selected: isSelected,
          selectedColor: MyTheme.primaryColor,
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
            side: BorderSide(
              color: isSelected ? MyTheme.primaryColor : Colors.grey.shade300,
              width: 1.5,
            ),
          ),
          onSelected: (bool selected) {
            if (selected) {
              provider.setExpiryDays(days);
              // Also notify the parent widget about the change
              onExpiryChanged?.call(days);
            }
          },
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          labelPadding: EdgeInsets.symmetric(horizontal: 4.w),
        ),
      );
    }).toList();
  }
}