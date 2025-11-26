import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:payfussion/core/theme/theme.dart';
import 'package:payfussion/core/widget/card_screen.dart';
import '../../../../logic/blocs/pay_bill/gas_bill/gas_bill_bloc.dart';
import '../../../../logic/blocs/pay_bill/gas_bill/gas_bill_state.dart';

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
        builder: (BuildContext context) => GasBillDetailsScreen(
          accountNumber: _accountController.text,
          companyName: widget.companyName,
          region: widget.region,
          averageRate: widget.averageRate,
        ),
      ),
    );
  }

  void _scanBill() async {
    try {
      final String? result = await Navigator.push<String>(
        context,
        MaterialPageRoute(builder: (_) => const ScannerScreen()),
      );

      if (result != null && mounted) {
        setState(() {
          _accountController.text = result;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Scanned: $result"),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Scanner error: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          widget.companyName,
        ),
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
                children: <Widget>[
                  Row(
                    children: <Widget>[
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
              inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
              style: TextStyle(
                color: theme.primaryColor != Colors.white ? Colors.white : Colors.black,
              ),
              decoration: InputDecoration(
                hintText: 'Enter your account number',
                hintStyle: TextStyle(
                  color: theme.primaryColor != Colors.white
                      ? Colors.white.withOpacity(0.5)
                      : Colors.grey[400],
                ),
                prefixIcon: const Icon(Icons.account_balance, color: MyTheme.primaryColor),
              ),
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
              children: <Widget>[
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
              child: Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: MyTheme.primaryColor,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
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
                            : Colors.black,
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

// Scanner Screen - Same as Electricity Bill Scanner
class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  MobileScannerController cameraController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scan Bill / QR"),
        actions: <Widget>[
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: cameraController.torchState,
              builder: (BuildContext context, TorchState state, Widget? child) {
                switch (state) {
                  case TorchState.off:
                    return const Icon(Icons.flash_off, color: Colors.grey);
                  case TorchState.on:
                    return const Icon(Icons.flash_on, color: Colors.yellow);
                }
              },
            ),
            onPressed: () => cameraController.toggleTorch(),
          ),
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: cameraController.cameraFacingState,
              builder: (BuildContext context, CameraFacing state, Widget? child) {
                return const Icon(Icons.cameraswitch);
              },
            ),
            onPressed: () => cameraController.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: <Widget>[
          MobileScanner(
            controller: cameraController,
            onDetect: (BarcodeCapture capture) {
              final List<Barcode> barcodes = capture.barcodes;

              if (barcodes.isEmpty) return;

              final Barcode barcode = barcodes.first;
              final String? code = barcode.rawValue;

              if (code != null && code.isNotEmpty) {
                // Stop the camera before popping
                cameraController.stop();
                Navigator.pop(context, code);
              }
            },
          ),
          // Overlay with scanning area
          Center(
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Align QR code or barcode within the frame',
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Gas Bill Details Screen (unchanged)
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

  void _proceedToCardSelection(BuildContext context) {
    // Sample data - replace with actual API data
    final double billAmount = 245.80;
    final String dueDate = '25 Nov 2025';
    final String billMonth = 'October 2025';
    final String consumerName = 'John Anderson';
    final String address = '123 Main Street, California';
    final String gasUsage = '85 therms';
    final String previousReading = '12,450';
    final String currentReading = '12,535';

    // Set gas bill data in bloc
    context.read<GasBillBloc>().add(SetGasBillData(
      companyName: companyName,
      region: region,
      averageRate: averageRate,
      accountNumber: accountNumber,
      consumerName: consumerName,
      address: address,
      billMonth: billMonth,
      amount: billAmount,
      gasUsage: gasUsage,
      previousReading: previousReading,
      currentReading: currentReading,
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
    final String billAmount = '245.80';
    final String dueDate = '25 Nov 2025';
    final String billMonth = 'October 2025';
    final String consumerName = 'John Anderson';
    final String address = '123 Main Street, California';
    final String gasUsage = '85 therms';
    final String previousReading = '12,450';
    final String currentReading = '12,535';

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
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(5.r),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Theme.of(context).brightness == Brightness.light ? Colors.grey.withOpacity(0.3) : Colors.black.withOpacity(0.3),
                    blurRadius: 5,
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
                          Icons.local_fire_department,
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