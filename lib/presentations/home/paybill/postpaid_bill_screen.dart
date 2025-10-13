import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:go_router/go_router.dart';
import 'package:payfussion/core/theme/theme.dart';

import '../../../core/constants/routes_name.dart';

class PostpaidBillScreen extends StatefulWidget {
  const PostpaidBillScreen({super.key});

  @override
  State<PostpaidBillScreen> createState() => _PostpaidBillScreenState();
}

class _PostpaidBillScreenState extends State<PostpaidBillScreen>
    with TickerProviderStateMixin {

  // Animation controllers
  late AnimationController _headerController;
  late AnimationController _listController;

  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;
  late Animation<double> _listFade;

  final List<Map<String, dynamic>> postpaidProviders = [
    {
      "name": "Verizon Wireless",
      "description": "Premium postpaid plans with 5G",
      "icon": Icons.signal_cellular_4_bar,
      "color": MyTheme.primaryColor,
      "planType": "Unlimited Plans",
      "startingPrice": "\$70/month",
      "features": ["5G Ultra Wideband", "Premium Data", "Hotspot"],
    },
    {
      "name": "AT&T Mobility",
      "description": "Reliable nationwide coverage",
      "icon": Icons.wifi_tethering,
      "color": MyTheme.primaryColor,
      "planType": "Unlimited Plans",
      "startingPrice": "\$65/month",
      "features": ["5G Access", "HBO Max", "Mobile Hotspot"],
    },
    {
      "name": "T-Mobile US",
      "description": "Un-carrier benefits included",
      "icon": Icons.cell_tower,
      "color": MyTheme.primaryColor,
      "planType": "Magenta Plans",
      "startingPrice": "\$70/month",
      "features": ["5G Included", "Netflix", "International"],
    },
    {
      "name": "US Cellular",
      "description": "Rural coverage specialist",
      "icon": Icons.landscape,
      "color": MyTheme.primaryColor,
      "planType": "Unlimited Plans",
      "startingPrice": "\$60/month",
      "features": ["5G Access", "Roaming", "Family Plans"],
    },
    {
      "name": "Google Fi Wireless",
      "description": "Flexible data plans",
      "icon": Icons.cloud,
      "color": MyTheme.primaryColor,
      "planType": "Flexible & Unlimited",
      "startingPrice": "\$50/month",
      "features": ["International", "Multi-network", "Data Only"],
    },
    {
      "name": "Visible",
      "description": "All-in-one unlimited plan",
      "icon": Icons.visibility,
      "color": MyTheme.primaryColor,
      "planType": "Single Plan",
      "startingPrice": "\$40/month",
      "features": ["Unlimited Everything", "5G", "Party Pay"],
    },
    {
      "name": "Cricket Wireless",
      "description": "AT&T network coverage",
      "icon": Icons.sports_cricket,
      "color": MyTheme.primaryColor,
      "planType": "Unlimited Plans",
      "startingPrice": "\$55/month",
      "features": ["AT&T 5G", "Unlimited Talk", "Mobile Hotspot"],
    },
    {
      "name": "Boost Mobile",
      "description": "Shrinking payments plan",
      "icon": Icons.rocket_launch,
      "color": MyTheme.primaryColor,
      "planType": "Shrinking Plans",
      "startingPrice": "\$50/month",
      "features": ["T-Mobile 5G", "Shrinks to \$25", "Unlimited"],
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
              "Postpaid Bill",
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
                    "Pay Your",
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w300,
                      color: theme.primaryColor != Colors.white ? Colors.white.withOpacity(0.8) : const Color(0xff718096),
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    "Postpaid Bill",
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor != Colors.white ? Colors.white : const Color(0xff2D3748),
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    "Select your carrier to pay monthly postpaid bills",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.primaryColor != Colors.white ? Colors.white.withOpacity(0.7) : const Color(0xff718096),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // Postpaid Providers List
            Expanded(
              child: _buildPostpaidProvidersList(theme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostpaidProvidersList(ThemeData theme) {
    return AnimationLimiter(
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        itemCount: postpaidProviders.length,
        itemBuilder: (context, index) {
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 400),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: _buildProviderCard(
                  postpaidProviders[index],
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
          boxShadow: [
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
              extra: {
                'billType': "postpaidBill",
                'companyName': provider['name'],
                'planType': provider['planType'],
                'startingPrice': provider['startingPrice'],
                'features': provider['features'],
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
                  tag: 'postpaid_icon_${provider['name']}',
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
                    children: [
                      // Provider name and price
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
                          // Price badge
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: MyTheme.primaryColor,
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Text(
                              provider['startingPrice'] as String,
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

                      // Plan type and features
                      Row(
                        children: [
                          Icon(
                            Icons.featured_play_list,
                            size: 14.sp,
                          ),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: Text(
                              "${provider['planType']} • ${(provider['features'] as List).length} features",
                              style: const TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 12,
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