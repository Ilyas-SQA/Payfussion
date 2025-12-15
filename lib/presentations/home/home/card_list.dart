import 'package:flip_card_swiper/flip_card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/fonts.dart';
import '../../../data/models/card/card_model.dart';
import '../../../logic/blocs/add_card/card_bloc.dart';
import '../../../logic/blocs/add_card/card_event.dart';
import '../../../logic/blocs/add_card/card_state.dart';
import '../../widgets/home_widgets/custom_credit_card.dart';
import '../../widgets/home_widgets/custom_empty_card.dart';

class CardList extends StatefulWidget {
  const CardList({super.key});

  @override
  State<CardList> createState() => _CardListState();
}

class _CardListState extends State<CardList> with TickerProviderStateMixin{
  late Animation<double> _cardScaleAnimation;
  late AnimationController _cardAnimationController;

  static final List<String> imageUrl = <String>[
    "assets/images/cards/card_1.svg",
    "assets/images/cards/card_2.svg",
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimationSequence();
  }

  void _initializeAnimations() {

    /// Card animation
    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );


    /// Card scale animation
    _cardScaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _cardAnimationController,
      curve: Curves.elasticOut,
    ));
  }

  void _startAnimationSequence() async {
   await _cardAnimationController.forward();
    await Future.delayed(const Duration(milliseconds: 100));
  }


  @override
  void dispose() {
    _cardAnimationController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
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
