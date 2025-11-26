import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:payfussion/core/theme/theme.dart';
import 'package:payfussion/presentations/home/paybill/postpaid_bill/postpaid_bill_form_screen.dart';

import '../../../../core/constants/fonts.dart';
import '../../../widgets/background_theme.dart';

class PostpaidBillScreen extends StatefulWidget {
  const PostpaidBillScreen({super.key});

  @override
  State<PostpaidBillScreen> createState() => _PostpaidBillScreenState();
}

class _PostpaidBillScreenState extends State<PostpaidBillScreen> with TickerProviderStateMixin {

  // Animation controllers
  late AnimationController _headerController;
  late AnimationController _listController;
  late AnimationController _backgroundAnimationController;
  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;
  late Animation<double> _listFade;

  final List<Map<String, dynamic>> postpaidProviders = <Map<String, dynamic>>[
    <String, dynamic>{
      "name": "Verizon Wireless",
      "description": "Premium postpaid plans with 5G",
      "icon": "assets/images/paybill/postpaid_bill/verizon.png",
      "color": MyTheme.primaryColor,
      "planType": "Unlimited Plans",
      "startingPrice": "\$70/month",
      "features": <String>["5G Ultra Wideband", "Premium Data", "Hotspot"],
    },
    <String, dynamic>{
      "name": "AT&T Mobility",
      "description": "Reliable nationwide coverage",
      "icon": "assets/images/paybill/postpaid_bill/at_t_mobility.png",
      "color": MyTheme.primaryColor,
      "planType": "Unlimited Plans",
      "startingPrice": "\$65/month",
      "features": <String>["5G Access", "HBO Max", "Mobile Hotspot"],
    },
    <String, dynamic>{
      "name": "T-Mobile US",
      "description": "Un-carrier benefits included",
      "icon": "assets/images/paybill/postpaid_bill/t_mobile.png",
      "color": MyTheme.primaryColor,
      "planType": "Magenta Plans",
      "startingPrice": "\$70/month",
      "features": <String>["5G Included", "Netflix", "International"],
    },
    <String, dynamic>{
      "name": "US Cellular",
      "description": "Rural coverage specialist",
      "icon": "assets/images/paybill/postpaid_bill/us_cellular.png",
      "color": MyTheme.primaryColor,
      "planType": "Unlimited Plans",
      "startingPrice": "\$60/month",
      "features": <String>["5G Access", "Roaming", "Family Plans"],
    },
    <String, dynamic>{
      "name": "Google Fi Wireless",
      "description": "Flexible data plans",
      "icon": "assets/images/paybill/postpaid_bill/google_fi_wireless.png",
      "color": MyTheme.primaryColor,
      "planType": "Flexible & Unlimited",
      "startingPrice": "\$50/month",
      "features": <String>["International", "Multi-network", "Data Only"],
    },
    <String, dynamic>{
      "name": "Visible",
      "description": "All-in-one unlimited plan",
      "icon": "assets/images/paybill/postpaid_bill/visible.png",
      "color": MyTheme.primaryColor,
      "planType": "Single Plan",
      "startingPrice": "\$40/month",
      "features": <String>["Unlimited Everything", "5G", "Party Pay"],
    },
    <String, dynamic>{
      "name": "Cricket Wireless",
      "description": "AT&T network coverage",
      "icon": "assets/images/paybill/postpaid_bill/cricket_wireless.png",
      "color": MyTheme.primaryColor,
      "planType": "Unlimited Plans",
      "startingPrice": "\$55/month",
      "features": <String>["AT&T 5G", "Unlimited Talk", "Mobile Hotspot"],
    },
    <String, dynamic>{
      "name": "Boost Mobile",
      "description": "Shrinking payments plan",
      "icon": "assets/images/paybill/postpaid_bill/boost_mobile.png",
      "color": MyTheme.primaryColor,
      "planType": "Shrinking Plans",
      "startingPrice": "\$50/month",
      "features": <String>["T-Mobile 5G", "Shrinks to \$25", "Unlimited"],
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
        ],
      ),
    );
  }

  Widget _buildPostpaidProvidersList(ThemeData theme) {
    return AnimationLimiter(
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        itemCount: postpaidProviders.length,
        itemBuilder: (BuildContext context, int index) {
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(5.r),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Theme.of(context).brightness == Brightness.light
                  ? Colors.grey.withOpacity(0.3)
                  : Colors.black.withOpacity(0.3),
              blurRadius: 5,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: InkWell(
          onTap: () {
            // Pass the actual provider data instead of hardcoded values
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => PostpaidBillFormScreen(
                  providerName: provider['name'] as String,
                  planType: provider['planType'] as String,
                  startingPrice: provider['startingPrice'] as String,
                  features: List<String>.from(provider['features'] as List),
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20.r),
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Row(
              children: <Widget>[
                // Icon Container
                Hero(
                  tag: 'mobile_icon_${provider['name']}',
                  child: CircleAvatar(
                    radius: 24.r,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: Image.asset(
                        provider['icon'] as String,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),

                SizedBox(width: 16.w),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // Provider name and price
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
                        children: <Widget>[
                          Icon(
                            Icons.featured_play_list,
                            size: 14.sp,
                          ),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: Text(
                              "${provider['planType']} • ${(provider['features'] as List).length} features",
                              style: Font.montserratFont(
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