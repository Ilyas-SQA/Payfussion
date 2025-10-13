import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:go_router/go_router.dart';
import 'package:payfussion/core/theme/theme.dart';

import '../../../core/constants/routes_name.dart';

class RentPaymentScreen extends StatefulWidget {
  const RentPaymentScreen({super.key});

  @override
  State<RentPaymentScreen> createState() => _RentPaymentScreenState();
}

class _RentPaymentScreenState extends State<RentPaymentScreen>
    with TickerProviderStateMixin {

  // Animation controllers
  late AnimationController _headerController;
  late AnimationController _listController;

  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;
  late Animation<double> _listFade;

  final List<Map<String, dynamic>> rentServices = [
    {
      "name": "Airbnb",
      "description": "Short-term rental marketplace",
      "icon": Icons.apartment,
      "color": MyTheme.primaryColor,
      "category": "Vacation Rentals",
      "feeRange": "3% host fee",
      "properties": "6M+ listings",
    },
    {
      "name": "Vrbo",
      "description": "Vacation rental by owner",
      "icon": Icons.holiday_village,
      "color": MyTheme.primaryColor,
      "category": "Vacation Rentals",
      "feeRange": "5-10% host fee",
      "properties": "2M+ properties",
    },
    {
      "name": "Zillow Rentals",
      "description": "Long-term rental marketplace",
      "icon": Icons.home_work,
      "color": MyTheme.primaryColor,
      "category": "Long-term Rentals",
      "feeRange": "No listing fees",
      "properties": "1M+ rentals",
    },
    {
      "name": "Apartments.com",
      "description": "Apartment search platform",
      "icon": Icons.location_city,
      "color": MyTheme.primaryColor,
      "category": "Apartments",
      "feeRange": "Free for renters",
      "properties": "1M+ apartments",
    },
    {
      "name": "Realtor.com Rentals",
      "description": "Professional rental listings",
      "icon": Icons.business,
      "color": MyTheme.primaryColor,
      "category": "Professional Rentals",
      "feeRange": "Varies by agent",
      "properties": "800K+ listings",
    },
    {
      "name": "Trulia Rentals",
      "description": "Neighborhood-focused rentals",
      "icon": Icons.maps_home_work,
      "color": MyTheme.primaryColor,
      "category": "Neighborhood Rentals",
      "feeRange": "Free for renters",
      "properties": "600K+ rentals",
    },
    {
      "name": "Furnished Finder",
      "description": "Furnished rental specialists",
      "icon": Icons.chair,
      "color": MyTheme.primaryColor,
      "category": "Furnished Rentals",
      "feeRange": "Premium listings",
      "properties": "200K+ furnished",
    },
    {
      "name": "HotPads",
      "description": "Map-based rental search",
      "icon": Icons.map,
      "color": MyTheme.primaryColor,
      "category": "Map-based Search",
      "feeRange": "Free platform",
      "properties": "1M+ listings",
    },
    {
      "name": "Rent.com",
      "description": "Full-service rental platform",
      "icon": Icons.key,
      "color": MyTheme.primaryColor,
      "category": "Full-service",
      "feeRange": "Service fees apply",
      "properties": "750K+ rentals",
    },
    {
      "name": "Cozy",
      "description": "Property management platform",
      "icon": Icons.dashboard,
      "color": MyTheme.primaryColor,
      "category": "Property Management",
      "feeRange": "2.75% payment fee",
      "properties": "500K+ properties",
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
              "Rent Payment",
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
                    "Rent & Housing",
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
                    "Choose your rental platform for secure payments",
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

            // Rent Services List
            Expanded(
              child: _buildRentServicesList(theme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRentServicesList(ThemeData theme) {
    return AnimationLimiter(
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        itemCount: rentServices.length,
        itemBuilder: (context, index) {
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 400),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: _buildServiceCard(
                  rentServices[index],
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

  Widget _buildServiceCard(Map<String, dynamic> service, ThemeData theme, int index) {
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
                'billType': "rent",
                'companyName': service['name'],
                'category': service['category'],
                'feeRange': service['feeRange'],
                'properties': service['properties'],
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
                  tag: 'rent_icon_${service['name']}',
                  child: Icon(
                    service['icon'] as IconData,
                    size: 28.sp,
                    color: service['color'] as Color,
                  ),
                ),

                SizedBox(width: 16.w),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Service name and category
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              service['name'] as String,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: theme.primaryColor != Colors.white
                                    ? Colors.white
                                    : const Color(0xff2D3748),
                              ),
                            ),
                          ),
                          // Category badge
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: MyTheme.primaryColor,
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Text(
                              service['category'] as String,
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
                        service['description'] as String,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.primaryColor != Colors.white
                              ? Colors.white.withOpacity(0.7)
                              : const Color(0xff718096),
                        ),
                      ),

                      SizedBox(height: 8.h),

                      // Properties count and fee info
                      Row(
                        children: [
                          Icon(
                            Icons.home,
                            size: 14.sp,
                          ),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: Text(
                              "${service['properties']} • ${service['feeRange']}",
                              style: const TextStyle(
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