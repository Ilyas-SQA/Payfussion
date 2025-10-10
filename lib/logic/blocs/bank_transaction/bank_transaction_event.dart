import 'package:equatable/equatable.dart';

import '../../../data/models/recipient/recipient_model.dart';

abstract class BankTransactionEvent extends Equatable {
  const BankTransactionEvent();

  @override
  List<Object?> get props => [];
}

// Events for bank selection
class FetchBanks extends BankTransactionEvent {
  const FetchBanks();
}

class BankSelected extends BankTransactionEvent {
  const BankSelected(this.bank);

  final Bank? bank;

  @override
  List<Object?> get props => [bank];
}

class BankUnselected extends BankTransactionEvent {
  const BankUnselected();

  @override
  List<Object?> get props => [];
}

// Events for bank details
class BankDetailsSubmitted extends BankTransactionEvent {
  final String accountNumber;
  final String paymentPurpose;
  final String phoneNumber;
  final Bank bank;

  const BankDetailsSubmitted({
    required this.accountNumber,
    required this.paymentPurpose,
    required this.phoneNumber,
    required this.bank,
  });

  @override
  List<Object?> get props => [accountNumber, paymentPurpose, phoneNumber, bank];
}

// Events for amount handling
class BankTransferAmountChanged extends BankTransactionEvent {
  final String rawAmount;

  const BankTransferAmountChanged(this.rawAmount);

  @override
  List<Object?> get props => [rawAmount];
}

class BankTransferAmountSet extends BankTransactionEvent {
  final double amount;

  const BankTransferAmountSet(this.amount);

  @override
  List<Object?> get props => [amount];
}

// Events for transaction processing
class ProcessBankTransfer extends BankTransactionEvent {
  const ProcessBankTransfer();
}

class BankTransferCompleted extends BankTransactionEvent {
  final String transactionId;

  const BankTransferCompleted(this.transactionId);

  @override
  List<Object?> get props => [transactionId];
}

class BankTransferFailed extends BankTransactionEvent {
  final String errorMessage;

  const BankTransferFailed(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}

// Events for fetching transactions
class FetchBankTransactions extends BankTransactionEvent {
  const FetchBankTransactions();
}

class FetchBankTransactionsByDate extends BankTransactionEvent {
  final DateTime startDate;
  final DateTime endDate;

  const FetchBankTransactionsByDate({
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [startDate, endDate];
}

// Events for validation
class ValidateAccountNumber extends BankTransactionEvent {
  final String accountNumber;
  final Bank bank;

  const ValidateAccountNumber({
    required this.accountNumber,
    required this.bank,
  });

  @override
  List<Object?> get props => [accountNumber, bank];
}

// Events for resetting state
class ResetBankTransaction extends BankTransactionEvent {
  const ResetBankTransaction();
}

class ClearBankTransactionError extends BankTransactionEvent {
  const ClearBankTransactionError();
}

// Events for favorites
class AddBankToFavorites extends BankTransactionEvent {
  final Bank bank;
  final String accountNumber;
  final String recipientName;

  const AddBankToFavorites({
    required this.bank,
    required this.accountNumber,
    required this.recipientName,
  });

  @override
  List<Object?> get props => [bank, accountNumber, recipientName];
}

class RemoveBankFromFavorites extends BankTransactionEvent {
  final String favoriteId;

  const RemoveBankFromFavorites(this.favoriteId);

  @override
  List<Object?> get props => [favoriteId];
}

class FetchFavoriteBanks extends BankTransactionEvent {
  const FetchFavoriteBanks();
}

