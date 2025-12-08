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

class ReceiptsScreen extends StatefulWidget {
  const ReceiptsScreen({super.key});

  @override
  State<ReceiptsScreen> createState() => _ReceiptsScreenState();
}

class _ReceiptsScreenState extends State<ReceiptsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Receipts & Invoices'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: MyTheme.primaryColor,
          labelColor: MyTheme.primaryColor,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'Transactions'),
            Tab(text: 'Bill Payments'),
            Tab(text: 'Insurance'),
            Tab(text: 'Tickets'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: EdgeInsets.all(16.w),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search receipts...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
            ),
          ),

          // Tab views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildReceiptsList('transactions'),
                _buildReceiptsList('payBills'),
                _buildReceiptsList('insurance'),
                _buildReceiptsList('movie_bookings'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptsList(String collection) {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Center(
        child: Text('Please login to view receipts'),
      );
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .collection(collection)
          .orderBy(_getOrderByField(collection), descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  size: 100.sp,
                  color: Colors.grey,
                ),
                SizedBox(height: 16.h),
                Text(
                  'No receipts found',
                  style: Font.montserratFont(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        final docs = snapshot.data!.docs;

        // Filter based on search query
        final filteredDocs = docs.where((doc) {
          if (searchQuery.isEmpty) return true;

          final data = doc.data();
          final title = _getTitle(collection, data).toLowerCase();
          final id = doc.id.toLowerCase();

          return title.contains(searchQuery) || id.contains(searchQuery);
        }).toList();

        if (filteredDocs.isEmpty) {
          return Center(
            child: Text(
              'No matching receipts found',
              style: Font.montserratFont(
                fontSize: 16.sp,
                color: Colors.grey,
              ),
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          itemCount: filteredDocs.length,
          itemBuilder: (context, index) {
            final doc = filteredDocs[index];
            final data = doc.data();

            return _buildReceiptCard(
              context: context,
              collection: collection,
              docId: doc.id,
              data: data,
            );
          },
        );
      },
    );
  }

  Widget _buildReceiptCard({
    required BuildContext context,
    required String collection,
    required String docId,
    required Map<String, dynamic> data,
  }) {
    final title = _getTitle(collection, data);
    final amount = _getAmount(collection, data);
    final date = _getDate(collection, data);
    final status = _getStatus(collection, data);

    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: InkWell(
        onTap: () => _generateReceipt(
          collection: collection,
          docId: docId,
          data: data,
        ),
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: Row(
            children: [
              // Icon
              Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: MyTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.receipt,
                  color: MyTheme.primaryColor,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 16.w),

              // Details
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
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'PKR ${amount.toStringAsFixed(2)}',
                      style: Font.montserratFont(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: MyTheme.primaryColor,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 12.sp, color: Colors.grey),
                        SizedBox(width: 4.w),
                        Text(
                          DateFormat('MMM dd, yyyy').format(date),
                          style: Font.montserratFont(
                            fontSize: 12.sp,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: _getStatusColor(status).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            status,
                            style: Font.montserratFont(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                              color: _getStatusColor(status),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Download icon
              Icon(
                Icons.file_download,
                color: MyTheme.primaryColor,
                size: 24.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getOrderByField(String collection) {
    switch (collection) {
      case 'transactions':
        return 'created_at';
      case 'payBills':
        return 'createdAt';
      case 'insurance':
        return 'createdAt';
      case 'movie_bookings':
        return 'bookingDate';
      default:
        return 'created_at';
    }
  }

  String _getTitle(String collection, Map<String, dynamic> data) {
    switch (collection) {
      case 'transactions':
        return data['recipient_name'] ?? data['title'] ?? 'Payment';
      case 'payBills':
        final company = data['companyName'] ?? 'Bill Payment';
        final type = data['billType'] ?? '';
        return type.isNotEmpty ? '$company - $type' : company;
      case 'insurance':
        final company = data['companyName'] ?? 'Insurance';
        final type = data['insuranceType'] ?? '';
        return '$company - $type';
      case 'movie_bookings':
        return data['movieTitle'] ?? 'Movie Ticket';
      default:
        return 'Receipt';
    }
  }

  double _getAmount(String collection, Map<String, dynamic> data) {
    switch (collection) {
      case 'transactions':
        return (data['amount'] ?? 0).toDouble();
      case 'payBills':
        return (data['amount'] ?? 0).toDouble();
      case 'insurance':
        return (data['premiumAmount'] ?? 0).toDouble();
      case 'movie_bookings':
        return (data['totalAmount'] ?? 0).toDouble();
      default:
        return 0.0;
    }
  }

  DateTime _getDate(String collection, Map<String, dynamic> data) {
    dynamic dateField;

    switch (collection) {
      case 'transactions':
        dateField = data['created_at'];
        break;
      case 'payBills':
        dateField = data['createdAt'];
        break;
      case 'insurance':
        dateField = data['createdAt'];
        break;
      case 'movie_bookings':
        dateField = data['bookingDate'];
        break;
      default:
        return DateTime.now();
    }

    if (dateField is Timestamp) {
      return dateField.toDate();
    } else if (dateField is String) {
      return DateTime.tryParse(dateField) ?? DateTime.now();
    }
    return DateTime.now();
  }

  String _getStatus(String collection, Map<String, dynamic> data) {
    String rawStatus;

    switch (collection) {
      case 'transactions':
        rawStatus = (data['status'] ?? 'completed').toString().toLowerCase();
        break;
      case 'payBills':
        rawStatus = (data['status'] ?? 'completed').toString().toLowerCase();
        break;
      case 'insurance':
        rawStatus = (data['status'] ?? 'completed').toString().toLowerCase();
        break;
      case 'movie_bookings':
        rawStatus = (data['paymentStatus'] ?? 'completed').toString().toLowerCase();
        break;
      default:
        rawStatus = 'completed';
    }

    switch (rawStatus) {
      case 'success':
      case 'completed':
        return 'Completed';
      case 'pending':
        return 'Pending';
      case 'failed':
      case 'failure':
        return 'Failed';
      default:
        return 'Completed';
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      default:
        return Colors.green;
    }
  }

  Future<void> _generateReceipt({
    required String collection,
    required String docId,
    required Map<String, dynamic> data,
  }) async {
    try {
      final pdf = pw.Document();

      // Get current user info
      final User? currentUser = FirebaseAuth.instance.currentUser;
      final String userEmail = currentUser?.email ?? 'N/A';
      final String userId = currentUser?.uid ?? 'N/A';

      // Get receipt details
      final title = _getTitle(collection, data);
      final amount = _getAmount(collection, data);
      final date = _getDate(collection, data);
      final status = _getStatus(collection, data);

      // Load logo image
      final logoImage = await imageFromAssetBundle('assets/images/logo.png');

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Container(
                  padding: const pw.EdgeInsets.all(20),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.blue50,
                    borderRadius: pw.BorderRadius.circular(10),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Row(
                        children: [
                          // Logo
                          pw.Image(logoImage, width: 50, height: 50),
                          pw.SizedBox(width: 12),
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                'PayFusion',
                                style: pw.TextStyle(
                                  fontSize: 28,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.blue900,
                                ),
                              ),
                              pw.SizedBox(height: 4),
                              pw.Text(
                                'Payment Receipt',
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
                            'Receipt #${docId.substring(0, 8).toUpperCase()}',
                            style: pw.TextStyle(
                              fontSize: 12,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            'Date: ${DateFormat('MMM dd, yyyy').format(date)}',
                            style: const pw.TextStyle(
                              fontSize: 12,
                              color: PdfColors.grey700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                pw.SizedBox(height: 30),

                // Customer Information
                pw.Text(
                  'Customer Information',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Container(
                  padding: const pw.EdgeInsets.all(15),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      _buildPDFRow('Email:', userEmail),
                      pw.SizedBox(height: 8),
                      _buildPDFRow('Customer ID:', userId.substring(0, 12)),
                    ],
                  ),
                ),

                pw.SizedBox(height: 30),

                // Transaction Details
                pw.Text(
                  'Transaction Details',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey300),
                  children: [
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(10),
                          child: pw.Text(
                            'Description',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(10),
                          child: pw.Text(
                            'Amount',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                            textAlign: pw.TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(10),
                          child: pw.Text(title),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(10),
                          child: pw.Text(
                            'PKR ${amount.toStringAsFixed(2)}',
                            textAlign: pw.TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                pw.SizedBox(height: 20),

                // Payment Status & Details
                _buildDetailSection(collection, data, amount, status, date),

                pw.Spacer(),

                // Footer
                pw.Divider(thickness: 2),
                pw.SizedBox(height: 10),
                pw.Center(
                  child: pw.Column(
                    children: [
                      pw.Text(
                        'Thank you for using PayFusion!',
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'For support, contact: support@payfusion.com',
                        style: const pw.TextStyle(
                          fontSize: 10,
                          color: PdfColors.grey700,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Generated on: ${DateFormat('MMM dd, yyyy hh:mm a').format(DateTime.now())}',
                        style: const pw.TextStyle(
                          fontSize: 8,
                          color: PdfColors.grey600,
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

      // Show PDF preview
      await Printing.layoutPdf(
        onLayout: (format) async => pdf.save(),
        name: 'Receipt_${docId.substring(0, 8)}.pdf',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating receipt: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  pw.Widget _buildPDFRow(String label, String value) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: 100,
          child: pw.Text(
            label,
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey700,
            ),
          ),
        ),
        pw.Expanded(
          child: pw.Text(value),
        ),
      ],
    );
  }

  pw.Widget _buildDetailSection(
      String collection,
      Map<String, dynamic> data,
      double amount,
      String status,
      DateTime date,
      ) {
    final List<pw.Widget> details = [
      pw.Container(
        padding: const pw.EdgeInsets.all(15),
        decoration: pw.BoxDecoration(
          color: status == 'Completed' ? PdfColors.green50 : PdfColors.orange50,
          borderRadius: pw.BorderRadius.circular(8),
        ),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Payment Status:',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(
              status.toUpperCase(),
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: status == 'Completed' ? PdfColors.green900 : PdfColors.orange900,
              ),
            ),
          ],
        ),
      ),
      pw.SizedBox(height: 15),
    ];

    // Add specific details based on collection type
    switch (collection) {
      case 'payBills':
        details.add(_buildInfoBox([
          _buildPDFRow('Bill Number:', data['billNumber'] ?? 'N/A'),
          pw.SizedBox(height: 8),
          _buildPDFRow('Company:', data['companyName'] ?? 'N/A'),
          pw.SizedBox(height: 8),
          _buildPDFRow('Bill Type:', data['billType'] ?? 'N/A'),
        ]));
        break;
      case 'insurance':
        details.add(_buildInfoBox([
          _buildPDFRow('Policy Number:', data['policyNumber'] ?? 'N/A'),
          pw.SizedBox(height: 8),
          _buildPDFRow('Company:', data['companyName'] ?? 'N/A'),
          pw.SizedBox(height: 8),
          _buildPDFRow('Insurance Type:', data['insuranceType'] ?? 'N/A'),
        ]));
        break;
      case 'movie_bookings':
        details.add(_buildInfoBox([
          _buildPDFRow('Movie:', data['movieTitle'] ?? 'N/A'),
          pw.SizedBox(height: 8),
          _buildPDFRow('Cinema:', data['cinemaChain'] ?? 'N/A'),
          pw.SizedBox(height: 8),
          _buildPDFRow('Tickets:', '${data['numberOfTickets'] ?? 0}'),
          pw.SizedBox(height: 8),
          _buildPDFRow('Seat Type:', data['seatType'] ?? 'N/A'),
        ]));
        break;
      case 'transactions':
        details.add(_buildInfoBox([
          _buildPDFRow('Recipient:', data['recipient_name'] ?? 'N/A'),
          pw.SizedBox(height: 8),
          _buildPDFRow('Transaction ID:', data['transaction_id'] ?? 'N/A'),
        ]));
        break;
    }

    return pw.Column(children: details);
  }

  pw.Widget _buildInfoBox(List<pw.Widget> children) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}