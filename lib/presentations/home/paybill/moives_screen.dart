import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:go_router/go_router.dart';
import 'package:payfussion/core/theme/theme.dart';

import '../../../core/constants/routes_name.dart';

class MoviesScreen extends StatefulWidget {
  const MoviesScreen({super.key});

  @override
  State<MoviesScreen> createState() => _MoviesScreenState();
}

class _MoviesScreenState extends State<MoviesScreen>
    with TickerProviderStateMixin {

  // Animation controllers
  late AnimationController _headerController;
  late AnimationController _listController;

  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;
  late Animation<double> _listFade;

  final List<Map<String, dynamic>> streamingServices = [
    {
      "name": "Netflix",
      "description": "The world's leading streaming service",
      "icon": Icons.play_circle_filled,
      "color": Colors.white,
      "category": "Movies & TV",
      "monthlyPrice": "\$15.49/month",
      "content": "Movies, Series, Documentaries",
    },
    {
      "name": "Amazon Prime Video",
      "description": "Stream with Prime membership",
      "icon": Icons.shopping_cart,
      "color": Colors.white,
      "category": "Movies & TV",
      "monthlyPrice": "\$14.98/month",
      "content": "Movies, Series, Prime Originals",
    },
    {
      "name": "Disney+",
      "description": "The streaming home of Disney",
      "icon": Icons.castle,
      "color": Colors.white,
      "category": "Family Content",
      "monthlyPrice": "\$7.99/month",
      "content": "Disney, Marvel, Star Wars",
    },
    {
      "name": "Hulu",
      "description": "Stream current TV and classic hits",
      "icon": Icons.tv,
      "color": Colors.white,
      "category": "TV Shows",
      "monthlyPrice": "\$7.99/month",
      "content": "Current TV, Hulu Originals",
    },
    {
      "name": "HBO Max",
      "description": "Where HBO meets so much more",
      "icon": Icons.theaters,
      "color": Colors.white,
      "category": "Premium Content",
      "monthlyPrice": "\$15.99/month",
      "content": "HBO, Movies, Max Originals",
    },
    {
      "name": "Apple TV+",
      "description": "Apple's streaming service",
      "icon": Icons.apple,
      "color": Colors.white,
      "category": "Originals",
      "monthlyPrice": "\$6.99/month",
      "content": "Apple TV+ Originals",
    },
    {
      "name": "Peacock",
      "description": "NBCUniversal's streaming service",
      "icon": Icons.pets,
      "color": Colors.white,
      "category": "TV & Movies",
      "monthlyPrice": "\$5.99/month",
      "content": "NBC Shows, Movies, Sports",
    },
    {
      "name": "Paramount+",
      "description": "A mountain of entertainment",
      "icon": Icons.landscape,
      "color": Colors.white,
      "category": "Movies & TV",
      "monthlyPrice": "\$5.99/month",
      "content": "CBS, Paramount, Comedy Central",
    },
    {
      "name": "YouTube Premium",
      "description": "Ad-free YouTube with extras",
      "icon": Icons.play_arrow,
      "color": Colors.white,
      "category": "Video Platform",
      "monthlyPrice": "\$11.99/month",
      "content": "Ad-free, Music, Originals",
    },
    {
      "name": "Sling TV",
      "description": "Live TV streaming service",
      "icon": Icons.live_tv,
      "color": Colors.white,
      "category": "Live TV",
      "monthlyPrice": "\$40/month",
      "content": "Live TV Channels",
    },
    {
      "name": "ESPN+",
      "description": "The ultimate sports streaming",
      "icon": Icons.sports_football,
      "color": Colors.white,
      "category": "Sports",
      "monthlyPrice": "\$9.99/month",
      "content": "Live Sports, Documentaries",
    },
    {
      "name": "Showtime",
      "description": "Premium entertainment network",
      "icon": Icons.star,
      "color": Colors.white,
      "category": "Premium TV",
      "monthlyPrice": "\$10.99/month",
      "content": "Showtime Series & Movies",
    },
    {
      "name": "Starz",
      "description": "Premium movies and series",
      "icon": Icons.auto_awesome,
      "color": Colors.white,
      "category": "Premium Movies",
      "monthlyPrice": "\$9.99/month",
      "content": "Premium Movies & Series",
    },
    {
      "name": "Discovery+",
      "description": "Real life entertainment",
      "icon": Icons.explore,
      "color": Colors.white,
      "category": "Documentary",
      "monthlyPrice": "\$4.99/month",
      "content": "Discovery, HGTV, Food Network",
    },
    {
      "name": "Crunchyroll",
      "description": "The ultimate anime experience",
      "icon": Icons.animation,
      "color": Colors.white,
      "category": "Anime",
      "monthlyPrice": "\$7.99/month",
      "content": "Anime, Manga, Drama",
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
              "Movies & TV Subscriptions",
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
                    "Manage Your",
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w300,
                      color: theme.primaryColor != Colors.white
                          ? Colors.white.withOpacity(0.8)
                          : const Color(0xff718096),
                    ),
                  ),
                  Text(
                    "Streaming Bills",
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor != Colors.white
                          ? Colors.white
                          : const Color(0xff2D3748),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    "Pay for your favorite streaming services in one place",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.primaryColor != Colors.white
                          ? Colors.white.withOpacity(0.7)
                          : const Color(0xff718096),
                    ),
                  ),
                ],
              ),
            ),

            // Streaming Services List
            Expanded(
              child: _buildStreamingServicesList(theme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreamingServicesList(ThemeData theme) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: AnimationLimiter(
        child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: streamingServices.length,
          itemBuilder: (context, index) {
            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 400),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: _buildServiceCard(
                    streamingServices[index],
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

  Widget _buildServiceCard(Map<String, dynamic> service, ThemeData theme, int index) {
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
                'billType': "movies",
                'companyName': service['name'],
                'category': service['category'],
                'monthlyPrice': service['monthlyPrice'],
                'content': service['content'],
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
                  tag: 'movies_icon_${service['name']}',
                  child: Container(
                    height: 65.h,
                    width: 65.w,
                    decoration: BoxDecoration(
                      color: MyTheme.primaryColor,
                      borderRadius: BorderRadius.circular(18.r),
                      border: Border.all(
                        color: (service['color'] as Color).withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      service['icon'] as IconData,
                      size: 28.sp,
                      color: service['color'] as Color,
                    ),
                  ),
                ),

                SizedBox(width: 16.w),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Service name and price
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
                          // Price badge
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: MyTheme.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Text(
                              service['monthlyPrice'] as String,
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.w600,
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

                      // Category and content info
                      Row(
                        children: [
                          Icon(
                            Icons.category,
                            size: 14.sp,
                          ),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: Text(
                              "${service['category']} • ${service['content']}",
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