import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:payfussion/core/theme/theme.dart';
import '../../../core/constants/fonts.dart';
import '../../widgets/background_theme.dart';
import 'insurance_payment_screen.dart';

class InsuranceTypeScreen extends StatefulWidget {
  final String companyName;
  final List<String> types;
  final IconData icon;
  final Color color;

  const InsuranceTypeScreen({
    super.key,
    required this.companyName,
    required this.types,
    required this.icon,
    required this.color,
  });

  @override
  State<InsuranceTypeScreen> createState() => _InsuranceTypeScreenState();
}

class _InsuranceTypeScreenState extends State<InsuranceTypeScreen> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late AnimationController _backgroundAnimationController;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
    _backgroundAnimationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    _backgroundAnimationController.dispose();
    super.dispose();
  }

  IconData _getInsuranceTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'auto insurance':
      case 'auto':
        return Icons.directions_car;
      case 'life insurance':
      case 'life':
        return Icons.favorite;
      case 'health insurance':
      case 'health':
        return Icons.health_and_safety;
      case 'homeowners insurance':
      case 'home insurance':
      case 'homeowners':
        return Icons.home;
      case 'property & casualty':
        return Icons.business;
      case 'annuities':
        return Icons.trending_up;
      case 'disability insurance':
        return Icons.accessible;
      case 'travel insurance':
        return Icons.flight;
      case 'dental & vision insurance':
        return Icons.visibility;
      case 'renters & condo insurance':
        return Icons.apartment;
      case 'group benefits':
        return Icons.group;
      case 'commercial insurance':
        return Icons.domain;
      case 'specialty insurance':
        return Icons.star;
      case 'accident & health':
        return Icons.medical_services;
      case 'long-term care insurance':
        return Icons.elderly;
      case 'retirement plans':
      case 'investment & retirement solutions':
        return Icons.savings;
      case 'reinsurance':
        return Icons.security;
      default:
        return Icons.verified_user;
    }
  }

  Color _getInsuranceTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'auto insurance':
      case 'auto':
        return MyTheme.secondaryColor;
      case 'life insurance':
      case 'life':
        return MyTheme.secondaryColor;
      case 'health insurance':
      case 'health':
        return MyTheme.secondaryColor;
      case 'homeowners insurance':
      case 'home insurance':
      case 'homeowners':
        return MyTheme.secondaryColor;
      case 'property & casualty':
        return MyTheme.secondaryColor;
      case 'annuities':
        return MyTheme.secondaryColor;
      case 'disability insurance':
        return MyTheme.secondaryColor;
      case 'travel insurance':
        return MyTheme.secondaryColor;
      case 'dental & vision insurance':
        return MyTheme.secondaryColor;
      case 'renters & condo insurance':
        return MyTheme.secondaryColor;
      case 'group benefits':
        return MyTheme.secondaryColor;
      case 'commercial insurance':
        return MyTheme.secondaryColor;
      case 'specialty insurance':
        return MyTheme.secondaryColor;
      case 'accident & health':
        return MyTheme.secondaryColor;
      case 'long-term care insurance':
        return MyTheme.secondaryColor;
      case 'retirement plans':
      case 'investment & retirement solutions':
        return MyTheme.secondaryColor;
      case 'reinsurance':
        return MyTheme.secondaryColor;
      default:
        return widget.color;
    }
  }

  void _navigateToPayment(String insuranceType) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) =>
            InsurancePaymentScreen(
              companyName: widget.companyName,
              insuranceType: insuranceType,
              color: _getInsuranceTypeColor(insuranceType),
              icon: _getInsuranceTypeIcon(insuranceType),
            ),
        transitionsBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
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
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: <Widget>[
          AnimatedBackground(
            animationController: _backgroundAnimationController,
          ),
          FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: CustomScrollView(
                slivers: <Widget>[
                  // App Bar
                  SliverAppBar(
                    expandedHeight: 200.h,
                    pinned: true,
                    backgroundColor: widget.color,
                    iconTheme: IconThemeData(
                      color: Colors.white,
                      size: 24.sp,
                    ),
                    flexibleSpace: FlexibleSpaceBar(
                      title: Text(
                        widget.companyName,
                        style: Font.montserratFont(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16.sp,
                        ),
                      ),
                      background: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: <Color>[
                              widget.color,
                              widget.color.withOpacity(0.8),
                            ],
                          ),
                        ),
                        child: Center(
                          child: Hero(
                            tag: 'insurance_icon_${widget.companyName}',
                            child: Container(
                              height: 80.h,
                              width: 80.w,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              child: Icon(
                                widget.icon,
                                size: 40.sp,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Content
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(20.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          // Header Section
                          Container(
                            padding: EdgeInsets.all(20.w),
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
                            child: Row(
                              children: <Widget>[
                                Icon(
                                  Icons.info_outline,
                                  color: widget.color,
                                  size: 24.sp,
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        'Available Insurance Types',
                                        style: Font.montserratFont(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w600,
                                          color: theme.primaryColor != Colors.white
                                              ? Colors.white
                                              : const Color(0xff2D3748),
                                        ),
                                      ),
                                      SizedBox(height: 4.h),
                                      Text(
                                        'Choose from ${widget.types.length} insurance options',
                                        style: Font.montserratFont(
                                          fontSize: 14.sp,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 32.h),

                          // Insurance Types Header
                          Text(
                            "Select Insurance Type",
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.primaryColor != Colors.white ? Colors.white : const Color(0xff2D3748),
                              fontSize: 16,
                            ),
                          ),

                          SizedBox(height: 16.h),
                        ],
                      ),
                    ),
                  ),

                  // Insurance Types List
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (BuildContext context, int index) {
                        final String insuranceType = widget.types[index];
                        final Color typeColor = _getInsuranceTypeColor(insuranceType);
                        final IconData typeIcon = _getInsuranceTypeIcon(insuranceType);

                        return AnimationConfiguration.staggeredList(
                          position: index,
                          duration: const Duration(milliseconds: 375),
                          child: SlideAnimation(
                            verticalOffset: 30.0,
                            child: FadeInAnimation(
                              child: Container(
                                margin: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.h),
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

                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () => _navigateToPayment(insuranceType),
                                    borderRadius: BorderRadius.circular(16.r),
                                    child: Padding(
                                      padding: EdgeInsets.all(20.w),
                                      child: Row(
                                        children: <Widget>[
                                          // Icon Container
                                          Icon(
                                            typeIcon,
                                            color: typeColor,
                                            size: 28.sp,
                                          ),

                                          SizedBox(width: 16.w),

                                          // Content
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Text(
                                                  insuranceType,
                                                  style: theme.textTheme.titleSmall?.copyWith(
                                                    fontWeight: FontWeight.w600,
                                                    color: theme.primaryColor != Colors.white
                                                        ? Colors.white
                                                        : const Color(0xff2D3748),
                                                  ),
                                                ),
                                                SizedBox(height: 4.h),
                                                Text(
                                                  'Tap to pay premium',
                                                  style: Font.montserratFont(
                                                    fontSize: 12.sp,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                          // Arrow and Premium Indicator
                                          Column(
                                            children: <Widget>[
                                              Icon(
                                                Icons.arrow_forward_ios,
                                                size: 12.sp,
                                                color: typeColor,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      childCount: widget.types.length,
                    ),
                  ),

                  // Bottom spacing
                  SliverToBoxAdapter(
                    child: SizedBox(height: 32.h),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}