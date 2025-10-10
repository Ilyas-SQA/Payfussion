import 'package:equatable/equatable.dart';

import '../../../data/models/card/card_model.dart';

abstract class CardState extends Equatable {
  const CardState();

  @override
  List<Object?> get props => [];
}

class AddCardInitial extends CardState {}

class AddCardLoading extends CardState {}

class AddCardSuccess extends CardState {
  final String paymentMethodId;

  AddCardSuccess({required this.paymentMethodId});

  @override
  List<Object?> get props => [paymentMethodId];
}

class AddCardFailure extends CardState {
  final String errorMessage;

  AddCardFailure(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}

class CardInitial extends CardState {}

class CardLoading extends CardState {}

class CardLoaded extends CardState {
  final List<CardModel> cards;
  const CardLoaded(this.cards);

  @override
  List<Object?> get props => [cards];
}

class CardError extends CardState {
  final String message;
  const CardError(this.message);

  @override
  List<Object?> get props => [message];
}

// NEW STATE - Add this for duplicate detection
class CardDuplicateDetected extends CardState {
  final String message;
  const CardDuplicateDetected(this.message);

  @override
  List<Object?> get props => [message];
}