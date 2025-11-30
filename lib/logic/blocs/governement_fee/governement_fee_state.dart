import 'package:equatable/equatable.dart';

abstract class GovernmentFeeState extends Equatable {
  const GovernmentFeeState();

  @override
  List<Object?> get props => <Object?>[];
}

class GovernmentFeeInitial extends GovernmentFeeState {}

class GovernmentFeeDataSet extends GovernmentFeeState {
  final String serviceName;
  final String agency;
  final String inputLabel;
  final String inputValue;
  final double amount;
  final double taxAmount;
  final double totalAmount;
  final String? cardId;
  final String? cardHolderName;
  final String? cardEnding;

  const GovernmentFeeDataSet({
    required this.serviceName,
    required this.agency,
    required this.inputLabel,
    required this.inputValue,
    required this.amount,
    required this.taxAmount,
    required this.totalAmount,
    this.cardId,
    this.cardHolderName,
    this.cardEnding,
  });

  @override
  List<Object?> get props => <Object?>[
    serviceName,
    agency,
    inputLabel,
    inputValue,
    amount,
    taxAmount,
    totalAmount,
    cardId,
    cardHolderName,
    cardEnding,
  ];

  GovernmentFeeDataSet copyWith({
    String? serviceName,
    String? agency,
    String? inputLabel,
    String? inputValue,
    double? amount,
    double? taxAmount,
    double? totalAmount,
    String? cardId,
    String? cardHolderName,
    String? cardEnding,
  }) {
    return GovernmentFeeDataSet(
      serviceName: serviceName ?? this.serviceName,
      agency: agency ?? this.agency,
      inputLabel: inputLabel ?? this.inputLabel,
      inputValue: inputValue ?? this.inputValue,
      amount: amount ?? this.amount,
      taxAmount: taxAmount ?? this.taxAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      cardId: cardId ?? this.cardId,
      cardHolderName: cardHolderName ?? this.cardHolderName,
      cardEnding: cardEnding ?? this.cardEnding,
    );
  }
}

class GovernmentFeeProcessing extends GovernmentFeeState {}

class GovernmentFeeSuccess extends GovernmentFeeState {
  final String transactionId;
  final String message;

  const GovernmentFeeSuccess({
    required this.transactionId,
    required this.message,
  });

  @override
  List<Object> get props => <Object>[transactionId, message];
}

class GovernmentFeeError extends GovernmentFeeState {
  final String error;

  const GovernmentFeeError(this.error);

  @override
  List<Object> get props => <Object>[error];
}