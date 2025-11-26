import 'package:equatable/equatable.dart';

abstract class CreditCardLoanState extends Equatable {
  const CreditCardLoanState();

  @override
  List<Object?> get props => <Object?>[];
}

class CreditCardLoanInitial extends CreditCardLoanState {}

class CreditCardLoanDataSet extends CreditCardLoanState {
  final String bankName;
  final String branchName;
  final String accountNumber;
  final String cardNumber;
  final double amount;
  final String paymentType;
  final double taxAmount;
  final double totalAmount;
  final String? cardId;
  final String? cardHolderName;
  final String? cardEnding;

  const CreditCardLoanDataSet({
    required this.bankName,
    required this.branchName,
    required this.accountNumber,
    required this.cardNumber,
    required this.amount,
    required this.paymentType,
    required this.taxAmount,
    required this.totalAmount,
    this.cardId,
    this.cardHolderName,
    this.cardEnding,
  });

  @override
  List<Object?> get props => <Object?>[
    bankName,
    branchName,
    accountNumber,
    cardNumber,
    amount,
    paymentType,
    taxAmount,
    totalAmount,
    cardId,
    cardHolderName,
    cardEnding,
  ];

  CreditCardLoanDataSet copyWith({
    String? bankName,
    String? branchName,
    String? accountNumber,
    String? cardNumber,
    double? amount,
    String? paymentType,
    double? taxAmount,
    double? totalAmount,
    String? cardId,
    String? cardHolderName,
    String? cardEnding,
  }) {
    return CreditCardLoanDataSet(
      bankName: bankName ?? this.bankName,
      branchName: branchName ?? this.branchName,
      accountNumber: accountNumber ?? this.accountNumber,
      cardNumber: cardNumber ?? this.cardNumber,
      amount: amount ?? this.amount,
      paymentType: paymentType ?? this.paymentType,
      taxAmount: taxAmount ?? this.taxAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      cardId: cardId ?? this.cardId,
      cardHolderName: cardHolderName ?? this.cardHolderName,
      cardEnding: cardEnding ?? this.cardEnding,
    );
  }
}

class CreditCardLoanProcessing extends CreditCardLoanState {}

class CreditCardLoanSuccess extends CreditCardLoanState {
  final String transactionId;
  final String message;

  const CreditCardLoanSuccess({
    required this.transactionId,
    required this.message,
  });

  @override
  List<Object> get props => <Object>[transactionId, message];
}

class CreditCardLoanError extends CreditCardLoanState {
  final String error;

  const CreditCardLoanError(this.error);

  @override
  List<Object> get props => <Object>[error];
}