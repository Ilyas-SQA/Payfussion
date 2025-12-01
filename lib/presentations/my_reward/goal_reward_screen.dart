// goal_rewards_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:payfussion/core/theme/theme.dart';
import 'package:payfussion/core/constants/fonts.dart';
import '../widgets/background_theme.dart';

class GoalRewardsScreen extends StatefulWidget {
  const GoalRewardsScreen({super.key});

  @override
  State<GoalRewardsScreen> createState() => _GoalRewardsScreenState();
}

class _GoalRewardsScreenState extends State<GoalRewardsScreen> with TickerProviderStateMixin {
  late AnimationController _backgroundAnimationController;

  int completedGoals = 8;
  int totalPoints = 1500;
  String selectedTab = 'Active';

  final List<Goal> goals = [
    Goal(
      title: 'Make 5 Transactions',
      description: 'Complete 5 transactions this week',
      progress: 3,
      target: 5,
      reward: 100,
      icon: Icons.payment,
      color: Colors.blue,
      category: 'Active',
      daysLeft: 4,
    ),
    Goal(
      title: 'Invite 3 Friends',
      description: 'Invite and get 3 friends to sign up',
      progress: 1,
      target: 3,
      reward: 300,
      icon: Icons.group_add,
      color: Colors.purple,
      category: 'Active',
      daysLeft: 10,
    ),
    Goal(
      title: 'Bill Payment Pro',
      description: 'Pay 3 utility bills',
      progress: 2,
      target: 3,
      reward: 150,
      icon: Icons.receipt_long,
      color: Colors.orange,
      category: 'Active',
      daysLeft: 7,
    ),
    Goal(
      title: 'Mobile Top-up Master',
      description: 'Recharge 5 mobile numbers',
      progress: 5,
      target: 5,
      reward: 200,
      icon: Icons.phone_android,
      color: Colors.green,
      category: 'Completed',
      daysLeft: 0,
    ),
    Goal(
      title: 'First Transaction',
      description: 'Complete your first transaction',
      progress: 1,
      target: 1,
      reward: 50,
      icon: Icons.rocket_launch,
      color: Colors.teal,
      category: 'Completed',
      daysLeft: 0,
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

  List<Goal> get filteredGoals {
    return goals.where((goal) => goal.category == selectedTab).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Goal & Rewards',
          style: Font.montserratFont(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        iconTheme: const IconThemeData(color: MyTheme.secondaryColor),
      ),
      body: Stack(
        children: [
          AnimatedBackground(animationController: _backgroundAnimationController),
          Column(
            children: [
              // Stats Card
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [MyTheme.secondaryColor, MyTheme.primaryColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.emoji_events, color: Colors.white, size: 28),
                              const SizedBox(width: 8),
                              Text(
                                'Total Points',
                                style: Font.montserratFont(
                                  fontSize: 16,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            totalPoints.toString(),
                            style: Font.montserratFont(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Text(
                            completedGoals.toString(),
                            style: Font.montserratFont(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Completed',
                            style: Font.montserratFont(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Tabs
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildTab('Active'),
                    ),
                    Expanded(
                      child: _buildTab('Completed'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Goals List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredGoals.length,
                  itemBuilder: (context, index) {
                    return _buildGoalCard(filteredGoals[index]);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String tab) {
    final isSelected = selectedTab == tab;
    return GestureDetector(
      onTap: () => setState(() => selectedTab = tab),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? MyTheme.secondaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          tab,
          textAlign: TextAlign.center,
          style: Font.montserratFont(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildGoalCard(Goal goal) {
    final progressPercent = (goal.progress / goal.target * 100).toInt();
    final isCompleted = goal.category == 'Completed';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: goal.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(goal.icon, color: goal.color, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              goal.title,
                              style: Font.montserratFont(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (!isCompleted)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.access_time, size: 12, color: Colors.orange),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${goal.daysLeft}d left',
                                    style: Font.montserratFont(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (isCompleted)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.check_circle, size: 12, color: Colors.green),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Done',
                                    style: Font.montserratFont(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        goal.description,
                        style: Font.montserratFont(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.stars, size: 16, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            '${goal.reward} Points Reward',
                            style: Font.montserratFont(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: MyTheme.secondaryColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Progress Bar
          if (!isCompleted)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progress',
                        style: Font.montserratFont(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        '${goal.progress}/${goal.target}',
                        style: Font.montserratFont(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: goal.color,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: goal.progress / goal.target,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(goal.color),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$progressPercent% completed',
                    style: Font.montserratFont(
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

          if (isCompleted)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Goal Completed! +${goal.reward} Points Earned',
                    style: Font.montserratFont(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class Goal {
  final String title;
  final String description;
  final int progress;
  final int target;
  final int reward;
  final IconData icon;
  final Color color;
  final String category;
  final int daysLeft;

  Goal({
    required this.title,
    required this.description,
    required this.progress,
    required this.target,
    required this.reward,
    required this.icon,
    required this.color,
    required this.category,
    required this.daysLeft,
  });
}