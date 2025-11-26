import 'package:equatable/equatable.dart';

abstract class ElectricityBillState extends Equatable {
  const ElectricityBillState();

  @override
  List<Object?> get props => <Object?>[];
}

class ElectricityBillInitial extends ElectricityBillState {}

class ElectricityBillDataSet extends ElectricityBillState {
  final String providerName;
  final String region;
  final String averageRate;
  final String accountNumber;
  final String consumerName;
  final String address;
  final String billMonth;
  final double amount;
  final double taxAmount;
  final double totalAmount;
  final String unitsConsumed;
  final String previousReading;
  final String currentReading;
  final String dueDate;
  final String? cardId;
  final String? cardHolderName;
  final String? cardEnding;

  const ElectricityBillDataSet({
    required this.providerName,
    required this.region,
    required this.averageRate,
    required this.accountNumber,
    required this.consumerName,
    required this.address,
    required this.billMonth,
    required this.amount,
    required this.taxAmount,
    required this.totalAmount,
    required this.unitsConsumed,
    required this.previousReading,
    required this.currentReading,
    required this.dueDate,
    this.cardId,
    this.cardHolderName,
    this.cardEnding,
  });

  @override
  List<Object?> get props => <Object?>[
    providerName,
    region,
    averageRate,
    accountNumber,
    consumerName,
    address,
    billMonth,
    amount,
    taxAmount,
    totalAmount,
    unitsConsumed,
    previousReading,
    currentReading,
    dueDate,
    cardId,
    cardHolderName,
    cardEnding,
  ];

  ElectricityBillDataSet copyWith({
    String? providerName,
    String? region,
    String? averageRate,
    String? accountNumber,
    String? consumerName,
    String? address,
    String? billMonth,
    double? amount,
    double? taxAmount,
    double? totalAmount,
    String? unitsConsumed,
    String? previousReading,
    String? currentReading,
    String? dueDate,
    String? cardId,
    String? cardHolderName,
    String? cardEnding,
  }) {
    return ElectricityBillDataSet(
      providerName: providerName ?? this.providerName,
      region: region ?? this.region,
      averageRate: averageRate ?? this.averageRate,
      accountNumber: accountNumber ?? this.accountNumber,
      consumerName: consumerName ?? this.consumerName,
      address: address ?? this.address,
      billMonth: billMonth ?? this.billMonth,
      amount: amount ?? this.amount,
      taxAmount: taxAmount ?? this.taxAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      unitsConsumed: unitsConsumed ?? this.unitsConsumed,
      previousReading: previousReading ?? this.previousReading,
      currentReading: currentReading ?? this.currentReading,
      dueDate: dueDate ?? this.dueDate,
      cardId: cardId ?? this.cardId,
      cardHolderName: cardHolderName ?? this.cardHolderName,
      cardEnding: cardEnding ?? this.cardEnding,
    );
  }
}

class ElectricityBillProcessing extends ElectricityBillState {}

class ElectricityBillSuccess extends ElectricityBillState {
  final String transactionId;
  final String message;

  const ElectricityBillSuccess({
    required this.transactionId,
    required this.message,
  });

  @override
  List<Object> get props => <Object>[transactionId, message];
}

class ElectricityBillError extends ElectricityBillState {
  final String error;

  const ElectricityBillError(this.error);

  @override
  List<Object> get props => <Object>[error];
}