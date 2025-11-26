import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:payfussion/core/constants/routes_name.dart';
import '../../../../core/constants/image_url.dart';
import '../../../../core/theme/theme.dart';
import '../../../../data/models/recipient/recipient_model.dart';
import '../../../widgets/background_theme.dart';

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
      route: RouteNames.splitBill,
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
        children: <Widget>[
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
                children: <Widget>[
                  // Header Section
                  Padding(
                    padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 20.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
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
          itemBuilder: (BuildContext context, int index) {
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
            if (item.route != null) {
              context.push(item.route!);
            }
          },
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.all(10.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
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
                    color: theme.primaryColor != Colors.white ? const Color(0xffffffff) : const Color(0xff2D3748),
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