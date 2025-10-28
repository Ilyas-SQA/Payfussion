import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:payfussion/core/constants/routes_name.dart';
import 'package:payfussion/presentations/widgets/add_card_widgets/custom_card_fields.dart';
import '../../../core/constants/image_url.dart';
import '../../core/constants/fonts.dart';
import '../../logic/blocs/add_card/card_bloc.dart';
import '../../logic/blocs/add_card/card_event.dart';
import '../../logic/blocs/add_card/card_state.dart';
import '../widgets/add_card_widgets/expiry_date_validator.dart';

class AddCardHomescreen extends StatefulWidget {
  const AddCardHomescreen({super.key});
  @override
  State<AddCardHomescreen> createState() => _AddCardHomescreenState();
}

class _AddCardHomescreenState extends State<AddCardHomescreen> {
  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController expiryDateController = TextEditingController();
  final TextEditingController cardHolderNameController =
      TextEditingController();
  final TextEditingController cvvController = TextEditingController();

  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  bool isCvvFocused = false;

  @override
  void initState() {
    super.initState();

    // Add listeners to update the card preview
    cardNumberController.addListener(() {
      setState(() {
        cardNumber = cardNumberController.text;
      });
    });

    expiryDateController.addListener(() {
      setState(() {
        expiryDate = expiryDateController.text;
      });
    });

    cardHolderNameController.addListener(() {
      setState(() {
        cardHolderName = cardHolderNameController.text;
      });
    });

    cvvController.addListener(() {
      setState(() {
        cvvCode = cvvController.text;
      });
    });
  }

  // void _handleSubmit() async {
  //   try {
  //     StripePayment.paymentRequestWithCardForm(CardFormPaymentRequest())
  //         .then((paymentMethod) {
  //           // Successfully got payment method
  //           print(paymentMethod.id);
  //           // Optionally save the paymentMethod ID locally or send it to your server
  //           _savePaymentMethodLocally(paymentMethod);
  //         })
  //         .catchError((error) {
  //           print(error);
  //         });
  //   } catch (e) {
  //     print('Error: $e');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return BlocProvider(
      create: (_) => CardBloc(),
      child: SafeArea(
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: Padding(
            padding: EdgeInsets.all(16.w),
            child: BlocConsumer<CardBloc, CardState>(
              listener: (BuildContext context, CardState state) {
                if (state is AddCardSuccess) {
                  // Clear all text fields
                  cardNumberController.clear();
                  expiryDateController.clear();
                  cardHolderNameController.clear();
                  cvvController.clear();


                  // Show success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Card successfully added!")),
                  );

                  // Navigate back to home screen
                  context.go(RouteNames.homeScreen);
                } else if (state is AddCardFailure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("You cannot add more than 5 cards.")),
                  );
                }
              },
              builder: (BuildContext context, CardState state) {
                return SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      SizedBox(height: 15.h),
                      InkWell(
                        onTap: () {
                          context.go(RouteNames.homeScreen);
                        },
                        child: Row(
                          children: <Widget>[
                            Icon(
                              Icons.arrow_back_ios_new,
                              color: const Color(0xff2D9CDB),
                              size: 24.r,
                            ),
                            SizedBox(width: 2.w),
                            Text(
                              'Back',
                              style: Font.montserratFont(
                                fontSize: 20.sp,
                                color: const Color(0xff2D9CDB),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16.h),
                      // Credit Card Widget
                      CreditCardWidget(
                        cardNumber: cardNumber,
                        expiryDate: expiryDate,
                        cardHolderName: cardHolderName,
                        cvvCode: cvvCode,
                        showBackView: isCvvFocused,
                        onCreditCardWidgetChange: (CreditCardBrand brand) {
                          if (kDebugMode) {
                            print('Card brand: ${brand.brandName}');
                          }
                        },
                        backgroundImage: TImageUrl.iconCardBGBlur,
                        height: 200.h,
                        width: 342.w,
                        animationDuration: const Duration(milliseconds: 340),
                        obscureCardNumber: true, // This will show asterisks automatically
                        obscureCardCvv: true,
                        isChipVisible: true,
                        isSwipeGestureEnabled: true,
                        labelCardHolder: 'CARD HOLDER',
                        labelValidThru: 'VALID\nTHRU',
                        isHolderNameVisible: true,
                      ),

                      SizedBox(height: 20.h),
                      // Card Details
                      Container(
                        height: 470.h,
                        width: 342.w,
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15.r),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Column(
                            children: <Widget>[
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "Enter Card Details",
                                  style: Font.montserratFont(
                                    fontSize: 14.sp,
                                    color: const Color(0xff2D9CDB),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(height: 20.h),
                              //text "Card Number" in blue color above the field
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "Card Number",
                                  style: Font.montserratFont(
                                    fontSize: 14.sp,
                                    color: Colors.black,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ),
                              SizedBox(height: 10.h),
                              // Input Field for Card Number
                              CustomCardField(
                                labelText: "Card Number",
                                hintText: "XXXX XXXX XXXX XXXX",
                                controller: cardNumberController,
                                keyboardType: TextInputType.number,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(16),
                                ],
                                onChanged: (String value) {
                                  setState(() {
                                    cardNumber = value;
                                  });
                                },
                              ),
                              SizedBox(height: 20.h),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "Expiry Date",
                                  style: Font.montserratFont(
                                    fontSize: 14.sp,
                                    color: Colors.black,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ),
                              SizedBox(height: 10.h),
                              CustomCardField(
                                labelText: "Expiry Date (MM/YY)",
                                hintText: "MM/YY",
                                controller: expiryDateController,
                                keyboardType: TextInputType.number,
                                inputFormatters: <TextInputFormatter>[
                                  ExpiryDateFormatter(),
                                  LengthLimitingTextInputFormatter(5),
                                ],
                                onChanged: (String value) {
                                  if (!isExpiryDateValid(value)) {
                                    // Show error or handle invalid date
                                    print("Invalid expiry date");
                                  } else {
                                    print("Valid expiry date");
                                  }
                                  setState(() {
                                    expiryDate = value;
                                  });
                                },
                              ),
                              SizedBox(height: 20.h),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "Card Holder Name",
                                  style: Font.montserratFont(
                                    fontSize: 14.sp,
                                    color: Colors.black,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ),
                              SizedBox(height: 5.h),
                              CustomCardField(
                                labelText: "Card Holder Name",
                                hintText: "Enter Card Holder Name",
                                controller: cardHolderNameController,
                                keyboardType: TextInputType.name,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'[a-zA-Z\s]'),
                                  ),
                                  LengthLimitingTextInputFormatter(30),
                                ],
                                onChanged: (String value) {
                                  setState(() {
                                    cardHolderName = value;
                                  });
                                },
                              ),
                              SizedBox(height: 20.h),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "CVV",
                                  style: Font.montserratFont(
                                    fontSize: 14.sp,
                                    color: Colors.black,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ),
                              SizedBox(height: 5.h),
                              Focus(
                                onFocusChange: (bool hasFocus) {
                                  setState(() {
                                    isCvvFocused = hasFocus;
                                  });
                                },
                                child: CustomCardField(
                                  labelText: "CVV",
                                  hintText: "Enter CVV",
                                  controller: cvvController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(4),
                                  ],
                                  onChanged: (String value) {
                                    setState(() {
                                      cvvCode = value;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Input Fields
                      SizedBox(height: 20.h),
                      // Add Card Button
                      InkWell(
                        onTap: () {
                          final String cardNumber = cardNumberController.text.trim();
                          final String expiryDate = expiryDateController.text.trim();
                          final String cardHolderName = cardHolderNameController.text.trim();
                          final String cvv = cvvController.text.trim();

                          if (cardNumber.isEmpty || expiryDate.isEmpty || cardHolderName.isEmpty || cvv.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Please fill in all fields."),
                              ),
                            );
                            return;
                          }

                          if (!isExpiryDateValid(expiryDate)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Invalid expiry date. Please enter a valid date.",
                                ),
                              ),
                            );
                            return;
                          }

                          context.read<CardBloc>().add(
                            AddCardInFirebase(
                              cardNumber: cardNumber,
                              cvv: cvv,
                              expiryMonth: expiryDate,
                              expiryYear: expiryDate,
                              holderName: cardHolderName,
                            ),
                          );

                          // context.read<AddCardBloc>().add(CreateIntent());

                        },
                        child: Material(
                          elevation: 5,
                          borderRadius: BorderRadius.all(Radius.circular(24.r)),
                          child: Container(
                            height: 48.h,
                            width: 193.w,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(
                                Radius.circular(24.r),
                              ),
                              gradient: LinearGradient(
                                colors: <Color>[
                                  const Color(0xff2D9CDB),
                                  const Color(0xff2D9CDB).withOpacity(0.6),
                                ],
                                stops: const <double>[0.5, 1],
                              ),
                            ),
                            child: Align(
                              alignment: Alignment.center,
                              child: Text(
                                "Proceed",
                                style: Font.montserratFont(
                                  fontSize: 18.sp,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
