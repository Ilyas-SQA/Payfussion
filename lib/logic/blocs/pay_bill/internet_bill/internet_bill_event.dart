import 'package:equatable/equatable.dart';

abstract class InternetBillEvent extends Equatable {
  const InternetBillEvent();

  @override
  List<Object?> get props => <Object?>[];
}

// Set internet bill data
class SetInternetBillData extends InternetBillEvent {
  final String companyName;
  final String connectionType;
  final String maxSpeed;
  final String coverage;
  final String accountNumber;
  final String consumerName;
  final String address;
  final String billMonth;
  final double amount;
  final String planName;
  final String dataUsage;
  final String downloadSpeed;
  final String uploadSpeed;
  final String dueDate;

  const SetInternetBillData({
    required this.companyName,
    required this.connectionType,
    required this.maxSpeed,
    required this.coverage,
    required this.accountNumber,
    required this.consumerName,
    required this.address,
    required this.billMonth,
    required this.amount,
    required this.planName,
    required this.dataUsage,
    required this.downloadSpeed,
    required this.uploadSpeed,
    required this.dueDate,
  });

  @override
  List<Object?> get props => <Object?>[
    companyName,
    connectionType,
    maxSpeed,
    coverage,
    accountNumber,
    consumerName,
    address,
    billMonth,
    amount,
    planName,
    dataUsage,
    downloadSpeed,
    uploadSpeed,
    dueDate,
  ];
}

// Set selected card
class SetSelectedCardForInternetBill extends InternetBillEvent {
  final String cardId;
  final String cardHolderName;
  final String cardEnding;

  const SetSelectedCardForInternetBill({
    required this.cardId,
    required this.cardHolderName,
    required this.cardEnding,
  });

  @override
  List<Object> get props => <Object>[cardId, cardHolderName, cardEnding];
}

// Process internet bill payment
class ProcessInternetBillPayment extends InternetBillEvent {
  const ProcessInternetBillPayment();
}

// Reset internet bill state
class ResetInternetBill extends InternetBillEvent {
  const ResetInternetBill();
}