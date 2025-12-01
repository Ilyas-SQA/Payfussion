// enter_win_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:payfussion/core/theme/theme.dart';
import 'package:payfussion/core/constants/fonts.dart';
import '../widgets/background_theme.dart';
import 'dart:math';

class EnterWinScreen extends StatefulWidget {
  const EnterWinScreen({super.key});

  @override
  State<EnterWinScreen> createState() => _EnterWinScreenState();
}

class _EnterWinScreenState extends State<EnterWinScreen> with TickerProviderStateMixin {
  late AnimationController _backgroundAnimationController;
  late AnimationController _shakeController;
  final TextEditingController _codeController = TextEditingController();

  int totalAttempts = 15;
  int successfulWins = 3;
  double totalWinnings = 850.0;

  final List<WinHistory> history = [
    WinHistory(
      code: 'WIN2024ABC',
      amount: 500.0,
      date: '28 Nov 2024',
      status: 'Won',
      icon: Icons.emoji_events,
      color: Colors.amber,
    ),
    WinHistory(
      code: 'LUCKY123XY',
      amount: 200.0,
      date: '25 Nov 2024',
      status: 'Won',
      icon: Icons.emoji_events,
      color: Colors.amber,
    ),
    WinHistory(
      code: 'CASH456ZZZ',
      amount: 0,
      date: '22 Nov 2024',
      status: 'No Win',
      icon: Icons.cancel,
      color: Colors.grey,
    ),
    WinHistory(
      code: 'BONUS789QQ',
      amount: 150.0,
      date: '20 Nov 2024',
      status: 'Won',
      icon: Icons.emoji_events,
      color: Colors.amber,
    ),
    WinHistory(
      code: 'TEST999AAA',
      amount: 0,
      date: '18 Nov 2024',
      status: 'No Win',
      icon: Icons.cancel,
      color: Colors.grey,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _backgroundAnimationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _backgroundAnimationController.dispose();
    _shakeController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _submitCode() {
    final code = _codeController.text.trim();

    if (code.isEmpty) {
      _showMessage('Please enter a lucky code', Colors.orange);
      _shakeAnimation();
      return;
    }

    if (code.length < 6) {
      _showMessage('Code must be at least 6 characters', Colors.orange);
      _shakeAnimation();
      return;
    }

    // Simulate code validation (30% win chance)
    final random = Random();
    final isWinner = random.nextInt(10) < 3;

    if (isWinner) {
      final amounts = [100, 150, 200, 300, 500, 1000];
      final winAmount = amounts[random.nextInt(amounts.length)];
      _showWinDialog(winAmount);
    } else {
      _showLoseDialog();
    }

    _codeController.clear();
  }

  void _shakeAnimation() {
    _shakeController.forward().then((_) => _shakeController.reverse());
  }

  void _showMessage(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showWinDialog(int amount) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.amber, Colors.orange],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.emoji_events,
                  color: Colors.amber,
                  size: 60,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '🎉 Congratulations! 🎉',
                style: Font.montserratFont(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'You Won',
                style: Font.montserratFont(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Rs. $amount',
                style: Font.montserratFont(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Amount will be credited to your wallet within 24 hours',
                style: Font.montserratFont(
                  fontSize: 12,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Awesome!',
                  style: Font.montserratFont(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLoseDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: [
            const Icon(
              Icons.sentiment_dissatisfied,
              size: 60,
              color: Colors.grey,
            ),
            const SizedBox(height: 12),
            Text(
              'Better Luck Next Time!',
              style: Font.montserratFont(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        content: Text(
          'This code didn\'t win. Try another code or wait for new lucky codes!',
          style: Font.montserratFont(fontSize: 14),
          textAlign: TextAlign.center,
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: MyTheme.secondaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              ),
              child: Text(
                'Try Again',
                style: Font.montserratFont(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Enter & Win',
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
                // Stats Card
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
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatItem(
                              'Total Winnings',
                              'Rs. ${totalWinnings.toStringAsFixed(0)}',
                              Icons.account_balance_wallet,
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 50,
                            color: Colors.white.withOpacity(0.3),
                          ),
                          Expanded(
                            child: _buildStatItem(
                              'Success Rate',
                              '${((successfulWins / totalAttempts) * 100).toStringAsFixed(0)}%',
                              Icons.trending_up,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Enter Code Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
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
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: MyTheme.secondaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.stars,
                              color: MyTheme.secondaryColor,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Enter Lucky Code',
                                  style: Font.montserratFont(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Win up to Rs. 1000',
                                  style: Font.montserratFont(
                                    fontSize: 13,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      AnimatedBuilder(
                        animation: _shakeController,
                        builder: (context, child) {
                          final offset = sin(_shakeController.value * 2 * pi) * 5;
                          return Transform.translate(
                            offset: Offset(offset, 0),
                            child: child,
                          );
                        },
                        child: TextField(
                          controller: _codeController,
                          textCapitalization: TextCapitalization.characters,
                          decoration: InputDecoration(
                            hintText: 'Enter your lucky code',
                            prefixIcon: const Icon(Icons.confirmation_number),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: MyTheme.secondaryColor,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _submitCode,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: MyTheme.secondaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Check Code',
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

                // How to Get Codes
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.info_outline, color: Colors.blue),
                          const SizedBox(width: 8),
                          Text(
                            'How to Get Lucky Codes?',
                            style: Font.montserratFont(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildInfoItem('Check notifications for exclusive codes'),
                      _buildInfoItem('Follow us on social media'),
                      _buildInfoItem('Complete transactions to receive codes'),
                      _buildInfoItem('Participate in special promotions'),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // History
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Attempts',
                      style: Font.montserratFont(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '$totalAttempts total',
                      style: Font.montserratFont(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
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

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: Font.montserratFont(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: Font.montserratFont(
            fontSize: 13,
            color: Colors.white70,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildInfoItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Font.montserratFont(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(WinHistory item) {
    final isWin = item.status == 'Won';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isWin ? Colors.amber.withOpacity(0.3) : Colors.grey.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: item.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(item.icon, color: item.color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.code,
                  style: Font.montserratFont(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 12, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      item.date,
                      style: Font.montserratFont(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isWin
                      ? Colors.green.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  item.status,
                  style: Font.montserratFont(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isWin ? Colors.green : Colors.grey,
                  ),
                ),
              ),
              if (isWin) ...[
                const SizedBox(height: 4),
                Text(
                  'Rs. ${item.amount.toStringAsFixed(0)}',
                  style: Font.montserratFont(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class WinHistory {
  final String code;
  final double amount;
  final String date;
  final String status;
  final IconData icon;
  final Color color;

  WinHistory({
    required this.code,
    required this.amount,
    required this.date,
    required this.status,
    required this.icon,
    required this.color,
  });
}