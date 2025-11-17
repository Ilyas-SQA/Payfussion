import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:payfussion/core/theme/theme.dart';

class InternetBillFormScreen extends StatefulWidget {
  final String companyName;
  final String connectionType;
  final String maxSpeed;
  final String coverage;

  const InternetBillFormScreen({
    super.key,
    required this.companyName,
    required this.connectionType,
    required this.maxSpeed,
    required this.coverage,
  });

  @override
  State<InternetBillFormScreen> createState() => _InternetBillFormScreenState();
}

class _InternetBillFormScreenState extends State<InternetBillFormScreen> {
  final TextEditingController _accountController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _accountController.dispose();
    super.dispose();
  }

  void _fetchBillDetails() async {
    if (_accountController.text.isEmpty ||
        _accountController.text.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a valid account number'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
    });

    // Navigate to bill details screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InternetBillDetailsScreen(
          accountNumber: _accountController.text,
          companyName: widget.companyName,
          connectionType: widget.connectionType,
          maxSpeed: widget.maxSpeed,
        ),
      ),
    );
  }

  void _scanBill() {
    // Show coming soon dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Row(
          children: [
            Icon(
              Icons.qr_code_scanner,
              color: MyTheme.primaryColor,
            ),
            SizedBox(width: 12.w),
            Text(
              'QR Scanner',
              style: TextStyle(
                color: Theme.of(context).primaryColor != Colors.white
                    ? Colors.white
                    : const Color(0xff2D3748),
              ),
            ),
          ],
        ),
        content: Text(
          'QR code scanning feature will be available soon. Please enter your account number manually.',
          style: TextStyle(
            color: Theme.of(context).primaryColor != Colors.white
                ? Colors.white.withOpacity(0.8)
                : const Color(0xff718096),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: TextStyle(color: MyTheme.primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: theme.primaryColor != Colors.white
                ? Colors.white
                : const Color(0xff2D3748),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.companyName,
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.primaryColor != Colors.white
                ? Colors.white
                : const Color(0xff2D3748),
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Company Info Card
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    MyTheme.primaryColor.withOpacity(0.1),
                    MyTheme.primaryColor.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: MyTheme.primaryColor.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.wifi,
                        size: 24.sp,
                        color: MyTheme.primaryColor,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          widget.companyName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.primaryColor != Colors.white
                                ? Colors.white
                                : const Color(0xff2D3748),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  _buildInfoRow(Icons.router, widget.connectionType, theme),
                  SizedBox(height: 8.h),
                  _buildInfoRow(Icons.speed, widget.maxSpeed, theme),
                  SizedBox(height: 8.h),
                  _buildInfoRow(Icons.public, widget.coverage, theme),
                ],
              ),
            ),

            SizedBox(height: 32.h),

            // Account Number Input
            Text(
              '13 Digit Account Number',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.primaryColor != Colors.white
                    ? Colors.white
                    : const Color(0xff2D3748),
              ),
            ),
            SizedBox(height: 12.h),
            TextField(
              controller: _accountController,
              keyboardType: TextInputType.number,
              maxLength: 13,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: TextStyle(
                color: theme.primaryColor != Colors.white
                    ? Colors.white
                    : const Color(0xff2D3748),
              ),
              decoration: InputDecoration(
                hintText: '1234567890123',
                hintStyle: TextStyle(
                  color: theme.primaryColor != Colors.white
                      ? Colors.white.withOpacity(0.3)
                      : Colors.grey[400],
                ),
                filled: true,
                fillColor: theme.primaryColor != Colors.white
                    ? Colors.white.withOpacity(0.05)
                    : Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(
                    color: MyTheme.primaryColor.withOpacity(0.2),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(
                    color: MyTheme.primaryColor.withOpacity(0.2),
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(
                    color: MyTheme.primaryColor,
                    width: 2,
                  ),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    Icons.info_outline,
                    color: MyTheme.primaryColor,
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        title: Text(
                          'Finding Account Number',
                          style: TextStyle(
                            color: theme.primaryColor != Colors.white
                                ? Colors.white
                                : const Color(0xff2D3748),
                          ),
                        ),
                        content: Text(
                          'Your 13-digit account number can be found on your internet bill or "Bill Reference Number" on your monthly statement.',
                          style: TextStyle(
                            color: theme.primaryColor != Colors.white
                                ? Colors.white.withOpacity(0.8)
                                : const Color(0xff718096),
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              'OK',
                              style: TextStyle(color: MyTheme.primaryColor),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                counterStyle: TextStyle(
                  color: theme.primaryColor != Colors.white
                      ? Colors.white.withOpacity(0.6)
                      : Colors.grey[600],
                ),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Tap on information icon for tutorial on how to see your "Bill Reference Number"',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.primaryColor != Colors.white
                    ? Colors.white.withOpacity(0.6)
                    : Colors.grey[600],
                fontSize: 11.sp,
              ),
            ),

            SizedBox(height: 32.h),

            // OR Divider
            Row(
              children: [
                Expanded(
                  child: Divider(
                    color: theme.primaryColor != Colors.white
                        ? Colors.white.withOpacity(0.2)
                        : Colors.grey[300],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Text(
                    'OR',
                    style: TextStyle(
                      color: theme.primaryColor != Colors.white
                          ? Colors.white.withOpacity(0.6)
                          : Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  child: Divider(
                    color: theme.primaryColor != Colors.white
                        ? Colors.white.withOpacity(0.2)
                        : Colors.grey[300],
                  ),
                ),
              ],
            ),

            SizedBox(height: 32.h),

            // Scan Bill Button
            InkWell(
              onTap: _scanBill,
              borderRadius: BorderRadius.circular(12.r),
              child: Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: MyTheme.primaryColor.withOpacity(0.3),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.qr_code_scanner,
                      color: MyTheme.primaryColor,
                      size: 28.sp,
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      'Or Tap here to scan your Bill',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.primaryColor != Colors.white
                            ? Colors.white
                            : const Color(0xff2D3748),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 40.h),

            // Next Button
            SizedBox(
              width: double.infinity,
              height: 56.h,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _fetchBillDetails,
                style: ElevatedButton.styleFrom(
                  backgroundColor: MyTheme.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                  elevation: 4,
                  disabledBackgroundColor: Colors.grey[400],
                ),
                child: _isLoading
                    ? SizedBox(
                  height: 24.h,
                  width: 24.w,
                  child: const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : Text(
                  'Next',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, ThemeData theme) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16.sp,
          color: MyTheme.primaryColor,
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.primaryColor != Colors.white
                  ? Colors.white.withOpacity(0.8)
                  : const Color(0xff718096),
            ),
          ),
        ),
      ],
    );
  }
}

// Internet Bill Details Screen
class InternetBillDetailsScreen extends StatelessWidget {
  final String accountNumber;
  final String companyName;
  final String connectionType;
  final String maxSpeed;

  const InternetBillDetailsScreen({
    super.key,
    required this.accountNumber,
    required this.companyName,
    required this.connectionType,
    required this.maxSpeed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Sample data - replace with actual API data
    final billAmount = '89.99';
    final dueDate = '25 Nov 2025';
    final billMonth = 'November 2025';
    final consumerName = 'Sarah Johnson';
    final address = '456 Oak Avenue, New York';
    final planName = 'Premium Unlimited';
    final dataUsage = '850 GB';
    final downloadSpeed = '500 Mbps';
    final uploadSpeed = '100 Mbps';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: theme.primaryColor != Colors.white
                ? Colors.white
                : const Color(0xff2D3748),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Bill Details',
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.primaryColor != Colors.white
                ? Colors.white
                : const Color(0xff2D3748),
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Bill Card
            Container(
              margin: EdgeInsets.all(16.w),
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: theme.primaryColor != Colors.white
                    ? Colors.white.withOpacity(0.05)
                    : Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: MyTheme.primaryColor.withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: MyTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Icon(
                          Icons.wifi,
                          color: MyTheme.primaryColor,
                          size: 28.sp,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          companyName,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.primaryColor != Colors.white
                                ? Colors.white
                                : const Color(0xff2D3748),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),
                  _buildInfoRow('Account Number', accountNumber, theme),
                  SizedBox(height: 12.h),
                  _buildInfoRow('Consumer Name', consumerName, theme),
                  SizedBox(height: 12.h),
                  _buildInfoRow('Address', address, theme),
                  SizedBox(height: 12.h),
                  _buildInfoRow('Bill Month', billMonth, theme),
                  SizedBox(height: 12.h),
                  _buildInfoRow('Plan', planName, theme),
                  SizedBox(height: 12.h),
                  _buildInfoRow('Connection Type', connectionType, theme),
                  SizedBox(height: 12.h),
                  _buildInfoRow('Data Usage', dataUsage, theme),
                  SizedBox(height: 12.h),
                  _buildInfoRow('Download Speed', downloadSpeed, theme),
                  SizedBox(height: 12.h),
                  _buildInfoRow('Upload Speed', uploadSpeed, theme),
                  SizedBox(height: 20.h),
                  Divider(
                    color: theme.primaryColor != Colors.white
                        ? Colors.white.withOpacity(0.2)
                        : Colors.grey[300],
                  ),
                  SizedBox(height: 20.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Amount Due',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.primaryColor != Colors.white
                                  ? Colors.white.withOpacity(0.7)
                                  : Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            '\$$billAmount',
                            style: theme.textTheme.headlineLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: MyTheme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 8.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                            color: Colors.orange.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Due Date',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.primaryColor != Colors.white
                                    ? Colors.white.withOpacity(0.7)
                                    : Colors.grey[700],
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              dueDate,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange[800],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Pay Button
            Padding(
              padding: EdgeInsets.all(16.w),
              child: SizedBox(
                width: double.infinity,
                height: 56.h,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Processing payment...'),
                        backgroundColor: MyTheme.primaryColor,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MyTheme.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                    elevation: 4,
                  ),
                  child: Text(
                    'Pay Now',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 130.w,
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.primaryColor != Colors.white
                  ? Colors.white.withOpacity(0.6)
                  : Colors.grey[600],
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: theme.primaryColor != Colors.white
                  ? Colors.white
                  : const Color(0xff2D3748),
            ),
          ),
        ),
      ],
    );
  }
}