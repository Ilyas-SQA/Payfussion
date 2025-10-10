import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:payfussion/core/theme/theme.dart';

import 'insurance_type_screen.dart';

class InsuranceScreen extends StatefulWidget {
  const InsuranceScreen({super.key});

  @override
  State<InsuranceScreen> createState() => _InsuranceScreenState();
}

class _InsuranceScreenState extends State<InsuranceScreen>
    with TickerProviderStateMixin {

  // Animation controllers
  late AnimationController _headerController;
  late AnimationController _listController;

  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;
  late Animation<double> _listFade;

  final List<Map<String, dynamic>> insuranceCompanies = [
    {
      "name": "State Farm",
      "types": [
        "Auto Insurance",
        "Homeowners Insurance",
        "Property & Casualty"
      ],
      "icon": Icons.directions_car,
      "color": MyTheme.secondaryColor,
      "description": "America's largest auto insurer"
    },
    {
      "name": "Berkshire Hathaway",
      "types": [
        "Auto Insurance (GEICO)",
        "Reinsurance (Gen Re)",
        "Property & Casualty",
        "Life & Health"
      ],
      "icon": Icons.business,
      "color": MyTheme.secondaryColor,
      "description": "Warren Buffett's insurance empire"
    },
    {
      "name": "MetLife",
      "types": [
        "Life Insurance",
        "Health Insurance",
        "Dental & Vision Insurance",
        "Group Benefits"
      ],
      "icon": Icons.favorite,
      "color": MyTheme.secondaryColor,
      "description": "Leading life insurance provider"
    },
    {
      "name": "Prudential Financial",
      "types": [
        "Life Insurance",
        "Annuities",
        "Investment & Retirement Solutions"
      ],
      "icon": Icons.account_balance,
      "color": MyTheme.secondaryColor,
      "description": "Financial wellness solutions"
    },
    {
      "name": "Allstate Corporation",
      "types": [
        "Auto Insurance",
        "Homeowners Insurance",
        "Renters & Condo Insurance",
        "Life Insurance"
      ],
      "icon": Icons.shield,
      "color": MyTheme.secondaryColor,
      "description": "You're in good hands"
    },
    {
      "name": "American International Group (AIG)",
      "types": [
        "Life Insurance",
        "Property & Casualty Insurance",
        "Retirement Products",
        "Travel Insurance"
      ],
      "icon": Icons.public,
      "color": MyTheme.secondaryColor,
      "description": "Global insurance leader"
    },
    {
      "name": "Chubb Limited",
      "types": [
        "Commercial Insurance",
        "Property & Casualty",
        "Accident & Health",
        "Specialty Insurance"
      ],
      "icon": Icons.security,
      "color": MyTheme.secondaryColor,
      "description": "Premium insurance solutions"
    },
    {
      "name": "Northwestern Mutual",
      "types": [
        "Life Insurance",
        "Disability Insurance",
        "Long-Term Care Insurance",
        "Investment & Financial Planning"
      ],
      "icon": Icons.trending_up,
      "color": MyTheme.secondaryColor,
      "description": "Financial planning expertise"
    },
    {
      "name": "Lincoln Financial Group",
      "types": [
        "Life Insurance",
        "Retirement Plans",
        "Annuities",
        "Group Benefits"
      ],
      "icon": Icons.savings,
      "color": MyTheme.secondaryColor,
      "description": "Retirement planning specialists"
    },
    {
      "name": "MassMutual",
      "types": [
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: FadeTransition(
          opacity: _headerFade,
          child: SlideTransition(
            position: _headerSlide,
            child: Text(
              "Insurance Companies",
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.primaryColor != Colors.white
                    ? Colors.white
                    : const Color(0xff2D3748),
              ),
            ),
          ),
        ),
        leading: FadeTransition(
          opacity: _headerFade,
          child: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: theme.primaryColor != Colors.white
                  ? Colors.white
                  : const Color(0xff2D3748),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ),
      body: FadeTransition(
        opacity: _listFade,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Padding(
              padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Choose Your",
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w300,
                      color: theme.primaryColor != Colors.white
                          ? Colors.white.withOpacity(0.8)
                          : const Color(0xff718096),
                    ),
                  ),
                  Text(
                    "Insurance Provider",
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor != Colors.white
                          ? Colors.white
                          : const Color(0xff2D3748),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    "Protect what matters most with trusted insurance companies",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.primaryColor != Colors.white
                          ? Colors.white.withOpacity(0.7)
                          : const Color(0xff718096),
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
    );
  }

  Widget _buildInsuranceList(ThemeData theme) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: AnimationLimiter(
        child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: insuranceCompanies.length,
          itemBuilder: (context, index) {
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
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          const BoxShadow(
            color: Colors.black26,
            blurRadius: 5,
            offset: Offset(1, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    InsuranceTypeScreen(
                      companyName: company['name'],
                      types: List<String>.from(company['types']),
                      icon: company['icon'],
                      color: company['color'],
                    ),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
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
            padding: EdgeInsets.all(20.w),
            child: Row(
              children: [
                // Icon Container
                Hero(
                  tag: 'insurance_icon_${company['name']}',
                  child: Container(
                    height: 65.h,
                    width: 65.w,
                    decoration: BoxDecoration(
                      color: (company['color'] as Color).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(18.r),
                      border: Border.all(
                        color: (company['color'] as Color).withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      company['icon'] as IconData,
                      size: 28.sp,
                      color: company['color'] as Color,
                    ),
                  ),
                ),

                SizedBox(width: 16.w),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        company['name'] as String,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: theme.primaryColor != Colors.white
                              ? Colors.white
                              : const Color(0xff2D3748),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        company['description'] as String,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.primaryColor != Colors.white
                              ? Colors.white.withOpacity(0.7)
                              : const Color(0xff718096),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      // Insurance types count
                      Row(
                        children: [
                          Icon(
                            Icons.list_alt,
                            size: 14.sp,
                            color: company['color'] as Color,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            "${(company['types'] as List).length} Insurance Types",
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: company['color'] as Color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Arrow Icon
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: (company['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    size: 14.sp,
                    color: company['color'] as Color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
