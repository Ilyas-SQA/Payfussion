import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:payfussion/core/constants/app_colors.dart';
import 'package:payfussion/core/constants/image_url.dart';
import 'package:payfussion/core/theme/theme.dart';
import 'package:payfussion/data/models/card/card_model.dart';
import 'package:payfussion/presentations/home/government_fees/government_fees_screen.dart';
import 'package:payfussion/presentations/home/paybill/pay_bill_screen.dart';
import 'package:payfussion/presentations/home/send_money/select_bank_screen.dart';
import 'package:payfussion/presentations/home/send_money/select_local_bank_screen.dart';
import 'package:payfussion/presentations/home/tickets/ticket_booking_screen.dart';
import 'package:payfussion/presentations/scan_to_pay/scan_to_pay_home.dart';
import 'package:payfussion/presentations/widgets/profile_app_bar.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/constants/routes_name.dart';
import '../../data/models/transaction/transaction_model.dart';
import '../../logic/blocs/add_card/card_bloc.dart';
import '../../logic/blocs/add_card/card_event.dart';
import '../../logic/blocs/add_card/card_state.dart';
import '../widgets/home_widgets/custom_credit_card.dart';
import '../widgets/home_widgets/custom_empty_card.dart';
import '../widgets/home_widgets/transaction_item.dart';
import '../widgets/home_widgets/transaction_items_header.dart';
import 'apply_card/apply_card_screen.dart';
import 'insurance/insurance_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _profileAnimationController;
  late AnimationController _cardAnimationController;
  late AnimationController _actionButtonsController;
  late AnimationController _transactionController;

  late Animation<double> _profileAnimation;
  late Animation<Offset> _profileSlideAnimation;
  late Animation<double> _cardScaleAnimation;
  late Animation<double> _actionButtonsAnimation;
  late Animation<Offset> _transactionSlideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimationSequence();
  }

  void _initializeAnimations() {
    // Profile animation
    _profileAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    // Card animation
    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // Action buttons animation
    _actionButtonsController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Transaction animation
    _transactionController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );

    // Profile animations
    _profileAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _profileAnimationController,
      curve: Curves.easeOutCubic,
    ));

    _profileSlideAnimation = Tween<Offset>(
      begin: const Offset(-1.0, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _profileAnimationController,
      curve: Curves.elasticOut,
    ));

    // Card scale animation
    _cardScaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _cardAnimationController,
      curve: Curves.elasticOut,
    ));

    // Action buttons animation
    _actionButtonsAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _actionButtonsController,
      curve: Curves.easeOutBack,
    ));

    // Transaction slide animation
    _transactionSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _transactionController,
      curve: Curves.easeOutCubic,
    ));
  }

  void _startAnimationSequence() async {
    await _profileAnimationController.forward();
    await Future.delayed(const Duration(milliseconds: 100));
    await _cardAnimationController.forward();
    await Future.delayed(const Duration(milliseconds: 100));
    await _actionButtonsController.forward();
    await Future.delayed(const Duration(milliseconds: 100));
    await _transactionController.forward();
  }

  @override
  void dispose() {
    _profileAnimationController.dispose();
    _cardAnimationController.dispose();
    _actionButtonsController.dispose();
    _transactionController.dispose();
    super.dispose();
  }

  DateTime _getStartOfDay() {
    final DateTime now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  DateTime _getEndOfDay() {
    final DateTime now = DateTime.now();
    return DateTime(now.year, now.month, now.day, 23, 59, 59);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(5.0),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              SizedBox(height: 10.h),

              /// Animated Profile Section
              SlideTransition(
                position: _profileSlideAnimation,
                child: FadeTransition(
                  opacity: _profileAnimation,
                  child: const ProfileAppBar(),
                ),
              ),

              /// Animated Card Section
              ScaleTransition(
                scale: _cardScaleAnimation,
                child: FadeTransition(
                  opacity: _cardAnimationController,
                  child: BlocProvider(
                    create: (BuildContext context) => CardBloc()..add(LoadCards()),
                    child: BlocBuilder<CardBloc, CardState>(
                      builder: (BuildContext context, CardState state) {
                        if (state is CardLoaded) {
                          final List<CardModel> cards = state.cards;
                          if (cards.isEmpty) {
                            return Column(
                              children: [
                                SizedBox(height: 15.h),
                                const CustomEmptyCard(),
                              ],
                            );
                          }
                          final activeCards = cards.where((card) => card.isDefault).toList();
                          return Column(
                            children: [
                              SizedBox(height: 15.h),
                              SizedBox(
                                height: 200,
                                child: activeCards.isEmpty ?
                                const CustomEmptyCard() :
                                AnimationLimiter(
                                  child: ListView.builder(
                                    itemCount: activeCards.length,
                                    scrollDirection: Axis.horizontal,
                                    itemBuilder: (context, index) {
                                      final card = activeCards[index];
                                      return AnimationConfiguration.staggeredList(
                                        position: index,
                                        duration: const Duration(milliseconds: 300),
                                        child: SlideAnimation(
                                          horizontalOffset: 50.0,
                                          child: FadeInAnimation(
                                            child: Padding(
                                              padding: const EdgeInsets.only(left: 3),
                                              child: CustomCreditCard(
                                                cardId: card.id,
                                                cardNumber: "**** **** **** ${card.last4}",
                                                cvc: "${card.expMonth}/${card.expYear}",
                                                cardColor: AppColors.cardColor[index % AppColors.cardColor.length],
                                                cardBrand: card.brand,
                                                cardHolder: 'Ilyas Khan',
                                                expiryDate:"${card.expMonth}/${card.expYear}",
                                                balance: '\$ 10000',
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          );
                        } else if (state is CardError) {
                          return Column(
                            children: [
                              SizedBox(height: 35.h),
                              Center(
                                child: Text(
                                  state.message,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          );
                        } else {
                          return Column(
                            children: [
                              SizedBox(height: 15.h),
                              SizedBox(
                                height: 200,
                                child: AnimationLimiter(
                                  child: ListView.builder(
                                    itemCount: 3,
                                    scrollDirection: Axis.horizontal,
                                    itemBuilder: (context, index) {
                                      return AnimationConfiguration.staggeredList(
                                        position: index,
                                        duration: const Duration(milliseconds: 375),
                                        child: SlideAnimation(
                                          horizontalOffset: 50.0,
                                          child: FadeInAnimation(
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 10),
                                              child: _buildShimmerCard(),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          );
                        }
                      },
                    ),
                  ),
                ),
              ),

              SizedBox(height: 30.h,),

              /// Animated Action Buttons
              FadeTransition(
                opacity: _actionButtonsAnimation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.5),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: _actionButtonsController,
                    curve: Curves.easeOutCubic,
                  )),
                  child: Column(
                    spacing: 10,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          BoxWidget(
                            title: "Send Money",
                            imageURL: TImageUrl.sendMoney,
                            onTap: () => {
                              showDialog(
                                context: context,
                                builder: (context){
                                  return AlertDialog(
                                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                                    content: const Text('Send Money To'),
                                    actions: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: [
                                          BoxWidget(
                                            title: "PayFussion Transfer",
                                            imageURL: TImageUrl.bankTransfer,
                                            onTap: (){
                                              context.push(RouteNames.sendMoneyHome);
                                            },
                                          ),
                                          BoxWidget(
                                            title: "Bank Transfer",
                                            imageURL: TImageUrl.bankTransfer,
                                            onTap: (){
                                              Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => SelectBankScreen()));
                                            },
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 10,),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: [
                                          BoxWidget(
                                            title: "Other Wallet",
                                            imageURL: TImageUrl.otherWallet,
                                            onTap: (){
                                              Navigator.push(context, MaterialPageRoute(builder: (context) => SelectLocalBankScreen()));
                                            },
                                          ),
                                          BoxWidget(
                                            title: "Scanner QR",
                                            imageURL: TImageUrl.scanner,
                                            onTap: (){
                                              Navigator.push(context, MaterialPageRoute(builder: (context) => ScanToPayHomeScreen()));
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  );
                                },
                              )
                            },
                          ),
                          BoxWidget(
                            title: "Recived Money",
                            imageURL: TImageUrl.recivedMoney,
                            onTap: (){
                              context.push(RouteNames.receiveMoneyScreen);
                            },
                          ),
                          BoxWidget(
                            title: "Pay Bills",
                            imageURL: TImageUrl.payBill,
                            onTap: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const PayBillScreen()));
                            },
                          ),
                          BoxWidget(
                            title: "Convert Currency",
                            imageURL: TImageUrl.convertCurrency,
                            onTap: (){
                              context.push(RouteNames.currencyExchangeView);
                            },
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          BoxWidget(
                            title: "Ticket Booking",
                            imageURL: TImageUrl.ticketBooking,
                            onTap: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context) => TicketBookingScreen()));
                            },
                          ),
                          BoxWidget(
                            title: "Insurance",
                            imageURL: TImageUrl.insurance,
                            onTap: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context) => InsuranceScreen()));                            },
                          ),
                          BoxWidget(
                            title: "Apply Card",
                            imageURL: TImageUrl.applyCard,
                            onTap: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const ApplyCardScreen()));
                            },
                          ),
                          BoxWidget(
                            title: "Government Fees",
                            imageURL: TImageUrl.governmentFee,
                            onTap: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context) => GovernmentFeesScreen()));
                            },
                          ),
                        ],
                      ),
                    ],
                  )
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }


  // Widget _buildActionButtons(BuildContext context) {
  //   final List<Map<String, Object>> actionButtons = [
  //     {
  //       'backgroundColor': Theme.of(context).scaffoldBackgroundColor,
  //       'iconPath': TImageUrl.sendMoney,
  //       'iconBackgroundColor': MyTheme.primaryColor,
  //       'text': "Send Money",
  //       'onPressed': () => {
  //         showDialog(
  //           context: context,
  //           builder: (context){
  //             return AlertDialog(
  //               backgroundColor: Theme.of(context).scaffoldBackgroundColor,
  //               content: const Text('Send Money To'),
  //               actions: [
  //                 Row(
  //                   mainAxisAlignment: MainAxisAlignment.spaceAround,
  //                   children: [
  //                     SendMoneyWidget(
  //                       title: "PayFussion Transfer",
  //                       imageUrl: TImageUrl.bankTransfer,
  //                       onTap: (){
  //                         context.push(RouteNames.sendMoneyHome);
  //                       },
  //                     ),
  //                     SendMoneyWidget(
  //                       title: "Bank Transfer",
  //                       imageUrl: TImageUrl.bankTransfer,
  //                       onTap: (){
  //                         Navigator.push(context, MaterialPageRoute(builder: (context) => SelectBankScreen()));
  //                       },
  //                     ),
  //                   ],
  //                 ),
  //                 SizedBox(height: 10,),
  //                 Row(
  //                   mainAxisAlignment: MainAxisAlignment.spaceAround,
  //                   children: [
  //                     SendMoneyWidget(
  //                       title: "Other Wallet",
  //                       imageUrl: TImageUrl.otherWallet,
  //                       onTap: (){
  //                         Navigator.push(context, MaterialPageRoute(builder: (context) => SelectLocalBankScreen()));
  //                       },
  //                     ),
  //                     SendMoneyWidget(
  //                       title: "Scanner QR",
  //                       imageUrl: TImageUrl.scanner,
  //                       onTap: (){
  //                         Navigator.push(context, MaterialPageRoute(builder: (context) => ScanToPayHomeScreen()));
  //                       },
  //                     ),
  //                   ],
  //                 ),
  //               ],
  //             );
  //           },
  //         )
  //       },
  //     },
  //     {
  //       'backgroundColor': Theme.of(context).scaffoldBackgroundColor,
  //       'iconPath': TImageUrl.recivedMoney,
  //       'iconBackgroundColor': MyTheme.secondaryColor,
  //       'text': "Receive Money",
  //       'onPressed': () => context.push(RouteNames.receiveMoneyScreen),
  //     },
  //     {
  //       'backgroundColor': Theme.of(context).scaffoldBackgroundColor,
  //       'iconPath': TImageUrl.payBill,
  //       'iconBackgroundColor': MyTheme.primaryColor,
  //       'text': "Pay Bills",
  //       'onPressed': () => Navigator.push(context, MaterialPageRoute(builder: (context) => PayBillScreen())),
  //     },
  //     {
  //       'backgroundColor': Theme.of(context).scaffoldBackgroundColor,
  //       'iconPath': TImageUrl.convertCurrency,
  //       'iconBackgroundColor': MyTheme.secondaryColor,
  //       'text': "Convert Currency",
  //       'onPressed': () => context.push(RouteNames.currencyExchangeView),
  //     },
  //     {
  //       'backgroundColor': Theme.of(context).scaffoldBackgroundColor,
  //       'iconPath': TImageUrl.ticketBooking,
  //       'iconBackgroundColor': MyTheme.primaryColor,
  //       'text': "Ticket Booking",
  //       'onPressed': () => Navigator.push(context, MaterialPageRoute(builder: (context) => TicketBookingScreen())),
  //     },
  //     {
  //       'backgroundColor': Theme.of(context).scaffoldBackgroundColor,
  //       'iconPath': TImageUrl.insurance,
  //       'iconBackgroundColor': MyTheme.secondaryColor,
  //       'text': "Insurance",
  //       'onPressed': () => Navigator.push(context, MaterialPageRoute(builder: (context) => InsuranceScreen())),
  //     },
  //     {
  //       'backgroundColor': Theme.of(context).scaffoldBackgroundColor,
  //       'iconPath': TImageUrl.applyCard,
  //       'iconBackgroundColor': MyTheme.primaryColor,
  //       'text': "Apply Card",
  //       'onPressed': () => Navigator.push(context, MaterialPageRoute(builder: (context) => ApplyCardScreen())),
  //
  //     },
  //     {
  //       'backgroundColor': Theme.of(context).scaffoldBackgroundColor,
  //       'iconPath': TImageUrl.governmentFee,
  //       'iconBackgroundColor': MyTheme.secondaryColor,
  //       'text': "Government Fees",
  //       'onPressed': () => Navigator.push(context, MaterialPageRoute(builder: (context) => GovernmentFeesScreen())),
  //     },
  //   ];
  //
  //   return Column(
  //     children: [
  //       SizedBox(height: 20.h),
  //       AnimationLimiter(
  //         child: Column(
  //           children: [
  //             Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceAround,
  //               children: [
  //                 AnimationConfiguration.staggeredList(
  //                   position: 0,
  //                   duration: const Duration(milliseconds: 300),
  //                   child: SlideAnimation(
  //                     verticalOffset: 30.0,
  //                     child: FadeInAnimation(
  //                       child: CustomActionButton(
  //                         backgroundColor: actionButtons[0]['backgroundColor'] as Color,
  //                         iconPath: actionButtons[0]['iconPath'] as String,
  //                         iconBackgroundColor: actionButtons[0]['iconBackgroundColor'] as Color,
  //                         text: actionButtons[0]['text'] as String,
  //                         onPressed: actionButtons[0]['onPressed'] as VoidCallback,
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //                 AnimationConfiguration.staggeredList(
  //                   position: 1,
  //                   duration: const Duration(milliseconds: 300),
  //                   child: SlideAnimation(
  //                     verticalOffset: 30.0,
  //                     child: FadeInAnimation(
  //                       child: CustomActionButton(
  //                         backgroundColor: actionButtons[1]['backgroundColor'] as Color,
  //                         iconPath: actionButtons[1]['iconPath'] as String,
  //                         iconBackgroundColor: actionButtons[1]['iconBackgroundColor'] as Color,
  //                         text: actionButtons[1]['text'] as String,
  //                         onPressed: actionButtons[1]['onPressed'] as VoidCallback,
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //             SizedBox(height: 10.h),
  //             Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceAround,
  //               children: [
  //                 AnimationConfiguration.staggeredList(
  //                   position: 2,
  //                   duration: const Duration(milliseconds: 300),
  //                   child: SlideAnimation(
  //                     verticalOffset: 30.0,
  //                     child: FadeInAnimation(
  //                       child: CustomActionButton(
  //                         backgroundColor: actionButtons[2]['backgroundColor'] as Color,
  //                         iconPath: actionButtons[2]['iconPath'] as String,
  //                         iconBackgroundColor: actionButtons[2]['iconBackgroundColor'] as Color,
  //                         text: actionButtons[2]['text'] as String,
  //                         onPressed: actionButtons[2]['onPressed'] as VoidCallback,
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //                 AnimationConfiguration.staggeredList(
  //                   position: 3,
  //                   duration: const Duration(milliseconds: 300),
  //                   child: SlideAnimation(
  //                     verticalOffset: 30.0,
  //                     child: FadeInAnimation(
  //                       child: CustomActionButton(
  //                         backgroundColor: actionButtons[3]['backgroundColor'] as Color,
  //                         iconPath: actionButtons[3]['iconPath'] as String,
  //                         iconBackgroundColor: actionButtons[3]['iconBackgroundColor'] as Color,
  //                         text: actionButtons[3]['text'] as String,
  //                         onPressed: actionButtons[3]['onPressed'] as VoidCallback,
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //             SizedBox(height: 10.h),
  //             Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceAround,
  //               children: [
  //                 AnimationConfiguration.staggeredList(
  //                   position: 2,
  //                   duration: const Duration(milliseconds: 300),
  //                   child: SlideAnimation(
  //                     verticalOffset: 30.0,
  //                     child: FadeInAnimation(
  //                       child: CustomActionButton(
  //                         backgroundColor: actionButtons[4]['backgroundColor'] as Color,
  //                         iconPath: actionButtons[4]['iconPath'] as String,
  //                         iconBackgroundColor: actionButtons[4]['iconBackgroundColor'] as Color,
  //                         text: actionButtons[4]['text'] as String,
  //                         onPressed: actionButtons[4]['onPressed'] as VoidCallback,
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //                 AnimationConfiguration.staggeredList(
  //                   position: 3,
  //                   duration: const Duration(milliseconds: 300),
  //                   child: SlideAnimation(
  //                     verticalOffset: 30.0,
  //                     child: FadeInAnimation(
  //                       child: CustomActionButton(
  //                         backgroundColor: actionButtons[5]['backgroundColor'] as Color,
  //                         iconPath: actionButtons[5]['iconPath'] as String,
  //                         iconBackgroundColor: actionButtons[5]['iconBackgroundColor'] as Color,
  //                         text: actionButtons[5]['text'] as String,
  //                         onPressed: actionButtons[5]['onPressed'] as VoidCallback,
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //             SizedBox(height: 10.h),
  //             Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceAround,
  //               children: [
  //                 AnimationConfiguration.staggeredList(
  //                   position: 2,
  //                   duration: const Duration(milliseconds: 300),
  //                   child: SlideAnimation(
  //                     verticalOffset: 30.0,
  //                     child: FadeInAnimation(
  //                       child: CustomActionButton(
  //                         backgroundColor: actionButtons[6]['backgroundColor'] as Color,
  //                         iconPath: actionButtons[6]['iconPath'] as String,
  //                         iconBackgroundColor: actionButtons[6]['iconBackgroundColor'] as Color,
  //                         text: actionButtons[6]['text'] as String,
  //                         onPressed: actionButtons[6]['onPressed'] as VoidCallback,
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //                 AnimationConfiguration.staggeredList(
  //                   position: 3,
  //                   duration: const Duration(milliseconds: 300),
  //                   child: SlideAnimation(
  //                     verticalOffset: 30.0,
  //                     child: FadeInAnimation(
  //                       child: CustomActionButton(
  //                         backgroundColor: actionButtons[7]['backgroundColor'] as Color,
  //                         iconPath: actionButtons[7]['iconPath'] as String,
  //                         iconBackgroundColor: actionButtons[7]['iconBackgroundColor'] as Color,
  //                         text: actionButtons[7]['text'] as String,
  //                         onPressed: actionButtons[7]['onPressed'] as VoidCallback,
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ],
  //         ),
  //       ),
  //     ],
  //   );
  // }

  Widget _buildTransactionSection() {
    return Column(
      children: [
        SizedBox(height: 20.h),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("users")
              .doc(FirebaseAuth.instance.currentUser?.uid)
              .collection('transactions')
              .where('created_at', isGreaterThanOrEqualTo: _getStartOfDay())
              .where('created_at', isLessThanOrEqualTo: _getEndOfDay())
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildShimmerLoading(context);
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 80.h),
                    ScaleTransition(
                      scale: Tween<double>(begin: 0.5, end: 1.0).animate(
                        CurvedAnimation(
                          parent: _transactionController,
                          curve: Curves.elasticOut,
                        ),
                      ),
                      child: const Center(child: Text('No transactions for today.')),
                    ),
                  ],
                ),
              );
            }

            print("Fetched transactions: ${snapshot.data!.docs.length}");

            var transactions = snapshot.data!.docs.map((doc) {
              return TransactionModel.fromDoc(doc);
            }).toList();

            return AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              height: 392.0,
              width: 405.0,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(10.0),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: MyTheme.primaryColor.withOpacity(0.6),
                    blurRadius: 20,
                    offset: const Offset(0, 7),
                  ),
                ],
              ),
              child: Column(
                children: <Widget>[
                  const TransactionItemHeader(
                    heading: 'Today',
                    showTrailingButton: true,
                  ),
                  SizedBox(height: 20.0),
                  Expanded(
                    child: AnimationLimiter(
                      child: ListView.builder(
                        itemCount: transactions.length,
                        itemBuilder: (context, index) {
                          final tx = transactions[index];
                          return AnimationConfiguration.staggeredList(
                            position: index,
                            duration: const Duration(milliseconds: 375),
                            child: SlideAnimation(
                              verticalOffset: 50.0,
                              child: FadeInAnimation(
                                child: Padding(
                                  padding: EdgeInsets.only(bottom: 10.0),
                                  child: TransactionItem(
                                    iconPath: TImageUrl.iconCreditCard,
                                    heading: tx.recipientName,
                                    transactionId: tx.id,
                                    moneyValue: '${tx.amount.toStringAsFixed(2)}',
                                    status: tx.status,
                                    date: DateFormat('MM/dd/yyyy').format(tx.createdAt),
                                    time: DateFormat('hh:mm a').format(tx.createdAt),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildShimmerCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: 300,
        height: 180,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 50,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const Spacer(),
              Container(
                width: double.infinity,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: 80,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerLoading(BuildContext context) {
    return AnimationLimiter(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        height: 392.0,
        width: 405.0,
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: const Color(0xff8CB7FF).withOpacity(0.6),
              blurRadius: 20,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildShimmerBox(width: 60, height: 20),
                  _buildShimmerBox(width: 80, height: 32, borderRadius: 16),
                ],
              ),
            ),
            SizedBox(height: 10.0),
            Expanded(
              child: ListView.builder(
                itemCount: 4,
                itemBuilder: (context, index) {
                  return AnimationConfiguration.staggeredList(
                    position: index,
                    duration: const Duration(milliseconds: 375),
                    child: SlideAnimation(
                      verticalOffset: 30.0,
                      child: FadeInAnimation(
                        child: _buildTransactionShimmer(),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionShimmer() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          _buildShimmerBox(width: 48, height: 48, borderRadius: 24),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildShimmerBox(width: 120, height: 16),
                    _buildShimmerBox(width: 70, height: 16),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildShimmerBox(width: 80, height: 12),
                    _buildShimmerBox(width: 60, height: 20, borderRadius: 10),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerBox({
    required double width,
    required double height,
    double borderRadius = 4.0,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.grey.shade300,
            Colors.grey.shade100,
            Colors.grey.shade300,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: _ShimmerAnimation(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
      ),
    );
  }
}

class _ShimmerAnimation extends StatefulWidget {
  final Widget child;

  const _ShimmerAnimation({required this.child});

  @override
  _ShimmerAnimationState createState() => _ShimmerAnimationState();
}

class _ShimmerAnimationState extends State<_ShimmerAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: const [
                Colors.transparent,
                Colors.white54,
                Colors.transparent,
              ],
              stops: [
                _animation.value - 0.3,
                _animation.value,
                _animation.value + 0.3,
              ],
              transform: GradientRotation(0),
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}


class SendMoneyWidget extends StatelessWidget {
  const SendMoneyWidget({super.key, required this.title, required this.imageUrl, required this.onTap});

  final String title;
  final String imageUrl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 80.h,
        width: 80.w,
        padding: EdgeInsets.all(8.r),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(5.r),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 5,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            SvgPicture.asset(imageUrl,color: MyTheme.primaryColor,height: 30,width: 30,),
            // SizedBox(height: 5.h),
            Text(
              title,
              style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.normal,),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}


class BoxWidget extends StatelessWidget {
  const BoxWidget({super.key, required this.title, required this.imageURL, required this.onTap});
  final String title;
  final String imageURL;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 95.h,
        width: 80.h,
        padding: EdgeInsets.all(5.w),
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          // spacing: 10,
          children: [
            SvgPicture.asset(imageURL, height: 27.h, width: 30.w,color: MyTheme.primaryColor,),
            Text(title,style: const TextStyle(fontSize: 10,fontWeight: FontWeight.w500),textAlign: TextAlign.center,),
          ],
        ),
      ),
    );
  }
}

