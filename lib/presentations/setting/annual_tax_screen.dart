import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:payfussion/core/constants/fonts.dart';
import 'package:payfussion/core/theme/theme.dart';

class AnnualTaxReportScreen extends StatefulWidget {
  const AnnualTaxReportScreen({super.key});

  @override
  State<AnnualTaxReportScreen> createState() => _AnnualTaxReportScreenState();
}

class _AnnualTaxReportScreenState extends State<AnnualTaxReportScreen> {
  int selectedYear = DateTime.now().year;
  bool isLoading = false;

  // Transaction data
  List<Map<String, dynamic>> transactions = [];
  List<Map<String, dynamic>> payBills = [];
  List<Map<String, dynamic>> insurance = [];
  List<Map<String, dynamic>> tickets = [];

  // Summary data
  double totalTransactions = 0;
  double totalPayBills = 0;
  double totalInsurance = 0;
  double totalTickets = 0;
  double grandTotal = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Annual Tax Report'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Year selector
          Container(
            margin: EdgeInsets.all(16.w),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).brightness == Brightness.light
                      ? Colors.grey.withOpacity(0.3)
                      : Colors.black.withOpacity(0.3),
                  blurRadius: 5,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Select Year',
                  style: Font.montserratFont(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, size: 20),
                      onPressed: () {
                        setState(() {
                          selectedYear--;
                        });
                      },
                    ),
                    Text(
                      selectedYear.toString(),
                      style: Font.montserratFont(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: MyTheme.primaryColor,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward_ios, size: 20),
                      onPressed: selectedYear < DateTime.now().year
                          ? () {
                        setState(() {
                          selectedYear++;
                        });
                      }
                          : null,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Generate Report Button
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : _generateReport,
                style: ElevatedButton.styleFrom(
                  backgroundColor: MyTheme.primaryColor,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                icon: isLoading
                    ? SizedBox(
                  width: 20.w,
                  height: 20.h,
                  child: const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : const Icon(Icons.file_download, color: Colors.white),
                label: Text(
                  isLoading ? 'Generating Report...' : 'Generate & Download PDF',
                  style: Font.montserratFont(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Summary cards
          if (grandTotal > 0) ...[
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Summary for $selectedYear',
                      style: Font.montserratFont(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    _buildSummaryCard(
                      'Transactions',
                      transactions.length,
                      totalTransactions,
                      Icons.swap_horiz,
                    ),
                    SizedBox(height: 12.h),
                    _buildSummaryCard(
                      'Bill Payments',
                      payBills.length,
                      totalPayBills,
                      Icons.receipt,
                    ),
                    SizedBox(height: 12.h),
                    _buildSummaryCard(
                      'Insurance',
                      insurance.length,
                      totalInsurance,
                      Icons.shield,
                    ),
                    SizedBox(height: 12.h),
                    _buildSummaryCard(
                      'Movie Tickets',
                      tickets.length,
                      totalTickets,
                      Icons.movie,
                    ),
                    SizedBox(height: 16.h),
                    Container(
                      padding: EdgeInsets.all(16.r),
                      decoration: BoxDecoration(
                        color: MyTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: MyTheme.primaryColor,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Grand Total',
                            style: Font.montserratFont(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: MyTheme.primaryColor,
                            ),
                          ),
                          Text(
                            'PKR ${grandTotal.toStringAsFixed(2)}',
                            style: Font.montserratFont(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                              color: MyTheme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),
          ] else
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.description_outlined,
                      size: 100.sp,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'No data available',
                      style: Font.montserratFont(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Generate report to view summary',
                      style: Font.montserratFont(
                        fontSize: 14.sp,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, int count, double amount, IconData icon) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.light
                ? Colors.grey.withOpacity(0.3)
                : Colors.black.withOpacity(0.3),
            blurRadius: 5,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: MyTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              icon,
              color: MyTheme.primaryColor,
              size: 24.sp,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Font.montserratFont(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '$count transactions',
                  style: Font.montserratFont(
                    fontSize: 12.sp,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Text(
            'PKR ${amount.toStringAsFixed(2)}',
            style: Font.montserratFont(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: MyTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _generateReport() async {
    setState(() {
      isLoading = true;
      // Reset data
      transactions = [];
      payBills = [];
      insurance = [];
      tickets = [];
      totalTransactions = 0;
      totalPayBills = 0;
      totalInsurance = 0;
      totalTickets = 0;
      grandTotal = 0;
    });

    try {
      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        _showError('Please login to generate report');
        return;
      }

      // Fetch data from all collections
      await Future.wait([
        _fetchTransactions(currentUser.uid),
        _fetchPayBills(currentUser.uid),
        _fetchInsurance(currentUser.uid),
        _fetchTickets(currentUser.uid),
      ]);

      // Calculate totals
      _calculateTotals();

      setState(() {
        isLoading = false;
      });

      if (grandTotal == 0) {
        _showError('No transactions found for $selectedYear');
        return;
      }

      // Generate and show PDF
      await _generatePDF();
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showError('Error generating report: $e');
    }
  }

  Future<void> _fetchTransactions(String uid) async {
    final DateTime startDate = DateTime(selectedYear, 1, 1);
    final DateTime endDate = DateTime(selectedYear, 12, 31, 23, 59, 59);

    final QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('transactions')
        .where('created_at', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('created_at', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .get();

    transactions = snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'title': data['recipient_name'] ?? data['title'] ?? 'Payment',
        'amount': (data['amount'] ?? 0).toDouble(),
        'date': (data['created_at'] as Timestamp).toDate(),
        'status': data['status'] ?? 'completed',
      };
    }).toList();
  }

  Future<void> _fetchPayBills(String uid) async {
    final DateTime startDate = DateTime(selectedYear, 1, 1);
    final DateTime endDate = DateTime(selectedYear, 12, 31, 23, 59, 59);

    final QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('payBills')
        .get();

    payBills = snapshot.docs.where((doc) {
      final data = doc.data();
      final dateStr = data['createdAt'];
      DateTime date;
      if (dateStr is String) {
        date = DateTime.tryParse(dateStr) ?? DateTime.now();
      } else if (dateStr is Timestamp) {
        date = dateStr.toDate();
      } else {
        return false;
      }
      return date.isAfter(startDate) && date.isBefore(endDate);
    }).map((doc) {
      final data = doc.data();
      final dateStr = data['createdAt'];
      DateTime date;
      if (dateStr is String) {
        date = DateTime.tryParse(dateStr) ?? DateTime.now();
      } else {
        date = (dateStr as Timestamp).toDate();
      }

      return {
        'title': '${data['companyName'] ?? 'Bill'} - ${data['billType'] ?? ''}',
        'amount': (data['amount'] ?? 0).toDouble(),
        'date': date,
        'status': data['status'] ?? 'completed',
      };
    }).toList();
  }

  Future<void> _fetchInsurance(String uid) async {
    final DateTime startDate = DateTime(selectedYear, 1, 1);
    final DateTime endDate = DateTime(selectedYear, 12, 31, 23, 59, 59);

    final QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('insurance')
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .get();

    insurance = snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'title': '${data['companyName'] ?? 'Insurance'} - ${data['insuranceType'] ?? ''}',
        'amount': (data['premiumAmount'] ?? 0).toDouble(),
        'date': (data['createdAt'] as Timestamp).toDate(),
        'status': data['status'] ?? 'completed',
      };
    }).toList();
  }

  Future<void> _fetchTickets(String uid) async {
    final DateTime startDate = DateTime(selectedYear, 1, 1);
    final DateTime endDate = DateTime(selectedYear, 12, 31, 23, 59, 59);

    final QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('movie_bookings')
        .where('bookingDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('bookingDate', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .get();

    tickets = snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'title': '${data['movieTitle'] ?? 'Movie'} (${data['numberOfTickets'] ?? 1} tickets)',
        'amount': (data['totalAmount'] ?? 0).toDouble(),
        'date': (data['bookingDate'] as Timestamp).toDate(),
        'status': data['paymentStatus'] ?? 'completed',
      };
    }).toList();
  }

  void _calculateTotals() {
    totalTransactions = transactions.fold(0, (sum, item) => sum + item['amount']);
    totalPayBills = payBills.fold(0, (sum, item) => sum + item['amount']);
    totalInsurance = insurance.fold(0, (sum, item) => sum + item['amount']);
    totalTickets = tickets.fold(0, (sum, item) => sum + item['amount']);
    grandTotal = totalTransactions + totalPayBills + totalInsurance + totalTickets;
  }

  Future<void> _generatePDF() async {
    final pdf = pw.Document();

    // Load logo image
    final logoImage = await imageFromAssetBundle('assets/images/logo.png');

    // Add pages
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          // Header
          pw.Header(
            level: 0,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Row(
                      children: [
                        pw.Image(logoImage, width: 60, height: 60),
                        pw.SizedBox(width: 16),
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              'Annual Tax Report',
                              style: pw.TextStyle(
                                fontSize: 28,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            pw.SizedBox(height: 4),
                            pw.Text(
                              'PayFusion',
                              style: pw.TextStyle(
                                fontSize: 16,
                                color: PdfColors.grey700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          'Year: $selectedYear',
                          style: pw.TextStyle(
                            fontSize: 18,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'Generated: ${DateFormat('MMM dd, yyyy').format(DateTime.now())}',
                          style: pw.TextStyle(
                            fontSize: 12,
                            color: PdfColors.grey700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 8),
                pw.Divider(thickness: 2),
              ],
            ),
          ),

          pw.SizedBox(height: 20),

          // Summary section
          pw.Text(
            'Summary',
            style: pw.TextStyle(
              fontSize: 20,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 10),
          _buildPDFSummaryTable(),

          pw.SizedBox(height: 30),

          // Transactions
          if (transactions.isNotEmpty) ...[
            pw.Text(
              'Transactions (${transactions.length})',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 10),
            _buildPDFTransactionTable(transactions),
            pw.SizedBox(height: 20),
          ],

          // Pay Bills
          if (payBills.isNotEmpty) ...[
            pw.Text(
              'Bill Payments (${payBills.length})',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 10),
            _buildPDFTransactionTable(payBills),
            pw.SizedBox(height: 20),
          ],

          // Insurance
          if (insurance.isNotEmpty) ...[
            pw.Text(
              'Insurance (${insurance.length})',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 10),
            _buildPDFTransactionTable(insurance),
            pw.SizedBox(height: 20),
          ],

          // Tickets
          if (tickets.isNotEmpty) ...[
            pw.Text(
              'Movie Tickets (${tickets.length})',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 10),
            _buildPDFTransactionTable(tickets),
          ],
        ],
      ),
    );

    // Show PDF preview with save/share options
    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: 'Tax_Report_$selectedYear.pdf',
    );
  }

  pw.Widget _buildPDFSummaryTable() {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400),
      children: [
        // Header
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey300),
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                'Category',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                'Count',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                textAlign: pw.TextAlign.center,
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                'Total Amount (PKR)',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                textAlign: pw.TextAlign.right,
              ),
            ),
          ],
        ),
        // Transactions
        _buildPDFSummaryRow('Transactions', transactions.length, totalTransactions),
        _buildPDFSummaryRow('Bill Payments', payBills.length, totalPayBills),
        _buildPDFSummaryRow('Insurance', insurance.length, totalInsurance),
        _buildPDFSummaryRow('Movie Tickets', tickets.length, totalTickets),
        // Grand Total
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                'Grand Total',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                '${transactions.length + payBills.length + insurance.length + tickets.length}',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                textAlign: pw.TextAlign.center,
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                grandTotal.toStringAsFixed(2),
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                textAlign: pw.TextAlign.right,
              ),
            ),
          ],
        ),
      ],
    );
  }

  pw.TableRow _buildPDFSummaryRow(String category, int count, double amount) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(category),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(
            count.toString(),
            textAlign: pw.TextAlign.center,
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(
            amount.toStringAsFixed(2),
            textAlign: pw.TextAlign.right,
          ),
        ),
      ],
    );
  }

  pw.Widget _buildPDFTransactionTable(List<Map<String, dynamic>> items) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400),
      columnWidths: {
        0: const pw.FlexColumnWidth(2),
        1: const pw.FlexColumnWidth(1.5),
        2: const pw.FlexColumnWidth(1.5),
        3: const pw.FlexColumnWidth(1),
      },
      children: [
        // Header
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey300),
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                'Description',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                'Date',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                'Amount (PKR)',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                textAlign: pw.TextAlign.right,
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                'Status',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                textAlign: pw.TextAlign.center,
              ),
            ),
          ],
        ),
        // Data rows
        ...items.map((item) => pw.TableRow(
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(item['title']),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                DateFormat('MMM dd, yyyy').format(item['date']),
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                item['amount'].toStringAsFixed(2),
                textAlign: pw.TextAlign.right,
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                item['status'].toString().toUpperCase(),
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(fontSize: 10),
              ),
            ),
          ],
        )),
      ],
    );
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}