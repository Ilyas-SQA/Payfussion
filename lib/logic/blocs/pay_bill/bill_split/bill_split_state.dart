import 'package:equatable/equatable.dart';

abstract class BillSplitState extends Equatable {
  const BillSplitState();

  @override
  List<Object?> get props => <Object?>[];
}

class BillSplitInitial extends BillSplitState {}

class BillSplitDataSet extends BillSplitState {
  final String billName;
  final double totalAmount;
  final int numberOfPeople;
  final List<String> participantNames;
  final String splitType;
  final Map<String, double>? customAmounts;
  final double amountPerPerson;
  final double taxAmount;
  final double totalWithTax;
  final String? cardId;
  final String? cardHolderName;
  final String? cardEnding;

  const BillSplitDataSet({
    required this.billName,
    required this.totalAmount,
    required this.numberOfPeople,
    required this.participantNames,
    required this.splitType,
    this.customAmounts,
    required this.amountPerPerson,
    required this.taxAmount,
    required this.totalWithTax,
    this.cardId,
    this.cardHolderName,
    this.cardEnding,
  });

  @override
  List<Object?> get props => <Object?>[
    billName,
    totalAmount,
    numberOfPeople,
    participantNames,
    splitType,
    customAmounts,
    amountPerPerson,
    taxAmount,
    totalWithTax,
    cardId,
    cardHolderName,
    cardEnding,
  ];

  BillSplitDataSet copyWith({
    String? billName,
    double? totalAmount,
    int? numberOfPeople,
    List<String>? participantNames,
    String? splitType,
    Map<String, double>? customAmounts,
    double? amountPerPerson,
    double? taxAmount,
    double? totalWithTax,
    String? cardId,
    String? cardHolderName,
    String? cardEnding,
  }) {
    return BillSplitDataSet(
      billName: billName ?? this.billName,
      totalAmount: totalAmount ?? this.totalAmount,
      numberOfPeople: numberOfPeople ?? this.numberOfPeople,
      participantNames: participantNames ?? this.participantNames,
      splitType: splitType ?? this.splitType,
      customAmounts: customAmounts ?? this.customAmounts,
      amountPerPerson: amountPerPerson ?? this.amountPerPerson,
      taxAmount: taxAmount ?? this.taxAmount,
      totalWithTax: totalWithTax ?? this.totalWithTax,
      cardId: cardId ?? this.cardId,
      cardHolderName: cardHolderName ?? this.cardHolderName,
      cardEnding: cardEnding ?? this.cardEnding,
    );
  }
}

class BillSplitProcessing extends BillSplitState {}

class BillSplitSuccess extends BillSplitState {
  final String transactionId;
  final String message;

  const BillSplitSuccess({
    required this.transactionId,
    required this.message,
  });

  @override
  List<Object> get props => <Object>[transactionId, message];
}

class BillSplitError extends BillSplitState {
  final String error;

  const BillSplitError(this.error);

  @override
  List<Object> get props => <Object>[error];
}