import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:go_router/go_router.dart';
import 'package:payfussion/core/theme/theme.dart';

import '../../../core/constants/fonts.dart';
import '../../../core/constants/routes_name.dart';
import '../../widgets/background_theme.dart';

class InternetBillScreen extends StatefulWidget {
  const InternetBillScreen({super.key});

  @override
  State<InternetBillScreen> createState() => _InternetBillScreenState();
}

class _InternetBillScreenState extends State<InternetBillScreen>
    with TickerProviderStateMixin {

  // Animation controllers
  late AnimationController _headerController;
  late AnimationController _listController;
  late AnimationController _backgroundAnimationController;
  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;
  late Animation<double> _listFade;

  final List<Map<String, dynamic>> internetProviders = <Map<String, dynamic>>[
    <String, dynamic>{
      "name": "Xfinity (Comcast)",
      "description": "America's largest cable internet provider",
      "icon": Icons.router,
      "color": MyTheme.primaryColor,
      "connectionType": "Cable & Fiber",
      "maxSpeed": "Up to 1200 Mbps",
      "coverage": "40 states",
    },
    <String, dynamic>{
      "name": "AT&T Internet",
      "description": "Fiber and DSL internet services",
      "icon": Icons.fiber_smart_record,
      "color": MyTheme.primaryColor,
      "connectionType": "Fiber & DSL",
      "maxSpeed": "Up to 5000 Mbps",
      "coverage": "21 states",
    },
    <String, dynamic>{
      "name": "Verizon Fios",
      "description": "100% fiber-optic network",
      "icon": Icons.cable,
      "color": MyTheme.primaryColor,
      "connectionType": "Fiber",
      "maxSpeed": "Up to 940 Mbps",
      "coverage": "9 states",
    },
    <String, dynamic>{
      "name": "Spectrum (Charter Communications)",
      "description": "Cable internet without contracts",
      "icon": Icons.wifi_tethering,
      "color": MyTheme.primaryColor,
      "connectionType": "Cable",
      "maxSpeed": "Up to 940 Mbps",
      "coverage": "41 states",
    },
    <String, dynamic>{
      "name": "Cox Communications",
      "description": "Cable and fiber internet services",
      "icon": Icons.hub,
      "color": MyTheme.primaryColor,
      "connectionType": "Cable & Fiber",
      "maxSpeed": "Up to 940 Mbps",
      "coverage": "18 states",
    },
    <String, dynamic>{
      "name": "CenturyLink",
      "description": "DSL and fiber internet provider",
      "icon": Icons.device_hub,
      "color": MyTheme.primaryColor,
      "connectionType": "DSL & Fiber",
      "maxSpeed": "Up to 940 Mbps",
      "coverage": "36 states",
    },
    <String, dynamic>{
      "name": "Frontier Communications",
      "description": "Rural internet specialist",
      "icon": Icons.landscape,
      "color": MyTheme.primaryColor,
      "connectionType": "DSL & Fiber",
      "maxSpeed": "Up to 940 Mbps",
      "coverage": "25 states",
    },
    <String, dynamic>{
      "name": "Optimum (Altice USA)",
      "description": "Northeast cable internet provider",
      "icon": Icons.settings_ethernet,
      "color": MyTheme.primaryColor,
      "connectionType": "Cable",
      "maxSpeed": "Up to 940 Mbps",
      "coverage": "4 states",
    },
    <String, dynamic>{
      "name": "Windstream",
      "description": "Rural and business internet",
      "icon": Icons.air,
      "color": MyTheme.primaryColor,
      "connectionType": "DSL & Fiber",
      "maxSpeed": "Up to 1000 Mbps",
      "coverage": "18 states",
    },
    <String, dynamic>{
      "name": "HughesNet",
      "description": "Satellite internet nationwide",
      "icon": Icons.satellite_alt,
      "color": MyTheme.primaryColor,
      "connectionType": "Satellite",
      "maxSpeed": "Up to 25 Mbps",
      "coverage": "All 50 states",
    },
    <String, dynamic>{
      "name": "Viasat",
      "description": "High-speed satellite internet",
      "icon": Icons.satellite,
      "color": MyTheme.primaryColor,
      "connectionType": "Satellite",
      "maxSpeed": "Up to 100 Mbps",
      "coverage": "All 50 states",
    },
    <String, dynamic>{
      "name": "Google Fiber",
      "description": "Ultra-fast fiber internet",
      "icon": Icons.flash_on,
      "color": MyTheme.primaryColor,
      "connectionType": "Fiber",
      "maxSpeed": "Up to 2000 Mbps",
      "coverage": "17 cities",
    },
    <String, dynamic>{
      "name": "RCN",
      "description": "Regional cable internet provider",
      "icon": Icons.wifi,
      "color": MyTheme.primaryColor,
      "connectionType": "Cable",
      "maxSpeed": "Up to 940 Mbps",
      "coverage": "6 states",
    },
    <String, dynamic>{
      "name": "Mediacom",
      "description": "Midwest cable internet provider",
      "icon": Icons.cast_connected,
      "color": MyTheme.primaryColor,
      "connectionType": "Cable",
      "maxSpeed": "Up to 1000 Mbps",
      "coverage": "22 states",
    },
    <String, dynamic>{
      "name": "Suddenlink",
      "description": "Regional cable internet service",
      "icon": Icons.link,
      "color": MyTheme.primaryColor,
      "connectionType": "Cable",
      "maxSpeed": "Up to 940 Mbps",
      "coverage": "16 states",
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
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: FadeTransition(
          opacity: _headerFade,
          child: SlideTransition(
            position: _headerSlide,
            child: Text(
              "Internet Bill",
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.primaryColor != Colors.white
                    ? Colors.white
                    : const Color(0xff2D3748),
              ),
            ),
          ),
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
                        "Pay Your",
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w300,
                          color: theme.primaryColor != Colors.white ? Colors.white.withOpacity(0.8) : const Color(0xff718096),
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        "Internet Bill",
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.primaryColor != Colors.white
                              ? Colors.white
                              : const Color(0xff2D3748),
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        "Select your internet provider for instant bill payment",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.primaryColor != Colors.white
                              ? Colors.white.withOpacity(0.7)
                              : const Color(0xff718096),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                // Internet Providers List
                Expanded(
                  child: _buildInternetProvidersList(theme),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInternetProvidersList(ThemeData theme) {
    return AnimationLimiter(
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        itemCount: internetProviders.length,
        itemBuilder: (BuildContext context, int index) {
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 400),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: _buildProviderCard(
                  internetProviders[index],
                  theme,
                  index,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProviderCard(Map<String, dynamic> provider, ThemeData theme, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 5),
      child: Container(
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
            context.push(
              RouteNames.payBillsDetailView,
              extra: <String, dynamic>{
                'billType': "internetBill",
                'companyName': provider['name'],
                'connectionType': provider['connectionType'],
                'maxSpeed': provider['maxSpeed'],
                'coverage': provider['coverage'],
              },
            );
          },
          borderRadius: BorderRadius.circular(20.r),
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Row(
              children: <Widget>[
                // Icon Container
                Hero(
                  tag: 'internet_icon_${provider['name']}',
                  child: Icon(
                    provider['icon'] as IconData,
                    size: 28.sp,
                    color: provider['color'] as Color,
                  ),
                ),

                SizedBox(width: 16.w),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // Provider name and connection type
                      Row(
                        children: <Widget>[
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
                          // Connection type badge
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: MyTheme.primaryColor,
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Text(
                              provider['connectionType'] as String,
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
                        provider['description'] as String,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.primaryColor != Colors.white
                              ? Colors.white.withOpacity(0.7)
                              : const Color(0xff718096),
                        ),
                      ),

                      SizedBox(height: 8.h),

                      // Speed and coverage info
                      Row(
                        children: <Widget>[
                          Icon(
                            Icons.speed,
                            size: 14.sp,
                          ),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: Text(
                              "${provider['maxSpeed']} • ${provider['coverage']}",
                              style: Font.montserratFont(
                                fontSize: 10,
                              ),
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
        ),
      ),
    );
  }
}