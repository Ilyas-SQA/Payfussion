import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:payfussion/core/theme/theme.dart';
import '../../../../logic/blocs/pay_bill/bill_split/bill_split_bloc.dart';
import '../../../../logic/blocs/pay_bill/bill_split/bill_split_event.dart';
import '../../../../logic/blocs/pay_bill/bill_split/bill_split_state.dart';

class BillSplitSummaryScreen extends StatelessWidget {
  const BillSplitSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bill Split Summary'),
        backgroundColor: Colors.transparent,
      ),
      body: BlocConsumer<BillSplitBloc, BillSplitState>(
        listener: (BuildContext context, BillSplitState state) {
          if (state is BillSplitSuccess) {
            // Show success dialog
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.r),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 80.sp,
                    ),
                    SizedBox(height: 20.h),
                    Text(
                      'Payment Successful!',
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      'Transaction ID: ${state.transactionId}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      // Reset bloc and navigate back to home
                      context.read<BillSplitBloc>().add(const ResetBillSplit());
                      Navigator.of(context).popUntil((Route route) => route.isFirst);
                    },
                    child: Text(
                      'Done',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: MyTheme.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else if (state is BillSplitError) {
            // Show error dialog
            showDialog(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.r),
                ),
                title: const Text('Error'),
                content: Text(state.error),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          }
        },
        builder: (BuildContext context, BillSplitState state) {
          if (state is BillSplitProcessing) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const CircularProgressIndicator(
                    color: MyTheme.primaryColor,
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    'Processing your payment...',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }

          if (state is! BillSplitDataSet) {
            return const Center(child: Text('Invalid state'));
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Header
                Text(
                  'Review Bill Split',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Please review all details before confirming',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 32.h),

                // Bill Info Card
                _buildInfoCard(
                  context,
                  title: 'Bill Information',
                  icon: Icons.receipt_long,
                  children: <Widget>[
                    _buildInfoRow('Bill Name', state.billName),
                    _buildInfoRow('Total Amount', '\$${state.totalAmount.toStringAsFixed(2)}'),
                    _buildInfoRow('Number of People', '${state.numberOfPeople}'),
                    _buildInfoRow('Split Type', state.splitType == 'equal' ? 'Equal Split' : 'Custom Split'),
                  ],
                ),
                SizedBox(height: 16.h),

                // Your Share Card
                _buildYourShareCard(context, state),
                SizedBox(height: 16.h),

                // Participants Card
                _buildParticipantsCard(context, state),
                SizedBox(height: 16.h),

                // Payment Card Info
                if (state.cardId != null)
                  _buildInfoCard(
                    context,
                    title: 'Payment Method',
                    icon: Icons.credit_card,
                    children: <Widget>[
                      _buildInfoRow('Card Holder', state.cardHolderName!),
                      _buildInfoRow('Card Number', '****${state.cardEnding}'),
                    ],
                  ),
                SizedBox(height: 16.h),

                // Amount Breakdown Card
                _buildAmountCard(context, state),
                SizedBox(height: 32.h),

                // Confirm Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      context.read<BillSplitBloc>().add(const ProcessBillSplitPayment());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MyTheme.primaryColor,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      elevation: 4,
                    ),
                    child: Text(
                      'Confirm Payment',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(
      BuildContext context, {
        required String title,
        required IconData icon,
        required List<Widget> children,
      }) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(icon, color: MyTheme.primaryColor, size: 24.sp),
              SizedBox(width: 12.w),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYourShareCard(BuildContext context, BillSplitDataSet state) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[
            MyTheme.primaryColor.withOpacity(0.8),
            MyTheme.primaryColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: MyTheme.primaryColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.person, color: Colors.white, size: 24.sp),
              SizedBox(width: 12.w),
              Text(
                'Your Share',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Center(
            child: Text(
              '\$${state.amountPerPerson.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 48.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantsCard(BuildContext context, BillSplitDataSet state) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(5.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.light ? Colors.grey.withOpacity(0.3) : Colors.black.withOpacity(0.3),
            blurRadius: 5,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.people, color: MyTheme.primaryColor, size: 24.sp),
              SizedBox(width: 12.w),
              Text(
                'All Participants',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          ...state.participantNames.asMap().entries.map((MapEntry<int, String> entry) {
            final int index = entry.key;
            final String name = entry.value;
            final double amount = state.splitType == 'equal'
                ? state.amountPerPerson
                : (state.customAmounts?[name] ?? 0.0);

            return Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: Row(
                children: <Widget>[
                  CircleAvatar(
                    radius: 20.r,
                    backgroundColor: MyTheme.primaryColor.withOpacity(0.2),
                    child: Text(
                      name[0].toUpperCase(),
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: MyTheme.primaryColor,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      name,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    '\$${amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: MyTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildAmountCard(BuildContext context, BillSplitDataSet state) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[MyTheme.primaryColor, MyTheme.primaryColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(5.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: MyTheme.primaryColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          _buildAmountRow('Your Share', '\$${state.amountPerPerson.toStringAsFixed(2)}', isWhite: true),
          Divider(color: Colors.white.withOpacity(0.3), height: 24.h),
          _buildAmountRow('Tax', '\$${state.taxAmount.toStringAsFixed(2)}', isWhite: true),
          Divider(color: Colors.white.withOpacity(0.3), height: 24.h),
          _buildAmountRow(
            'You Pay',
            '\$${(state.amountPerPerson + state.taxAmount).toStringAsFixed(2)}',
            isWhite: true,
            isBold: true,
            isLarge: true,
          ),
        ],
      ),
    );
  }

  Widget _buildAmountRow(
      String label,
      String value, {
        bool isWhite = false,
        bool isBold = false,
        bool isLarge = false,
      }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          label,
          style: TextStyle(
            fontSize: isLarge ? 18.sp : 14.sp,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isWhite ? Colors.white : Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isLarge ? 24.sp : 16.sp,
            fontWeight: FontWeight.bold,
            color: isWhite ? Colors.white : Colors.black,
          ),
        ),
      ],
    );
  }
}