import 'package:equatable/equatable.dart';

abstract class PostpaidBillEvent extends Equatable {
  const PostpaidBillEvent();

  @override
  List<Object?> get props => <Object?>[];
}

// Set postpaid bill data
class SetPostpaidBillData extends PostpaidBillEvent {
  final String providerName;
  final String planType;
  final String startingPrice;
  final List<String> features;
  final String mobileNumber;
  final String billNumber;
  final String accountHolderName;
  final String billCycle;
  final double amount;
  final String? email;
  final bool saveForFuture;

  const SetPostpaidBillData({
    required this.providerName,
    required this.planType,
    required this.startingPrice,
    required this.features,
    required this.mobileNumber,
    required this.billNumber,
    required this.accountHolderName,
    required this.billCycle,
    required this.amount,
    this.email,
    this.saveForFuture = false,
  });

  @override
  List<Object?> get props => <Object?>[
    providerName,
    planType,
    startingPrice,
    features,
    mobileNumber,
    billNumber,
    accountHolderName,
    billCycle,
    amount,
    email,
    saveForFuture,
  ];
}

// Set selected card for postpaid bill
class SetSelectedCardForPostpaidBill extends PostpaidBillEvent {
  final String cardId;
  final String cardHolderName;
  final String cardEnding;

  const SetSelectedCardForPostpaidBill({
    required this.cardId,
    required this.cardHolderName,
    required this.cardEnding,
  });

  @override
  List<Object> get props => <Object>[cardId, cardHolderName, cardEnding];
}

// Process postpaid bill payment
class ProcessPostpaidBillPayment extends PostpaidBillEvent {
  const ProcessPostpaidBillPayment();
}

// Reset postpaid bill state
class ResetPostpaidBill extends PostpaidBillEvent {
  const ResetPostpaidBill();
}