import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:payfussion/presentations/home/send_money/select_bank_screen.dart';

import '../../../core/theme/theme.dart';

class SelectLocalBankScreen extends StatefulWidget {
  const SelectLocalBankScreen({super.key});

  @override
  State<SelectLocalBankScreen> createState() => _SelectLocalBankScreenState();
}

class _SelectLocalBankScreenState extends State<SelectLocalBankScreen> {
  final List<Map<String, String>> financialApps = [
    {"imageUrl":"assets/images/otherBank/download (10).png" ,'name': 'Cash App', 'type': 'Digital Wallet'},
    {"imageUrl":"assets/images/otherBank/download (11).png" ,'name': 'Venmo', 'type': 'P2P Payment'},
    {"imageUrl":"assets/images/otherBank/download (12).png" ,'name': 'Zelle', 'type': 'Bank Transfer'},
    {"imageUrl":"assets/images/otherBank/download (13).png" ,'name': 'PayPal', 'type': 'Digital Payment'},
    {"imageUrl":"assets/images/otherBank/download (14).png" ,'name': 'Chime', 'type': 'Digital Bank'},
    {"imageUrl":"assets/images/otherBank/download (15).png" ,'name': 'SoFi', 'type': 'Online Bank'},
    {"imageUrl":"assets/images/otherBank/download (16).png" ,'name': 'Revolut', 'type': 'Digital Bank'},
    {"imageUrl":"assets/images/otherBank/download (1).png" ,'name': 'Wise', 'type': 'International Transfer'},
    {"imageUrl":"assets/images/otherBank/reward.png" ,'name': 'Google Pay', 'type': 'Digital Wallet'},
    {"imageUrl":"assets/images/otherBank/download.png" ,'name': 'Apple Pay', 'type': 'Digital Wallet'},
    {"imageUrl":"assets/images/otherBank/download (2).png" ,'name': 'Robinhood', 'type': 'Investment App'},
    {"imageUrl":"assets/images/otherBank/download (3).png" ,'name': 'Square', 'type': 'Business Payment'},
    {"imageUrl":"assets/images/otherBank/download (4).png" ,'name': 'Current', 'type': 'Digital Bank'},
    {"imageUrl":"assets/images/otherBank/download (5).png" ,'name': 'N26', 'type': 'Digital Bank'},
    {"imageUrl":"assets/images/otherBank/download (6).png" ,'name': 'Ally Bank', 'type': 'Online Bank'},
    {"imageUrl":"assets/images/otherBank/download (7).png" ,'name': 'One Finance', 'type': 'Digital Bank'},
    {"imageUrl":"assets/images/otherBank/download (8).png" ,'name': 'Dave', 'type': 'Banking App'},
    {"imageUrl":"assets/images/otherBank/download (9).png" ,'name': 'Brigit', 'type': 'Financial App'},
    {"imageUrl":"assets/images/otherBank/download.jpeg" ,'name': 'Bluebird', 'type': 'Prepaid Card'},
    {"imageUrl":"assets/images/otherBank/download (1).jpeg" ,'name': 'Tally', 'type': 'Credit Management'},
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
    return Navigator.push(context, MaterialPageRoute(builder: (context) => BankDetailsScreen()));
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
        gradient: isSelected ?
        LinearGradient(
          colors: [MyTheme.primaryColor, MyTheme.primaryColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        )
            : null,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: isSelected ? MyTheme.primaryColor.withOpacity(0.3) : Colors.grey.withOpacity(0.1),
            blurRadius: isSelected ? 8 : 4,
            offset: Offset(0, isSelected ? 4 : 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12.r),
          onTap: () => _toggleAppSelection(app['name']!, isSelected),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
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
                    children: [
                      Text(
                        app['name']!,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        app['type']!,
                        style: TextStyle(
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Other Wallet',
          style: TextStyle(
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
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 24.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Choose your Other Wallet',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Select a Other Wallet from the list below (tap again to unselect)',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey.shade600,
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
                children: [
                  Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 64.sp,
                    color: Colors.grey.shade400,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'No Financial Apps Available',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: EdgeInsets.only(top: 8.h, bottom: 16.h),
              itemCount: financialApps.length,
              itemBuilder: (context, index) {
                final app = financialApps[index];
                final isSelected = selectedApp == app['name'];
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
                  children: [
                    Text(
                      'Continue',
                      style: TextStyle(
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
    );
  }
}