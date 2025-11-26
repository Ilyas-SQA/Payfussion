import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:payfussion/core/theme/theme.dart';
import '../../../../logic/blocs/pay_bill/gas_bill/gas_bill_bloc.dart';
import '../../../../logic/blocs/pay_bill/gas_bill/gas_bill_event.dart';
import '../../../../logic/blocs/pay_bill/gas_bill/gas_bill_state.dart';

class GasBillSummaryScreen extends StatelessWidget {
  const GasBillSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Summary'),
      ),
      body: BlocConsumer<GasBillBloc, GasBillState>(
        listener: (BuildContext context, GasBillState state) {
          if (state is GasBillSuccess) {
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
                      context.read<GasBillBloc>().add(const ResetGasBill());
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
          } else if (state is GasBillError) {
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
        builder: (BuildContext context, GasBillState state) {
          if (state is GasBillProcessing) {
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

          if (state is! GasBillDataSet) {
            return const Center(child: Text('Invalid state'));
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Header
                Text(
                  'Review Your Payment',
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

                // Company Info Card
                _buildInfoCard(
                  context,
                  title: 'Gas Provider',
                  icon: Icons.local_fire_department,
                  children: <Widget>[
                    _buildInfoRow('Company', state.companyName),
                    _buildInfoRow('Region', state.region),
                    _buildInfoRow('Rate', state.averageRate),
                  ],
                ),
                SizedBox(height: 16.h),

                // Account Details Card
                _buildInfoCard(
                  context,
                  title: 'Account Details',
                  icon: Icons.account_balance,
                  children: <Widget>[
                    _buildInfoRow('Account Number', state.accountNumber),
                    _buildInfoRow('Consumer Name', state.consumerName),
                    _buildInfoRow('Bill Month', state.billMonth),
                  ],
                ),
                SizedBox(height: 16.h),

                // Usage Details Card
                _buildInfoCard(
                  context,
                  title: 'Usage Details',
                  icon: Icons.analytics,
                  children: <Widget>[
                    _buildInfoRow('Gas Usage', state.gasUsage),
                    _buildInfoRow('Previous Reading', state.previousReading),
                    _buildInfoRow('Current Reading', state.currentReading),
                    _buildInfoRow('Due Date', state.dueDate),
                  ],
                ),
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
                      context.read<GasBillBloc>().add(const ProcessGasBillPayment());
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

  Widget _buildAmountCard(BuildContext context, GasBillDataSet state) {
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
          _buildAmountRow('Amount', '\$${state.amount.toStringAsFixed(2)}', isWhite: true),
          Divider(color: Colors.white.withOpacity(0.3), height: 24.h),
          _buildAmountRow('Tax', '\$${state.taxAmount.toStringAsFixed(2)}', isWhite: true),
          Divider(color: Colors.white.withOpacity(0.3), height: 24.h),
          _buildAmountRow(
            'Total Amount',
            '\$${state.totalAmount.toStringAsFixed(2)}',
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