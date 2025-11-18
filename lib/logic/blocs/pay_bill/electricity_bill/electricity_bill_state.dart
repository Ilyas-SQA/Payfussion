import 'package:equatable/equatable.dart';

abstract class ElectricityBillState extends Equatable {
  const ElectricityBillState();

  @override
  List<Object?> get props => [];
}

class ElectricityBillInitial extends ElectricityBillState {}

class ElectricityBillFetching extends ElectricityBillState {}

class ElectricityBillDataSet extends ElectricityBillState {
  final String providerName;
  final String accountNumber;
  final String consumerName;
  final String address;
  final String billMonth;
  final double amount;
  final double taxAmount;
  final double totalAmount;
  final String dueDate;
  final String? cardId;
  final String? cardHolderName;
  final String? cardEnding;

  const ElectricityBillDataSet({
    required this.providerName,
    required this.accountNumber,
    required this.consumerName,
    required this.address,
    required this.billMonth,
    required this.amount,
    required this.taxAmount,
    required this.totalAmount,
    required this.dueDate,
    this.cardId,
    this.cardHolderName,
    this.cardEnding,
  });

  @override
  List<Object?> get props => [
    providerName,
    accountNumber,
    consumerName,
    address,
    billMonth,
    amount,
    taxAmount,
    totalAmount,
    dueDate,
    cardId,
    cardHolderName,
    cardEnding,
  ];

  ElectricityBillDataSet copyWith({
    String? providerName,
    String? accountNumber,
    String? consumerName,
    String? address,
    String? billMonth,
    double? amount,
    double? taxAmount,
    double? totalAmount,
    String? dueDate,
    String? cardId,
    String? cardHolderName,
    String? cardEnding,
  }) {
    return ElectricityBillDataSet(
      providerName: providerName ?? this.providerName,
      accountNumber: accountNumber ?? this.accountNumber,
      consumerName: consumerName ?? this.consumerName,
      address: address ?? this.address,
      billMonth: billMonth ?? this.billMonth,
      amount: amount ?? this.amount,
      taxAmount: taxAmount ?? this.taxAmount,
      totalAmount: totalAmount ?? this.totalAmount,
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
  List<Object> get props => [transactionId, message];
}

class ElectricityBillError extends ElectricityBillState {
  final String error;

  const ElectricityBillError(this.error);

  @override
  List<Object> get props => [error];
}