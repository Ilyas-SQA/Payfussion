import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/routes_name.dart';
import '../../../core/theme/theme.dart';

class TransactionItemHeader extends StatelessWidget {
  const TransactionItemHeader({
    super.key,
    required this.heading,
    this.showTrailingButton = true,
  });

  final String heading;
  final bool showTrailingButton;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(top: 20.h, left: 20.w, right: 20.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            // Make width dynamic to accommodate different text lengths
            constraints: BoxConstraints(minWidth: 120.w, maxWidth: 160.w),
            height: 32.h,
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: MyTheme.primaryColor,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              heading, // Use the heading parameter
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 16.sp,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          // Conditionally show the View All button
          if (showTrailingButton)
            TextButton(
              onPressed: () {
                context.push(RouteNames.transactionHistory);
              },
              child: Text(
                "View All",
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 12.sp,
                  color: MyTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
