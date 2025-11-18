import 'package:equatable/equatable.dart';

abstract class ElectricityBillEvent extends Equatable {
  const ElectricityBillEvent();

  @override
  List<Object?> get props => [];
}

class FetchBillDetails extends ElectricityBillEvent {
  final String providerName;
  final String accountNumber;

  const FetchBillDetails({
    required this.providerName,
    required this.accountNumber,
  });

  @override
  List<Object> get props => [providerName, accountNumber];
}

class SetBillData extends ElectricityBillEvent {
  final String providerName;
  final String accountNumber;
  final String consumerName;
  final String address;
  final String billMonth;
  final double amount;
  final String dueDate;

  const SetBillData({
    required this.providerName,
    required this.accountNumber,
    required this.consumerName,
    required this.address,
    required this.billMonth,
    required this.amount,
    required this.dueDate,
  });

  @override
  List<Object> get props => [
    providerName,
    accountNumber,
    consumerName,
    address,
    billMonth,
    amount,
    dueDate,
  ];
}

class SetSelectedCardForBill extends ElectricityBillEvent {
  final String cardId;
  final String cardHolderName;
  final String cardEnding;

  const SetSelectedCardForBill({
    required this.cardId,
    required this.cardHolderName,
    required this.cardEnding,
  });

  @override
  List<Object> get props => [cardId, cardHolderName, cardEnding];
}

class ProcessBillPayment extends ElectricityBillEvent {
  const ProcessBillPayment();
}

class ResetBillPayment extends ElectricityBillEvent {
  const ResetBillPayment();
}