import 'package:equatable/equatable.dart';

abstract class MobileRechargeEvent extends Equatable {
  const MobileRechargeEvent();

  @override
  List<Object?> get props => <Object?>[];
}

// Set recharge data
class SetRechargeData extends MobileRechargeEvent {
  final String companyName;
  final String network;
  final String phoneNumber;
  final double amount;
  final String? packageName;
  final String? packageData;
  final String? packageValidity;

  const SetRechargeData({
    required this.companyName,
    required this.network,
    required this.phoneNumber,
    required this.amount,
    this.packageName,
    this.packageData,
    this.packageValidity,
  });

  @override
  List<Object?> get props => <Object?>[
    companyName,
    network,
    phoneNumber,
    amount,
    packageName,
    packageData,
    packageValidity,
  ];
}

// Set selected card
class SetSelectedCard extends MobileRechargeEvent {
  final String cardId;
  final String cardHolderName;
  final String cardEnding;

  const SetSelectedCard({
    required this.cardId,
    required this.cardHolderName,
    required this.cardEnding,
  });

  @override
  List<Object> get props => <Object>[cardId, cardHolderName, cardEnding];
}

// Process recharge payment
class ProcessRechargePayment extends MobileRechargeEvent {
  const ProcessRechargePayment();
}

// Reset recharge state
class ResetRecharge extends MobileRechargeEvent {
  const ResetRecharge();
}