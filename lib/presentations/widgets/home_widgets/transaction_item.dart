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

    // Define status color based on status value
    Color statusColor;

    switch (status.toLowerCase()) {
      case 'completed':
        statusColor = const Color(0xff00B383); // Green
        break;
      case 'pending':
        statusColor = const Color(0xffFFAA00); // Amber
        break;
      case 'failed':
        statusColor = const Color(0xffFF3B30); // Red
        break;
      default:
        statusColor = Colors.grey;
    }

    // Determine if amount is positive or negative for coloring
    final bool isNegative =
        double.tryParse(moneyValue) != null && double.parse(moneyValue) < 0;
    final Color amountColor = isNegative
        ? const Color(0xffFF3B30)
        : const Color(0xff00B383);

    final String amountPrefix = isNegative ? "-\$" : "\$";
    final String displayAmount = isNegative
        ? moneyValue.replaceAll('-', '')
        : moneyValue;

    return Container(
      height: 95.h,
      width: 358.w,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.light
                ? Colors.grey.withOpacity(0.2)
                : Colors.black.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.credit_card,
            color: MyTheme.primaryColor,
            size: 32.sp,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  heading,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 13.sp,
                    color: theme.secondaryHeaderColor,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Text(
                  "ID: $transactionId",
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 10.sp,
                    color: theme.secondaryHeaderColor.withOpacity(0.6),
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Row(
                  children: <Widget>[
                    Icon(
                      Icons.access_time_rounded,
                      size: 11.sp,
                      color: theme.secondaryHeaderColor.withOpacity(0.6),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      "$date • $time",
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 10.sp,
                        color: theme.secondaryHeaderColor.withOpacity(0.6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(
                "$amountPrefix $displayAmount",
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 14.sp,
                  color: amountColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 6.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: statusColor.withOpacity(0.3),
                    width: 1,
                  ),
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
                    SizedBox(width: 5.w),
                    Text(
                      status,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 11.sp,
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}