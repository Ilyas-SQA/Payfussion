import 'package:equatable/equatable.dart';

import '../../../../data/models/card/card_model.dart';
import '../../../../data/models/recipient/recipient_model.dart';
import '../../../../data/models/transaction/transaction_model.dart';

class TransactionState extends Equatable {
  final List<TransactionModel> todaysTransactions;
  final RecipientModel? recipient;
  final double amount;
  final String? amountError;
  final CardModel? selectedCard;
  final bool isProcessing;
  final bool isSuccess;
  final String? errorMessage;

  const TransactionState({
    required this.todaysTransactions,
    required this.recipient,
    required this.amount,
    required this.amountError,
    required this.selectedCard,
    required this.isProcessing,
    required this.isSuccess,
    required this.errorMessage,
  });

  factory TransactionState.initial() => const TransactionState(
    todaysTransactions: <TransactionModel>[],
    recipient: null,
    amount: 0.0,
    amountError: null,
    selectedCard: null,
    isProcessing: false,
    isSuccess: false,
    errorMessage: null,
  );

  TransactionState copyWith({
    List<TransactionModel>? todaysTransactions,
    RecipientModel? recipient,
    double? amount,
    String? amountError,
    CardModel? selectedCard,
    bool? isProcessing,
    bool? isSuccess,
    String? errorMessage,
  }) {
    return TransactionState(
      todaysTransactions: todaysTransactions ?? this.todaysTransactions,
      recipient: recipient ?? this.recipient,
      amount: amount ?? this.amount,
      amountError: amountError,
      selectedCard: selectedCard ?? this.selectedCard,
      isProcessing: isProcessing ?? this.isProcessing,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    todaysTransactions,
    recipient,
    amount,
    amountError,
    selectedCard,
    isProcessing,
    isSuccess,
    errorMessage,
  ];
}
