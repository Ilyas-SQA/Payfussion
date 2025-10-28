import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:payfussion/core/utils/setting_utils/data_and_permission_utils/app_styles.dart';

import '../../../../core/constants/fonts.dart';

class BulletPoint extends StatelessWidget {
  final String text;

  const BulletPoint(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("•  ", style: Font.montserratFont(fontSize: 16.sp, fontWeight: FontWeight.bold)),
          Expanded(child: Text(text, style: Font.montserratFont(
            fontSize: 12,
          ),)),
        ],
      ),
    );
  }
}