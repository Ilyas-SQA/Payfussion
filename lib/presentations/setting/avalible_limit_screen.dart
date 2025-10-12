import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/theme/theme.dart';

// Limit model
class LimitOption {
  final int amount;
  final int utilityBills;
  final String period;

  LimitOption({
    required this.amount,
    required this.utilityBills,
    this.period = 'Daily',
  });
}

// Updated SettingContainer with Bottom Sheet
class LimitSettingContainer extends StatefulWidget {
  @override
  State<LimitSettingContainer> createState() => _LimitSettingContainerState();
}

class _LimitSettingContainerState extends State<LimitSettingContainer> {
  int currentLimit = 250000;
  int currentUtilityBills = 5;

  final List<LimitOption> limitOptions = [
    LimitOption(amount: 1000000, utilityBills: 15),
    LimitOption(amount: 500000, utilityBills: 10),
    LimitOption(amount: 250000, utilityBills: 5),
    LimitOption(amount: 0, utilityBills: 0),
  ];

  void _showLimitOptions() {
    LimitOption tempSelectedLimit = limitOptions.firstWhere(
          (option) =>
      option.amount == currentLimit &&
          option.utilityBills == currentUtilityBills,
      orElse: () => limitOptions[2],
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.75,
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(5.r),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).brightness == Brightness.light ? Colors.grey.withOpacity(0.3) : Colors.black.withOpacity(0.3),
                  blurRadius: 5,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Drag handle
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Text(
                            'Available limits',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Options List
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: limitOptions.length,
                    itemBuilder: (context, index) {
                      final option = limitOptions[index];
                      final isSelected = tempSelectedLimit == option;

                      return Container(
                        margin: EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? MyTheme.primaryColor
                                : Colors.transparent,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: InkWell(
                          onTap: () {
                            setModalState(() {
                              tempSelectedLimit = option;
                            });
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Row(
                              children: [
                                // Radio button
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected
                                          ? MyTheme.primaryColor
                                          : Colors.grey[400]!,
                                      width: 2,
                                    ),
                                  ),
                                  child: isSelected
                                      ? Center(
                                    child: Container(
                                      width: 16,
                                      height: 16,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: MyTheme.primaryColor
                                      ),
                                    ),
                                  )
                                      : null,
                                ),
                                SizedBox(width: 16),
                                // Limit details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'PKR ${option.amount.toString().replaceAllMapped(
                                          RegExp(
                                              r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                              (Match m) => '${m[1]},',
                                        )} | ${option.utilityBills} utility bills',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        option.period,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Bottom button
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          currentLimit = tempSelectedLimit.amount;
                          currentUtilityBills = tempSelectedLimit.utilityBills;
                        });
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MyTheme.primaryColor,
                        minimumSize: Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Confirm Selection',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showLimitOptions,
      child: Container(
        height: 170,
        width: double.infinity,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(5.r),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).brightness == Brightness.light ? Colors.grey.withOpacity(0.3) : Colors.black.withOpacity(0.3),
              blurRadius: 5,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Limit',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Incoming',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Rs. ${currentLimit.toString().replaceAllMapped(
                    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                        (Match m) => '${m[1]},',
                  )} left',
                  style: TextStyle(
                    fontSize: 16,
                    color: MyTheme.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            // Progress bar
            Container(
              height: 8,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: 1.0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        MyTheme.primaryColor,
                        MyTheme.primaryColor,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Your Rs. ${(currentLimit / 1000).toStringAsFixed(0)}k monthly limit resets on the 1st of next month',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}