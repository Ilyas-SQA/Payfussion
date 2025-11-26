import 'package:equatable/equatable.dart';

abstract class DonationState extends Equatable {
  const DonationState();

  @override
  List<Object?> get props => <Object?>[];
}

class DonationInitial extends DonationState {}

class DonationDataSet extends DonationState {
  final String foundationName;
  final String category;
  final String description;
  final String website;
  final double amount;
  final double taxAmount;
  final double totalAmount;
  final String? cardId;
  final String? cardHolderName;
  final String? cardEnding;

  const DonationDataSet({
    required this.foundationName,
    required this.category,
    required this.description,
    required this.website,
    required this.amount,
    required this.taxAmount,
    required this.totalAmount,
    this.cardId,
    this.cardHolderName,
    this.cardEnding,
  });

  @override
  List<Object?> get props => <Object?>[
    foundationName,
    category,
    description,
    website,
    amount,
    taxAmount,
    totalAmount,
    cardId,
    cardHolderName,
    cardEnding,
  ];

  DonationDataSet copyWith({
    String? foundationName,
    String? category,
    String? description,
    String? website,
    double? amount,
    double? taxAmount,
    double? totalAmount,
    String? cardId,
    String? cardHolderName,
    String? cardEnding,
  }) {
    return DonationDataSet(
      foundationName: foundationName ?? this.foundationName,
      category: category ?? this.category,
      description: description ?? this.description,
      website: website ?? this.website,
      amount: amount ?? this.amount,
      taxAmount: taxAmount ?? this.taxAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      cardId: cardId ?? this.cardId,
      cardHolderName: cardHolderName ?? this.cardHolderName,
      cardEnding: cardEnding ?? this.cardEnding,
    );
  }
}

class DonationProcessing extends DonationState {}

class DonationSuccess extends DonationState {
  final String transactionId;
  final String message;

  const DonationSuccess({
    required this.transactionId,
    required this.message,
  });

  @override
  List<Object> get props => <Object>[transactionId, message];
}

class DonationError extends DonationState {
  final String error;

  const DonationError(this.error);

  @override
  List<Object> get props => <Object>[error];
}