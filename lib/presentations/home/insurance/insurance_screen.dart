import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:payfussion/core/theme/theme.dart';

import '../../widgets/background_theme.dart';
import 'insurance_type_screen.dart';

class InsuranceScreen extends StatefulWidget {
  const InsuranceScreen({super.key});

  @override
  State<InsuranceScreen> createState() => _InsuranceScreenState();
}

class _InsuranceScreenState extends State<InsuranceScreen> with TickerProviderStateMixin {

  // Animation controllers
  late AnimationController _headerController;
  late AnimationController _listController;
  late AnimationController _backgroundAnimationController;
  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;
  late Animation<double> _listFade;

  final List<Map<String, dynamic>> insuranceCompanies = <Map<String, dynamic>>[
    <String, dynamic>{
      "name": "State Farm",
      "types": <String>[
        "Auto Insurance",
        "Homeowners Insurance",
        "Property & Casualty"
      ],
      "icon": Icons.directions_car,
      "color": MyTheme.secondaryColor,
      "description": "America's largest auto insurer"
    },
    <String, dynamic>{
      "name": "Berkshire Hathaway",
      "types": <String>[
        "Auto Insurance (GEICO)",
        "Reinsurance (Gen Re)",
        "Property & Casualty",
        "Life & Health"
      ],
      "icon": Icons.business,
      "color": MyTheme.secondaryColor,
      "description": "Warren Buffett's insurance empire"
    },
    <String, dynamic>{
      "name": "MetLife",
      "types": <String>[
        "Life Insurance",
        "Health Insurance",
        "Dental & Vision Insurance",
        "Group Benefits"
      ],
      "icon": Icons.favorite,
      "color": MyTheme.secondaryColor,
      "description": "Leading life insurance provider"
    },
    <String, dynamic>{
      "name": "Prudential Financial",
      "types": <String>[
        "Life Insurance",
        "Annuities",
        "Investment & Retirement Solutions"
      ],
      "icon": Icons.account_balance,
      "color": MyTheme.secondaryColor,
      "description": "Financial wellness solutions"
    },
    <String, dynamic>{
      "name": "Allstate Corporation",
      "types": <String>[
        "Auto Insurance",
        "Homeowners Insurance",
        "Renters & Condo Insurance",
        "Life Insurance"
      ],
      "icon": Icons.shield,
      "color": MyTheme.secondaryColor,
      "description": "You're in good hands"
    },
    <String, dynamic>{
      "name": "American International Group (AIG)",
      "types": <String>[
        "Life Insurance",
        "Property & Casualty Insurance",
        "Retirement Products",
        "Travel Insurance"
      ],
      "icon": Icons.public,
      "color": MyTheme.secondaryColor,
      "description": "Global insurance leader"
    },
    <String, dynamic>{
      "name": "Chubb Limited",
      "types": <String>[
        "Commercial Insurance",
        "Property & Casualty",
        "Accident & Health",
        "Specialty Insurance"
      ],
      "icon": Icons.security,
      "color": MyTheme.secondaryColor,
      "description": "Premium insurance solutions"
    },
    <String, dynamic>{
      "name": "Northwestern Mutual",
      "types": <String>[
        "Life Insurance",
        "Disability Insurance",
        "Long-Term Care Insurance",
        "Investment & Financial Planning"
      ],
      "icon": Icons.trending_up,
      "color": MyTheme.secondaryColor,
      "description": "Financial planning expertise"
    },
    <String, dynamic>{
      "name": "Lincoln Financial Group",
      "types": <String>[
        "Life Insurance",
        "Retirement Plans",
        "Annuities",
        "Group Benefits"
      ],
      "icon": Icons.savings,
      "color": MyTheme.secondaryColor,
      "description": "Retirement planning specialists"
    },
    <String, dynamic>{
      "name": "MassMutual",
      "types": <String>[
        "Life Insurance",
        "Disability Income Insurance",
        "Long-Term Care Insurance",
        "Annuities",
        "Retirement Planning"
      ],
      "icon": Icons.family_restroom,
      "color": MyTheme.secondaryColor,
      "description": "Mutual insurance company"
    },
  ];

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startAnimationSequence();
    _backgroundAnimationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
  }

  void _initAnimations() {
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _listController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _headerFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _headerController, curve: Curves.easeOut),
    );

    _headerSlide = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _headerController, curve: Curves.easeOut));

    _listFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _listController, curve: Curves.easeOut),
    );
  }

  void _startAnimationSequence() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _headerController.forward();

    await Future.delayed(const Duration(milliseconds: 300));
    _listController.forward();
  }

  @override
  void dispose() {
    _headerController.dispose();
    _listController.dispose();
    _backgroundAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: FadeTransition(
          opacity: _headerFade,
          child: SlideTransition(
            position: _headerSlide,
            child: Text(
              "Insurance Companies",
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.primaryColor != Colors.white ? Colors.white : const Color(0xff2D3748),
              ),
            ),
          ),
        ),
        iconTheme: const IconThemeData(
          color: MyTheme.secondaryColor,
        ),
      ),
      body: Stack(
        children: <Widget>[
          AnimatedBackground(
            animationController: _backgroundAnimationController,
          ),
          FadeTransition(
            opacity: _listFade,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Header Section
                Padding(
                  padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 20.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "Choose Your",
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w300,
                          color: theme.primaryColor != Colors.white ? Colors.white.withOpacity(0.8) : const Color(0xff718096),
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        "Insurance Provider",
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.primaryColor != Colors.white ? Colors.white : const Color(0xff2D3748),
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        "Protect what matters most with trusted insurance companies",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.primaryColor != Colors.white ? Colors.white.withOpacity(0.7) : const Color(0xff718096),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                // Insurance List
                Expanded(
                  child: _buildInsuranceList(theme),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsuranceList(ThemeData theme) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: AnimationLimiter(
        child: GridView.builder(
          physics: const BouncingScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 10.h,
            crossAxisSpacing: 10.w,
            childAspectRatio: 8 / 12,
          ),
          itemCount: insuranceCompanies.length,
          itemBuilder: (BuildContext context, int index) {
            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 500),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: _buildInsuranceCard(
                    insuranceCompanies[index],
                    theme,
                    index,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInsuranceCard(Map<String, dynamic> company, ThemeData theme, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(5.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.light ? Colors.grey.withOpacity(0.3) : Colors.black.withOpacity(0.3),
            blurRadius: 5,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) =>
                  InsuranceTypeScreen(
                    companyName: company['name'],
                    types: List<String>.from(company['types']),
                    icon: company['icon'],
                    color: company['color'],
                  ),
              transitionsBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(1.0, 0.0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                );
              },
            ),
          );
        },
        borderRadius: BorderRadius.circular(20.r),
        child: Padding(
          padding: EdgeInsets.all(10.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              // Icon Container
              Hero(
                tag: 'insurance_icon_${company['name']}',
                child: Icon(
                  company['icon'] as IconData,
                  size: 28.sp,
                  color: MyTheme.secondaryColor,
                ),
              ),

              SizedBox(width: 16.w),

              // Content
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    company['name'] as String,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: theme.primaryColor != Colors.white ? Colors.white : const Color(0xff2D3748),
                    ),
                  ),
                ],
              ),

            ],
          ),
        ),
      ),
    );
  }
}
