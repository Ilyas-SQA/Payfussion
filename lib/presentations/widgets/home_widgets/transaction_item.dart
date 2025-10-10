import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/theme.dart';

class TransactionItem extends StatelessWidget {
  final String iconPath;
  final String heading;
  final String transactionId;
  final String moneyValue;
  final String status;
  final String date;
  final String time;

  const TransactionItem({
    super.key,
    required this.iconPath,
    required this.heading,
    required this.transactionId,
    required this.moneyValue,
    required this.status,
    required this.date,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    // Define status color and background based on status value
    Color statusColor;
    Color statusBackground;

    switch (status.toLowerCase()) {
      case 'completed':
        statusColor = const Color(0xff00B383); // Green
        statusBackground = const Color(0xffE6F7F1);
        break;
      case 'pending':
        statusColor = const Color(0xffFFAA00); // Amber
        statusBackground = const Color(0xffFFF6E5);
        break;
      case 'failed':
        statusColor = const Color(0xffFF3B30); // Red
        statusBackground = const Color(0xffFFF0EF);
        break;
      default:
        statusColor = Colors.grey;
        statusBackground = const Color(0xffF2F2F2);
    }

    // Determine if amount is positive or negative for coloring
    final bool isNegative =
        double.tryParse(moneyValue) != null && double.parse(moneyValue) < 0;
    final Color amountColor = isNegative
        ? const Color(0xffFF3B30)
        : const Color(0xff00B383);

    final String amountPrefix = isNegative ? "- \$" : "\$";
    final String displayAmount = isNegative
        ? moneyValue.replaceAll('-', '')
        : moneyValue;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(15.r),
      elevation: 2,
      child: Container(
        height: 85.h,
        width: 358.w,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            const BoxShadow(
              color: Colors.black26,
              blurRadius: 5,
              offset: Offset(1, 1),
            ),
          ],
        ),
        child: Row(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 15.w),
              child: Container(
                height: 52.h,
                width: 52.w,
                decoration: BoxDecoration(
                  color: MyTheme.primaryColor,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Image.asset(
                  iconPath,
                  color: theme.primaryColor,
                  scale: 0.8,
                ),
              ),
            ),
            SizedBox(width: 15.w),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    heading,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 16.sp,
                      color: theme.secondaryHeaderColor,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 5.h),
                  Row(
                    children: <Widget>[
                      Text(
                        "ID: ",
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 12.sp,
                          color: theme.secondaryHeaderColor.withOpacity(0.6),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Flexible(
                        child: Text(
                          transactionId,
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 12.sp,
                            color: theme.secondaryHeaderColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5.h),
                  Row(
                    children: <Widget>[
                      Icon(
                        Icons.access_time_rounded,
                        size: 12.sp,
                        color: theme.secondaryHeaderColor.withOpacity(0.6),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        "$date • $time",
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 11.sp,
                          color: theme.secondaryHeaderColor.withOpacity(0.6),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(right: 15.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(
                    "$amountPrefix $displayAmount",
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 16.sp,
                      color: amountColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    height: 22.h,
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    decoration: BoxDecoration(
                      color: statusBackground,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Container(
                          width: 6.w,
                          height: 6.h,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          status,
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 12.sp,
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
