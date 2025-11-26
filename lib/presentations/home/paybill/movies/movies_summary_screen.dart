import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:payfussion/core/theme/theme.dart';
import '../../../../logic/blocs/pay_bill/movies/movies_bloc.dart';
import '../../../../logic/blocs/pay_bill/movies/movies_event.dart';
import '../../../../logic/blocs/pay_bill/movies/movies_state.dart';

class MoviesSummaryScreen extends StatelessWidget {
  const MoviesSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscription Summary'),
        backgroundColor: Colors.transparent,
      ),
      body: BlocConsumer<MoviesBloc, MoviesState>(
        listener: (BuildContext context, MoviesState state) {
          if (state is MoviesSuccess) {
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
                      'Subscription Active!',
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
                      context.read<MoviesBloc>().add(const ResetSubscription());
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
          } else if (state is MoviesError) {
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
        builder: (BuildContext context, MoviesState state) {
          if (state is MoviesProcessing) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const CircularProgressIndicator(
                    color: MyTheme.primaryColor,
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    'Processing your subscription...',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }

          if (state is! MoviesDataSet) {
            return const Center(child: Text('Invalid state'));
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Header
                Text(
                  'Review Your Subscription',
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

                // Service Info Card
                _buildInfoCard(
                  context,
                  title: 'Streaming Service',
                  icon: Icons.live_tv,
                  children: <Widget>[
                    _buildInfoRow('Service', state.serviceName),
                    _buildInfoRow('Category', state.category),
                  ],
                ),
                SizedBox(height: 16.h),

                // Account Email Card
                _buildInfoCard(
                  context,
                  title: 'Account Email',
                  icon: Icons.email,
                  children: <Widget>[
                    _buildInfoRow('Email', state.email),
                  ],
                ),
                SizedBox(height: 16.h),

                // Subscription Plan Card
                _buildInfoCard(
                  context,
                  title: 'Subscription Plan',
                  icon: Icons.card_membership,
                  children: <Widget>[
                    _buildInfoRow('Plan', state.planName),
                    _buildInfoRow('Duration', state.planDuration),
                    _buildInfoRow('Description', state.planDescription),
                    _buildInfoRow('Auto-Renew', state.autoRenew ? 'Enabled' : 'Disabled'),
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
                      context.read<MoviesBloc>().add(const ProcessSubscriptionPayment());
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
                      'Confirm Subscription',
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

  Widget _buildAmountCard(BuildContext context, MoviesDataSet state) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[MyTheme.primaryColor, MyTheme.primaryColor.withOpacity(0.8)],
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
        children: <Widget>[
          _buildAmountRow('Plan Price', '\$${state.planPrice.toStringAsFixed(2)}', isWhite: true),
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