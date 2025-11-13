import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:go_router/go_router.dart';
import 'package:payfussion/core/theme/theme.dart';
import '../../../core/constants/routes_name.dart';
import '../../widgets/background_theme.dart';

class ElectricCityBillScreen extends StatefulWidget {
  const ElectricCityBillScreen({super.key});

  @override
  State<ElectricCityBillScreen> createState() => _ElectricCityBillScreenState();
}

class _ElectricCityBillScreenState extends State<ElectricCityBillScreen>
    with TickerProviderStateMixin {

  // Animation controllers
  late AnimationController _headerController;
  late AnimationController _listController;
  late AnimationController _backgroundAnimationController;
  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;
  late Animation<double> _listFade;

  final List<Map<String, dynamic>> electricityProviders = <Map<String, dynamic>>[
    <String, dynamic>{
      "name": "Pacific Gas & Electric (PG&E)",
      "description": "California's largest utility provider",
      "icon": Icons.flash_on,
      "color": MyTheme.primaryColor,
      "region": "California",
      "averageRate": "\$0.28/kWh",
      "customers": "16M+",
    },
    <String, dynamic>{
      "name": "Southern California Edison (SCE)",
      "description": "Serving Southern California communities",
      "icon": Icons.electrical_services,
      "color": MyTheme.primaryColor,
      "region": "Southern California",
      "averageRate": "\$0.25/kWh",
      "customers": "15M+",
    },
    <String, dynamic>{
      "name": "Con Edison (ConEd)",
      "description": "New York's primary energy provider",
      "icon": Icons.power,
      "color": MyTheme.primaryColor,
      "region": "New York",
      "averageRate": "\$0.22/kWh",
      "customers": "10M+",
    },
    <String, dynamic>{
      "name": "Florida Power & Light (FPL)",
      "description": "Florida's largest electric utility",
      "icon": Icons.wb_sunny,
      "color": MyTheme.primaryColor,
      "region": "Florida",
      "averageRate": "\$0.12/kWh",
      "customers": "5.7M+",
    },
    <String, dynamic>{
      "name": "Duke Energy",
      "description": "Multi-state energy corporation",
      "icon": Icons.business,
      "color": MyTheme.primaryColor,
      "region": "Southeast US",
      "averageRate": "\$0.11/kWh",
      "customers": "8.2M+",
    },
    <String, dynamic>{
      "name": "Commonwealth Edison (ComEd)",
      "description": "Northern Illinois electric utility",
      "icon": Icons.location_city,
      "color": MyTheme.primaryColor,
      "region": "Illinois",
      "averageRate": "\$0.13/kWh",
      "customers": "4M+",
    },
    <String, dynamic>{
      "name": "National Grid",
      "description": "Northeast electricity & gas utility",
      "icon": Icons.grid_on,
      "color": MyTheme.primaryColor,
      "region": "Northeast US",
      "averageRate": "\$0.20/kWh",
      "customers": "3.3M+",
    },
    <String, dynamic>{
      "name": "Xcel Energy",
      "description": "Multi-state utility company",
      "icon": Icons.wind_power,
      "color": MyTheme.primaryColor,
      "region": "Midwest US",
      "averageRate": "\$0.12/kWh",
      "customers": "3.7M+",
    },
    <String, dynamic>{
      "name": "PPL Electric Utilities",
      "description": "Pennsylvania electric utility",
      "icon": Icons.energy_savings_leaf,
      "color": MyTheme.primaryColor,
      "region": "Pennsylvania",
      "averageRate": "\$0.14/kWh",
      "customers": "1.4M+",
    },
    <String, dynamic>{
      "name": "Entergy",
      "description": "Southern US energy provider",
      "icon": Icons.eco,
      "color": MyTheme.primaryColor,
      "region": "Southern US",
      "averageRate": "\$0.10/kWh",
      "customers": "3M+",
    },
    <String, dynamic>{
      "name": "Eversource Energy",
      "description": "New England's largest utility",
      "icon": Icons.cottage,
      "color": MyTheme.primaryColor,
      "region": "New England",
      "averageRate": "\$0.23/kWh",
      "customers": "4.3M+",
    },
    <String, dynamic>{
      "name": "OG&E (Oklahoma Gas & Electric)",
      "description": "Oklahoma's primary utility",
      "icon": Icons.local_gas_station,
      "color": MyTheme.primaryColor,
      "region": "Oklahoma",
      "averageRate": "\$0.11/kWh",
      "customers": "900K+",
    },
    <String, dynamic>{
      "name": "Evergy",
      "description": "Kansas & Missouri energy provider",
      "icon": Icons.wb_incandescent,
      "color": MyTheme.primaryColor,
      "region": "Kansas & Missouri",
      "averageRate": "\$0.13/kWh",
      "customers": "1.7M+",
    },
    <String, dynamic>{
      "name": "Oncor",
      "description": "Texas electric delivery company",
      "icon": Icons.electrical_services,
      "color": MyTheme.primaryColor,
      "region": "Texas",
      "averageRate": "\$0.12/kWh",
      "customers": "10M+",
    },
    <String, dynamic>{
      "name": "Avista Utilities",
      "description": "Pacific Northwest utility",
      "icon": Icons.water_drop,
      "color": MyTheme.primaryColor,
      "region": "Pacific Northwest",
      "averageRate": "\$0.10/kWh",
      "customers": "430K+",
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
              "Electricity Bill",
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.primaryColor != Colors.white ? Colors.white : const Color(0xff2D3748),
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
                        "Electricity Bill",
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.primaryColor != Colors.white ? Colors.white : const Color(0xff2D3748),
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        "Select your electricity provider to pay bills instantly",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.primaryColor != Colors.white ? Colors.white.withOpacity(0.7) : const Color(0xff718096),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                // Electricity Providers List
                Expanded(
                  child: _buildElectricityProvidersList(theme),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildElectricityProvidersList(ThemeData theme) {
    return AnimationLimiter(
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        itemCount: electricityProviders.length,
        itemBuilder: (BuildContext context, int index) {
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 400),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: _buildProviderCard(
                  electricityProviders[index],
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
                'billType': "electricity",
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
                  tag: 'electricity_icon_${provider['name']}',
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
                                fontSize: 14,
                                color: theme.primaryColor != Colors.white ? Colors.white : const Color(0xff2D3748),
                              ),
                            ),
                          ),

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
                          color: theme.primaryColor != Colors.white ? Colors.white.withOpacity(0.7) : const Color(0xff718096),
                        ),
                      ),

                      SizedBox(height: 8.h),

                      /// Region and customers info
                      Row(
                        children: <Widget>[
                          Icon(
                            Icons.location_on,
                            size: 14.sp,
                          ),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: Text(
                              "${provider['region']} • ${provider['customers']} customers",
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: Colors.white,
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