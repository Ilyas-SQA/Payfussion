import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:payfussion/core/theme/theme.dart';

class GasBillFormScreen extends StatefulWidget {
  final String companyName;
  final String region;
  final String averageRate;
  final String customers;

  const GasBillFormScreen({
    super.key,
    required this.companyName,
    required this.region,
    required this.averageRate,
    required this.customers,
  });

  @override
  State<GasBillFormScreen> createState() => _GasBillFormScreenState();
}

class _GasBillFormScreenState extends State<GasBillFormScreen> {
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
        builder: (context) => GasBillDetailsScreen(
          accountNumber: _accountController.text,
          companyName: widget.companyName,
          region: widget.region,
          averageRate: widget.averageRate,
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
              color: Theme.of(context).primaryColor,
            ),
            SizedBox(width: 12.w),
            Text(
              'QR Scanner',
              style: TextStyle(
                color: Theme.of(context).primaryColor != Colors.white ? Colors.white : const Color(0xff2D3748),
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
              style: TextStyle(color: Theme.of(context).primaryColor),
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
                    theme.primaryColor.withOpacity(0.1),
                    theme.primaryColor.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: theme.primaryColor.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.local_fire_department,
                        size: 24.sp,
                        color: MyTheme.primaryColor,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          widget.companyName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.primaryColor != Colors.white ? Colors.white : const Color(0xff2D3748),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  _buildInfoRow(Icons.location_on, widget.region, theme),
                  SizedBox(height: 8.h),
                  _buildInfoRow(Icons.attach_money, widget.averageRate, theme),
                ],
              ),
            ),

            SizedBox(height: 32.h),

            // Account Number Input
            Text(
              'Account Number',
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
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            SizedBox(height: 8.h),
            Text(
              'Tap on information icon for details on finding your account number',
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

            // Scan Bill Button (Disabled)
            Opacity(
              opacity: 0.5,
              child: Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: theme.primaryColor.withOpacity(0.3),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.qr_code_scanner,
                      color: theme.primaryColor,
                      size: 28.sp,
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      'Scan Your Bill (Coming Soon)',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                  elevation: 4,
                ),
                child: _isLoading ? SizedBox(
                  height: 24.h,
                  width: 24.w,
                  child: const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : Text(
                  'Continue',
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

// Gas Bill Details Screen
class GasBillDetailsScreen extends StatelessWidget {
  final String accountNumber;
  final String companyName;
  final String region;
  final String averageRate;

  const GasBillDetailsScreen({
    super.key,
    required this.accountNumber,
    required this.companyName,
    required this.region,
    required this.averageRate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Sample data - replace with actual API data
    final billAmount = '245.80';
    final dueDate = '25 Nov 2025';
    final billMonth = 'October 2025';
    final consumerName = 'John Anderson';
    final address = '123 Main Street, California';
    final gasUsage = '85 therms';
    final previousReading = '12,450';
    final currentReading = '12,535';

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
                  color: theme.primaryColor.withOpacity(0.2),
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
                          color: theme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Icon(
                          Icons.local_fire_department,
                          color: theme.primaryColor,
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
                  _buildInfoRow('Gas Usage', gasUsage, theme),
                  SizedBox(height: 12.h),
                  _buildInfoRow('Previous Reading', previousReading, theme),
                  SizedBox(height: 12.h),
                  _buildInfoRow('Current Reading', currentReading, theme),
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
                              color: theme.primaryColor,
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
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
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