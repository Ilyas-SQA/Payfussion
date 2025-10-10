import 'package:equatable/equatable.dart';

import '../../../data/models/recipient/recipient_model.dart';
import '../../../data/models/transaction/transaction_model.dart';

enum BankTransactionStatus {
  initial,
  loading,
  bankSelected,
  detailsSubmitted,
  amountSet,
  processing,
  success,
  failure,
}

class BankTransactionState extends Equatable {
  final BankTransactionStatus status;
  final List<Bank> availableBanks;
  final Bank? selectedBank;
  final String? accountNumber;
  final String? paymentPurpose;
  final String? phoneNumber;
  final double amount;
  final String? amountError;
  final bool isLoadingBanks;
  final bool isProcessing;
  final bool isSuccess;
  final String? errorMessage;
  final String? transactionId;
  final List<TransactionModel> transactions; // Changed from BankTransactionModel to TransactionModel
  final List<FavoriteBank> favoriteBanks;
  final bool isValidatingAccount;
  final bool isAccountValid;

  const BankTransactionState({
    this.status = BankTransactionStatus.initial,
    this.availableBanks = const [],
    this.selectedBank,
    this.accountNumber,
    this.paymentPurpose,
    this.phoneNumber,
    this.amount = 0.0,
    this.amountError,
    this.isLoadingBanks = false,
    this.isProcessing = false,
    this.isSuccess = false,
    this.errorMessage,
    this.transactionId,
    this.transactions = const [],
    this.favoriteBanks = const [],
    this.isValidatingAccount = false,
    this.isAccountValid = false,
  });

  factory BankTransactionState.initial() {
    return const BankTransactionState();
  }

  // Replace your existing copyWith method with this one:

  BankTransactionState copyWith({
    BankTransactionStatus? status,
    List<Bank>? availableBanks,
    Bank? selectedBank, // This won't work for null values
    String? accountNumber,
    String? paymentPurpose,
    String? phoneNumber,
    double? amount,
    String? amountError,
    bool? isLoadingBanks,
    bool? isProcessing,
    bool? isSuccess,
    String? errorMessage,
    String? transactionId,
    List<TransactionModel>? transactions,
    List<FavoriteBank>? favoriteBanks,
    bool? isValidatingAccount,
    bool? isAccountValid,
    // Add these parameters to handle null values explicitly
    bool clearSelectedBank = false,
    bool clearAccountNumber = false,
    bool clearPaymentPurpose = false,
    bool clearPhoneNumber = false,
    bool clearErrorMessage = false,
    bool clearTransactionId = false,
    bool clearAmountError = false,
  }) {
    return BankTransactionState(
      status: status ?? this.status,
      availableBanks: availableBanks ?? this.availableBanks,
      selectedBank: clearSelectedBank ? null : (selectedBank ?? this.selectedBank),
      accountNumber: clearAccountNumber ? null : (accountNumber ?? this.accountNumber),
      paymentPurpose: clearPaymentPurpose ? null : (paymentPurpose ?? this.paymentPurpose),
      phoneNumber: clearPhoneNumber ? null : (phoneNumber ?? this.phoneNumber),
      amount: amount ?? this.amount,
      amountError: clearAmountError ? null : (amountError ?? this.amountError),
      isLoadingBanks: isLoadingBanks ?? this.isLoadingBanks,
      isProcessing: isProcessing ?? this.isProcessing,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      transactionId: clearTransactionId ? null : (transactionId ?? this.transactionId),
      transactions: transactions ?? this.transactions,
      favoriteBanks: favoriteBanks ?? this.favoriteBanks,
      isValidatingAccount: isValidatingAccount ?? this.isValidatingAccount,
      isAccountValid: isAccountValid ?? this.isAccountValid,
    );
  }

  // Getters for computed properties
  bool get hasSelectedBank => selectedBank != null;

  bool get hasCompleteDetails =>
      selectedBank != null &&
          accountNumber != null &&
          paymentPurpose != null &&
          phoneNumber != null;

  bool get canProcessTransfer =>
      hasCompleteDetails &&
          amount > 0 &&
          amountError == null;

  double get totalAmount => amount + transactionFee;

  double get transactionFee => 2.50; // Fixed fee for bank transfers

  String get formattedAmount => '\$${amount.toStringAsFixed(2)}';

  String get formattedTotalAmount => '\$${totalAmount.toStringAsFixed(2)}';

  // Helper to get only bank transfer transactions
  List<TransactionModel> get bankTransferTransactions =>
      transactions.where((tx) => tx.recipientId == 'bank_transfer').toList();

  @override
  List<Object?> get props => [
    status,
    availableBanks,
    selectedBank,
    accountNumber,
    paymentPurpose,
    phoneNumber,
    amount,
    amountError,
    isLoadingBanks,
    isProcessing,
    isSuccess,
    errorMessage,
    transactionId,
    transactions,
    favoriteBanks,
    isValidatingAccount,
    isAccountValid,
  ];
}

// Model for favorite banks
class FavoriteBank extends Equatable {
  final String id;
  final Bank bank;
  final String accountNumber;
  final String recipientName;
  final DateTime addedAt;

  const FavoriteBank({
    required this.id,
    required this.bank,
    required this.accountNumber,
    required this.recipientName,
    required this.addedAt,
  });

  factory FavoriteBank.fromJson(Map<String, dynamic> json) {
    return FavoriteBank(
      id: json['id'] ?? '',
      bank: Bank.fromJson(json['bank']),
      accountNumber: json['accountNumber'] ?? '',
      recipientName: json['recipientName'] ?? '',
      addedAt: DateTime.parse(json['addedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bank': bank.toJson(),
      'accountNumber': accountNumber,
      'recipientName': recipientName,
      'addedAt': addedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, bank, accountNumber, recipientName, addedAt];
}