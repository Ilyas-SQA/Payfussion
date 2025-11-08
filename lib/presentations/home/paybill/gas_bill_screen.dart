import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:go_router/go_router.dart';
import 'package:payfussion/core/theme/theme.dart';

import '../../../core/constants/fonts.dart';
import '../../../core/constants/routes_name.dart';
import '../../widgets/background_theme.dart';

class GasBillScreen extends StatefulWidget {
  const GasBillScreen({super.key});

  @override
  State<GasBillScreen> createState() => _GasBillScreenState();
}

class _GasBillScreenState extends State<GasBillScreen>
    with TickerProviderStateMixin {

  // Animation controllers
  late AnimationController _headerController;
  late AnimationController _listController;
  late AnimationController _backgroundAnimationController;
  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;
  late Animation<double> _listFade;

  final List<Map<String, dynamic>> gasProviders = <Map<String, dynamic>>[
    <String, dynamic>{
      "name": "PG&E (Pacific Gas & Electric)",
      "description": "California's largest gas & electric utility",
      "icon": Icons.local_gas_station,
      "color": MyTheme.primaryColor,
      "region": "Northern California",
      "averageRate": "\$1.15/therm",
      "customers": "16M+",
    },
    <String, dynamic>{
      "name": "Southern California Gas Company (SoCalGas)",
      "description": "Largest natural gas utility in US",
      "icon": Icons.whatshot,
      "color": MyTheme.primaryColor,
      "region": "Southern California",
      "averageRate": "\$1.20/therm",
      "customers": "22M+",
    },
    <String, dynamic>{
      "name": "Con Edison",
      "description": "New York's primary gas utility",
      "icon": Icons.fireplace,
      "color": MyTheme.primaryColor,
      "region": "New York",
      "averageRate": "\$1.35/therm",
      "customers": "1.2M+",
    },
    <String, dynamic>{
      "name": "Dominion Energy",
      "description": "Multi-state energy provider",
      "icon": Icons.factory,
      "color": MyTheme.primaryColor,
      "region": "Virginia & Ohio",
      "averageRate": "\$1.05/therm",
      "customers": "2.5M+",
    },
    <String, dynamic>{
      "name": "National Grid",
      "description": "Northeast gas & electric utility",
      "icon": Icons.grid_on,
      "color": MyTheme.primaryColor,
      "region": "Northeast US",
      "averageRate": "\$1.28/therm",
      "customers": "3.4M+",
    },
    <String, dynamic>{
      "name": "Atmos Energy",
      "description": "Nation's largest gas-only distributor",
      "icon": Icons.cloud,
      "color": MyTheme.primaryColor,
      "region": "Texas & Midwest",
      "averageRate": "\$0.95/therm",
      "customers": "3.2M+",
    },
    <String, dynamic>{
      "name": "CenterPoint Energy",
      "description": "Texas & Minnesota gas provider",
      "icon": Icons.center_focus_strong,
      "color": MyTheme.primaryColor,
      "region": "Texas & Minnesota",
      "averageRate": "\$1.08/therm",
      "customers": "7M+",
    },
    <String, dynamic>{
      "name": "Xcel Energy",
      "description": "Multi-state utility company",
      "icon": Icons.wind_power,
      "color": MyTheme.primaryColor,
      "region": "Midwest US",
      "averageRate": "\$1.02/therm",
      "customers": "3.7M+",
    },
    <String, dynamic>{
      "name": "Duke Energy",
      "description": "Southeast energy corporation",
      "icon": Icons.business,
      "color": MyTheme.primaryColor,
      "region": "Southeast US",
      "averageRate": "\$1.12/therm",
      "customers": "1.6M+",
    },
    <String, dynamic>{
      "name": "NiSource (Columbia Gas)",
      "description": "Midwest natural gas distributor",
      "icon": Icons.propane_tank,
      "color": MyTheme.primaryColor,
      "region": "Midwest US",
      "averageRate": "\$1.18/therm",
      "customers": "3.5M+",
    },
    <String, dynamic>{
      "name": "PPL Gas Utilities",
      "description": "Pennsylvania gas services",
      "icon": Icons.energy_savings_leaf,
      "color": MyTheme.primaryColor,
      "region": "Pennsylvania",
      "averageRate": "\$1.22/therm",
      "customers": "350K+",
    },
    <String, dynamic>{
      "name": "Eversource Energy",
      "description": "New England's gas utility",
      "icon": Icons.cottage,
      "color": MyTheme.primaryColor,
      "region": "New England",
      "averageRate": "\$1.32/therm",
      "customers": "1.3M+",
    },
    <String, dynamic>{
      "name": "Washington Gas",
      "description": "DC metro area gas provider",
      "icon": Icons.account_balance,
      "color": MyTheme.primaryColor,
      "region": "DC Metro",
      "averageRate": "\$1.24/therm",
      "customers": "1.2M+",
    },
    <String, dynamic>{
      "name": "AVISTA Utilities",
      "description": "Pacific Northwest gas utility",
      "icon": Icons.water_drop,
      "color": MyTheme.primaryColor,
      "region": "Pacific Northwest",
      "averageRate": "\$1.08/therm",
      "customers": "370K+",
    },
    <String, dynamic>{
      "name": "Vectren (CenterPoint Energy)",
      "description": "Indiana & Ohio gas services",
      "icon": Icons.science,
      "color": MyTheme.primaryColor,
      "region": "Indiana & Ohio",
      "averageRate": "\$1.14/therm",
      "customers": "1M+",
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
              "Gas Bill Payment",
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
                        "Natural Gas Bill",
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.primaryColor != Colors.white ? Colors.white : const Color(0xff2D3748),
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        "Select your gas utility provider for instant bill payment",
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

                // Gas Providers List
                Expanded(
                  child: _buildGasProvidersList(theme),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGasProvidersList(ThemeData theme) {
    return AnimationLimiter(
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        itemCount: gasProviders.length,
        itemBuilder: (BuildContext context, int index) {
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 400),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: _buildProviderCard(
                  gasProviders[index],
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
                'billType': "gasBill",
                'companyName': provider['name'],
                'region': provider['region'],
                'averageRate': provider['averageRate'],
                'customers': provider['customers'],
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
                  tag: 'gas_icon_${provider['name']}',
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
                      // Provider name and rate
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
                          // Rate badge
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: MyTheme.primaryColor,
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Text(
                              provider['averageRate'] as String,
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.w600,
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

                      // Region and customers info
                      Row(
                        children: <Widget>[
                          Icon(
                            Icons.location_on,
                            size: 14.sp,
                            color: provider['color'] as Color,
                          ),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: Text(
                              "${provider['region']} • ${provider['customers']} customers",
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