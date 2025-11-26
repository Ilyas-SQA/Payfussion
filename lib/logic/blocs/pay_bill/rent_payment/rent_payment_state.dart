import 'package:equatable/equatable.dart';

abstract class RentPaymentState extends Equatable {
  const RentPaymentState();

  @override
  List<Object?> get props => <Object?>[];
}

// Initial state
class RentPaymentInitial extends RentPaymentState {}

// Data set state
class RentPaymentDataSet extends RentPaymentState {
  final String companyName;
  final String category;
  final String propertyAddress;
  final String landlordName;
  final String landlordEmail;
  final String landlordPhone;
  final double amount;
  final String? notes;
  final double taxAmount;
  final double totalAmount;
  final String currency;

  // Card details
  final String? cardId;
  final String? cardHolderName;
  final String? cardEnding;

  const RentPaymentDataSet({
    required this.companyName,
    required this.category,
    required this.propertyAddress,
    required this.landlordName,
    required this.landlordEmail,
    required this.landlordPhone,
    required this.amount,
    this.notes,
    required this.taxAmount,
    required this.totalAmount,
    required this.currency,
    this.cardId,
    this.cardHolderName,
    this.cardEnding,
  });

  RentPaymentDataSet copyWith({
    String? companyName,
    String? category,
    String? propertyAddress,
    String? landlordName,
    String? landlordEmail,
    String? landlordPhone,
    double? amount,
    String? notes,
    double? taxAmount,
    double? totalAmount,
    String? currency,
    String? cardId,
    String? cardHolderName,
    String? cardEnding,
  }) {
    return RentPaymentDataSet(
      companyName: companyName ?? this.companyName,
      category: category ?? this.category,
      propertyAddress: propertyAddress ?? this.propertyAddress,
      landlordName: landlordName ?? this.landlordName,
      landlordEmail: landlordEmail ?? this.landlordEmail,
      landlordPhone: landlordPhone ?? this.landlordPhone,
      amount: amount ?? this.amount,
      notes: notes ?? this.notes,
      taxAmount: taxAmount ?? this.taxAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      currency: currency ?? this.currency,
      cardId: cardId ?? this.cardId,
      cardHolderName: cardHolderName ?? this.cardHolderName,
      cardEnding: cardEnding ?? this.cardEnding,
    );
  }

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
    taxAmount,
    totalAmount,
    currency,
    cardId,
    cardHolderName,
    cardEnding,
  ];
}

// Processing state
class RentPaymentProcessing extends RentPaymentState {}

// Success state
class RentPaymentSuccess extends RentPaymentState {
  final String message;
  final String transactionId;

  const RentPaymentSuccess({
    required this.message,
    required this.transactionId,
  });

  @override
  List<Object?> get props => <Object?>[message, transactionId];
}

// Error state
class RentPaymentError extends RentPaymentState {
  final String error;

  const RentPaymentError(this.error);

  @override
  List<Object?> get props => <Object?>[error];
}