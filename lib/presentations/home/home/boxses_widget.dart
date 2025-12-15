import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:payfussion/presentations/home/paybill/pay_bill/pay_bill_screen.dart';
import 'package:payfussion/presentations/home/send_money/select_bank_screen.dart';
import 'package:payfussion/presentations/home/send_money/select_local_bank_screen.dart';
import 'package:payfussion/presentations/home/tickets/ticket_booking_screen.dart';
import 'package:payfussion/presentations/scan_to_pay/scan_to_pay_home.dart';
import 'package:payfussion/presentations/home/donation/donation_screen.dart';
import 'package:payfussion/presentations/home/government_fees/government_fees_screen.dart';
import '../../../core/constants/fonts.dart';
import '../../../core/constants/image_url.dart';
import '../../../core/constants/routes_name.dart';
import '../../../core/theme/theme.dart';
import '../apply_card/apply_card_screen.dart';
import '../insurance/insurance_screen.dart';
import 'box_widget.dart';


class BoxsesWidget extends StatelessWidget {
  const BoxsesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
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
    );
  }
}
