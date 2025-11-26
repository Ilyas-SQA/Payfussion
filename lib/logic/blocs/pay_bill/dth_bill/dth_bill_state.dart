import 'package:equatable/equatable.dart';

abstract class DthRechargeState extends Equatable {
  const DthRechargeState();

  @override
  List<Object?> get props => <Object?>[];
}

class DthRechargeInitial extends DthRechargeState {}

class DthRechargeDataSet extends DthRechargeState {
  final String providerName;
  final String subscriberId;
  final String customerName;
  final String selectedPlan;
  final double amount;
  final double taxAmount;
  final double totalAmount;
  final double rating;
  final String? cardId;
  final String? cardHolderName;
  final String? cardEnding;

  const DthRechargeDataSet({
    required this.providerName,
    required this.subscriberId,
    required this.customerName,
    required this.selectedPlan,
    required this.amount,
    required this.taxAmount,
    required this.totalAmount,
    required this.rating,
    this.cardId,
    this.cardHolderName,
    this.cardEnding,
  });

  @override
  List<Object?> get props => <Object?>[
    providerName,
    subscriberId,
    customerName,
    selectedPlan,
    amount,
    taxAmount,
    totalAmount,
    rating,
    cardId,
    cardHolderName,
    cardEnding,
  ];

  DthRechargeDataSet copyWith({
    String? providerName,
    String? subscriberId,
    String? customerName,
    String? selectedPlan,
    double? amount,
    double? taxAmount,
    double? totalAmount,
    double? rating,
    String? cardId,
    String? cardHolderName,
    String? cardEnding,
  }) {
    return DthRechargeDataSet(
      providerName: providerName ?? this.providerName,
      subscriberId: subscriberId ?? this.subscriberId,
      customerName: customerName ?? this.customerName,
      selectedPlan: selectedPlan ?? this.selectedPlan,
      amount: amount ?? this.amount,
      taxAmount: taxAmount ?? this.taxAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      rating: rating ?? this.rating,
      cardId: cardId ?? this.cardId,
      cardHolderName: cardHolderName ?? this.cardHolderName,
      cardEnding: cardEnding ?? this.cardEnding,
    );
  }
}

class DthRechargeProcessing extends DthRechargeState {}

class DthRechargeSuccess extends DthRechargeState {
  final String transactionId;
  final String message;

  const DthRechargeSuccess({
    required this.transactionId,
    required this.message,
  });

  @override
  List<Object> get props => <Object>[transactionId, message];
}

class DthRechargeError extends DthRechargeState {
  final String error;

  const DthRechargeError(this.error);

  @override
  List<Object> get props => <Object>[error];
}