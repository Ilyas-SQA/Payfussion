import 'package:equatable/equatable.dart';

abstract class RentPaymentEvent extends Equatable {
  const RentPaymentEvent();

  @override
  List<Object?> get props => <Object?>[];
}

// Set rent payment data
class SetRentPaymentData extends RentPaymentEvent {
  final String companyName;
  final String category;
  final String propertyAddress;
  final String landlordName;
  final String landlordEmail;
  final String landlordPhone;
  final double amount;
  final String? notes;

  const SetRentPaymentData({
    required this.companyName,
    required this.category,
    required this.propertyAddress,
    required this.landlordName,
    required this.landlordEmail,
    required this.landlordPhone,
    required this.amount,
    this.notes,
  });

  @override
  List<Object?> get props => <Object?>[
    companyName,
    category,
    propertyAddress,
    landlordName,
    landlordEmail,
    landlordPhone,
    amount,
    notes,
  ];
}

// Set payment card
class SetRentPaymentCard extends RentPaymentEvent {
  final String cardId;
  final String cardHolderName;
  final String cardEnding;

  const SetRentPaymentCard({
    required this.cardId,
    required this.cardHolderName,
    required this.cardEnding,
  });

  @override
  List<Object?> get props => <Object?>[cardId, cardHolderName, cardEnding];
}

// Process rent payment
class ProcessRentPayment extends RentPaymentEvent {
  const ProcessRentPayment();
}

// Reset rent payment
class ResetRentPayment extends RentPaymentEvent {
  const ResetRentPayment();
}