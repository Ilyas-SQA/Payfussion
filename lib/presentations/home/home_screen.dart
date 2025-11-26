import 'package:cached_network_image/cached_network_image.dart';
import 'package:flip_card_swiper/flip_card_swiper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:payfussion/core/constants/app_colors.dart';
import 'package:payfussion/core/constants/image_url.dart';
import 'package:payfussion/core/theme/theme.dart';
import 'package:payfussion/data/models/card/card_model.dart';
import 'package:payfussion/presentations/home/donation/donation_screen.dart';
import 'package:payfussion/presentations/home/government_fees/government_fees_screen.dart';
import 'package:payfussion/presentations/home/paybill/pay_bill/pay_bill_screen.dart';
import 'package:payfussion/presentations/home/send_money/select_bank_screen.dart';
import 'package:payfussion/presentations/home/send_money/select_local_bank_screen.dart';
import 'package:payfussion/presentations/home/tickets/ticket_booking_screen.dart';
import 'package:payfussion/presentations/scan_to_pay/scan_to_pay_home.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/constants/fonts.dart';
import '../../core/constants/routes_name.dart';
import '../../logic/blocs/add_card/card_bloc.dart';
import '../../logic/blocs/add_card/card_event.dart';
import '../../logic/blocs/add_card/card_state.dart';
import '../../logic/blocs/notification/notification_bloc.dart';
import '../../logic/blocs/notification/notification_state.dart';
import '../../services/session_manager_service.dart';
import '../my_reward/my_reward_screen.dart';
import '../notification/notification_screen.dart';
import '../widgets/background_theme.dart';
import '../widgets/home_widgets/custom_credit_card.dart';
import '../widgets/home_widgets/custom_empty_card.dart';
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
  late AnimationController _backgroundAnimationController;
  late Animation<double> _cardScaleAnimation;
  late Animation<double> _actionButtonsAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimationSequence();
    _backgroundAnimationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
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

  static final List<String> imageUrl = <String>[
    "assets/images/cards/card_1.svg",
    "assets/images/cards/card_2.svg",
  ];

  @override
  void dispose() {
    _profileAnimationController.dispose();
    _cardAnimationController.dispose();
    _actionButtonsController.dispose();
    _transactionController.dispose();
    _backgroundAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size(double.infinity, 80),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            boxShadow: <BoxShadow>[
               BoxShadow(
                color: Colors.grey.withOpacity(0.15),
                blurRadius: 8,
                spreadRadius: 0,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    spacing: 10,
                    children: <Widget>[
                      GestureDetector(
                        onTap: () => context.push(RouteNames.profile),
                        child: Hero(
                          tag: 'profile_avatar',
                          child: Center(
                            child: Container(
                              width: 45.r,
                              height: 45.r,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 2,
                                ),
                              ),
                              child: ClipOval(
                                child: (SessionController.user.profileImageUrl != null &&
                                    SessionController.user.profileImageUrl!.isNotEmpty)
                                    ? CachedNetworkImage(
                                  imageUrl: SessionController.user.profileImageUrl!,
                                  width: 45.r,
                                  height: 45.r,
                                  fit: BoxFit.cover,
                                  placeholder: (BuildContext context, String url) => const Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  ),
                                  errorWidget: (BuildContext context, String url, Object error) =>
                                      Icon(Icons.person, size: 25.r, color: Colors.grey),
                                )
                                    : Container(
                                  color: Colors.grey[300],
                                  child: Icon(Icons.person, size: 25.r, color: Colors.grey[600]),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "Hi ${SessionController.user.fullName ?? 'User'}",
                            style: Font.montserratFont(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "${SessionController.user.email ?? ''}",
                            style: Font.montserratFont(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      BlocBuilder<NotificationBloc, NotificationState>(
                        builder: (BuildContext context, NotificationState state) {
                          int unreadCount = 0;
                          if (state is NotificationsLoaded) {
                            unreadCount = state.unreadCount;
                          }

                          final IconButton icon = IconButton(
                            icon: const Icon(CupertinoIcons.bell_fill, color: MyTheme.primaryColor,),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (BuildContext context) => const NotificationScreen(),
                                ),
                              );
                            },
                          );

                          return unreadCount > 0 ?
                          badges.Badge(
                            position: badges.BadgePosition.topEnd(top: 3, end: 3),
                            badgeContent: Text(
                              unreadCount.toString(),
                              style: Font.montserratFont(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            ),
                            badgeStyle: const badges.BadgeStyle(
                              badgeColor: MyTheme.primaryColor,
                              shape: badges.BadgeShape.circle,
                              padding: EdgeInsets.all(6),
                            ),
                            child: icon,
                          ) : icon;
                        },
                      ),
                      IconButton(
                        onPressed: (){
                          Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => const MyRewardScreen()));
                        },
                        icon: SvgPicture.asset("assets/images/home/reward.svg",height: 20,width: 20,color: MyTheme.secondaryColor,),
                      )
                    ],
                  )

                ],
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: <Widget>[
          AnimatedBackground(
            animationController: _backgroundAnimationController,
          ),
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Column(
              children: <Widget>[
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
                                children: <Widget>[
                                  SizedBox(height: 15.h),
                                  const CustomEmptyCard(),
                                ],
                              );
                            }
                            final List<CardModel> activeCards = cards.where((CardModel card) => card.isDefault).toList();
                            return Column(
                              children: <Widget>[
                                SizedBox(height: 15.h),
                                SizedBox(
                                  height: 200,
                                  child: activeCards.isEmpty ?
                                  const CustomEmptyCard() :
                                  AnimationLimiter(
                                    child: FlipCardSwiper(
                                      cardData: activeCards,
                                      onCardChange: (int newIndex) {
                                        // Optional: Do something when card changes
                                        print('Current card index: $newIndex');
                                      },
                                      onCardCollectionAnimationComplete: (bool value) {
                                        // Optional: Triggered when animation finishes
                                        print('Animation complete');
                                      },
                                      cardBuilder: (BuildContext context, int index, int visibleIndex) {
                                        final CardModel card = activeCards[index];
                                        return CustomCreditCard(
                                          cardId: card.id,
                                          cardNumber: "**** **** **** ${card.last4}",
                                          cvc: "${card.expMonth}/${card.expYear}",
                                          cardColor: AppColors.cardColor[index % AppColors.cardColor.length],
                                          cardBrand: card.brand,
                                          cardHolder: card.cardholderName,
                                          expiryDate: "${card.expMonth}/${card.expYear}",
                                          balance: '\$ 10000',
                                          imageUrl: imageUrl[index % imageUrl.length],
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            );
                          } else if (state is CardError) {
                            return Column(
                              children: <Widget>[
                                SizedBox(height: 35.h),
                                Center(
                                  child: Text(
                                    state.message,
                                    style: Font.montserratFont(color: Colors.red),
                                  ),
                                ),
                              ],
                            );
                          } else {
                            return Column(
                              children: <Widget>[
                                SizedBox(height: 15.h),
                                SizedBox(
                                  height: 200,
                                  child: AnimationLimiter(
                                    child: ListView.builder(
                                      itemCount: 3,
                                      scrollDirection: Axis.horizontal,
                                      itemBuilder: (BuildContext context, int index) {
                                        return AnimationConfiguration.staggeredList(
                                          position: index,
                                          duration: const Duration(milliseconds: 375),
                                          child: SlideAnimation(
                                            horizontalOffset: 50.0,
                                            child: FadeInAnimation(
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                                child: _buildShimmerCard(context),
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
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Column(
                        spacing: 10,
                        children: <Widget>[
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              BoxWidget(
                                title: "Send Money",
                                backgroundColor: MyTheme.primaryColor,
                                imageURL: TImageUrl.sendMoney,
                                onTap: () => <Future>{
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context){
                                      return AlertDialog(
                                        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                                        content: Text('Send Money To',style: Font.montserratFont(fontSize: 14,fontWeight: FontWeight.bold),),
                                        actions: <Widget>[
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                                            children: <Widget>[
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
                                                  Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => const SelectBankScreen()));
                                                },
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10,),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                                            children: <Widget>[
                                              BoxWidget(
                                                title: "Other Wallet",
                                                imageURL: TImageUrl.otherWallet,
                                                onTap: (){
                                                  Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => const SelectLocalBankScreen()));
                                                },
                                              ),
                                              BoxWidget(
                                                title: "Scanner QR",
                                                imageURL: TImageUrl.scanner,
                                                onTap: (){
                                                  Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => const ScanToPayHomeScreen()));
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
                                backgroundColor: MyTheme.primaryColor,
                                onTap: (){
                                  context.push(RouteNames.receiveMoneyScreen);
                                },
                              ),
                              BoxWidget(
                                title: "Pay Bills",
                                imageURL: TImageUrl.payBill,
                                backgroundColor: MyTheme.primaryColor,
                                onTap: (){
                                  Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => const PayBillScreen()));
                                },
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              BoxWidget(
                                title: "Convert Currency",
                                imageURL: TImageUrl.convertCurrency,
                                backgroundColor: MyTheme.primaryColor,
                                onTap: (){
                                  context.push(RouteNames.currencyExchangeView);
                                },
                              ),
                              BoxWidget(
                                title: "Ticket Booking",
                                imageURL: TImageUrl.ticketBooking,
                                backgroundColor: MyTheme.secondaryColor,
                                onTap: (){
                                  Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => const TicketBookingScreen()));
                                },
                              ),
                              BoxWidget(
                                title: "Insurance",
                                backgroundColor: MyTheme.secondaryColor,
                                imageURL: TImageUrl.insurance,
                                onTap: (){
                                  Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => const InsuranceScreen()));                            },
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              BoxWidget(
                                title: "Apply Card",
                                backgroundColor: MyTheme.secondaryColor,
                                imageURL: TImageUrl.applyCard,
                                onTap: (){
                                  Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => const ApplyCardScreen()));
                                },
                              ),
                              BoxWidget(
                                title: "Government Fees",
                                backgroundColor: MyTheme.secondaryColor,
                                imageURL: TImageUrl.governmentFee,
                                onTap: (){
                                  Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => const GovernmentFeesScreen()));
                                },
                              ),
                              BoxWidget(
                                title: "Donation",
                                backgroundColor: MyTheme.secondaryColor,
                                imageURL: TImageUrl.donation,
                                onTap: (){
                                  Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => const DonateListScreen()));
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  ),
                ),

              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerCard(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
      highlightColor: isDarkMode ? Colors.grey[500]! : Colors.grey[100]!,
      child: Container(
        width: 300,
        height: 180,
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey[800]! : Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 50,
                height: 30,
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey[700]! : Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const Spacer(),
              Container(
                width: double.infinity,
                height: 20,
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey[700]! : Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: 80,
                height: 16,
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey[700]! : Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
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
      builder: (BuildContext context, Widget? child) {
        return ShaderMask(
          shaderCallback: (Rect bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: const <Color>[
                Colors.transparent,
                Colors.white54,
                Colors.transparent,
              ],
              stops: <double>[
                _animation.value - 0.3,
                _animation.value,
                _animation.value + 0.3,
              ],
              transform: const GradientRotation(0),
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
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 5,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            SvgPicture.asset(imageUrl,color: MyTheme.primaryColor,height: 30,width: 30,),
            // SizedBox(height: 5.h),
            Text(
              title,
              style: Font.montserratFont(fontSize: 10.sp, fontWeight: FontWeight.normal,),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}


class BoxWidget extends StatelessWidget {
  const BoxWidget({super.key, required this.title, required this.imageURL, required this.onTap,this.backgroundColor = MyTheme.primaryColor});
  final String title;
  final String imageURL;
  final VoidCallback onTap;
  final Color? backgroundColor;

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
          boxShadow: <BoxShadow>[
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
          children: <Widget>[
            SvgPicture.asset(imageURL, height: 27.h, width: 30.w,color: backgroundColor,),
            Text(title,style: Font.montserratFont(fontSize: 10,fontWeight: FontWeight.w500),textAlign: TextAlign.center,),
          ],
        ),
      ),
    );
  }
}

