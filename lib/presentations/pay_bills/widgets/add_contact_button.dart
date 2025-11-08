// lib/presentations/widgets/quick_access/add_contact_button.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AddContactButton extends StatelessWidget {
  final VoidCallback onTap;

  const AddContactButton({
    Key? key,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.only(right: 16.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              height: 56.h,
              width: 56.w,
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: theme.primaryColor, width: 1.5),
              ),
              child: Icon(
                Icons.add,
                color: theme.primaryColor,
                size: 24.sp,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              "Add New",
              style: theme.textTheme.labelMedium,
            ),
          ],
        ),
      ),
    );
  }
}