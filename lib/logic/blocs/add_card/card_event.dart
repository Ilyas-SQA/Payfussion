import 'package:equatable/equatable.dart';

abstract class CardEvent extends Equatable {
  const CardEvent();

  @override
  List<Object?> get props => <Object?>[];
}

class AddCardDetailsSubmitted extends CardEvent {
  final Map<String, dynamic> cardDetails;

  AddCardDetailsSubmitted({required this.cardDetails});
}

class CreateIntent extends CardEvent {
  final Map<String, dynamic> cardDetails;

  CreateIntent({required this.cardDetails});
}

class AddCardInFirebase extends CardEvent{
  final String cardNumber,expiryMonth,expiryYear,holderName,cvv;
  AddCardInFirebase({
    required this.cardNumber,
    required this.expiryMonth,
    required this.expiryYear,
    required this.holderName,
    required this.cvv,
  });
}

class LoadCards extends CardEvent {
  @override
  List<Object?> get props => <Object?>[];
}

class SetDefaultCard extends CardEvent {
  final String cardId;
  final bool isDefault;

  SetDefaultCard({
    required this.cardId,
    required this.isDefault,
  });
}

// NEW EVENT - Add this for duplicate check
class AddCardWithDuplicateCheck extends CardEvent {
  final Map<String, dynamic> cardData;
  final String customerId;

  AddCardWithDuplicateCheck({
    required this.cardData,
    required this.customerId,
  });

  @override
  List<Object?> get props => <Object?>[cardData, customerId];
}
