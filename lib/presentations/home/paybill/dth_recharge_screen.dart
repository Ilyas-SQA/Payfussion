import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:go_router/go_router.dart';
import 'package:payfussion/core/theme/theme.dart';

import '../../../core/constants/routes_name.dart';

class DTHRechargeScreen extends StatefulWidget {
  const DTHRechargeScreen({super.key});

  @override
  State<DTHRechargeScreen> createState() => _DTHRechargeScreenState();
}

class _DTHRechargeScreenState extends State<DTHRechargeScreen>
    with TickerProviderStateMixin {

  // Animation controllers
  late AnimationController _headerController;
  late AnimationController _listController;

  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;
  late Animation<double> _listFade;

  final List<Map<String, dynamic>> dthProviders = [
    {
      "name": "DISH Network",
      "description": "America's top-rated TV provider",
      "icon": Icons.satellite_alt,
      "color": Colors.white,
      "color": Colors.white,
      "plans": ["Basic HD - \$60/month", "Top 200 - \$85/month", "Top 250 - \$95/month"],
      "rating": 4.2,
    },
    {
      "name": "DIRECTV (AT&T)",
      "description": "Premium entertainment experience",
      "icon": Icons.settings_input_antenna,
      "color": Colors.white,
      "color": Colors.white,
      "plans": ["Entertainment - \$70/month", "Choice - \$90/month", "Ultimate - \$105/month"],
      "rating": 4.0,
    },
    {
      "name": "Sky Angel",
      "description": "Family-friendly programming",
      "icon": Icons.family_restroom,
      "color": Colors.white,
      "color": Colors.white,
      "plans": ["Family Pack - \$25/month", "Premium Pack - \$40/month"],
      "rating": 3.8,
    },
    {
      "name": "C band Satellite Providers",
      "description": "Professional satellite solutions",
      "icon": Icons.radar,
      "color": Colors.white,
      "plans": ["Basic Package - \$45/month", "Professional - \$80/month"],
      "rating": 3.5,
    },
    {
      "name": "Viasat Satellite TV",
      "description": "Bundled internet & TV services",
      "icon": Icons.wifi_tethering,
      "color": Colors.white,
      "plans": ["TV + Internet Bundle - \$120/month", "Premium Bundle - \$150/month"],
      "rating": 3.9,
    },
    {
      "name": "Bell TV",
      "description": "Cross-border satellite service",
      "icon": Icons.public,
      "color": Colors.white,
      "plans": ["Basic Plan - \$55/month", "Premium Plan - \$75/month"],
      "rating": 3.7,
    },
    {
      "name": "HughesNet TV Bundles",
      "description": "Satellite internet with TV",
      "icon": Icons.router,
      "color": Colors.white,
      "plans": ["Bundle 50GB - \$100/month", "Bundle 100GB - \$130/month"],
      "rating": 3.6,
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
              "DTH Recharge",
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
                    "DTH Provider",
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor != Colors.white
                          ? Colors.white
                          : const Color(0xff2D3748),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    "Recharge your digital TV subscription instantly",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.primaryColor != Colors.white
                          ? Colors.white.withOpacity(0.7)
                          : const Color(0xff718096),
                    ),
                  ),
                ],
              ),
            ),

            // DTH Providers List
            Expanded(
              child: _buildDTHProvidersList(theme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDTHProvidersList(ThemeData theme) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: AnimationLimiter(
        child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: dthProviders.length,
          itemBuilder: (context, index) {
            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 400),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: _buildProviderCard(
                    dthProviders[index],
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

  Widget _buildProviderCard(Map<String, dynamic> provider, ThemeData theme, int index) {
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
            context.push(
              RouteNames.payBillsDetailView,
              extra: {
                'billType': "dthRecharge",
                'companyName': provider['name'],
                'plans': provider['plans'],
                'rating': provider['rating'],
              },
            );
          },
          borderRadius: BorderRadius.circular(20.r),
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Row(
              children: [
                // Icon Container
                Hero(
                  tag: 'dth_icon_${provider['name']}',
                  child: Container(
                    height: 65.h,
                    width: 65.w,
                    decoration: BoxDecoration(
                      color: MyTheme.primaryColor,
                      borderRadius: BorderRadius.circular(18.r),
                      border: Border.all(
                        color: (provider['color'] as Color).withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      provider['icon'] as IconData,
                      size: 28.sp,
                      color: provider['color'] as Color,
                    ),
                  ),
                ),

                SizedBox(width: 16.w),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Provider name and rating
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              provider['name'] as String,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: theme.primaryColor != Colors.white
                                    ? Colors.white
                                    : const Color(0xff2D3748),
                              ),
                            ),
                          ),
                          // Rating
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: MyTheme.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.star,
                                  size: 12.sp,
                                ),
                                SizedBox(width: 2.w),
                                Text(
                                  provider['rating'].toString(),
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 4.h),

                      Text(
                        provider['description'] as String,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.primaryColor != Colors.white ? Colors.white.withOpacity(0.7) : const Color(0xff718096),
                        ),
                      ),

                      SizedBox(height: 8.h),

                      // Plans count
                      Row(
                        children: [
                          Icon(
                            Icons.tv,
                            size: 14.sp,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            "${(provider['plans'] as List).length} Available Plans",
                            style: theme.textTheme.labelSmall?.copyWith(
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
                    color: MyTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    size: 14.sp,
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