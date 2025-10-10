import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:go_router/go_router.dart';
import 'package:payfussion/core/theme/theme.dart';

import '../../../core/constants/routes_name.dart';

class MobileRechargeScreen extends StatefulWidget {
  const MobileRechargeScreen({super.key});

  @override
  State<MobileRechargeScreen> createState() => _MobileRechargeScreenState();
}

class _MobileRechargeScreenState extends State<MobileRechargeScreen>
    with TickerProviderStateMixin {

  // Animation controllers
  late AnimationController _headerController;
  late AnimationController _listController;

  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;
  late Animation<double> _listFade;

  final List<Map<String, dynamic>> mobileCarriers = [
    {
      "name": "Verizon Wireless",
      "description": "America's most reliable network",
      "icon": Icons.signal_cellular_4_bar,
      "color": Colors.white,
      "network": "5G Nationwide",
      "customers": "94M+",
      "coverage": "99% Population",
    },
    {
      "name": "AT&T Mobility",
      "description": "Connect to your world",
      "icon": Icons.wifi_tethering,
      "color": Colors.white,
      "network": "5G+",
      "customers": "80M+",
      "coverage": "99% Population",
    },
    {
      "name": "T-Mobile US",
      "description": "The Un-carrier",
      "icon": Icons.cell_tower,
      "color": Colors.white,
      "network": "5G Ultra Capacity",
      "customers": "109M+",
      "coverage": "98% Population",
    },
    {
      "name": "Metro by T-Mobile",
      "description": "Prepaid wireless service",
      "icon": Icons.smartphone,
      "color": Colors.white,
      "network": "T-Mobile 5G",
      "customers": "20M+",
      "coverage": "98% Population",
    },
    {
      "name": "Cricket Wireless",
      "description": "AT&T network coverage",
      "icon": Icons.sports_cricket,
      "color": Colors.white,
      "network": "AT&T 5G",
      "customers": "10M+",
      "coverage": "99% Population",
    },
    {
      "name": "Boost Mobile",
      "description": "Where you at?",
      "icon": Icons.rocket_launch,
      "color": Colors.white,
      "network": "T-Mobile 5G",
      "customers": "8M+",
      "coverage": "98% Population",
    },
    {
      "name": "Mint Mobile",
      "description": "Premium wireless for less",
      "icon": Icons.eco,
      "color": Colors.white,
      "network": "T-Mobile 5G",
      "customers": "5M+",
      "coverage": "98% Population",
    },
    {
      "name": "Google Fi Wireless",
      "description": "Flexible wireless service",
      "icon": Icons.cloud,
      "color": Colors.white,
      "network": "Multi-carrier",
      "customers": "2M+",
      "coverage": "Multi-network",
    },
    {
      "name": "Straight Talk Wireless",
      "description": "No contract wireless",
      "icon": Icons.straighten,
      "color": Colors.white,
      "network": "Verizon 5G",
      "customers": "25M+",
      "coverage": "99% Population",
    },
    {
      "name": "TracFone Wireless",
      "description": "America's #1 prepaid wireless",
      "icon": Icons.track_changes,
      "color": Colors.white,
      "network": "Multi-carrier",
      "customers": "21M+",
      "coverage": "Multi-network",
    },
    {
      "name": "US Mobile",
      "description": "Built for you",
      "icon": Icons.flag,
      "color": Colors.white,
      "network": "Verizon/T-Mobile",
      "customers": "1M+",
      "coverage": "Multi-network",
    },
    {
      "name": "Visible",
      "description": "Wireless that gets better",
      "icon": Icons.visibility,
      "color": Colors.white,
      "network": "Verizon 5G",
      "customers": "3M+",
      "coverage": "99% Population",
    },
    {
      "name": "Ultra Mobile",
      "description": "International calling plans",
      "icon": Icons.public,
      "color": Colors.white,
      "network": "T-Mobile 5G",
      "customers": "2M+",
      "coverage": "98% Population",
    },
    {
      "name": "Lycamobile USA",
      "description": "World in your hands",
      "icon": Icons.language,
      "color": Colors.white,
      "network": "T-Mobile",
      "customers": "1.5M+",
      "coverage": "98% Population",
    },
    {
      "name": "H2O Wireless",
      "description": "Affordable wireless plans",
      "icon": Icons.water_drop,
      "color": Colors.white,
      "network": "AT&T",
      "customers": "1M+",
      "coverage": "99% Population",
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
              "Mobile Recharge",
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
                    "Recharge Your",
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w300,
                      color: theme.primaryColor != Colors.white
                          ? Colors.white.withOpacity(0.8)
                          : const Color(0xff718096),
                    ),
                  ),
                  Text(
                    "Mobile Phone",
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor != Colors.white
                          ? Colors.white
                          : const Color(0xff2D3748),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    "Select your carrier for instant mobile recharge",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.primaryColor != Colors.white
                          ? Colors.white.withOpacity(0.7)
                          : const Color(0xff718096),
                    ),
                  ),
                ],
              ),
            ),

            // Mobile Carriers List
            Expanded(
              child: _buildMobileCarriersList(theme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileCarriersList(ThemeData theme) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: AnimationLimiter(
        child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: mobileCarriers.length,
          itemBuilder: (context, index) {
            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 400),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: _buildCarrierCard(
                    mobileCarriers[index],
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

  Widget _buildCarrierCard(Map<String, dynamic> carrier, ThemeData theme, int index) {
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
                'billType': "mobileRecharge",
                'companyName': carrier['name'],
                'network': carrier['network'],
                'customers': carrier['customers'],
                'coverage': carrier['coverage'],
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
                  tag: 'mobile_icon_${carrier['name']}',
                  child: Container(
                    height: 65.h,
                    width: 65.w,
                    decoration: BoxDecoration(
                      color: MyTheme.primaryColor,
                      borderRadius: BorderRadius.circular(18.r),
                      border: Border.all(
                        color: (carrier['color'] as Color).withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      carrier['icon'] as IconData,
                      size: 28.sp,
                      color: carrier['color'] as Color,
                    ),
                  ),
                ),

                SizedBox(width: 16.w),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Carrier name and network
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              carrier['name'] as String,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: theme.primaryColor != Colors.white
                                    ? Colors.white
                                    : const Color(0xff2D3748),
                              ),
                            ),
                          ),
                          // Network badge
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: MyTheme.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Text(
                              carrier['network'] as String,
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 10.sp,
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 4.h),

                      Text(
                        carrier['description'] as String,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.primaryColor != Colors.white
                              ? Colors.white.withOpacity(0.7)
                              : const Color(0xff718096),
                        ),
                      ),

                      SizedBox(height: 8.h),

                      // Customers and coverage info
                      Row(
                        children: [
                          Icon(
                            Icons.people,
                            size: 14.sp,
                          ),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: Text(
                              "${carrier['customers']} • ${carrier['coverage']}",
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
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