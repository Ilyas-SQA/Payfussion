import 'package:equatable/equatable.dart';

abstract class DthRechargeEvent extends Equatable {
  const DthRechargeEvent();

  @override
  List<Object?> get props => <Object?>[];
}

// Set DTH recharge data
class SetDthRechargeData extends DthRechargeEvent {
  final String providerName;
  final String subscriberId;
  final String customerName;
  final String selectedPlan;
  final double amount;
  final double rating;

  const SetDthRechargeData({
    required this.providerName,
    required this.subscriberId,
    required this.customerName,
    required this.selectedPlan,
    required this.amount,
    required this.rating,
  });

  @override
  List<Object?> get props => <Object?>[
    providerName,
    subscriberId,
    customerName,
    selectedPlan,
    amount,
    rating,
  ];
}

// Set selected card for DTH
class SetSelectedCardForDth extends DthRechargeEvent {
  final String cardId;
  final String cardHolderName;
  final String cardEnding;

  const SetSelectedCardForDth({
    required this.cardId,
    required this.cardHolderName,
    required this.cardEnding,
  });

  @override
  List<Object> get props => <Object>[cardId, cardHolderName, cardEnding];
}

// Process DTH payment
class ProcessDthPayment extends DthRechargeEvent {
  const ProcessDthPayment();
}

// Reset DTH recharge state
class ResetDthRecharge extends DthRechargeEvent {
  const ResetDthRecharge();
}