import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:payfussion/core/theme/theme.dart';
import 'bill_split_form_screen.dart';

class BillSplitScreen extends StatefulWidget {
  const BillSplitScreen({super.key});

  @override
  State<BillSplitScreen> createState() => _BillSplitScreenState();
}

class _BillSplitScreenState extends State<BillSplitScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          'Bill Split',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.primaryColor != Colors.white
                ? Colors.white
                : const Color(0xff2D3748),
          ),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.all(24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Header Section
              Text(
                'Split Bills',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor != Colors.white
                      ? Colors.white
                      : const Color(0xff2D3748),
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Easily divide expenses with friends and family',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.primaryColor != Colors.white
                      ? Colors.white.withOpacity(0.7)
                      : const Color(0xff718096),
                ),
              ),
              SizedBox(height: 32.h),

              // Feature Cards
              _buildFeatureCard(
                context,
                icon: Icons.calculate,
                title: 'Equal Split',
                description: 'Divide the bill equally among all participants',
                color: Colors.blue,
              ),
              SizedBox(height: 16.h),
              _buildFeatureCard(
                context,
                icon: Icons.edit,
                title: 'Custom Split',
                description: 'Assign custom amounts to each person',
                color: Colors.orange,
              ),
              SizedBox(height: 16.h),
              _buildFeatureCard(
                context,
                icon: Icons.people,
                title: 'Multiple Participants',
                description: 'Split bills with up to 20 people',
                color: Colors.green,
              ),
              SizedBox(height: 32.h),

              // Illustration or Info Box
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: <Color>[
                      MyTheme.primaryColor.withOpacity(0.1),
                      MyTheme.primaryColor.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: MyTheme.primaryColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: <Widget>[
                    Icon(
                      Icons.receipt_long,
                      size: 64.sp,
                      color: MyTheme.primaryColor,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'How it works',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor != Colors.white ? Colors.white : const Color(0xff2D3748),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      '1. Enter the bill details\n2. Add participants\n3. Choose split method\n4. Select payment card\n5. Confirm and pay',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14.sp,
                        height: 1.5,
                        color: theme.primaryColor != Colors.white ? Colors.white.withOpacity(0.7) : const Color(0xff718096),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32.h),

              // Start Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) => const BillSplitFormScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MyTheme.primaryColor,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    elevation: 4,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(Icons.add_circle_outline, color: Colors.white, size: 24.sp),
                      SizedBox(width: 12.w),
                      Text(
                        'Start New Split',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String description,
        required Color color,
      }) {
    final ThemeData theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: theme.brightness == Brightness.light
                ? Colors.grey.withOpacity(0.2)
                : Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              icon,
              color: color,
              size: 32.sp,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor != Colors.white
                        ? Colors.white
                        : const Color(0xff2D3748),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: theme.primaryColor != Colors.white
                        ? Colors.white.withOpacity(0.7)
                        : const Color(0xff718096),
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