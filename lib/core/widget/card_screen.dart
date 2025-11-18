import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:payfussion/services/payment_service.dart';
import '../../data/models/card/card_model.dart';
import '../../logic/blocs/add_card/card_bloc.dart';
import '../../logic/blocs/add_card/card_event.dart';
import '../../logic/blocs/add_card/card_state.dart';
import '../../logic/blocs/pay_bill/mobile_recharge/mobile_recharge_bloc.dart';
import '../../logic/blocs/pay_bill/mobile_recharge/mobile_recharge_event.dart';
import '../../logic/blocs/pay_bill/mobile_recharge/mobile_recharge_state.dart';
import '../../logic/blocs/pay_bill/gas_bill/gas_bill_bloc.dart';
import '../../logic/blocs/pay_bill/gas_bill/gas_bill_event.dart';
import '../../logic/blocs/pay_bill/gas_bill/gas_bill_state.dart';
import '../../logic/blocs/pay_bill/movies/movies_bloc.dart';
import '../../logic/blocs/pay_bill/movies/movies_event.dart';
import '../../logic/blocs/pay_bill/movies/movies_state.dart';
import '../../presentations/home/paybill/mobile_recharge/mobile_recharge_summary_screen.dart';
import '../../presentations/home/paybill/gas_bill/gas_bill_summary_screen.dart';
import '../../presentations/home/paybill/movies/movies_summary_screen.dart';
import '../theme/theme.dart';

class CardsScreen extends StatefulWidget {
  const CardsScreen({super.key});

  @override
  State<CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {
  CardModel? _selectedCard;

  void _proceedToSummary() {
    if (_selectedCard == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a card')),
      );
      return;
    }

    // Check which bloc has active state
    final mobileRechargeState = context.read<MobileRechargeBloc>().state;
    final gasBillState = context.read<GasBillBloc>().state;
    final moviesState = context.read<MoviesBloc>().state;

    if (mobileRechargeState is MobileRechargeDataSet) {
      // Set selected card in mobile recharge bloc
      context.read<MobileRechargeBloc>().add(SetSelectedCard(
        cardId: _selectedCard!.id,
        cardHolderName: _selectedCard!.cardholderName,
        cardEnding: _selectedCard!.cardEnding,
      ));

      // Navigate to mobile recharge summary screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const RechargeSummaryScreen(),
        ),
      );
    } else if (gasBillState is GasBillDataSet) {
      // Set selected card in gas bill bloc
      context.read<GasBillBloc>().add(SetSelectedCardForGasBill(
        cardId: _selectedCard!.id,
        cardHolderName: _selectedCard!.cardholderName,
        cardEnding: _selectedCard!.cardEnding,
      ));

      // Navigate to gas bill summary screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const GasBillSummaryScreen(),
        ),
      );
    } else if (moviesState is MoviesDataSet) {
      // Set selected card in movies bloc
      context.read<MoviesBloc>().add(SetSelectedCardForMovies(
        cardId: _selectedCard!.id,
        cardHolderName: _selectedCard!.cardholderName,
        cardEnding: _selectedCard!.cardEnding,
      ));

      // Navigate to movies summary screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const MoviesSummaryScreen(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid payment state')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Card Payment"),
      ),
      body: BlocProvider(
        create: (BuildContext context) => CardBloc()..add(LoadCards()),
        child: BlocBuilder<CardBloc, CardState>(
          builder: (BuildContext context, CardState state) {
            if (state is CardLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is CardLoaded) {
              if (state.cards.isEmpty) {
                return const Center(child: Text("No cards available. Please add a card first."));
              }

              if (_selectedCard == null) {
                _selectedCard = state.cards.firstWhere((CardModel card) => card.isDefault,
                  orElse: () => state.cards.first,
                );
              }

              return Column(
                children: [
                  Expanded(
                    child: ListView(
                      children: [
                        ...state.cards.map((CardModel card) {
                          final bool isSelected = _selectedCard?.id == card.id;

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedCard = card;
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.all(16.w),
                              margin: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
                              decoration: BoxDecoration(
                                color: Theme.of(context).scaffoldBackgroundColor,
                                borderRadius: BorderRadius.circular(12.r),
                                border: isSelected
                                    ? Border.all(color: MyTheme.primaryColor, width: 2)
                                    : null,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.3),
                                    blurRadius: 5,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Image.asset(
                                    card.brandIconPath,
                                    height: 40.h,
                                    width: 40.w,
                                    color: Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white,
                                  ),
                                  SizedBox(width: 16.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          card.cardholderName,
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          card.cardEnding,
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        Text(
                                          'Exp: ${card.formattedExpiry}',
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isSelected)
                                    Icon(
                                      Icons.check_circle,
                                      color: MyTheme.primaryColor,
                                      size: 24.sp,
                                    ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),

                        // Add New Card Button
                        GestureDetector(
                          onTap: () {
                            PaymentService().saveCard(context);
                          },
                          child: Container(
                            padding: EdgeInsets.all(16.w),
                            margin: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
                            decoration: BoxDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(color: MyTheme.primaryColor, width: 1.5),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  blurRadius: 5,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_circle_outline,
                                  color: MyTheme.primaryColor,
                                  size: 24.sp,
                                ),
                                SizedBox(width: 12.w),
                                Text(
                                  "Add New Card",
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                    color: MyTheme.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Continue Button
                  if (_selectedCard != null)
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16.w),
                      child: ElevatedButton(
                        onPressed: _proceedToSummary,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: MyTheme.primaryColor,
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: Text(
                          "Continue",
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}