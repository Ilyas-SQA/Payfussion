import 'package:equatable/equatable.dart';

abstract class ElectricityBillEvent extends Equatable {
  const ElectricityBillEvent();

  @override
  List<Object?> get props => <Object?>[];
}

// Fetch bill details from API
class FetchBillDetails extends ElectricityBillEvent {
  final String providerName;
  final String accountNumber;

  const FetchBillDetails({
    required this.providerName,
    required this.accountNumber,
  });

  @override
  List<Object?> get props => <Object?>[providerName, accountNumber];
}

// Set electricity bill data
class SetElectricityBillData extends ElectricityBillEvent {
  final String providerName;
  final String region;
  final String averageRate;
  final String accountNumber;
  final String consumerName;
  final String address;
  final String billMonth;
  final double amount;
  final String unitsConsumed;
  final String previousReading;
  final String currentReading;
  final String dueDate;

  const SetElectricityBillData({
    required this.providerName,
    required this.region,
    required this.averageRate,
    required this.accountNumber,
    required this.consumerName,
    required this.address,
    required this.billMonth,
    required this.amount,
    required this.unitsConsumed,
    required this.previousReading,
    required this.currentReading,
    required this.dueDate,
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
    unitsConsumed,
    previousReading,
    currentReading,
    dueDate,
  ];
}

// Set selected card
class SetSelectedCardForElectricityBill extends ElectricityBillEvent {
  final String cardId;
  final String cardHolderName;
  final String cardEnding;

  const SetSelectedCardForElectricityBill({
    required this.cardId,
    required this.cardHolderName,
    required this.cardEnding,
  });

  @override
  List<Object> get props => <Object>[cardId, cardHolderName, cardEnding];
}

// Process electricity bill payment
class ProcessElectricityBillPayment extends ElectricityBillEvent {
  const ProcessElectricityBillPayment();
}

// Reset electricity bill state
class ResetElectricityBill extends ElectricityBillEvent {
  const ResetElectricityBill();
}