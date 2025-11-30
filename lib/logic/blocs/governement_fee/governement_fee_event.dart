import 'package:equatable/equatable.dart';

abstract class GovernmentFeeEvent extends Equatable {
  const GovernmentFeeEvent();

  @override
  List<Object?> get props => <Object?>[];
}

// Set government fee data
class SetGovernmentFeeData extends GovernmentFeeEvent {
  final String serviceName;
  final String agency;
  final String inputLabel;
  final String inputValue;
  final double amount;

  const SetGovernmentFeeData({
    required this.serviceName,
    required this.agency,
    required this.inputLabel,
    required this.inputValue,
    required this.amount,
  });

  @override
  List<Object?> get props => <Object?>[
    serviceName,
    agency,
    inputLabel,
    inputValue,
    amount,
  ];
}

// Set selected card
class SetSelectedCardForGovernmentFee extends GovernmentFeeEvent {
  final String cardId;
  final String cardHolderName;
  final String cardEnding;

  const SetSelectedCardForGovernmentFee({
    required this.cardId,
    required this.cardHolderName,
    required this.cardEnding,
  });

  @override
  List<Object> get props => <Object>[cardId, cardHolderName, cardEnding];
}

// Process government fee payment
class ProcessGovernmentFeePayment extends GovernmentFeeEvent {
  const ProcessGovernmentFeePayment();
}

// Reset government fee state
class ResetGovernmentFee extends GovernmentFeeEvent {
  const ResetGovernmentFee();
}