import 'dart:io';

import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:payfussion/core/constants/image_url.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';

// Import your PayBillModel
import '../data/models/pay_bills/bill_item.dart';

class PaymentReceiptData {
  final String paymentAmount; // e.g., USD 1000.00
  final String refNumber; // e.g., 000085752257
  final String paymentTime; // e.g., 25-02-2023, 13:22:16
  final String paymentMethod; // e.g., Bank Transfer
  final String senderName; // e.g., Marlon Malcolm
  final String originalAmount; // e.g., IDR 1,000,000
  final String adminFee; // e.g., IDR 193.00

  PaymentReceiptData({
    required this.paymentAmount,
    required this.refNumber,
    required this.paymentTime,
    required this.paymentMethod,
    required this.senderName,
    required this.originalAmount,
    required this.adminFee,
  });

  // Static method to create an instance with dummy data
  static PaymentReceiptData dummy() {
    return PaymentReceiptData(
      paymentAmount: 'USD 1000.00',
      refNumber: '000085752257',
      paymentTime: '25-02-2023, 13:22:16',
      paymentMethod: 'Bank Transfer',
      senderName: 'Marlon Malcolm',
      originalAmount: 'IDR 1,000,000',
      adminFee: 'IDR 193.00',
    );
  }

  // NEW: Custom method to create PaymentReceiptData from PayBillModel
  static PaymentReceiptData fromBillData(PayBillModel billData) {
    // Format payment method
    String formatPaymentMethod(String method) {
      switch (method.toLowerCase()) {
        case 'fingerprint':
          return 'Fingerprint Authentication';
        case 'pin':
          return 'PIN Authentication';
        case 'card':
          return 'Card Payment';
        default:
          return method.toUpperCase();
      }
    }

    return PaymentReceiptData(
      paymentAmount: '\$ ${billData.amount.toStringAsFixed(2)}',
      refNumber: billData.id.substring(0, 12).toUpperCase(),
      paymentTime: DateFormat('dd-MM-yyyy, HH:mm:ss').format(
          billData.paidAt ?? billData.createdAt
      ),
      paymentMethod: formatPaymentMethod(billData.paymentMethod),
      senderName: 'You', // You can customize this or get from user profile
      originalAmount: '\$ ${billData.amount.toStringAsFixed(2)}',
      adminFee: billData.hasFee
          ? '\$ ${billData.feeAmount.toStringAsFixed(2)}'
          : '\$ 0.00',
    );
  }
}

class PdfServices {
  Future<Uint8List> _loadImageFromAssets(String assetPath) async {
    final ByteData data = await rootBundle.load(
      assetPath,
    ); // Load asset from assets directory
    return data.buffer.asUint8List();
  }

  // Generate a payment receipt PDF with the given data
  Future<Uint8List> generateReceipt({required PaymentReceiptData data}) async {
    final pdf = pw.Document();
    final logoBytes = await _loadImageFromAssets(
      TImageUrl.iconLogo,
    ); // Load the local PNG image

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 80),
        build: (context) => <pw.Widget>[
          _buildReceiptHeader(
            data.paymentAmount,
            logoBytes,
          ), // Pass logo to header
          pw.SizedBox(height: 20),
          _buildReceiptDetails(data),
          pw.SizedBox(height: 10),
          _buildDashedLine(),
          pw.SizedBox(height: 10),
          _buildReceiptSummary(data.originalAmount, data.adminFee),
        ],
      ),
    );

    // Save the PDF and return the bytes
    return pdf.save();
  }

  // Builds the header with the logo, success message, and main amount
  pw.Widget _buildReceiptHeader(String paymentAmount, Uint8List logoBytes) {
    return pw.Column(
      children: <pw.Widget>[
        pw.Image(pw.MemoryImage(logoBytes), width: 120, height: 120),

        pw.SizedBox(height: 10),
        pw.Text(
          'Payment Success!',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16),
        ),
        pw.SizedBox(height: 5),
        pw.Text(
          paymentAmount,
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 24),
        ),
        pw.SizedBox(height: 20),
        pw.Divider(thickness: 1, color: PdfColors.grey),
      ],
    );
  }

  // Builds payment details section (Ref Number, Time, Method, Sender)
  pw.Widget _buildReceiptDetails(PaymentReceiptData data) {
    return pw.Column(
      children: <pw.Widget>[
        _buildKeyValueRow('Ref Number', data.refNumber),
        _buildKeyValueRow('Payment Time', data.paymentTime),
        _buildKeyValueRow('Payment Method', data.paymentMethod),
        _buildKeyValueRow('Sender Name', data.senderName),
      ],
    );
  }

  // Builds a key-value row for PDF
  pw.Widget _buildKeyValueRow(String key, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 5),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: <pw.Widget>[
          pw.Text(key, style: const pw.TextStyle(color: PdfColors.grey700)),
          pw.Text(value, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }

  // Builds a dashed line for PDF
  pw.Widget _buildDashedLine() {
    return pw.Row(
      children: List<pw.Widget>.generate(
        60, // Number of dashes, adjust as needed for page width
            (index) => pw.Expanded(
          child: pw.Padding(
            padding: const pw.EdgeInsets.symmetric(horizontal: 1.0),
            child: pw.Container(height: 1, color: PdfColors.grey500),
          ),
        ),
      ),
    );
  }

  // Builds the total summary section (Amount, Admin Fee)
  pw.Widget _buildReceiptSummary(String originalAmount, String adminFee) {
    return pw.Column(
      children: <pw.Widget>[
        _buildKeyValueRow('Amount', originalAmount),
        _buildKeyValueRow('Admin Fee', adminFee),
      ],
    );
  }

  // Request storage permissions (for Android)
  Future<void> requestPermissions() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        print('Permission denied for storage.');
      }
    }
    // iOS typically does not require explicit storage permission for app-specific directories.
  }

  // Save the generated PDF to the device storage
  Future<String> savePdfFile(String fileName, Uint8List byteList) async {
    await requestPermissions();

    Directory? output;
    if (Platform.isAndroid) {
      output = await getExternalStorageDirectory();
    } else if (Platform.isIOS) {
      output = await getApplicationDocumentsDirectory();
    } else {
      output =
      await getApplicationDocumentsDirectory(); // For desktop/other platforms
    }

    if (output == null) {
      return 'Error: Could not get a valid directory to save the file.';
    }

    final filePath = "${output.path}/$fileName.pdf";
    final file = File(filePath);
    await file.writeAsBytes(byteList);
    print('PDF saved to: $filePath');
    return filePath;
  }
}