import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:payfussion/core/theme/theme.dart';
import 'package:payfussion/core/widget/card_screen.dart';
import '../../../../logic/blocs/pay_bill/internet_bill/internet_bill_bloc.dart';
import '../../../../logic/blocs/pay_bill/internet_bill/internet_bill_event.dart';

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
        builder: (BuildContext context) => InternetBillDetailsScreen(
          accountNumber: _accountController.text,
          companyName: widget.companyName,
          connectionType: widget.connectionType,
          maxSpeed: widget.maxSpeed,
          coverage: widget.coverage,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

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
          children: <Widget>[
            // Company Info Card
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: <Color>[
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
                children: <Widget>[
                  Row(
                    children: <Widget>[
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
              inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
              style: TextStyle(
                color: theme.primaryColor != Colors.white
                    ? Colors.white
                    : const Color(0xff2D3748),
              ),
              decoration: InputDecoration(
                hintText: 'Enter your account number',
                hintStyle: TextStyle(
                  color: theme.primaryColor != Colors.white
                      ? Colors.white.withOpacity(0.3)
                      : Colors.grey[400],
                ),
                prefixIcon: const Icon(Icons.account_balance, color: MyTheme.primaryColor),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Tap on information icon for details on finding your account number',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.primaryColor != Colors.white ? Colors.white.withOpacity(0.6) : Colors.grey[600],
                fontSize: 11.sp,
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
                  disabledBackgroundColor: Colors.grey[300],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
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
      children: <Widget>[
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
  final String coverage;

  const InternetBillDetailsScreen({
    super.key,
    required this.accountNumber,
    required this.companyName,
    required this.connectionType,
    required this.maxSpeed,
    required this.coverage,
  });

  void _proceedToCardSelection(BuildContext context) {
    // Sample data - replace with actual API data
    final double billAmount = 89.99;
    final String dueDate = '25 Nov 2025';
    final String billMonth = 'November 2025';
    final String consumerName = 'Sarah Johnson';
    final String address = '456 Oak Avenue, New York';
    final String planName = 'Premium Unlimited';
    final String dataUsage = '850 GB';
    final String downloadSpeed = '500 Mbps';
    final String uploadSpeed = '100 Mbps';

    // Set internet bill data in bloc
    context.read<InternetBillBloc>().add(SetInternetBillData(
      companyName: companyName,
      connectionType: connectionType,
      maxSpeed: maxSpeed,
      coverage: coverage,
      accountNumber: accountNumber,
      consumerName: consumerName,
      address: address,
      billMonth: billMonth,
      amount: billAmount,
      planName: planName,
      dataUsage: dataUsage,
      downloadSpeed: downloadSpeed,
      uploadSpeed: uploadSpeed,
      dueDate: dueDate,
    ));

    // Navigate to card selection
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => const CardsScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    // Sample data - replace with actual API data
    final String billAmount = '89.99';
    final String dueDate = '25 Nov 2025';
    final String billMonth = 'November 2025';
    final String consumerName = 'Sarah Johnson';
    final String address = '456 Oak Avenue, New York';
    final String planName = 'Premium Unlimited';
    final String dataUsage = '850 GB';
    final String downloadSpeed = '500 Mbps';
    final String uploadSpeed = '100 Mbps';

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
          children: <Widget>[
            // Bill Card
            Container(
              margin: EdgeInsets.all(16.w),
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: theme.primaryColor.withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: theme.brightness == Brightness.light ? Colors.grey.withOpacity(0.3) : Colors.black.withOpacity(0.3),
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
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withOpacity(0.1),
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
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
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
                          children: <Widget>[
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
                  onPressed: () => _proceedToCardSelection(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MyTheme.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    elevation: 4,
                  ),
                  child: Text(
                    'Continue to Card Selection',
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
      children: <Widget>[
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