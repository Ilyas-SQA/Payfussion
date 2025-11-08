import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:payfussion/presentations/home/send_money/select_bank_screen.dart';

import '../../../core/constants/fonts.dart';
import '../../../core/theme/theme.dart';
import '../../widgets/background_theme.dart';

class SelectLocalBankScreen extends StatefulWidget {
  const SelectLocalBankScreen({super.key});

  @override
  State<SelectLocalBankScreen> createState() => _SelectLocalBankScreenState();
}

class _SelectLocalBankScreenState extends State<SelectLocalBankScreen> with TickerProviderStateMixin{
  final List<Map<String, String>> financialApps = <Map<String, String>>[
    <String, String>{"imageUrl":"assets/images/otherBank/download (10).png" ,'name': 'Cash App', 'type': 'Digital Wallet'},
    <String, String>{"imageUrl":"assets/images/otherBank/download (11).png" ,'name': 'Venmo', 'type': 'P2P Payment'},
    <String, String>{"imageUrl":"assets/images/otherBank/download (12).png" ,'name': 'Zelle', 'type': 'Bank Transfer'},
    <String, String>{"imageUrl":"assets/images/otherBank/download (13).png" ,'name': 'PayPal', 'type': 'Digital Payment'},
    <String, String>{"imageUrl":"assets/images/otherBank/download (14).png" ,'name': 'Chime', 'type': 'Digital Bank'},
    <String, String>{"imageUrl":"assets/images/otherBank/download (15).png" ,'name': 'SoFi', 'type': 'Online Bank'},
    <String, String>{"imageUrl":"assets/images/otherBank/download (16).png" ,'name': 'Revolut', 'type': 'Digital Bank'},
    <String, String>{"imageUrl":"assets/images/otherBank/download (1).png" ,'name': 'Wise', 'type': 'International Transfer'},
    <String, String>{"imageUrl":"assets/images/otherBank/reward.png" ,'name': 'Google Pay', 'type': 'Digital Wallet'},
    <String, String>{"imageUrl":"assets/images/otherBank/download.png" ,'name': 'Apple Pay', 'type': 'Digital Wallet'},
    <String, String>{"imageUrl":"assets/images/otherBank/download (2).png" ,'name': 'Robinhood', 'type': 'Investment App'},
    <String, String>{"imageUrl":"assets/images/otherBank/download (3).png" ,'name': 'Square', 'type': 'Business Payment'},
    <String, String>{"imageUrl":"assets/images/otherBank/download (4).png" ,'name': 'Current', 'type': 'Digital Bank'},
    <String, String>{"imageUrl":"assets/images/otherBank/download (5).png" ,'name': 'N26', 'type': 'Digital Bank'},
    <String, String>{"imageUrl":"assets/images/otherBank/download (6).png" ,'name': 'Ally Bank', 'type': 'Online Bank'},
    <String, String>{"imageUrl":"assets/images/otherBank/download (7).png" ,'name': 'One Finance', 'type': 'Digital Bank'},
    <String, String>{"imageUrl":"assets/images/otherBank/download (8).png" ,'name': 'Dave', 'type': 'Banking App'},
    <String, String>{"imageUrl":"assets/images/otherBank/download (9).png" ,'name': 'Brigit', 'type': 'Financial App'},
    <String, String>{"imageUrl":"assets/images/otherBank/download.jpeg" ,'name': 'Bluebird', 'type': 'Prepaid Card'},
    <String, String>{"imageUrl":"assets/images/otherBank/download (1).jpeg" ,'name': 'Tally', 'type': 'Credit Management'},
  ];

  String? selectedApp;

  void _toggleAppSelection(String app, bool isCurrentlySelected) {
    setState(() {
      if (isCurrentlySelected) {
        selectedApp = null;
      } else {
        selectedApp = app;
      }
    });
  }

  _proceedToNextScreen() {
    return Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => const BankDetailsScreen()));
  }

  Widget _buildAppCard(Map<String, String> app, bool isSelected) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: EdgeInsets.only(
        left: 16.w,
        right: 16.w,
        bottom: 12.h,
      ),

      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        gradient: isSelected ?
        LinearGradient(
          colors: <Color>[MyTheme.primaryColor, MyTheme.primaryColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ) : null,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.light ? Colors.grey.withOpacity(0.3) : Colors.black.withOpacity(0.3),
            blurRadius: 5,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: () => _toggleAppSelection(app['name']!, isSelected),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: <Widget>[
              Container(
                width: 50.w,
                height: 50.w,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25.r),
                ),
                child: ClipRRect(borderRadius: BorderRadius.circular(50),child: Image.asset(app["imageUrl"].toString(),fit: BoxFit.contain,))
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      app['name']!,
                      style: Font.montserratFont(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      app['type']!,
                      style: Font.montserratFont(
                        fontSize: 12.sp,
                        color: isSelected
                            ? Colors.white.withOpacity(0.8)
                            : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Container(
                  width: 24.w,
                  height: 24.w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.check,
                    color: MyTheme.primaryColor,
                    size: 16.sp,
                  ),
                )
              else
                Container(
                  width: 24.w,
                  height: 24.w,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey.shade400,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  late AnimationController _backgroundAnimationController;
  @override
  void initState() {
    super.initState();
    _backgroundAnimationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _backgroundAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Other Wallet',
          style: Font.montserratFont(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: <Widget>[
          AnimatedBackground(
            animationController: _backgroundAnimationController,
          ),
          Column(
            children: <Widget>[
              // Header
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 24.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Choose your Other Wallet',
                      style: Font.montserratFont(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Select a Other Wallet from the list below (tap again to unselect)',
                      style: Font.montserratFont(
                        fontSize: 14.sp,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ),

              // Financial Apps List
              Expanded(
                child: financialApps.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.account_balance_wallet_outlined,
                        size: 64.sp,
                        color: Colors.grey.shade400,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'No Financial Apps Available',
                        style: Font.montserratFont(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ) : ListView.builder(
                  padding: EdgeInsets.only(top: 8.h, bottom: 16.h),
                  itemCount: financialApps.length,
                  itemBuilder: (BuildContext context, int index) {
                    final Map<String, String> app = financialApps[index];
                    final bool isSelected = selectedApp == app['name'];
                    return _buildAppCard(app, isSelected);
                  },
                ),
              ),

              // Continue Button
              if (selectedApp != null)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.w),
                  child: ElevatedButton(
                    onPressed: _proceedToNextScreen,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MyTheme.primaryColor,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      elevation: 2,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'Continue',
                          style: Font.montserratFont(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                          size: 20.sp,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}