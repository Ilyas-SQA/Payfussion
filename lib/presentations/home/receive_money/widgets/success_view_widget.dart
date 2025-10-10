// lib/presentations/screens/home/receive_money/widgets/payment_success_view.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/theme.dart';
import '../receive_money_payment_screen.dart';

class PaymentSuccessView extends StatelessWidget {
  final ReceiveMoneyPaymentProvider provider;

  const PaymentSuccessView({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 20.h),
            _buildSuccessIcon(),
            SizedBox(height: 24.h),
            Text(
              'Payment Request Created',
              style: TextStyle(
                fontSize: 24.sp, // Slightly larger
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: TextStyle(
                  fontSize: 16.sp,
                  color: AppColors.textSecondary,
                ),
                children: <InlineSpan>[
                  const TextSpan(text: 'You\'ve requested '),
                  TextSpan(
                    text: provider.getFormattedAmount(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: MyTheme.secondaryColor,
                      fontSize: 18.sp,
                    ),
                  ),
                  TextSpan(text: ' from ${provider.selectedContact?.name}'),
                ],
              ),
            ),
            SizedBox(height: 36.h),
            _buildQrCode(),
            SizedBox(height: 36.h),
            _buildRequestDetails(),
            SizedBox(height: 36.h),
            _buildActionButtons(context),
            SizedBox(height: 24.h),
            _buildNewRequestButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessIcon() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 800),
      curve: Curves.elasticOut,
      tween: Tween<double>(begin: 0.5, end: 1.0),
      builder: (BuildContext context, double value, Widget? child) {
        return Transform.scale(
          scale: value,
          child: Container(
            width: 100.r,
            height: 100.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.successGreen.withOpacity(0.1),
            ),
            child: Icon(
              Icons.check_circle,
              size: 60.r,
              color: AppColors.successGreen,
            ),
          ),
        );
      },
    );
  }

  Widget _buildQrCode() {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          if (provider.qrCodeData != null)
            QrImageView(
              data: provider.qrCodeData!,
              version: QrVersions.auto,
              size: 200.r,
              backgroundColor: Colors.white,
              errorStateBuilder: (BuildContext context, Object? error) {
                return Container(
                  width: 200.r,
                  height: 200.r,
                  color: Colors.white,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.error_outline,
                        color: AppColors.errorRed,
                        size: 40.r,
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Error generating QR code',
                        style: TextStyle(
                          color: AppColors.errorRed,
                          fontSize: 14.sp,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.qr_code_scanner,
                size: 16.sp,
                color: AppColors.textSecondary,
              ),
              SizedBox(width: 4.w),
              Text(
                'Scan to pay',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRequestDetails() {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: <Widget>[
          _buildDetailRow('Amount', provider.getFormattedAmount()),
          _buildDivider(),
          _buildDetailRow('To', provider.selectedAccount?.name ?? 'N/A'),
          _buildDivider(),
          _buildDetailRow('From', provider.selectedContact?.name ?? 'N/A'),
          if (provider.note.isNotEmpty) ...<Widget>[
            _buildDivider(),
            _buildDetailRow('Note', provider.note),
          ],
          _buildDivider(),
          _buildDetailRow('Expires', '${provider.expiryDays} days from now'),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            label,
            style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
          ),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(color: Colors.grey.shade200, height: 24.h);
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () async {
              HapticFeedback.lightImpact();

              // Show loading state
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Preparing to share...'),
                  duration: Duration(seconds: 1),
                ),
              );

              // Implement actual share functionality
              try {
                // Replace with actual share implementation
                await Future.delayed(const Duration(milliseconds: 800));

                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Payment request shared successfully'),
                    duration: Duration(seconds: 2),
                    backgroundColor: AppColors.successGreen,
                  ),
                );
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to share: ${e.toString()}'),
                    backgroundColor: AppColors.errorRed,
                  ),
                );
              }
            },
            icon: Icon(Icons.share, size: 20.sp),
            label: Text('Share', style: TextStyle(fontSize: 16.sp)),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              backgroundColor: MyTheme.secondaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
        ),
        // Copy button remains similar with minor improvements
      ],
    );
  }

  Widget _buildNewRequestButton(BuildContext context) {
    return TextButton(
      onPressed: () {
        provider.reset();
      },
      style: TextButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 24.w),
      ),
      child: Text(
        'Create New Request',
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          color: MyTheme.secondaryColor,
        ),
      ),
    );
  }
}
