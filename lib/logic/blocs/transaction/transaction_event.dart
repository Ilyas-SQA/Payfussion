import 'package:equatable/equatable.dart';

import '../../../../data/models/card/card_model.dart';
import '../../../../data/models/recipient/recipient_model.dart';

abstract class TransactionEvent extends Equatable {
  const TransactionEvent();
  @override
  List<Object?> get props => <Object?>[];
}

class PaymentStarted extends TransactionEvent {
  final RecipientModel recipient;
  const PaymentStarted(this.recipient);

  @override
  List<Object?> get props => <Object?>[recipient];
}

class PaymentAmountChanged extends TransactionEvent {
  final String raw; // user typed string
  const PaymentAmountChanged(this.raw);

  @override
  List<Object?> get props => <Object?>[raw];
}

class PaymentSelectCard extends TransactionEvent {
  final CardModel card;
  const PaymentSelectCard(this.card);

  @override
  List<Object?> get props => <Object?>[card];
}

class PaymentSubmit extends TransactionEvent {
  const PaymentSubmit();
}

class PaymentReset extends TransactionEvent {
  const PaymentReset();
}

class FetchTodaysTransactions extends TransactionEvent {
  const FetchTodaysTransactions();

  @override
  List<Object?> get props => <Object?>[];
}
