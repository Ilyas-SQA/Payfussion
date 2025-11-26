import 'package:equatable/equatable.dart';

abstract class PostpaidBillState extends Equatable {
  const PostpaidBillState();

  @override
  List<Object?> get props => <Object?>[];
}

class PostpaidBillInitial extends PostpaidBillState {}

class PostpaidBillDataSet extends PostpaidBillState {
  final String providerName;
  final String planType;
  final String startingPrice;
  final List<String> features;
  final String mobileNumber;
  final String billNumber;
  final String accountHolderName;
  final String billCycle;
  final double amount;
  final double taxAmount;
  final double totalAmount;
  final String? email;
  final bool saveForFuture;
  final String? cardId;
  final String? cardHolderName;
  final String? cardEnding;

  const PostpaidBillDataSet({
    required this.providerName,
    required this.planType,
    required this.startingPrice,
    required this.features,
    required this.mobileNumber,
    required this.billNumber,
    required this.accountHolderName,
    required this.billCycle,
    required this.amount,
    required this.taxAmount,
    required this.totalAmount,
    this.email,
    this.saveForFuture = false,
    this.cardId,
    this.cardHolderName,
    this.cardEnding,
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
    taxAmount,
    totalAmount,
    email,
    saveForFuture,
    cardId,
    cardHolderName,
    cardEnding,
  ];

  PostpaidBillDataSet copyWith({
    String? providerName,
    String? planType,
    String? startingPrice,
    List<String>? features,
    String? mobileNumber,
    String? billNumber,
    String? accountHolderName,
    String? billCycle,
    double? amount,
    double? taxAmount,
    double? totalAmount,
    String? email,
    bool? saveForFuture,
    String? cardId,
    String? cardHolderName,
    String? cardEnding,
  }) {
    return PostpaidBillDataSet(
      providerName: providerName ?? this.providerName,
      planType: planType ?? this.planType,
      startingPrice: startingPrice ?? this.startingPrice,
      features: features ?? this.features,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      billNumber: billNumber ?? this.billNumber,
      accountHolderName: accountHolderName ?? this.accountHolderName,
      billCycle: billCycle ?? this.billCycle,
      amount: amount ?? this.amount,
      taxAmount: taxAmount ?? this.taxAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      email: email ?? this.email,
      saveForFuture: saveForFuture ?? this.saveForFuture,
      cardId: cardId ?? this.cardId,
      cardHolderName: cardHolderName ?? this.cardHolderName,
      cardEnding: cardEnding ?? this.cardEnding,
    );
  }
}

class PostpaidBillProcessing extends PostpaidBillState {}

class PostpaidBillSuccess extends PostpaidBillState {
  final String transactionId;
  final String message;

  const PostpaidBillSuccess({
    required this.transactionId,
    required this.message,
  });

  @override
  List<Object> get props => <Object>[transactionId, message];
}

class PostpaidBillError extends PostpaidBillState {
  final String error;

  const PostpaidBillError(this.error);

  @override
  List<Object> get props => <Object>[error];
}