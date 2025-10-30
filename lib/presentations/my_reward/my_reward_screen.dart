import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:payfussion/core/theme/theme.dart';
import 'package:payfussion/presentations/my_reward/specific_reward_screen.dart';

import '../../core/constants/fonts.dart';
import '../widgets/background_theme.dart';

class MyRewardScreen extends StatefulWidget {
  const MyRewardScreen({super.key});

  @override
  State<MyRewardScreen> createState() => _MyRewardScreenState();
}

class _MyRewardScreenState extends State<MyRewardScreen> with TickerProviderStateMixin{

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
          'My Rewards',
          style: Font.montserratFont(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Stack(
        children: [
          AnimatedBackground(
            animationController: _backgroundAnimationController,
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 200,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
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
                            colors: [MyTheme.primaryColor, MyTheme.primaryColor],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(child: SvgPicture.asset("assets/images/home/reward.svg",height: 40,width: 40,color: Colors.white,)),
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
                            boxShadow: [
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
                ),

                // Rewards List
                _buildRewardItem(
                  context,
                  icon: Icons.local_offer,
                  iconColor: MyTheme.primaryColor,
                  title: 'Vouchers',
                  subtitle: 'Enjoy amazing rewards',
                  iconBg: MyTheme.primaryColor.withOpacity(0.1),
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => const SpecificRewardScreen(title: "Vouchers",)));
                  },
                ),
                const SizedBox(height: 16),

                _buildRewardItem(
                  context,
                  icon: Icons.monetization_on,
                  iconColor: MyTheme.primaryColor,
                  title: 'Rs 1 Game',
                  subtitle: 'Perform Rs. 1 transaction and a chance to win',
                  iconBg: MyTheme.primaryColor.withOpacity(0.1),
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => const SpecificRewardScreen(title: "Rs 1 Game",)));
                  },
                ),
                const SizedBox(height: 16),

                _buildRewardItem(
                  context,
                  icon: Icons.savings,
                  iconColor: MyTheme.primaryColor,
                  title: 'Savings',
                  subtitle: 'Earn up to 10.5 % profit daily',
                  iconBg: MyTheme.primaryColor.withOpacity(0.1),
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => const SpecificRewardScreen(title: "Savings",)));
                  },
                ),
                const SizedBox(height: 16),

                _buildRewardItem(
                  context,
                  icon: Icons.person_add,
                  iconColor: MyTheme.primaryColor,
                  title: 'Invite & Earn',
                  subtitle: 'Invite your friend to register on the Easypaisa app',
                  iconBg: MyTheme.primaryColor.withOpacity(0.1),
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const SpecificRewardScreen(title: "Invite & Earn",)));
                  },
                ),
                const SizedBox(height: 16),

                _buildRewardItem(
                  context,
                  icon: Icons.emoji_events,
                  iconColor: MyTheme.primaryColor,
                  title: 'Goal & Rewards',
                  subtitle: 'Complete goals and earn exiting rewards',
                  iconBg: MyTheme.primaryColor.withOpacity(0.1),
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const SpecificRewardScreen(title: "Goal & Rewards",)));
                  },
                ),
                const SizedBox(height: 16),

                _buildRewardItem(
                  context,
                  icon: Icons.card_giftcard,
                  iconColor: MyTheme.primaryColor,
                  title: 'Enter & Win',
                  subtitle: 'Enter lucky code and win cash rewards',
                  iconBg: MyTheme.primaryColor.withOpacity(0.1),
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const SpecificRewardScreen(title: "Enter & Win",)));
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardItem(context,{
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
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).brightness == Brightness.light ? Colors.grey.withOpacity(0.3) : Colors.black.withOpacity(0.3),
              blurRadius: 5,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: iconColor,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
              color: MyTheme.primaryColor,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}