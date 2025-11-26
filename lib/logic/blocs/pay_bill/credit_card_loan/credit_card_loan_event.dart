import 'package:equatable/equatable.dart';

abstract class CreditCardLoanEvent extends Equatable {
  const CreditCardLoanEvent();

  @override
  List<Object?> get props => <Object?>[];
}

// Set loan payment data
class SetLoanPaymentData extends CreditCardLoanEvent {
  final String bankName;
  final String branchName;
  final String accountNumber;
  final String cardNumber;
  final double amount;
  final String paymentType; // 'minimum', 'full', 'custom'

  const SetLoanPaymentData({
    required this.bankName,
    required this.branchName,
    required this.accountNumber,
    required this.cardNumber,
    required this.amount,
    required this.paymentType,
  });

  @override
  List<Object?> get props => <Object?>[
    bankName,
    branchName,
    accountNumber,
    cardNumber,
    amount,
    paymentType,
  ];
}

// Set selected card
class SetSelectedCardForLoan extends CreditCardLoanEvent {
  final String cardId;
  final String cardHolderName;
  final String cardEnding;

  const SetSelectedCardForLoan({
    required this.cardId,
    required this.cardHolderName,
    required this.cardEnding,
  });

  @override
  List<Object> get props => <Object>[cardId, cardHolderName, cardEnding];
}

// Process loan payment
class ProcessLoanPayment extends CreditCardLoanEvent {
  const ProcessLoanPayment();
}

// Reset loan payment state
class ResetLoanPayment extends CreditCardLoanEvent {
  const ResetLoanPayment();
}