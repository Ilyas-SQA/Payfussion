// savings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:payfussion/core/theme/theme.dart';
import 'package:payfussion/core/constants/fonts.dart';
import '../widgets/background_theme.dart';

class SavingsScreen extends StatefulWidget {
  const SavingsScreen({super.key});

  @override
  State<SavingsScreen> createState() => _SavingsScreenState();
}

class _SavingsScreenState extends State<SavingsScreen> with TickerProviderStateMixin {
  late AnimationController _backgroundAnimationController;
  final TextEditingController _amountController = TextEditingController();

  String selectedPlan = '3 Months';
  double totalSavings = 25000.0;
  double totalEarned = 1250.0;

  final List<SavingsPlan> plans = [
    SavingsPlan(
      duration: '3 Months',
      rate: 8.5,
      minAmount: 1000,
      description: 'Short term savings with competitive returns',
      icon: Icons.calendar_today,
      color: Colors.blue,
    ),
    SavingsPlan(
      duration: '6 Months',
      rate: 9.5,
      minAmount: 5000,
      description: 'Medium term savings with better returns',
      icon: Icons.date_range,
      color: Colors.green,
    ),
    SavingsPlan(
      duration: '12 Months',
      rate: 10.5,
      minAmount: 10000,
      description: 'Long term savings with maximum returns',
      icon: Icons.calendar_month,
      color: Colors.purple,
    ),
  ];

  final List<SavingsHistory> history = [
    SavingsHistory(
      amount: 10000,
      plan: '6 Months',
      startDate: '01 Sep 2024',
      endDate: '01 Mar 2025',
      earned: 475.0,
      status: 'Active',
    ),
    SavingsHistory(
      amount: 15000,
      plan: '3 Months',
      startDate: '01 Oct 2024',
      endDate: '01 Jan 2025',
      earned: 318.75,
      status: 'Active',
    ),
    SavingsHistory(
      amount: 5000,
      plan: '3 Months',
      startDate: '01 Jul 2024',
      endDate: '01 Oct 2024',
      earned: 106.25,
      status: 'Completed',
    ),
  ];

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
    _amountController.dispose();
    super.dispose();
  }

  SavingsPlan get currentPlan {
    return plans.firstWhere((plan) => plan.duration == selectedPlan);
  }

  double calculateReturns(double amount) {
    final plan = currentPlan;
    final months = int.parse(plan.duration.split(' ')[0]);
    return (amount * plan.rate * months) / (12 * 100);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Savings',
          style: Font.montserratFont(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        iconTheme: const IconThemeData(color: MyTheme.secondaryColor),
      ),
      body: Stack(
        children: [
          AnimatedBackground(animationController: _backgroundAnimationController),
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Total Savings Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [MyTheme.secondaryColor, MyTheme.primaryColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Savings',
                        style: Font.montserratFont(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Rs. ${totalSavings.toStringAsFixed(0)}',
                        style: Font.montserratFont(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(Icons.trending_up, color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Earned: Rs. ${totalEarned.toStringAsFixed(2)}',
                            style: Font.montserratFont(
                              fontSize: 14,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Plans Section
                Text(
                  'Choose Your Plan',
                  style: Font.montserratFont(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                ...plans.map((plan) => _buildPlanCard(plan)).toList(),

                const SizedBox(height: 24),

                // Investment Calculator
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: MyTheme.secondaryColor.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Calculate Your Returns',
                        style: Font.montserratFont(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Enter Amount',
                          prefixText: 'Rs. ',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: MyTheme.secondaryColor),
                          ),
                        ),
                        onChanged: (value) => setState(() {}),
                      ),
                      const SizedBox(height: 16),
                      if (_amountController.text.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: MyTheme.secondaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Investment:',
                                    style: Font.montserratFont(fontSize: 14),
                                  ),
                                  Text(
                                    'Rs. ${_amountController.text}',
                                    style: Font.montserratFont(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Expected Returns:',
                                    style: Font.montserratFont(fontSize: 14),
                                  ),
                                  Text(
                                    'Rs. ${calculateReturns(double.tryParse(_amountController.text) ?? 0).toStringAsFixed(2)}',
                                    style: Font.montserratFont(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Total Amount:',
                                    style: Font.montserratFont(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Rs. ${((double.tryParse(_amountController.text) ?? 0) + calculateReturns(double.tryParse(_amountController.text) ?? 0)).toStringAsFixed(2)}',
                                    style: Font.montserratFont(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: MyTheme.secondaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_amountController.text.isNotEmpty) {
                              _showInvestDialog();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: MyTheme.secondaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Start Saving',
                            style: Font.montserratFont(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // History
                Text(
                  'My Savings',
                  style: Font.montserratFont(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                ...history.map((item) => _buildHistoryCard(item)).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(SavingsPlan plan) {
    final isSelected = selectedPlan == plan.duration;
    return GestureDetector(
      onTap: () => setState(() => selectedPlan = plan.duration),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? MyTheme.secondaryColor : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: plan.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(plan.icon, color: plan.color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        plan.duration,
                        style: Font.montserratFont(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${plan.rate}% p.a.',
                          style: Font.montserratFont(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    plan.description,
                    style: Font.montserratFont(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Min: Rs. ${plan.minAmount}',
                    style: Font.montserratFont(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: MyTheme.secondaryColor,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryCard(SavingsHistory item) {
    final isActive = item.status == 'Active';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Rs. ${item.amount}',
                style: Font.montserratFont(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: isActive
                      ? Colors.green.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  item.status,
                  style: Font.montserratFont(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isActive ? Colors.green : Colors.grey,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            item.plan,
            style: Font.montserratFont(
              fontSize: 14,
              color: MyTheme.secondaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                '${item.startDate} - ${item.endDate}',
                style: Font.montserratFont(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Earned:',
                style: Font.montserratFont(fontSize: 14),
              ),
              Text(
                'Rs. ${item.earned.toStringAsFixed(2)}',
                style: Font.montserratFont(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showInvestDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Confirm Investment',
          style: Font.montserratFont(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Amount: Rs. ${_amountController.text}'),
            Text('Plan: $selectedPlan'),
            Text('Rate: ${currentPlan.rate}% p.a.'),
            const SizedBox(height: 8),
            Text(
              'Expected Returns: Rs. ${calculateReturns(double.parse(_amountController.text)).toStringAsFixed(2)}',
              style: Font.montserratFont(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Investment started successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: MyTheme.secondaryColor),
            child: Text('Confirm', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class SavingsPlan {
  final String duration;
  final double rate;
  final int minAmount;
  final String description;
  final IconData icon;
  final Color color;

  SavingsPlan({
    required this.duration,
    required this.rate,
    required this.minAmount,
    required this.description,
    required this.icon,
    required this.color,
  });
}

class SavingsHistory {
  final int amount;
  final String plan;
  final String startDate;
  final String endDate;
  final double earned;
  final String status;

  SavingsHistory({
    required this.amount,
    required this.plan,
    required this.startDate,
    required this.endDate,
    required this.earned,
    required this.status,
  });
}