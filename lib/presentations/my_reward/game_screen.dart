// rs1_game_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:payfussion/core/theme/theme.dart';
import 'package:payfussion/core/constants/fonts.dart';
import '../widgets/background_theme.dart';
import 'dart:math';

class Rs1GameScreen extends StatefulWidget {
  const Rs1GameScreen({super.key});

  @override
  State<Rs1GameScreen> createState() => _Rs1GameScreenState();
}

class _Rs1GameScreenState extends State<Rs1GameScreen> with TickerProviderStateMixin {
  late AnimationController _backgroundAnimationController;
  late AnimationController _spinController;
  bool isSpinning = false;
  String? result;
  int totalPlays = 0;
  int todayPlays = 0;
  final int maxDailyPlays = 5;

  final List<PrizeItem> prizes = [
    PrizeItem(name: '₹50 Cashback', color: Colors.green, icon: Icons.monetization_on),
    PrizeItem(name: '₹100 Cashback', color: Colors.blue, icon: Icons.account_balance_wallet),
    PrizeItem(name: 'Better Luck', color: Colors.grey, icon: Icons.sentiment_dissatisfied),
    PrizeItem(name: '₹25 Cashback', color: Colors.orange, icon: Icons.card_giftcard),
    PrizeItem(name: '₹200 Cashback', color: Colors.purple, icon: Icons.diamond),
    PrizeItem(name: 'Try Again', color: Colors.grey, icon: Icons.refresh),
  ];

  @override
  void initState() {
    super.initState();
    _backgroundAnimationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _spinController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _backgroundAnimationController.dispose();
    _spinController.dispose();
    super.dispose();
  }

  void _spinWheel() {
    if (todayPlays >= maxDailyPlays) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Daily limit reached! Come back tomorrow.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      isSpinning = true;
      result = null;
    });

    _spinController.reset();
    _spinController.forward().then((_) {
      final random = Random();
      final selectedPrize = prizes[random.nextInt(prizes.length)];

      setState(() {
        isSpinning = false;
        result = selectedPrize.name;
        totalPlays++;
        todayPlays++;
      });

      _showResultDialog(selectedPrize);
    });
  }

  void _showResultDialog(PrizeItem prize) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: [
            Icon(prize.icon, size: 60, color: prize.color),
            const SizedBox(height: 12),
            Text(
              prize.name.contains('Cashback') ? 'Congratulations!' : 'Oops!',
              style: Font.montserratFont(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ],
        ),
        content: Text(
          prize.name.contains('Cashback')
              ? 'You won ${prize.name}! It will be credited to your wallet.'
              : 'Better luck next time!',
          textAlign: TextAlign.center,
          style: Font.montserratFont(fontSize: 14),
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
                'OK',
                style: Font.montserratFont(color: Colors.white, fontWeight: FontWeight.bold),
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
          'Rs 1 Game',
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
              children: [
                // Info Card
                Container(
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
                      Text(
                        'Play for just ₹1',
                        style: Font.montserratFont(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Win up to ₹200 cashback!',
                        style: Font.montserratFont(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Stats
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Total Plays',
                        totalPlays.toString(),
                        Icons.play_circle_outline,
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Today\'s Plays',
                        '$todayPlays/$maxDailyPlays',
                        Icons.today,
                        Colors.green,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Spinning Wheel Animation
                RotationTransition(
                  turns: _spinController,
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const SweepGradient(
                        colors: [
                          Colors.red,
                          Colors.orange,
                          Colors.yellow,
                          Colors.green,
                          Colors.blue,
                          Colors.purple,
                          Colors.red,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: MyTheme.secondaryColor.withOpacity(0.5),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).scaffoldBackgroundColor,
                        ),
                        child: Center(
                          child: Icon(
                            Icons.monetization_on,
                            size: 80,
                            color: MyTheme.secondaryColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Play Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: isSpinning ? null : _spinWheel,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MyTheme.secondaryColor,
                      disabledBackgroundColor: Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      isSpinning ? 'Spinning...' : 'Play for ₹1',
                      style: Font.montserratFont(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Prizes List
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Available Prizes',
                        style: Font.montserratFont(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...prizes.map((prize) => _buildPrizeItem(prize)).toList(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: Font.montserratFont(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: Font.montserratFont(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrizeItem(PrizeItem prize) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(prize.icon, color: prize.color, size: 24),
          const SizedBox(width: 12),
          Text(
            prize.name,
            style: Font.montserratFont(fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class PrizeItem {
  final String name;
  final Color color;
  final IconData icon;

  PrizeItem({required this.name, required this.color, required this.icon});
}