import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:payfussion/core/constants/routes_name.dart';
import 'package:payfussion/presentations/pay_bills/widgets/quick_access_avatar.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/constants/image_url.dart';
import '../../../core/theme/theme.dart';
import '../../../data/models/recipient/recipient_model.dart';
import '../../widgets/background_theme.dart';
import '../tickets/bus/bus_screen.dart';
import '../tickets/car/car_screen.dart';
import '../tickets/flight/flight_screen.dart';
import '../tickets/movies/movies_list_screen.dart';

class PayBillScreen extends StatefulWidget {
  const PayBillScreen({super.key});

  @override
  State<PayBillScreen> createState() => _PayBillScreenState();
}

class _PayBillScreenState extends State<PayBillScreen> with TickerProviderStateMixin {
  final List<BillItem> billItems = <BillItem>[
    BillItem(
      icon: TImageUrl.electricBill,
      label: "Mobile Recharge",
      subtitle: "Prepaid & postpaid recharge",
      type: "mobile",
      gradient: MyTheme.primaryColor,
      iconColor: Colors.white,
      route: RouteNames.mobileRechargeScreen,
    ),
    BillItem(
      icon: TImageUrl.electricBill,
      label: "Electricity Bill",
      subtitle: "Pay your power bills instantly",
      type: "electricity",
      gradient: MyTheme.primaryColor,
      iconColor: Colors.white,
      route: RouteNames.electricCityBillScreen,
    ),
    BillItem(
      icon: TImageUrl.dth,
      label: "DTH Recharge",
      subtitle: "Digital TV & satellite services",
      type: "dth",
      gradient: MyTheme.primaryColor,
      iconColor: Colors.white,
      route: RouteNames.dthRechargeScreen,
    ),
    BillItem(
      icon: TImageUrl.electricBill,
      label: "Postpaid Bill",
      subtitle: "Monthly mobile bill payments",
      type: "postpaid",
      gradient: MyTheme.primaryColor,
      iconColor: Colors.white,
      route: RouteNames.postpaidBillScreen,
    ),
    BillItem(
      icon: TImageUrl.gasBill,
      label: "Gas Bill",
      subtitle: "Natural gas bill payments",
      type: "gas",
      gradient: MyTheme.primaryColor,
      iconColor: Colors.white,
      route: RouteNames.gasBillScreen,
    ),
    BillItem(
      icon: TImageUrl.electricBill,
      label: "Internet Bill",
      subtitle: "Broadband & fiber payments",
      type: "internet",
      gradient: MyTheme.primaryColor,
      iconColor: Colors.white,
      route: RouteNames.internetBillScreen,
    ),
    BillItem(
      icon: TImageUrl.creditCardLoan,
      label: "Credit Card Loan",
      subtitle: "Credit card bill payments",
      type: "credit_card",
      gradient: MyTheme.primaryColor,
      iconColor: Colors.white,
      route: RouteNames.creditCardLoanScreen,
    ),
    BillItem(
      icon: TImageUrl.rentBill,
      label: "Rent Payment",
      subtitle: "Monthly rent & property fees",
      type: "rent",
      gradient: MyTheme.primaryColor,
      iconColor: Colors.white,
      route: RouteNames.rentPaymentScreen,
    ),
    BillItem(
      icon: TImageUrl.entertainment,
      label: "Entertainment",
      subtitle: "Streaming & subscription bills",
      type: "movies",
      gradient: MyTheme.primaryColor,
      iconColor: Colors.white,
      route: RouteNames.moviesScreen,
    ),
    BillItem(
      icon: TImageUrl.billSplit,
      label: "Bill Split",
      subtitle: "Share expenses with friends",
      type: "bill_split",
      gradient: MyTheme.primaryColor,
      iconColor: Colors.white,
      route: RouteNames.payBillsDetailView,
    ),
  ];

  RecipientModel? _selectedRecipient;

  // Animation controllers
  late AnimationController _headerController;
  late AnimationController _cardController;
  late AnimationController _quickAccessController;
  late AnimationController _billsController;
  late AnimationController _ticketsController;
  late AnimationController _backgroundAnimationController;
  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;
  late Animation<double> _cardScale;
  late Animation<double> _quickAccessFade;
  late Animation<double> _billsFade;
  late Animation<double> _ticketsFade;

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
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _cardController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _quickAccessController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _billsController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );

    _ticketsController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _headerFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _headerController, curve: Curves.easeOut),
    );

    _headerSlide = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _headerController, curve: Curves.easeOut));

    _cardScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _cardController, curve: Curves.elasticOut),
    );

    _quickAccessFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _quickAccessController, curve: Curves.easeOut),
    );

    _billsFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _billsController, curve: Curves.easeOut),
    );

    _ticketsFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ticketsController, curve: Curves.easeOut),
    );
  }

  void _startAnimationSequence() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _headerController.forward();

    await Future.delayed(const Duration(milliseconds: 100));
    _cardController.forward();

    await Future.delayed(const Duration(milliseconds: 100));
    _quickAccessController.forward();

    await Future.delayed(const Duration(milliseconds: 100));
    _billsController.forward();

    await Future.delayed(const Duration(milliseconds: 100));
    _ticketsController.forward();
  }

  @override
  void dispose() {
    _headerController.dispose();
    _cardController.dispose();
    _quickAccessController.dispose();
    _billsController.dispose();
    _ticketsController.dispose();
    _backgroundAnimationController.dispose();
    super.dispose();
  }

  /// Generate random bill details based on bill type
  Map<String, dynamic> _generateBillDetails(String billType) {
    final random = DateTime.now().millisecondsSinceEpoch;

    switch (billType) {
      case 'mobile':
        return {
          'companyName': 'Mobilink Jazz',
          'billNumber': '03XX-XXXXXXX${random.toString().substring(9)}',
          'amount': 450.0 + (random % 500),
        };
      case 'electricity':
        return {
          'companyName': 'K-Electric',
          'billNumber': 'KE-${random.toString().substring(7)}',
          'amount': 2500.0 + (random % 3000),
        };
      case 'gas':
        return {
          'companyName': 'Sui Southern Gas',
          'billNumber': 'SSGC-${random.toString().substring(6)}',
          'amount': 1200.0 + (random % 1500),
        };
      case 'internet':
        return {
          'companyName': 'PTCL Broadband',
          'billNumber': 'PTCL-${random.toString().substring(8)}',
          'amount': 1800.0 + (random % 1000),
        };
      case 'dth':
        return {
          'companyName': 'Dish TV',
          'billNumber': 'DTH-${random.toString().substring(9)}',
          'amount': 800.0 + (random % 500),
        };
      case 'postpaid':
        return {
          'companyName': 'Telenor Pakistan',
          'billNumber': '03XX-XXXXXXX${random.toString().substring(9)}',
          'amount': 600.0 + (random % 800),
        };
      case 'credit_card':
        return {
          'companyName': 'HBL Credit Card',
          'billNumber': '**** **** **** ${random.toString().substring(9)}',
          'amount': 5000.0 + (random % 10000),
        };
      case 'rent':
        return {
          'companyName': 'Property Manager',
          'billNumber': 'RENT-${random.toString().substring(7)}',
          'amount': 25000.0 + (random % 20000),
        };
      case 'netflix':
        return {
          'companyName': 'Netflix Premium',
          'billNumber': 'NF-${random.toString().substring(10)}',
          'amount': 1500.0,
        };
      case 'bill_split':
        return {
          'companyName': 'Group Expense',
          'billNumber': 'SPLIT-${random.toString().substring(8)}',
          'amount': 1200.0 + (random % 2000),
        };
      default:
        return {
          'companyName': 'Service Provider',
          'billNumber': 'BILL-${random.toString().substring(9)}',
          'amount': 1000.0 + (random % 2000),
        };
    }
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
              "Pay Bills",
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
        children: [
          AnimatedBackground(
            animationController: _backgroundAnimationController,
          ),
          FadeTransition(
            opacity: _billsFade,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.3),
                end: Offset.zero,
              ).animate(_billsController),
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
                          "Quick & Easy",
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w300,
                            fontSize: 18,
                            color: theme.primaryColor != Colors.white ? Colors.white.withOpacity(0.8) : const Color(0xff718096),
                          ),
                        ),
                        Text(
                          "Bill Payments",
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.primaryColor != Colors.white ? Colors.white : const Color(0xff2D3748),
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          "Pay all your bills in one place, anytime",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.primaryColor != Colors.white ? Colors.white.withOpacity(0.7) : const Color(0xff718096),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Bills List
                  Expanded(
                    child: _buildBillPaymentList(theme),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBillPaymentList(ThemeData theme) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: AnimationLimiter(
        child: GridView.builder(
          physics: const BouncingScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 10.h,
            crossAxisSpacing: 10.w,
            childAspectRatio: 9 / 10,
          ),
          itemCount: billItems.length,
          itemBuilder: (context, index) {
            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 375),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: _buildBillListItem(
                    billItems[index],
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

  Widget _buildBillListItem(BillItem item, ThemeData theme, int index) {
    return Padding(
      padding: const EdgeInsets.all(10),
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
            if (item.route != null) {
              context.push(item.route!);
            }
          },
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.all(10.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Center(
                  child: SvgPicture.asset(
                    item.icon,
                    height: 25.h,
                    width: 25.w,
                    color: MyTheme.primaryColor,
                  ),
                ),
                SizedBox(height: 10.w),
                Text(
                  item.label,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: theme.primaryColor != Colors.white
                        ? const Color(0xffffffff)
                        : const Color(0xff2D3748),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAccessList() {
    return SizedBox(
      height: 100.h,
      child: FutureBuilder(
        future: FirebaseFirestore.instance
            .collection("users")
            .doc(FirebaseAuth.instance.currentUser?.uid)
            .collection("recipients")
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildShimmerList();
          } else if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            return _buildContactsList(snapshot.data!.docs);
          } else if (snapshot.hasError) {
            return _buildErrorState();
          } else {
            return _buildEmptyState();
          }
        },
      ),
    );
  }

  Widget _buildShimmerList() {
    return AnimationLimiter(
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: 5,
        itemBuilder: (BuildContext context, int index) {
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 150),
            child: SlideAnimation(
              horizontalOffset: 30.0,
              child: FadeInAnimation(
                child: Padding(
                  padding: EdgeInsets.only(right: 12.w),
                  child: Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 30.r,
                          backgroundColor: Colors.grey[300],
                        ),
                        SizedBox(height: 8.h),
                        Container(
                          width: 50.w,
                          height: 12.h,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                        ),
                      ],
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

  Widget _buildContactsList(List<QueryDocumentSnapshot> docs) {
    return AnimationLimiter(
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: docs.length,
        itemBuilder: (BuildContext context, int index) {
          var data = docs[index];
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 200),
            child: SlideAnimation(
              horizontalOffset: 30.0,
              child: FadeInAnimation(
                child: QuickAccessAvatar(
                  name: data["name"] ?? "No Name",
                  imagePath: data["imageUrl"],
                  onTap: () {
                    // Handle contact tap
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorState() {
    return AnimationConfiguration.synchronized(
      duration: const Duration(milliseconds: 300),
      child: SlideAnimation(
        verticalOffset: 20.0,
        child: FadeInAnimation(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 30.r,
                ),
                SizedBox(height: 8.h),
                Text(
                  "Failed to load contacts",
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return AnimationConfiguration.synchronized(
      duration: const Duration(milliseconds: 300),
      child: SlideAnimation(
        verticalOffset: 20.0,
        child: FadeInAnimation(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.people_outline,
                  color: Colors.grey[400],
                  size: 30.r,
                ),
                SizedBox(height: 8.h),
                Text(
                  "No contacts found",
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTicketBookingSection() {
    final ThemeData theme = Theme.of(context);

    final ticketItems = [
      {'icon': TImageUrl.iconMovies, 'label': 'Movies', 'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (context) => MovieListScreen()))},
      {'icon': TImageUrl.iconTrains, 'label': 'Trains', 'onTap': () => context.push(RouteNames.trainListScreen)},
      {'icon': TImageUrl.iconBus, 'label': 'Bus', 'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (context) => BusListScreen()))},
      {'icon': TImageUrl.iconFlight, 'label': 'Flights', 'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (context) => FlightListScreen()))},
      {'icon': TImageUrl.iconCar, 'label': 'Car', 'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (context) => RideServiceListScreen()))},
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: AnimationLimiter(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: AnimationConfiguration.toStaggeredList(
            duration: const Duration(milliseconds: 150),
            childAnimationBuilder: (widget) => SlideAnimation(
              verticalOffset: 30.0,
              child: FadeInAnimation(child: widget),
            ),
            children: ticketItems.map((item) =>
                _buildTicketItem(
                  item['icon'] as String,
                  item['label'] as String,
                  theme,
                  item['onTap'] as VoidCallback,
                )
            ).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildTicketItem(String icon, String label, ThemeData theme, VoidCallback onTap) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              height: 60.h,
              width: 59.w,
              decoration: BoxDecoration(
                color: Colors.pink.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(15.r),
              ),
              child: Image.asset(icon),
            ),
            SizedBox(height: 8.h),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.primaryColor != Colors.white
                    ? const Color(0xffffffff)
                    : const Color(0xff666666),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Generate ticket booking details based on ticket type
  Map<String, dynamic> _generateTicketDetails(String ticketType) {
    final random = DateTime.now().millisecondsSinceEpoch;

    switch (ticketType) {
      case 'movies':
        return {
          'companyName': 'Cinepax Cinema',
          'ticketNumber': 'MOV-${random.toString().substring(8)}',
          'amount': 800.0 + (random % 500),
        };
      case 'trains':
        return {
          'companyName': 'Pakistan Railways',
          'ticketNumber': 'TRN-${random.toString().substring(7)}',
          'amount': 1500.0 + (random % 1000),
        };
      case 'bus':
        return {
          'companyName': 'Daewoo Express',
          'ticketNumber': 'BUS-${random.toString().substring(9)}',
          'amount': 1200.0 + (random % 800),
        };
      case 'flights':
        return {
          'companyName': 'PIA Airlines',
          'ticketNumber': 'FLT-${random.toString().substring(6)}',
          'amount': 15000.0 + (random % 10000),
        };
      case 'car':
        return {
          'companyName': 'Car Rental Service',
          'ticketNumber': 'CAR-${random.toString().substring(8)}',
          'amount': 3000.0 + (random % 2000),
        };
      default:
        return {
          'companyName': 'Booking Service',
          'ticketNumber': 'TKT-${random.toString().substring(9)}',
          'amount': 1000.0 + (random % 1500),
        };
    }
  }
}

/// Updated BillItem class to include subtitle and iconColor
class BillItem {
  final String icon;
  final String label;
  final String subtitle;
  final String type;
  final Color gradient;
  final Color iconColor;
  final String? route;

  BillItem({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.type,
    required this.gradient,
    required this.iconColor,
    this.route,
  });
}