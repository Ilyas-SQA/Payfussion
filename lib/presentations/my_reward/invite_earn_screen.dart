// invite_earn_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:payfussion/core/theme/theme.dart';
import 'package:payfussion/core/constants/fonts.dart';
import '../widgets/background_theme.dart';
import 'package:share_plus/share_plus.dart'; // Add to pubspec.yaml

class InviteEarnScreen extends StatefulWidget {
  const InviteEarnScreen({super.key});

  @override
  State<InviteEarnScreen> createState() => _InviteEarnScreenState();
}

class _InviteEarnScreenState extends State<InviteEarnScreen> with TickerProviderStateMixin {
  late AnimationController _backgroundAnimationController;

  final String referralCode = 'PAYFUS2024XYZ';
  int totalReferrals = 12;
  double totalEarnings = 2400.0;
  int pendingReferrals = 3;

  final List<ReferralHistory> referrals = [
    ReferralHistory(
      name: 'Ahmad Khan',
      phone: '03XX-XXXXXXX',
      date: '25 Nov 2024',
      amount: 200.0,
      status: 'Completed',
    ),
    ReferralHistory(
      name: 'Sara Ali',
      phone: '03XX-XXXXXXX',
      date: '22 Nov 2024',
      amount: 200.0,
      status: 'Completed',
    ),
    ReferralHistory(
      name: 'Hassan Ahmed',
      phone: '03XX-XXXXXXX',
      date: '20 Nov 2024',
      amount: 200.0,
      status: 'Pending',
    ),
    ReferralHistory(
      name: 'Fatima Shah',
      phone: '03XX-XXXXXXX',
      date: '18 Nov 2024',
      amount: 200.0,
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
    super.dispose();
  }

  void _copyReferralCode() {
    Clipboard.setData(ClipboardData(text: referralCode));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Referral code copied to clipboard!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _shareReferralCode() {
    final message = '''
🎉 Join PayFussion and get Rs. 100 bonus!

Use my referral code: $referralCode

Download now: https://payfussion.app/download

- Fast & secure payments
- Exciting rewards & cashback
- Easy money transfers

Start earning today! 💰
    ''';

    Share.share(message, subject: 'Join PayFussion & Earn');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Invite & Earn',
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
                // Earnings Card
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
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.card_giftcard,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                          const Spacer(),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Total Earnings',
                                style: Font.montserratFont(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                              ),
                              Text(
                                'Rs. ${totalEarnings.toStringAsFixed(0)}',
                                style: Font.montserratFont(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatItem(
                              'Total Referrals',
                              totalReferrals.toString(),
                              Icons.people,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatItem(
                              'Pending',
                              pendingReferrals.toString(),
                              Icons.hourglass_empty,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Referral Code Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: MyTheme.secondaryColor.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Your Referral Code',
                        style: Font.montserratFont(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: MyTheme.secondaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: MyTheme.secondaryColor,
                            width: 2,
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              referralCode,
                              style: Font.montserratFont(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: MyTheme.secondaryColor,
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _copyReferralCode,
                              icon: const Icon(Icons.copy, size: 18),
                              label: Text(
                                'Copy Code',
                                style: Font.montserratFont(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                                foregroundColor: MyTheme.secondaryColor,
                                side: const BorderSide(color: MyTheme.secondaryColor),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _shareReferralCode,
                              icon: const Icon(Icons.share, size: 18),
                              label: Text(
                                'Share',
                                style: Font.montserratFont(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: MyTheme.secondaryColor,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // How it Works
                Text(
                  'How It Works',
                  style: Font.montserratFont(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                _buildStepCard(
                  1,
                  'Share Your Code',
                  'Share your unique referral code with friends',
                  Icons.share,
                  Colors.blue,
                ),
                _buildStepCard(
                  2,
                  'Friend Registers',
                  'Your friend signs up using your code',
                  Icons.person_add,
                  Colors.green,
                ),
                _buildStepCard(
                  3,
                  'Both Earn Rewards',
                  'You get Rs. 200, your friend gets Rs. 100',
                  Icons.card_giftcard,
                  Colors.orange,
                ),

                const SizedBox(height: 24),

                // Referral History
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Referral History',
                      style: Font.montserratFont(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        'View All',
                        style: Font.montserratFont(
                          fontSize: 14,
                          color: MyTheme.secondaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                ...referrals.map((referral) => _buildReferralCard(referral)).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: Font.montserratFont(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                label,
                style: Font.montserratFont(
                  fontSize: 11,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepCard(int step, String title, String description, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(icon, color: color, size: 24),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Step $step',
                        style: Font.montserratFont(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: Font.montserratFont(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Font.montserratFont(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReferralCard(ReferralHistory referral) {
    final isCompleted = referral.status == 'Completed';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: MyTheme.secondaryColor.withOpacity(0.1),
            child: Text(
              referral.name.substring(0, 1),
              style: Font.montserratFont(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: MyTheme.secondaryColor,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  referral.name,
                  style: Font.montserratFont(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  referral.phone,
                  style: Font.montserratFont(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  referral.date,
                  style: Font.montserratFont(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? Colors.green.withOpacity(0.1)
                      : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  referral.status,
                  style: Font.montserratFont(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isCompleted ? Colors.green : Colors.orange,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Rs. ${referral.amount.toStringAsFixed(0)}',
                style: Font.montserratFont(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isCompleted ? Colors.green : Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ReferralHistory {
  final String name;
  final String phone;
  final String date;
  final double amount;
  final String status;

  ReferralHistory({
    required this.name,
    required this.phone,
    required this.date,
    required this.amount,
    required this.status,
  });
}