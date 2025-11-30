import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:payfussion/logic/blocs/pay_bill/electricity_bill/electricity_bill_bloc.dart';
import 'package:payfussion/logic/blocs/pay_bill/electricity_bill/electricity_bill_state.dart';
import 'package:payfussion/logic/blocs/pay_bill/electricity_bill/electricity_bill_event.dart';
import 'package:payfussion/logic/blocs/pay_bill/internet_bill/internet_bill_bloc.dart';
import 'package:payfussion/logic/blocs/pay_bill/internet_bill/internet_bill_state.dart';
import 'package:payfussion/logic/blocs/pay_bill/internet_bill/internet_bill_event.dart';
import 'package:payfussion/logic/blocs/pay_bill/postpaid_bill/postpaid_bill_bloc.dart';
import 'package:payfussion/logic/blocs/pay_bill/postpaid_bill/postpaid_bill_state.dart';
import 'package:payfussion/logic/blocs/pay_bill/postpaid_bill/postpaid_bill_event.dart';
import 'package:payfussion/logic/blocs/pay_bill/rent_payment/rent_payment_bloc.dart';
import 'package:payfussion/logic/blocs/pay_bill/rent_payment/rent_payment_state.dart';
import 'package:payfussion/presentations/home/paybill/internet_bill/internet_bill_summary_screen.dart';
import 'package:payfussion/presentations/home/paybill/rent_payment/rent_payment_summary_screen.dart';
import 'package:payfussion/services/payment_service.dart';
import '../../data/models/card/card_model.dart';
import '../../logic/blocs/add_card/card_bloc.dart';
import '../../logic/blocs/add_card/card_event.dart';
import '../../logic/blocs/add_card/card_state.dart';
import '../../logic/blocs/donation/donation_bloc.dart';
import '../../logic/blocs/donation/donation_event.dart';
import '../../logic/blocs/donation/donation_status.dart';
import '../../logic/blocs/governement_fee/governement_fee_bloc.dart';
import '../../logic/blocs/governement_fee/governement_fee_event.dart';
import '../../logic/blocs/governement_fee/governement_fee_state.dart';
import '../../logic/blocs/pay_bill/bill_split/bill_split_bloc.dart';
import '../../logic/blocs/pay_bill/bill_split/bill_split_event.dart';
import '../../logic/blocs/pay_bill/bill_split/bill_split_state.dart';
import '../../logic/blocs/pay_bill/dth_bill/dth_bill_bloc.dart';
import '../../logic/blocs/pay_bill/dth_bill/dth_bill_event.dart';
import '../../logic/blocs/pay_bill/dth_bill/dth_bill_state.dart';
import '../../logic/blocs/pay_bill/mobile_recharge/mobile_recharge_bloc.dart';
import '../../logic/blocs/pay_bill/mobile_recharge/mobile_recharge_event.dart';
import '../../logic/blocs/pay_bill/mobile_recharge/mobile_recharge_state.dart';
import '../../logic/blocs/pay_bill/gas_bill/gas_bill_bloc.dart';
import '../../logic/blocs/pay_bill/gas_bill/gas_bill_event.dart';
import '../../logic/blocs/pay_bill/gas_bill/gas_bill_state.dart';
import '../../logic/blocs/pay_bill/movies/movies_bloc.dart';
import '../../logic/blocs/pay_bill/movies/movies_event.dart';
import '../../logic/blocs/pay_bill/movies/movies_state.dart';
import '../../logic/blocs/pay_bill/credit_card_loan/credit_card_loan_bloc.dart';
import '../../logic/blocs/pay_bill/credit_card_loan/credit_card_loan_event.dart';
import '../../logic/blocs/pay_bill/credit_card_loan/credit_card_loan_state.dart';
import '../../logic/blocs/pay_bill/rent_payment/rent_payment_event.dart';
import '../../presentations/home/government_fees/governement_fees_summary_screen.dart';
import '../../presentations/home/paybill/bill_split/bill_split_summary_screen.dart';
import '../../presentations/home/paybill/dth_recharge/dth_recharge_summary_screen.dart';
import '../../presentations/home/paybill/mobile_recharge/mobile_recharge_summary_screen.dart';
import '../../presentations/home/paybill/gas_bill/gas_bill_summary_screen.dart';
import '../../presentations/home/paybill/electricity_bill/electricity_bill_summary_screen.dart';
import '../../presentations/home/paybill/postpaid_bill/postpaid_bill_summary_screen.dart';
import '../../presentations/home/paybill/movies/movies_summary_screen.dart';
import '../../presentations/home/paybill/credit_card_loan/credit_card_loan_summary_screen.dart';
import '../../presentations/home/donation/donation_summary_screen.dart';
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
    final MobileRechargeState mobileRechargeState = context.read<MobileRechargeBloc>().state;
    final ElectricityBillState electricityBillState = context.read<ElectricityBillBloc>().state;
    final DthRechargeState dthState = context.read<DthRechargeBloc>().state;
    final PostpaidBillState postpaidBillState = context.read<PostpaidBillBloc>().state;
    final GasBillState gasBillState = context.read<GasBillBloc>().state;
    final InternetBillState internetBillState = context.read<InternetBillBloc>().state;
    final CreditCardLoanState creditLoanState = context.read<CreditCardLoanBloc>().state;
    final RentPaymentState rentPaymentState = context.read<RentPaymentBloc>().state;
    final MoviesState moviesState = context.read<MoviesBloc>().state;
    final BillSplitState billSplitState = context.read<BillSplitBloc>().state;
    final DonationState donationState = context.read<DonationBloc>().state;
    final GovernmentFeeState governmentFeeState = context.read<GovernmentFeeBloc>().state;

    if (donationState is DonationDataSet) {
      // Donation flow
      context.read<DonationBloc>().add(SetSelectedCardForDonation(
        cardId: _selectedCard!.id,
        cardHolderName: _selectedCard!.cardholderName,
        cardEnding: _selectedCard!.cardEnding,
      ));

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => const DonationSummaryScreen(),
        ),
      );
    }else if (governmentFeeState is GovernmentFeeDataSet) {
      // Government fee flow
      context.read<GovernmentFeeBloc>().add(SetSelectedCardForGovernmentFee(
        cardId: _selectedCard!.id,
        cardHolderName: _selectedCard!.cardholderName,
        cardEnding: _selectedCard!.cardEnding,
      ));

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => const GovernmentFeeSummaryScreen(),
        ),
      );
    } else if (mobileRechargeState is MobileRechargeDataSet) {
      // Mobile recharge flow
      context.read<MobileRechargeBloc>().add(SetSelectedCard(
        cardId: _selectedCard!.id,
        cardHolderName: _selectedCard!.cardholderName,
        cardEnding: _selectedCard!.cardEnding,
      ));

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => const RechargeSummaryScreen(),
        ),
      );
    } else if(rentPaymentState is RentPaymentDataSet){
      // Rent payment flow
      context.read<RentPaymentBloc>().add(SetRentPaymentCard(
        cardId: _selectedCard!.id,
        cardHolderName: _selectedCard!.cardholderName,
        cardEnding: _selectedCard!.cardEnding,
      ));
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => const RentPaymentSummaryScreen(),
        ),
      );
    }else if(internetBillState is InternetBillDataSet){
      // Internet bill flow
      context.read<InternetBillBloc>().add(SetSelectedCardForInternetBill(
        cardId: _selectedCard!.id,
        cardHolderName: _selectedCard!.cardholderName,
        cardEnding: _selectedCard!.cardEnding,
      ));
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => const InternetBillSummaryScreen(),
        ),
      );
    }else if (electricityBillState is ElectricityBillDataSet) {
      // Electricity bill flow
      context.read<ElectricityBillBloc>().add(SetSelectedCardForElectricityBill(
        cardId: _selectedCard!.id,
        cardHolderName: _selectedCard!.cardholderName,
        cardEnding: _selectedCard!.cardEnding,
      ));

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => const ElectricityBillSummaryScreen(),
        ),
      );
    } else if (gasBillState is GasBillDataSet) {
      // Gas bill flow
      context.read<GasBillBloc>().add(SetSelectedCardForGasBill(
        cardId: _selectedCard!.id,
        cardHolderName: _selectedCard!.cardholderName,
        cardEnding: _selectedCard!.cardEnding,
      ));

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => const GasBillSummaryScreen(),
        ),
      );
    } else if (moviesState is MoviesDataSet) {
      // Movies flow
      context.read<MoviesBloc>().add(SetSelectedCardForMovies(
        cardId: _selectedCard!.id,
        cardHolderName: _selectedCard!.cardholderName,
        cardEnding: _selectedCard!.cardEnding,
      ));

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => const MoviesSummaryScreen(),
        ),
      );
    } else if (creditLoanState is CreditCardLoanDataSet) {
      // Credit card loan flow
      context.read<CreditCardLoanBloc>().add(SetSelectedCardForLoan(
        cardId: _selectedCard!.id,
        cardHolderName: _selectedCard!.cardholderName,
        cardEnding: _selectedCard!.cardEnding,
      ));

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => const CreditCardLoanSummaryScreen(),
        ),
      );
    } else if (dthState is DthRechargeDataSet) {
      // DTH recharge flow
      context.read<DthRechargeBloc>().add(SetSelectedCardForDth(
        cardId: _selectedCard!.id,
        cardHolderName: _selectedCard!.cardholderName,
        cardEnding: _selectedCard!.cardEnding,
      ));

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => const DthSummaryScreen(),
        ),
      );
    } else if (postpaidBillState is PostpaidBillDataSet) {
      // Postpaid bill flow
      context.read<PostpaidBillBloc>().add(SetSelectedCardForPostpaidBill(
        cardId: _selectedCard!.id,
        cardHolderName: _selectedCard!.cardholderName,
        cardEnding: _selectedCard!.cardEnding,
      ));

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => const PostpaidBillSummaryScreen(),
        ),
      );
    } else if (billSplitState is BillSplitDataSet) {
      // Bill split flow
      context.read<BillSplitBloc>().add(SetSelectedCardForBillSplit(
        cardId: _selectedCard!.id,
        cardHolderName: _selectedCard!.cardholderName,
        cardEnding: _selectedCard!.cardEnding,
      ));

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => const BillSplitSummaryScreen(),
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
                children: <Widget>[
                  Expanded(
                    child: ListView(
                      children: <Widget>[
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
                                boxShadow: <BoxShadow>[
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.3),
                                    blurRadius: 5,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: <Widget>[
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
                                      children: <Widget>[
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
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  blurRadius: 5,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
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