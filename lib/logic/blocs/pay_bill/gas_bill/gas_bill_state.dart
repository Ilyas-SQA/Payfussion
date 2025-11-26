import 'package:equatable/equatable.dart';

abstract class GasBillEvent extends Equatable {
  const GasBillEvent();

  @override
  List<Object?> get props => <Object?>[];
}

// Set gas bill data
class SetGasBillData extends GasBillEvent {
  final String companyName;
  final String region;
  final String averageRate;
  final String accountNumber;
  final String consumerName;
  final String address;
  final String billMonth;
  final double amount;
  final String gasUsage;
  final String previousReading;
  final String currentReading;
  final String dueDate;

  const SetGasBillData({
    required this.companyName,
    required this.region,
    required this.averageRate,
    required this.accountNumber,
    required this.consumerName,
    required this.address,
    required this.billMonth,
    required this.amount,
    required this.gasUsage,
    required this.previousReading,
    required this.currentReading,
    required this.dueDate,
  });

  @override
  List<Object?> get props => <Object?>[
    companyName,
    region,
    averageRate,
    accountNumber,
    consumerName,
    address,
    billMonth,
    amount,
    gasUsage,
    previousReading,
    currentReading,
    dueDate,
  ];
}

// Set selected card
class SetSelectedCardForGasBill extends GasBillEvent {
  final String cardId;
  final String cardHolderName;
  final String cardEnding;

  const SetSelectedCardForGasBill({
    required this.cardId,
    required this.cardHolderName,
    required this.cardEnding,
  });

  @override
  List<Object> get props => <Object>[cardId, cardHolderName, cardEnding];
}

// Process gas bill payment
class ProcessGasBillPayment extends GasBillEvent {
  const ProcessGasBillPayment();
}

// Reset gas bill state
class ResetGasBill extends GasBillEvent {
  const ResetGasBill();
}