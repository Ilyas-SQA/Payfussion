import 'package:equatable/equatable.dart';

abstract class BillSplitEvent extends Equatable {
  const BillSplitEvent();

  @override
  List<Object?> get props => <Object?>[];
}

// Set bill split data
class SetBillSplitData extends BillSplitEvent {
  final String billName;
  final double totalAmount;
  final int numberOfPeople;
  final List<String> participantNames;
  final String splitType; // 'equal' or 'custom'
  final Map<String, double>? customAmounts; // For custom splits

  const SetBillSplitData({
    required this.billName,
    required this.totalAmount,
    required this.numberOfPeople,
    required this.participantNames,
    this.splitType = 'equal',
    this.customAmounts,
  });

  @override
  List<Object?> get props => <Object?>[
    billName,
    totalAmount,
    numberOfPeople,
    participantNames,
    splitType,
    customAmounts,
  ];
}

// Set selected card for bill split payment
class SetSelectedCardForBillSplit extends BillSplitEvent {
  final String cardId;
  final String cardHolderName;
  final String cardEnding;

  const SetSelectedCardForBillSplit({
    required this.cardId,
    required this.cardHolderName,
    required this.cardEnding,
  });

  @override
  List<Object> get props => <Object>[cardId, cardHolderName, cardEnding];
}

// Process bill split payment
class ProcessBillSplitPayment extends BillSplitEvent {
  const ProcessBillSplitPayment();
}

// Reset bill split state
class ResetBillSplit extends BillSplitEvent {
  const ResetBillSplit();
}