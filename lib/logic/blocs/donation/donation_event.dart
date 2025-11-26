import 'package:equatable/equatable.dart';

abstract class DonationEvent extends Equatable {
  const DonationEvent();

  @override
  List<Object?> get props => <Object?>[];
}

// Set donation data
class SetDonationData extends DonationEvent {
  final String foundationName;
  final String category;
  final String description;
  final String website;
  final double amount;

  const SetDonationData({
    required this.foundationName,
    required this.category,
    required this.description,
    required this.website,
    required this.amount,
  });

  @override
  List<Object?> get props => <Object?>[
    foundationName,
    category,
    description,
    website,
    amount,
  ];
}

// Set selected card
class SetSelectedCardForDonation extends DonationEvent {
  final String cardId;
  final String cardHolderName;
  final String cardEnding;

  const SetSelectedCardForDonation({
    required this.cardId,
    required this.cardHolderName,
    required this.cardEnding,
  });

  @override
  List<Object> get props => <Object>[cardId, cardHolderName, cardEnding];
}

// Process donation payment
class ProcessDonationPayment extends DonationEvent {
  const ProcessDonationPayment();
}

// Reset donation state
class ResetDonation extends DonationEvent {
  const ResetDonation();
}