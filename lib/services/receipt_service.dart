import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

class ReceiptService {
  // Generate PDF receipt
  static Future<File> generateReceipt({
    required String transactionId,
    required String title,
    required double amount,
    required String status,
    required DateTime dateTime,
    required String category,
    Map<String, dynamic>? additionalData,
  }) async {
    final pdf = pw.Document();

    // Add page to PDF
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Container(
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue,
                  borderRadius: pw.BorderRadius.circular(10),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'PayFussion',
                      style: pw.TextStyle(
                        fontSize: 28,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                      ),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text(
                      'Transaction Receipt',
                      style: pw.TextStyle(
                        fontSize: 16,
                        color: PdfColors.white,
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 30),

              // Status Badge
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                decoration: pw.BoxDecoration(
                  color: _getStatusColor(status),
                  borderRadius: pw.BorderRadius.circular(20),
                ),
                child: pw.Text(
                  status.toUpperCase(),
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                  ),
                ),
              ),

              pw.SizedBox(height: 30),

              // Transaction Details
              _buildPdfDetailRow('Transaction ID', transactionId),
              pw.Divider(),
              _buildPdfDetailRow('Category', category),
              pw.Divider(),
              _buildPdfDetailRow('Title', title),
              pw.Divider(),
              _buildPdfDetailRow(
                'Amount',
                'PKR ${amount.toStringAsFixed(2)}',
                isHighlighted: true,
              ),
              pw.Divider(),
              _buildPdfDetailRow(
                'Date',
                DateFormat('MMMM dd, yyyy').format(dateTime),
              ),
              pw.Divider(),
              _buildPdfDetailRow(
                'Time',
                DateFormat('hh:mm a').format(dateTime),
              ),
              pw.Divider(),

              // Additional Data
              if (additionalData != null) ...[
                pw.SizedBox(height: 20),
                pw.Text(
                  'Additional Information',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),
                ...additionalData.entries
                    .where((entry) => entry.value != null)
                    .map((entry) {
                  return pw.Column(
                    children: [
                      _buildPdfDetailRow(
                        _formatFieldName(entry.key),
                        entry.value.toString(),
                      ),
                      pw.Divider(),
                    ],
                  );
                }).toList(),
              ],

              pw.Spacer(),

              // Footer
              pw.Container(
                padding: const pw.EdgeInsets.all(15),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: pw.BorderRadius.circular(10),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Thank you for using PayFussion!',
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text(
                      'Generated on: ${DateFormat('MMMM dd, yyyy hh:mm a').format(DateTime.now())}',
                      style: const pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    // Save PDF to file
    final output = await _getOutputFile(transactionId);
    final file = File(output.path);
    await file.writeAsBytes(await pdf.save());

    return file;
  }

  // Build PDF detail row
  static pw.Widget _buildPdfDetailRow(
      String label,
      String value, {
        bool isHighlighted = false,
      }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 8),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 12,
              color: PdfColors.grey700,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: isHighlighted ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: isHighlighted ? PdfColors.blue : PdfColors.black,
            ),
          ),
        ],
      ),
    );
  }

  // Get status color for PDF
  static PdfColor _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return PdfColors.green;
      case 'pending':
        return PdfColors.orange;
      case 'failed':
        return PdfColors.red;
      default:
        return PdfColors.grey;
    }
  }

  // Format field name
  static String _formatFieldName(String fieldName) {
    return fieldName
        .replaceAllMapped(
      RegExp(r'([A-Z])'),
          (match) => ' ${match.group(0)}',
    )
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ')
        .trim();
  }

  // Get output file path
  static Future<File> _getOutputFile(String transactionId) async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = 'receipt_${transactionId}_${DateTime.now().millisecondsSinceEpoch}.pdf';
    return File('${directory.path}/$fileName');
  }

  // Download receipt
  static Future<void> downloadReceipt({
    required BuildContext context,
    required String transactionId,
    required String title,
    required double amount,
    required String status,
    required DateTime dateTime,
    required String category,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      // Show loading
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Generating receipt...'),
          duration: Duration(seconds: 2),
        ),
      );

      // Request storage permission
      if (Platform.isAndroid) {
        final permission = await Permission.storage.request();
        if (!permission.isGranted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Storage permission denied'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }

      // Generate PDF
      final file = await generateReceipt(
        transactionId: transactionId,
        title: title,
        amount: amount,
        status: status,
        dateTime: dateTime,
        category: category,
        additionalData: additionalData,
      );

      // Save to Downloads folder (Android)
      if (Platform.isAndroid) {
        final downloadsDir = Directory('/storage/emulated/0/Download');
        if (await downloadsDir.exists()) {
          final fileName = 'receipt_${transactionId}_${DateTime.now().millisecondsSinceEpoch}.pdf';
          final newFile = File('${downloadsDir.path}/$fileName');
          await file.copy(newFile.path);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Receipt saved to Downloads/$fileName'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Receipt saved to ${file.path}'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Receipt saved to ${file.path}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error downloading receipt: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Share receipt
  static Future<void> shareReceipt({
    required BuildContext context,
    required String transactionId,
    required String title,
    required double amount,
    required String status,
    required DateTime dateTime,
    required String category,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      // Show loading
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preparing receipt...'),
          duration: Duration(seconds: 2),
        ),
      );

      // Generate PDF
      final file = await generateReceipt(
        transactionId: transactionId,
        title: title,
        amount: amount,
        status: status,
        dateTime: dateTime,
        category: category,
        additionalData: additionalData,
      );

      // Share the file
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Transaction Receipt - $transactionId',
        text: 'Receipt for transaction: $title\nAmount: PKR ${amount.toStringAsFixed(2)}\nDate: ${DateFormat('MMMM dd, yyyy').format(dateTime)}',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sharing receipt: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}