import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:payfussion/core/theme/theme.dart';
import 'package:payfussion/core/constants/fonts.dart';
import 'package:payfussion/presentations/my_reward/saving_screen.dart';
import 'package:payfussion/presentations/my_reward/voucher_screen.dart';
import '../widgets/background_theme.dart';
import 'earn_and_win_screen.dart';
import 'game_screen.dart';
import 'goal_reward_screen.dart';
import 'invite_earn_screen.dart';


class MyRewardScreen extends StatefulWidget {
  const MyRewardScreen({super.key});

  @override
  State<MyRewardScreen> createState() => _MyRewardScreenState();
}

class _MyRewardScreenState extends State<MyRewardScreen> with TickerProviderStateMixin {
  late AnimationController _backgroundAnimationController;
  late List<RewardItem> rewardsList;

  @override
  void initState() {
    super.initState();
    _backgroundAnimationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    rewardsList = RewardData.getRewardsList();
  }

  @override
  void dispose() {
    _backgroundAnimationController.dispose();
    super.dispose();
  }

  // Navigate to specific screen based on title
  void _navigateToScreen(String title) {
    Widget screen;

    switch (title) {
      case 'Vouchers':
        screen = const VouchersScreen();
        break;
      case 'Rs 1 Game':
        screen = const Rs1GameScreen();
        break;
      case 'Savings':
        screen = const SavingsScreen();
        break;
      case 'Invite & Earn':
        screen = const InviteEarnScreen();
        break;
      case 'Goal & Rewards':
        screen = const GoalRewardsScreen();
        break;
      case 'Enter & Win':
        screen = const EnterWinScreen();
        break;
      default:
        screen = const VouchersScreen();
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Rewards',
          style: Font.montserratFont(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: MyTheme.secondaryColor),
      ),
      body: Stack(
        children: <Widget>[
          AnimatedBackground(
            animationController: _backgroundAnimationController,
          ),
          ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: rewardsList.length + 1, // +1 for header card
            itemBuilder: (context, index) {
              // Header Card
              if (index == 0) {
                return _buildHeaderCard(context);
              }

              // Reward Items
              final rewardIndex = index - 1;
              final reward = rewardsList[rewardIndex];

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildRewardItem(
                  context,
                  icon: reward.icon,
                  iconColor: reward.iconColor,
                  title: reward.title,
                  subtitle: reward.subtitle,
                  iconBg: reward.iconBg,
                  onTap: () => _navigateToScreen(reward.title),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 200,
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          // Decorative dots
          Positioned(
            top: 30,
            left: 40,
            child: Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: 50,
            right: 60,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.pink,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: 60,
            left: 50,
            child: Container(
              width: 4,
              height: 4,
              decoration: const BoxDecoration(
                color: Colors.cyan,
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Gift box icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: <Color>[MyTheme.secondaryColor, MyTheme.secondaryColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.card_giftcard, size: 40, color: Colors.white),
          ),
          // Gold coin
          Positioned(
            bottom: 40,
            right: 120,
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFFFFD700),
                shape: BoxShape.circle,
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  'RS',
                  style: Font.montserratFont(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardItem(
      BuildContext context, {
        required IconData icon,
        required Color iconColor,
        required String title,
        required String subtitle,
        required Color iconBg,
        required VoidCallback onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(5.r),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Theme.of(context).brightness == Brightness.light
                  ? Colors.grey.withOpacity(0.3)
                  : Colors.black.withOpacity(0.3),
              blurRadius: 5,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: <Widget>[
            Icon(
              icon,
              color: iconColor,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: Font.montserratFont(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Font.montserratFont(
                      fontSize: 13,
                      color: Colors.grey[600],
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: MyTheme.secondaryColor,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

// Reward Model
class RewardItem {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Color iconBg;

  RewardItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.iconBg,
  });
}

// Reward Data
class RewardData {
  static List<RewardItem> getRewardsList() {
    return [
      RewardItem(
        icon: Icons.local_offer,
        iconColor: MyTheme.secondaryColor,
        title: 'Vouchers',
        subtitle: 'Enjoy amazing rewards',
        iconBg: MyTheme.primaryColor.withOpacity(0.1),
      ),
      RewardItem(
        icon: Icons.monetization_on,
        iconColor: MyTheme.secondaryColor,
        title: 'Rs 1 Game',
        subtitle: 'Perform Rs. 1 transaction and a chance to win',
        iconBg: MyTheme.primaryColor.withOpacity(0.1),
      ),
      RewardItem(
        icon: Icons.savings,
        iconColor: MyTheme.secondaryColor,
        title: 'Savings',
        subtitle: 'Earn up to 10.5 % profit daily',
        iconBg: MyTheme.primaryColor.withOpacity(0.1),
      ),
      RewardItem(
        icon: Icons.person_add,
        iconColor: MyTheme.secondaryColor,
        title: 'Invite & Earn',
        subtitle: 'Invite your friend to register on the Easypaisa app',
        iconBg: MyTheme.primaryColor.withOpacity(0.1),
      ),
      RewardItem(
        icon: Icons.emoji_events,
        iconColor: MyTheme.secondaryColor,
        title: 'Goal & Rewards',
        subtitle: 'Complete goals and earn exiting rewards',
        iconBg: MyTheme.primaryColor.withOpacity(0.1),
      ),
      RewardItem(
        icon: Icons.card_giftcard,
        iconColor: MyTheme.secondaryColor,
        title: 'Enter & Win',
        subtitle: 'Enter lucky code and win cash rewards',
        iconBg: MyTheme.primaryColor.withOpacity(0.1),
      ),
    ];
  }
}