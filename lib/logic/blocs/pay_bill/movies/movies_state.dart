import 'package:equatable/equatable.dart';

abstract class MoviesState extends Equatable {
  const MoviesState();

  @override
  List<Object?> get props => <Object?>[];
}

class MoviesInitial extends MoviesState {}

class MoviesDataSet extends MoviesState {
  final String serviceName;
  final String category;
  final String email;
  final String planName;
  final double planPrice;
  final String planDuration;
  final String planDescription;
  final bool autoRenew;
  final double taxAmount;
  final double totalAmount;
  final String? cardId;
  final String? cardHolderName;
  final String? cardEnding;

  const MoviesDataSet({
    required this.serviceName,
    required this.category,
    required this.email,
    required this.planName,
    required this.planPrice,
    required this.planDuration,
    required this.planDescription,
    required this.autoRenew,
    required this.taxAmount,
    required this.totalAmount,
    this.cardId,
    this.cardHolderName,
    this.cardEnding,
  });

  @override
  List<Object?> get props => <Object?>[
    serviceName,
    category,
    email,
    planName,
    planPrice,
    planDuration,
    planDescription,
    autoRenew,
    taxAmount,
    totalAmount,
    cardId,
    cardHolderName,
    cardEnding,
  ];

  MoviesDataSet copyWith({
    String? serviceName,
    String? category,
    String? email,
    String? planName,
    double? planPrice,
    String? planDuration,
    String? planDescription,
    bool? autoRenew,
    double? taxAmount,
    double? totalAmount,
    String? cardId,
    String? cardHolderName,
    String? cardEnding,
  }) {
    return MoviesDataSet(
      serviceName: serviceName ?? this.serviceName,
      category: category ?? this.category,
      email: email ?? this.email,
      planName: planName ?? this.planName,
      planPrice: planPrice ?? this.planPrice,
      planDuration: planDuration ?? this.planDuration,
      planDescription: planDescription ?? this.planDescription,
      autoRenew: autoRenew ?? this.autoRenew,
      taxAmount: taxAmount ?? this.taxAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      cardId: cardId ?? this.cardId,
      cardHolderName: cardHolderName ?? this.cardHolderName,
      cardEnding: cardEnding ?? this.cardEnding,
    );
  }
}

class MoviesProcessing extends MoviesState {}

class MoviesSuccess extends MoviesState {
  final String transactionId;
  final String message;

  const MoviesSuccess({
    required this.transactionId,
    required this.message,
  });

  @override
  List<Object> get props => <Object>[transactionId, message];
}

class MoviesError extends MoviesState {
  final String error;

  const MoviesError(this.error);

  @override
  List<Object> get props => <Object>[error];
}