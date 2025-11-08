import 'dart:io';
import 'dart:typed_data';

import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:payfussion/core/constants/image_url.dart';
import 'package:payfussion/core/constants/routes_name.dart';
import 'package:payfussion/presentations/widgets/custom_button.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/theme/theme.dart';
import '../../data/models/pay_bills/bill_item.dart';
import '../../services/pdf_generate.dart';
import '../widgets/doted_line_widget.dart';

class ReceiptView extends StatelessWidget {
  final PayBillModel? payBillData;

  const ReceiptView({
    super.key,
    this.payBillData,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    // Use provided data or fallback to dummy data
    final PayBillModel? billData = payBillData;

    // Format amount - now properly uses actual data
    final String displayAmount = billData != null
        ? '\$ ${billData.amount.toStringAsFixed(2)}'
        : '\$ 2140.00';

    // Format date - now uses actual payment date
    final String displayDate = billData != null
        ? DateFormat('dd-MM-yyyy, HH:mm:ss').format(billData.paidAt ?? billData.createdAt)
        : '25-02-2023, 13:22:16';

    return Scaffold(
      backgroundColor: isDark ? MyTheme.darkBackgroundColor : MyTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: isDark ? MyTheme.darkBackgroundColor : MyTheme.backgroundColor,
        leading: IconButton(
          icon: Icon(
            Icons.close_sharp,
            size: 24.sp,
            color: isDark ? Colors.white : Colors.black54,
          ),
          onPressed: () => context.go(RouteNames.homeScreen),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.ios_share_rounded,
              size: 24.sp,
              color: isDark ? Colors.white : Colors.black54,
            ),
            onPressed: () {
              _shareReceipt(billData);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Image.asset(TImageUrl.iconLogo, width: 120.w, height: 120.h),

              AvatarGlow(
                glowColor: Colors.green.shade300,
                glowRadiusFactor: 0.3,
                glowShape: BoxShape.circle,
                curve: Curves.fastOutSlowIn,
                duration: const Duration(seconds: 2),
                repeat: true,
                child: Image.asset(
                  TImageUrl.iconDone,
                  width: 40.w,
                  height: 40.h,
                  colorBlendMode: BlendMode.srcIn,
                ),
              ),
              18.verticalSpace,
              Text(
                'Payment Success!',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontFamily: 'Poppins',
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w300,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),

              5.verticalSpace,

              Text(
                displayAmount,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontFamily: 'Poppins',
                  fontSize: 25.sp,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),

              12.verticalSpace,
              Divider(
                indent: 30.w,
                endIndent: 30.w,
                color: isDark ? Colors.white38 : Colors.black38,
                thickness: 2,
              ),

              25.verticalSpace,
              _buildRow(
                  'Ref Number',
                  billData?.id.substring(0, 10).toUpperCase() ?? '1234567890',
                  isDark
              ),
              8.verticalSpace,
              _buildRow('Payment Time', displayDate, isDark),
              8.verticalSpace,
              _buildRow(
                  'Payment Method',
                  billData != null ? _formatPaymentMethod(billData.paymentMethod) : 'Bank Transfer',
                  isDark
              ),
              8.verticalSpace,
              _buildRow(
                  'Bill Number',
                  billData?.billNumber ?? 'DEMO-123456',
                  isDark
              ),
              8.verticalSpace,
              _buildRow(
                  'Company Name',
                  billData?.companyName ?? 'XYZ Company',
                  isDark
              ),
              10.verticalSpace,

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 29.w),
                child: DottedLine(
                  indent: 25.w,
                  endIndent: 25.w,
                  dotLength: 4.w,
                  space: 4.w,
                  color: isDark ? Colors.white38 : Colors.black38,
                  thickness: 2,
                ),
              ),
              10.verticalSpace,
              _buildRow('Amount', displayAmount, isDark),
              8.verticalSpace,
              _buildRow(
                  'Admin Fee',
                  billData?.hasFee == true
                      ? '\$ ${billData!.feeAmount.toStringAsFixed(2)}'
                      : 'No fee',
                  isDark
              ),
              8.verticalSpace,
              _buildRow(
                  'Card Used',
                  billData?.cardEnding ?? '**** 1234',
                  isDark
              ),
              8.verticalSpace,
              _buildRow(
                'Status',
                billData?.status.toUpperCase() ?? 'COMPLETED',
                isDark,
                statusColor: _getStatusColor(billData?.status ?? 'completed'),
              ),
              100.verticalSpace,
              TextButton(
                child: Text(
                  'Get PDF Receipt',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontFamily: 'Poppins',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                onPressed: () async {
                  await _generateAndOpenPDF(billData);
                },
              ),
              10.verticalSpace,
              CustomButton(
                text: 'Back to Home',
                backgroundColor: const Color(0xff2D9CDB),
                onPressed: () {
                  context.go(RouteNames.homeScreen);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to get status color
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'success':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      default:
        return Colors.green;
    }
  }

  Future<void> _shareReceipt(PayBillModel? billData) async {
    try {
      // Show loading indicator (optional)
      // You can add a loading dialog here if needed

      if (billData != null) {
        // Create payment receipt data from actual bill data
        final PaymentReceiptData receiptData = PaymentReceiptData.fromBillData(billData);

        // Generate PDF
        final Uint8List pdfData = await PdfServices().generateReceipt(data: receiptData);

        // Get temporary directory to save PDF
        final Directory tempDir = await getTemporaryDirectory();

        // Create meaningful filename
        final String fileName = 'receipt_${billData.companyName.replaceAll(' ', '_')}_${DateFormat('yyyyMMdd_HHmmss').format(billData.paidAt ?? billData.createdAt)}.pdf';

        // Create file path
        final String filePath = '${tempDir.path}/$fileName';

        // Write PDF data to file
        final File file = File(filePath);
        await file.writeAsBytes(pdfData);

        print('PDF created for sharing at: $filePath');

        // Share the PDF file with share text
        await Share.shareXFiles(
          <XFile>[XFile(filePath, mimeType: 'application/pdf')],
          text: 'Payment Receipt for ${billData.companyName}\nAmount: ${billData.amount}\nDate: ${DateFormat('dd MMM yyyy, hh:mm a').format(billData.paidAt ?? billData.createdAt)}',
          subject: 'Payment Receipt - ${billData.companyName}',
        );

      } else {
        // Fallback: Use dummy data if no bill data available
        final PaymentReceiptData data = PaymentReceiptData.dummy();
        final Uint8List pdfData = await PdfServices().generateReceipt(data: data);

        final Directory tempDir = await getTemporaryDirectory();
        final String fileName = 'payment_receipt_demo_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf';
        final String filePath = '${tempDir.path}/$fileName';

        final File file = File(filePath);
        await file.writeAsBytes(pdfData);

        await Share.shareXFiles(
          <XFile>[XFile(filePath, mimeType: 'application/pdf')],
          text: 'Payment Receipt Demo',
          subject: 'Payment Receipt',
        );
      }

    } catch (e) {
      print('Error sharing receipt: $e');

      // Show error message to user
      // You can use your preferred method to show error (SnackBar, Toast, Dialog)
      // Example with SnackBar:
      /*
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Failed to share receipt. Please try again.'),
        backgroundColor: Colors.red,
      ),
    );
    */
    }
  }


  /// Helper method to generate and open PDF
  Future<void> _generateAndOpenPDF(PayBillModel? billData) async {
    try {
      if (billData != null) {
        // Create payment receipt data from actual bill data
        final PaymentReceiptData receiptData = PaymentReceiptData.fromBillData(billData);

        // Generate PDF
        final Uint8List pdfData = await PdfServices().generateReceipt(data: receiptData);

        // Save PDF with meaningful filename
        final String fileName = 'receipt_${billData.companyName.replaceAll(' ', '_')}_${DateFormat('yyyyMMdd_HHmmss').format(billData.paidAt ?? billData.createdAt)}';
        final String filePath = await PdfServices().savePdfFile(fileName, pdfData);

        print('PDF saved to: $filePath');

        // Open the saved PDF
        OpenFile.open(filePath);
      } else {
        // Use dummy data if no bill data (fallback)
        final PaymentReceiptData data = PaymentReceiptData.dummy();
        final Uint8List pdfData = await PdfServices().generateReceipt(data: data);
        final String filePath = await PdfServices().savePdfFile('payment_receipt_demo', pdfData);
        print('Demo PDF saved to: $filePath');
        OpenFile.open(filePath);
      }
    } catch (e) {
      print('Error generating PDF: $e');
      // TODO: Show error message to user
    }
  }

  String _formatPaymentMethod(String method) {
    switch (method.toLowerCase()) {
      case 'fingerprint':
        return 'Fingerprint Authentication';
      case 'pin':
        return 'PIN Authentication';
      case 'card':
        return 'Card Payment';
      case 'bank_transfer':
        return 'Bank Transfer';
      default:
        return method.toUpperCase();
    }
  }

  String _getServiceType(PayBillModel billData) {
    // Check if it's a ticket booking based on company name or bill type
    final String companyName = billData.companyName.toLowerCase();

    if (companyName.contains('cinema') || companyName.contains('movie')) {
      return 'Movie Ticket';
    } else if (companyName.contains('railway') || companyName.contains('train')) {
      return 'Train Ticket';
    } else if (companyName.contains('express') || companyName.contains('bus')) {
      return 'Bus Ticket';
    } else if (companyName.contains('airline') || companyName.contains('flight') || companyName.contains('pia')) {
      return 'Flight Ticket';
    } else if (companyName.contains('car') || companyName.contains('rental')) {
      return 'Car Rental';
    } else if (companyName.contains('electric') || companyName.contains('k-electric')) {
      return 'Electricity Bill';
    } else if (companyName.contains('gas') || companyName.contains('sui')) {
      return 'Gas Bill';
    } else if (companyName.contains('mobilink') || companyName.contains('telenor') || companyName.contains('jazz')) {
      return 'Mobile Recharge';
    } else if (companyName.contains('ptcl') || companyName.contains('internet')) {
      return 'Internet Bill';
    } else {
      return 'Bill Payment';
    }
  }
}

Widget _buildRow(String label, String value, bool isDark, {Color? statusColor}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: <Widget>[
      Text(
        label,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.white70 : Colors.black54,
        ),
      ),
      Flexible(
        child: Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: statusColor ?? (isDark ? Colors.white70 : Colors.black54),
          ),
          textAlign: TextAlign.end,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
  );
}