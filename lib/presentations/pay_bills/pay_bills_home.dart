// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
// import 'package:go_router/go_router.dart';
// import 'package:payfussion/core/constants/routes_name.dart';
// import 'package:payfussion/presentations/pay_bills/show_bills_screen.dart';
// import 'package:payfussion/presentations/pay_bills/tickets/bus/bus_screen.dart';
// import 'package:payfussion/presentations/pay_bills/tickets/car/car_screen.dart';
// import 'package:payfussion/presentations/pay_bills/tickets/flight/flight_screen.dart';
// import 'package:payfussion/presentations/pay_bills/tickets/movies/movies_list_screen.dart';
// import 'package:payfussion/presentations/pay_bills/widgets/quick_access_avatar.dart';
// import 'package:payfussion/presentations/pay_bills/widgets/section_header.dart';
// import 'package:payfussion/presentations/widgets/payment_selector_widget.dart';
// import 'package:payfussion/presentations/widgets/profile_app_bar.dart';
// import 'package:shimmer/shimmer.dart';
// import '../../core/constants/image_url.dart';
// import '../../data/models/recipient/recipient_model.dart';
// import '../widgets/home_widgets/home_custom_action_button.dart';
//
// class PayBillsHome extends StatefulWidget {
//   const PayBillsHome({super.key});
//
//   @override
//   State<PayBillsHome> createState() => _PayBillsHomeState();
// }
//
// class _PayBillsHomeState extends State<PayBillsHome> with TickerProviderStateMixin {
//   final List<BillItem> billItems = <BillItem>[
//     BillItem(
//       icon: TImageUrl.iconIphone,
//       label: "Mobile Recharge",
//       type: "mobile",
//       gradient: <Color>[const Color(0xff0054D2).withValues(alpha: 0.15)],
//       route: RouteNames.mobileRechargeScreen,
//     ),
//     BillItem(
//       icon: TImageUrl.iconElectricity,
//       label: "Electricity Bill",
//       type: "electricity",
//       gradient: <Color>[
//         const Color(0xFFFF8C6C).withValues(alpha: 0.15),
//         const Color(0xFFFF5F3F).withValues(alpha: 0.15),
//       ],
//       route: RouteNames.electricCityBillScreen,
//     ),
//     BillItem(
//       icon: TImageUrl.iconPlay,
//       label: "DTH Recharge",
//       type: "dth",
//       gradient: <Color>[
//         const Color.fromARGB(74, 89, 231, 115).withValues(alpha: 0.25),
//         const Color(0xFF3FBAFF).withValues(alpha: 0.15),
//       ],
//       route: RouteNames.dthRechargeScreen,
//     ),
//     BillItem(
//       icon: TImageUrl.iconPostpaid,
//       label: "Postpaid Bill",
//       type: "postpaid",
//       gradient: <Color>[
//         const Color.fromARGB(37, 237, 61, 93).withValues(alpha: 0.15),
//         const Color(0xFF8F3FFF).withValues(alpha: 0.15),
//       ],
//       route: RouteNames.postpaidBillScreen,
//     ),
//     BillItem(
//       icon: TImageUrl.iconGas,
//       label: "Gas Bill",
//       type: "gas",
//       gradient: <Color>[const Color(0xFF82d5ff).withValues(alpha: 0.9)],
//       route: RouteNames.internetBillScreen,
//     ),
//     BillItem(
//       icon: TImageUrl.iconInternet,
//       label: "Internet Bill",
//       type: "internet",
//       gradient: <Color>[const Color(0xFFcdd3e3).withValues(alpha: 0.7)],
//       route: RouteNames.internetBillScreen,
//     ),
//     BillItem(
//       icon: TImageUrl.iconCreditCard,
//       label: "Credit Card Loan",
//       type: "credit_card",
//       gradient: <Color>[
//         const Color(0xFFFF8C6C).withValues(alpha: 0.15),
//         const Color(0xFFFF3FBA).withValues(alpha: 0.15),
//       ],
//     ),
//     BillItem(
//       icon: TImageUrl.iconRent,
//       label: "Rent Payment",
//       type: "rent",
//       gradient: <Color>[
//         const Color.fromARGB(255, 167, 239, 58).withValues(alpha: 0.25),
//       ],
//       route: RouteNames.rentPaymentScreen,
//     ),
//     BillItem(
//       icon: TImageUrl.iconNetlix,
//       label: "Movies",
//       type: "movies",
//       gradient: <Color>[const Color(0xFFd2e1ff).withValues(alpha: 0.8)],
//       route: RouteNames.moviesScreen,
//     ),
//     BillItem(
//       icon: TImageUrl.iconBillSplit,
//       label: "Bill Split",
//       type: "bill_split",
//       gradient: <Color>[
//         const Color.fromARGB(74, 89, 231, 115).withValues(alpha: 0.25),
//       ],
//       route: RouteNames.payBillsDetailView,
//     ),
//   ];
//
//   RecipientModel? _selectedRecipient;
//
//   // Animation controllers
//   late AnimationController _headerController;
//   late AnimationController _cardController;
//   late AnimationController _quickAccessController;
//   late AnimationController _billsController;
//   late AnimationController _ticketsController;
//
//   late Animation<double> _headerFade;
//   late Animation<Offset> _headerSlide;
//   late Animation<double> _cardScale;
//   late Animation<double> _quickAccessFade;
//   late Animation<double> _billsFade;
//   late Animation<double> _ticketsFade;
//
//   @override
//   void initState() {
//     super.initState();
//     _initAnimations();
//     _startAnimationSequence();
//   }
//
//   void _initAnimations() {
//     _headerController = AnimationController(
//       duration: const Duration(milliseconds: 400),
//       vsync: this,
//     );
//
//     _cardController = AnimationController(
//       duration: const Duration(milliseconds: 500),
//       vsync: this,
//     );
//
//     _quickAccessController = AnimationController(
//       duration: const Duration(milliseconds: 600),
//       vsync: this,
//     );
//
//     _billsController = AnimationController(
//       duration: const Duration(milliseconds: 700),
//       vsync: this,
//     );
//
//     _ticketsController = AnimationController(
//       duration: const Duration(milliseconds: 800),
//       vsync: this,
//     );
//
//     _headerFade = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _headerController, curve: Curves.easeOut),
//     );
//
//     _headerSlide = Tween<Offset>(
//       begin: const Offset(0, -0.3),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(parent: _headerController, curve: Curves.easeOut));
//
//     _cardScale = Tween<double>(begin: 0.8, end: 1.0).animate(
//       CurvedAnimation(parent: _cardController, curve: Curves.elasticOut),
//     );
//
//     _quickAccessFade = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _quickAccessController, curve: Curves.easeOut),
//     );
//
//     _billsFade = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _billsController, curve: Curves.easeOut),
//     );
//
//     _ticketsFade = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _ticketsController, curve: Curves.easeOut),
//     );
//   }
//
//   void _startAnimationSequence() async {
//     await Future.delayed(const Duration(milliseconds: 100));
//     _headerController.forward();
//
//     await Future.delayed(const Duration(milliseconds: 100));
//     _cardController.forward();
//
//     await Future.delayed(const Duration(milliseconds: 100));
//     _quickAccessController.forward();
//
//     await Future.delayed(const Duration(milliseconds: 100));
//     _billsController.forward();
//
//     await Future.delayed(const Duration(milliseconds: 100));
//     _ticketsController.forward();
//   }
//
//   @override
//   void dispose() {
//     _headerController.dispose();
//     _cardController.dispose();
//     _quickAccessController.dispose();
//     _billsController.dispose();
//     _ticketsController.dispose();
//     super.dispose();
//   }
//
//   /// Generate random bill details based on bill type
//   Map<String, dynamic> _generateBillDetails(String billType) {
//     final random = DateTime.now().millisecondsSinceEpoch;
//
//     switch (billType) {
//       case 'mobile':
//         return {
//           'companyName': 'Mobilink Jazz',
//           'billNumber': '03XX-XXXXXXX${random.toString().substring(9)}',
//           'amount': 450.0 + (random % 500),
//         };
//       case 'electricity':
//         return {
//           'companyName': 'K-Electric',
//           'billNumber': 'KE-${random.toString().substring(7)}',
//           'amount': 2500.0 + (random % 3000),
//         };
//       case 'gas':
//         return {
//           'companyName': 'Sui Southern Gas',
//           'billNumber': 'SSGC-${random.toString().substring(6)}',
//           'amount': 1200.0 + (random % 1500),
//         };
//       case 'internet':
//         return {
//           'companyName': 'PTCL Broadband',
//           'billNumber': 'PTCL-${random.toString().substring(8)}',
//           'amount': 1800.0 + (random % 1000),
//         };
//       case 'dth':
//         return {
//           'companyName': 'Dish TV',
//           'billNumber': 'DTH-${random.toString().substring(9)}',
//           'amount': 800.0 + (random % 500),
//         };
//       case 'postpaid':
//         return {
//           'companyName': 'Telenor Pakistan',
//           'billNumber': '03XX-XXXXXXX${random.toString().substring(9)}',
//           'amount': 600.0 + (random % 800),
//         };
//       case 'credit_card':
//         return {
//           'companyName': 'HBL Credit Card',
//           'billNumber': '**** **** **** ${random.toString().substring(9)}',
//           'amount': 5000.0 + (random % 10000),
//         };
//       case 'rent':
//         return {
//           'companyName': 'Property Manager',
//           'billNumber': 'RENT-${random.toString().substring(7)}',
//           'amount': 25000.0 + (random % 20000),
//         };
//       case 'netflix':
//         return {
//           'companyName': 'Netflix Premium',
//           'billNumber': 'NF-${random.toString().substring(10)}',
//           'amount': 1500.0,
//         };
//       case 'bill_split':
//         return {
//           'companyName': 'Group Expense',
//           'billNumber': 'SPLIT-${random.toString().substring(8)}',
//           'amount': 1200.0 + (random % 2000),
//         };
//       default:
//         return {
//           'companyName': 'Service Provider',
//           'billNumber': 'BILL-${random.toString().substring(9)}',
//           'amount': 1000.0 + (random % 2000),
//         };
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: SingleChildScrollView(
//           physics: const BouncingScrollPhysics(),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: <Widget>[
//               SizedBox(height: 8.h),
//
//               // Animated Profile AppBar
//               SlideTransition(
//                 position: _headerSlide,
//                 child: FadeTransition(
//                   opacity: _headerFade,
//                   child: ProfileAppBar(),
//                 ),
//               ),
//
//               SizedBox(height: 24.h),
//
//               // Animated Payment Card Selector
//               ScaleTransition(
//                 scale: _cardScale,
//                 child: FadeTransition(
//                   opacity: _cardController,
//                   child: PaymentCardSelector(
//                     userId: FirebaseAuth.instance.currentUser?.uid ?? '',
//                     onCardSelect: (PaymentCard) {},
//                   ),
//                 ),
//               ),
//
//               SizedBox(height: 32.h),
//
//               // Animated Quick Access Section
//               FadeTransition(
//                 opacity: _quickAccessFade,
//                 child: SlideTransition(
//                   position: Tween<Offset>(
//                     begin: const Offset(0, 0.3),
//                     end: Offset.zero,
//                   ).animate(_quickAccessController),
//                   child: Column(
//                     children: [
//                       Padding(
//                         padding: EdgeInsets.symmetric(horizontal: 16.w),
//                         child: SectionHeader(
//                           title: "Quick Access",
//                           actionText: "View All",
//                           onActionPressed: () {
//                             Navigator.push(context, MaterialPageRoute(builder: (context) => const ShowBillsScreen()));
//                           },
//                         ),
//                       ),
//                       SizedBox(height: 16.h),
//                       _buildQuickAccessList(),
//                     ],
//                   ),
//                 ),
//               ),
//
//               SizedBox(height: 32.h),
//
//               // Animated Recharge & Bill Payments Section
//               FadeTransition(
//                 opacity: _billsFade,
//                 child: SlideTransition(
//                   position: Tween<Offset>(
//                     begin: const Offset(0, 0.3),
//                     end: Offset.zero,
//                   ).animate(_billsController),
//                   child: Column(
//                     children: [
//                       Padding(
//                         padding: EdgeInsets.symmetric(horizontal: 16.w),
//                         child: const SectionHeader(
//                           title: "Recharge & Bill Payments",
//                           actionText: null,
//                           onActionPressed: null,
//                         ),
//                       ),
//                       SizedBox(height: 16.h),
//                       _buildBillPaymentGrid(),
//                     ],
//                   ),
//                 ),
//               ),
//
//               SizedBox(height: 32.h),
//
//               // Animated Ticket Booking Section
//               FadeTransition(
//                 opacity: _ticketsFade,
//                 child: SlideTransition(
//                   position: Tween<Offset>(
//                     begin: const Offset(0, 0.3),
//                     end: Offset.zero,
//                   ).animate(_ticketsController),
//                   child: Column(
//                     children: [
//                       Padding(
//                         padding: EdgeInsets.symmetric(horizontal: 16.w),
//                         child: SectionHeader(
//                           title: "Ticket Booking",
//                           onActionPressed: () {},
//                         ),
//                       ),
//                       SizedBox(height: 16.h),
//                       _buildTicketBookingSection(),
//                     ],
//                   ),
//                 ),
//               ),
//
//               SizedBox(height: 24.h),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildQuickAccessList() {
//     return SizedBox(
//       height: 100.h,
//       child: FutureBuilder(
//         future: FirebaseFirestore.instance
//             .collection("users")
//             .doc(FirebaseAuth.instance.currentUser?.uid)
//             .collection("recipients")
//             .get(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return _buildShimmerList();
//           } else if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
//             return _buildContactsList(snapshot.data!.docs);
//           } else if (snapshot.hasError) {
//             return _buildErrorState();
//           } else {
//             return _buildEmptyState();
//           }
//         },
//       ),
//     );
//   }
//
//   Widget _buildShimmerList() {
//     return AnimationLimiter(
//       child: ListView.builder(
//         scrollDirection: Axis.horizontal,
//         physics: const BouncingScrollPhysics(),
//         padding: EdgeInsets.symmetric(horizontal: 16.w),
//         itemCount: 5,
//         itemBuilder: (BuildContext context, int index) {
//           return AnimationConfiguration.staggeredList(
//             position: index,
//             duration: const Duration(milliseconds: 150),
//             child: SlideAnimation(
//               horizontalOffset: 30.0,
//               child: FadeInAnimation(
//                 child: Padding(
//                   padding: EdgeInsets.only(right: 12.w),
//                   child: Shimmer.fromColors(
//                     baseColor: Colors.grey[300]!,
//                     highlightColor: Colors.grey[100]!,
//                     child: Column(
//                       children: [
//                         CircleAvatar(
//                           radius: 30.r,
//                           backgroundColor: Colors.grey[300],
//                         ),
//                         SizedBox(height: 8.h),
//                         Container(
//                           width: 50.w,
//                           height: 12.h,
//                           decoration: BoxDecoration(
//                             color: Colors.grey[300],
//                             borderRadius: BorderRadius.circular(6.r),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   Widget _buildContactsList(List<QueryDocumentSnapshot> docs) {
//     return AnimationLimiter(
//       child: ListView.builder(
//         scrollDirection: Axis.horizontal,
//         physics: const BouncingScrollPhysics(),
//         padding: EdgeInsets.symmetric(horizontal: 16.w),
//         itemCount: docs.length,
//         itemBuilder: (BuildContext context, int index) {
//           var data = docs[index];
//           return AnimationConfiguration.staggeredList(
//             position: index,
//             duration: const Duration(milliseconds: 200),
//             child: SlideAnimation(
//               horizontalOffset: 30.0,
//               child: FadeInAnimation(
//                 child: QuickAccessAvatar(
//                   name: data["name"] ?? "No Name",
//                   imagePath: data["imageUrl"],
//                   onTap: () {
//                     // Handle contact tap
//                   },
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   Widget _buildErrorState() {
//     return AnimationConfiguration.synchronized(
//       duration: const Duration(milliseconds: 300),
//       child: SlideAnimation(
//         verticalOffset: 20.0,
//         child: FadeInAnimation(
//           child: Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(
//                   Icons.error_outline,
//                   color: Colors.red,
//                   size: 30.r,
//                 ),
//                 SizedBox(height: 8.h),
//                 Text(
//                   "Failed to load contacts",
//                   style: TextStyle(
//                     color: Colors.grey[600],
//                     fontSize: 12.sp,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildEmptyState() {
//     return AnimationConfiguration.synchronized(
//       duration: const Duration(milliseconds: 300),
//       child: SlideAnimation(
//         verticalOffset: 20.0,
//         child: FadeInAnimation(
//           child: Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(
//                   Icons.people_outline,
//                   color: Colors.grey[400],
//                   size: 30.r,
//                 ),
//                 SizedBox(height: 8.h),
//                 Text(
//                   "No contacts found",
//                   style: TextStyle(
//                     color: Colors.grey[600],
//                     fontSize: 12.sp,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildBillPaymentGrid() {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 16.w),
//       child: AnimationLimiter(
//         child: GridView.builder(
//           shrinkWrap: true,
//           physics: const NeverScrollableScrollPhysics(),
//           gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//             crossAxisCount: 2,
//             crossAxisSpacing: 12.w,
//             mainAxisSpacing: 12.h,
//             childAspectRatio: 3.4.sp,
//           ),
//           itemCount: billItems.length,
//           itemBuilder: (BuildContext context, int index) {
//             return AnimationConfiguration.staggeredGrid(
//               position: index,
//               duration: const Duration(milliseconds: 200),
//               columnCount: 2,
//               child: ScaleAnimation(
//                 child: FadeInAnimation(
//                   child: CustomActionButton(
//                     backgroundColor: const Color(0xffEDEFFF),
//                     iconPath: billItems[index].icon,
//                     iconBackgroundColor: billItems[index].gradient[0],
//                     text: billItems[index].label,
//                     onPressed: () {
//                       context.push(
//                         billItems[index].route.toString(),
//                       );
//                     },
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
//
//   Widget _buildTicketBookingSection() {
//     final ThemeData theme = Theme.of(context);
//
//     final ticketItems = [
//       {'icon': TImageUrl.iconMovies, 'label': 'Movies', 'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (context) => MovieListScreen()))},
//       {'icon': TImageUrl.iconTrains, 'label': 'Trains', 'onTap': () => context.push(RouteNames.trainListScreen)},
//       {'icon': TImageUrl.iconBus, 'label': 'Bus', 'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (context) => BusListScreen()))},
//       {'icon': TImageUrl.iconFlight, 'label': 'Flights', 'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (context) => FlightListScreen()))},
//       {'icon': TImageUrl.iconCar, 'label': 'Car', 'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (context) => RideServiceListScreen()))},
//     ];
//
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 16.w),
//       child: AnimationLimiter(
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: AnimationConfiguration.toStaggeredList(
//             duration: const Duration(milliseconds: 150),
//             childAnimationBuilder: (widget) => SlideAnimation(
//               verticalOffset: 30.0,
//               child: FadeInAnimation(child: widget),
//             ),
//             children: ticketItems.map((item) =>
//                 _buildTicketItem(
//                   item['icon'] as String,
//                   item['label'] as String,
//                   theme,
//                   item['onTap'] as VoidCallback,
//                 )
//             ).toList(),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildTicketItem(String icon, String label, ThemeData theme, VoidCallback onTap) {
//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 200),
//       child: GestureDetector(
//         onTap: onTap,
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: <Widget>[
//             Container(
//               height: 60.h,
//               width: 59.w,
//               decoration: BoxDecoration(
//                 color: Colors.pink.withValues(alpha: 0.2),
//                 borderRadius: BorderRadius.circular(15.r),
//               ),
//               child: Image.asset(icon),
//             ),
//             SizedBox(height: 8.h),
//             Text(
//               label,
//               style: theme.textTheme.labelMedium?.copyWith(
//                 color: theme.primaryColor != Colors.white
//                     ? const Color(0xffffffff)
//                     : const Color(0xff666666),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   /// Generate ticket booking details based on ticket type
//   Map<String, dynamic> _generateTicketDetails(String ticketType) {
//     final random = DateTime.now().millisecondsSinceEpoch;
//
//     switch (ticketType) {
//       case 'movies':
//         return {
//           'companyName': 'Cinepax Cinema',
//           'ticketNumber': 'MOV-${random.toString().substring(8)}',
//           'amount': 800.0 + (random % 500),
//         };
//       case 'trains':
//         return {
//           'companyName': 'Pakistan Railways',
//           'ticketNumber': 'TRN-${random.toString().substring(7)}',
//           'amount': 1500.0 + (random % 1000),
//         };
//       case 'bus':
//         return {
//           'companyName': 'Daewoo Express',
//           'ticketNumber': 'BUS-${random.toString().substring(9)}',
//           'amount': 1200.0 + (random % 800),
//         };
//       case 'flights':
//         return {
//           'companyName': 'PIA Airlines',
//           'ticketNumber': 'FLT-${random.toString().substring(6)}',
//           'amount': 15000.0 + (random % 10000),
//         };
//       case 'car':
//         return {
//           'companyName': 'Car Rental Service',
//           'ticketNumber': 'CAR-${random.toString().substring(8)}',
//           'amount': 3000.0 + (random % 2000),
//         };
//       default:
//         return {
//           'companyName': 'Booking Service',
//           'ticketNumber': 'TKT-${random.toString().substring(9)}',
//           'amount': 1000.0 + (random % 1500),
//         };
//     }
//   }
// }
//
// /// Updated BillItem class to include type
// class BillItem {
//   final String icon;
//   final String label;
//   final String type;
//   final List<Color> gradient;
//   final String? route;
//
//   BillItem({
//     required this.icon,
//     required this.label,
//     required this.type,
//     required this.gradient,
//     this.route,
//   });
// }