import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:payfussion/core/theme/theme.dart';
import 'governement_pay_fee_screen.dart';

class GovernmentFeesScreen extends StatefulWidget {
  const GovernmentFeesScreen({super.key});

  @override
  State<GovernmentFeesScreen> createState() => _GovernmentFeesScreenState();
}

class _GovernmentFeesScreenState extends State<GovernmentFeesScreen> with TickerProviderStateMixin {
  final List<GovernmentFeeItem> governmentFeeItems = <GovernmentFeeItem>[
    // Federal Services
    GovernmentFeeItem(
      icon: Icons.account_balance,
      label: "IRS Tax Payment",
      subtitle: "Federal income tax & penalties",
      type: "irs",
      gradient: MyTheme.primaryColor,
      iconColor: Colors.white,
      category: "Federal",
    ),
    GovernmentFeeItem(
      icon: Icons.security,
      label: "Social Security",
      subtitle: "SSA services & benefits",
      type: "ssa",
      gradient: MyTheme.primaryColor,
      iconColor: Colors.white,
      category: "Federal",
    ),
    GovernmentFeeItem(
      icon: Icons.local_hospital,
      label: "Medicare Services",
      subtitle: "Healthcare premium payments",
      type: "medicare",
      gradient: MyTheme.primaryColor,
      iconColor: Colors.white,
      category: "Federal",
    ),
    GovernmentFeeItem(
      icon: Icons.flight_takeoff,
      label: "TSA PreCheck",
      subtitle: "Airport security services",
      type: "tsa",
      gradient: MyTheme.primaryColor,
      iconColor: Colors.white,
      category: "Federal",
    ),
    GovernmentFeeItem(
      icon: Icons.library_books,
      label: "Passport Services",
      subtitle: "US State Department fees",
      type: "passport",
      gradient: MyTheme.primaryColor,
      iconColor: Colors.white,
      category: "Federal",
    ),
    GovernmentFeeItem(
      icon: Icons.business,
      label: "SBA Loans",
      subtitle: "Small Business Administration",
      type: "sba",
      gradient: MyTheme.primaryColor,
      iconColor: Colors.white,
      category: "Federal",
    ),

    // State Services
    GovernmentFeeItem(
      icon: Icons.directions_car,
      label: "DMV Services",
      subtitle: "License renewal & registration",
      type: "dmv",
      gradient: MyTheme.primaryColor,
      iconColor: Colors.white,
      category: "State",
    ),
    GovernmentFeeItem(
      icon: Icons.account_balance_wallet,
      label: "State Tax Board",
      subtitle: "State income tax payments",
      type: "state_tax",
      gradient: MyTheme.primaryColor,
      iconColor: Colors.white,
      category: "State",
    ),
    GovernmentFeeItem(
      icon: Icons.work,
      label: "Employment Dept",
      subtitle: "Unemployment & workforce",
      type: "employment",
      gradient: MyTheme.primaryColor,
      iconColor: Colors.white,
      category: "State",
    ),
    GovernmentFeeItem(
      icon: Icons.health_and_safety,
      label: "Health Department",
      subtitle: "Permits & health services",
      type: "health_dept",
      gradient: MyTheme.primaryColor,
      iconColor: Colors.white,
      category: "State",
    ),
    GovernmentFeeItem(
      icon: Icons.school,
      label: "Education Dept",
      subtitle: "Student loans & services",
      type: "education",
      gradient: MyTheme.primaryColor,
      iconColor: Colors.white,
      category: "State",
    ),

    // Local Services
    GovernmentFeeItem(
      icon: Icons.local_police,
      label: "Police Department",
      subtitle: "Fines, permits & services",
      type: "police",
      gradient: MyTheme.primaryColor,
      iconColor: Colors.white,
      category: "Local",
    ),
    GovernmentFeeItem(
      icon: Icons.traffic,
      label: "Traffic Citations",
      subtitle: "Parking & traffic fines",
      type: "traffic",
      gradient: MyTheme.primaryColor,
      iconColor: Colors.white,
      category: "Local",
    ),
    GovernmentFeeItem(
      icon: Icons.delete,
      label: "Waste Management",
      subtitle: "Garbage & recycling fees",
      type: "waste",
      gradient: MyTheme.primaryColor,
      iconColor: Colors.white,
      category: "Local",
    ),
    GovernmentFeeItem(
      icon: Icons.water_drop,
      label: "Water Department",
      subtitle: "Water & sewer services",
      type: "water",
      gradient: MyTheme.primaryColor,
      iconColor: Colors.white,
      category: "Local",
    ),
    GovernmentFeeItem(
      icon: Icons.home,
      label: "Property Tax",
      subtitle: "Real estate tax payments",
      type: "property_tax",
      gradient: MyTheme.primaryColor,
      iconColor: Colors.white,
      category: "Local",
    ),
    GovernmentFeeItem(
      icon: Icons.build,
      label: "Building Permits",
      subtitle: "Construction & zoning",
      type: "permits",
      gradient: MyTheme.primaryColor,
      iconColor: Colors.white,
      category: "Local",
    ),
    GovernmentFeeItem(
      icon: Icons.local_fire_department,
      label: "Fire Department",
      subtitle: "Fire safety & permits",
      type: "fire_dept",
      gradient: MyTheme.primaryColor,
      iconColor: Colors.white,
      category: "Local",
    ),
    GovernmentFeeItem(
      icon: Icons.park,
      label: "Parks & Recreation",
      subtitle: "Park permits & activities",
      type: "parks",
      gradient: MyTheme.primaryColor,
      iconColor: Colors.white,
      category: "Local",
    ),

    // Court Services
    GovernmentFeeItem(
      icon: Icons.gavel,
      label: "Court Services",
      subtitle: "Filing fees & fines",
      type: "court",
      gradient: MyTheme.primaryColor,
      iconColor: Colors.white,
      category: "Judicial",
    ),
    GovernmentFeeItem(
      icon: Icons.balance,
      label: "Legal Services",
      subtitle: "Attorney general services",
      type: "legal",
      gradient: MyTheme.primaryColor,
      iconColor: Colors.white,
      category: "Judicial",
    ),
  ];

  // Animation controllers
  late AnimationController _headerController;
  late AnimationController _feesController;

  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;
  late Animation<double> _feesFade;

  String selectedCategory = "All";
  final List<String> categories = ["All", "Federal", "State", "Local", "Judicial"];

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startAnimationSequence();
  }

  void _initAnimations() {
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _feesController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _headerFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _headerController, curve: Curves.easeOut),
    );

    _headerSlide = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _headerController, curve: Curves.easeOut));

    _feesFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _feesController, curve: Curves.easeOut),
    );
  }

  void _startAnimationSequence() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _headerController.forward();

    await Future.delayed(const Duration(milliseconds: 100));
    _feesController.forward();
  }

  @override
  void dispose() {
    _headerController.dispose();
    _feesController.dispose();
    super.dispose();
  }

  List<GovernmentFeeItem> get filteredItems {
    if (selectedCategory == "All") {
      return governmentFeeItems;
    }
    return governmentFeeItems.where((item) => item.category == selectedCategory).toList();
  }

  // /// Generate random fee details based on service type
  // Map<String, dynamic> _generateFeeDetails(String serviceType) {
  //   final random = DateTime.now().millisecondsSinceEpoch;
  //
  //   switch (serviceType) {
  //     case 'irs':
  //       return {
  //         'serviceName': 'Internal Revenue Service',
  //         'referenceNumber': 'IRS-${random.toString().substring(7)}',
  //         'amount': 2500.0 + (random % 5000),
  //       };
  //     case 'dmv':
  //       return {
  //         'serviceName': 'Department of Motor Vehicles',
  //         'referenceNumber': 'DMV-${random.toString().substring(8)}',
  //         'amount': 85.0 + (random % 200),
  //       };
  //     case 'police':
  //       return {
  //         'serviceName': 'Police Department',
  //         'referenceNumber': 'PD-${random.toString().substring(9)}',
  //         'amount': 150.0 + (random % 300),
  //       };
  //     case 'traffic':
  //       return {
  //         'serviceName': 'Traffic Violations Bureau',
  //         'referenceNumber': 'TVB-${random.toString().substring(8)}',
  //         'amount': 75.0 + (random % 400),
  //       };
  //     case 'property_tax':
  //       return {
  //         'serviceName': 'Property Tax Department',
  //         'referenceNumber': 'PT-${random.toString().substring(7)}',
  //         'amount': 3500.0 + (random % 8000),
  //       };
  //     case 'court':
  //       return {
  //         'serviceName': 'Court Administration',
  //         'referenceNumber': 'CT-${random.toString().substring(9)}',
  //         'amount': 200.0 + (random % 500),
  //       };
  //     default:
  //       return {
  //         'serviceName': 'Government Service',
  //         'referenceNumber': 'GOV-${random.toString().substring(8)}',
  //         'amount': 100.0 + (random % 1000),
  //       };
  //   }
  // }

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
              "Government Fees",
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
        opacity: _feesFade,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.3),
            end: Offset.zero,
          ).animate(_feesController),
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
                      "US Government",
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w300,
                        fontSize: 18,
                        color: theme.primaryColor != Colors.white
                            ? Colors.white.withOpacity(0.8)
                            : const Color(0xff718096),
                      ),
                    ),
                    Text(
                      "Service Payments",
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: theme.primaryColor != Colors.white
                            ? Colors.white
                            : const Color(0xff2D3748),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      "Pay federal, state, and local government fees",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 12,
                        color: theme.primaryColor != Colors.white
                            ? Colors.white.withOpacity(0.7)
                            : const Color(0xff718096),
                      ),
                    ),
                  ],
                ),
              ),

              // Category Filter
              _buildCategoryFilter(theme),
              SizedBox(height: 16.h),

              // Government Services List
              Expanded(
                child: _buildGovernmentServicesList(theme),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter(ThemeData theme) {
    return SizedBox(
      height: 40.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedCategory == category;

          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 200),
            child: SlideAnimation(
              horizontalOffset: 30.0,
              child: FadeInAnimation(
                child: GestureDetector(
                  onTap: () => setState(() => selectedCategory = category),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                    decoration: BoxDecoration(
                      color: isSelected ? MyTheme.primaryColor : theme.cardColor,
                      borderRadius: BorderRadius.circular(25.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      category,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isSelected
                            ? Colors.white
                            : (theme.primaryColor != Colors.white
                            ? Colors.white
                            : const Color(0xff2D3748)),
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGovernmentServicesList(ThemeData theme) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: AnimationLimiter(
        child: GridView.builder(
          physics: const BouncingScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 10.h,
            crossAxisSpacing: 10.w,
            childAspectRatio: 9 / 12,
          ),
          itemCount: filteredItems.length,
          itemBuilder: (context, index) {
            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 375),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: _buildGovernmentServiceItem(
                    filteredItems[index],
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

  Widget _buildGovernmentServiceItem(GovernmentFeeItem item, ThemeData theme, int index) {
    return Container(
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
          Navigator.push(context, MaterialPageRoute(builder: (context) => const GovernmentPayFeeScreen()));
        },
        borderRadius: BorderRadius.circular(16.r),
        child: Padding(
          padding: EdgeInsets.all(10.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Icon Container
              Icon(
                item.icon,
                size: 32.sp,
                color: MyTheme.primaryColor,
              ),

              SizedBox(height: 16.w),

              /// Text Content
              Text(
                item.label,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: theme.primaryColor != Colors.white ? const Color(0xffffffff) : const Color(0xff2D3748),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }

  void _showPaymentDialog(BuildContext context, GovernmentFeeItem item, Map<String, dynamic> details) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item.label),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Service: ${details['serviceName']}'),
            SizedBox(height: 8.h),
            Text('Reference: ${details['referenceNumber']}'),
            SizedBox(height: 8.h),
            Text('Amount: \$${details['amount'].toStringAsFixed(2)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Handle payment process
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Processing payment for ${item.label}...')),
              );
            },
            child: const Text('Pay Now'),
          ),
        ],
      ),
    );
  }
}

class GovernmentFeeItem {
  final IconData icon;
  final String label;
  final String subtitle;
  final String type;
  final Color gradient;
  final Color iconColor;
  final String category;

  GovernmentFeeItem({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.type,
    required this.gradient,
    required this.iconColor,
    required this.category,
  });
}