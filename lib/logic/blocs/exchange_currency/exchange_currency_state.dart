// lib/logic/blocs/exchange_currency/exchange_currency_state.dart

import 'package:equatable/equatable.dart';

enum ExchangeStatus {
  initial,
  loading,
  success,
  error,
}

class ExchangeCurrencyState extends Equatable {
  final String amountInput;
  final double amount;
  final double conversionResult;
  final String sourceCurrency;
  final String targetCurrency;
  final DateTime? lastUpdated;
  final ExchangeStatus status;
  final String? errorMessage;
  final Map<String, double>? exchangeRates;

  const ExchangeCurrencyState({
    this.amountInput = '0',
    this.amount = 0,
    this.conversionResult = 0,
    this.sourceCurrency = 'USD',
    this.targetCurrency = 'EUR',
    this.lastUpdated,
    this.status = ExchangeStatus.initial,
    this.errorMessage,
    this.exchangeRates,
  });

  ExchangeCurrencyState copyWith({
    String? amountInput,
    double? amount,
    double? conversionResult,
    String? sourceCurrency,
    String? targetCurrency,
    DateTime? lastUpdated,
    ExchangeStatus? status,
    String? errorMessage,
    Map<String, double>? exchangeRates,
  }) {
    return ExchangeCurrencyState(
      amountInput: amountInput ?? this.amountInput,
      amount: amount ?? this.amount,
      conversionResult: conversionResult ?? this.conversionResult,
      sourceCurrency: sourceCurrency ?? this.sourceCurrency,
      targetCurrency: targetCurrency ?? this.targetCurrency,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      exchangeRates: exchangeRates ?? this.exchangeRates,
    );
  }

  String getLastUpdatedText() {
    if (lastUpdated == null) return 'Not updated yet';

    final DateTime now = DateTime.now();
    final Duration difference = now.difference(lastUpdated!);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds} seconds ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }

  @override
  List<Object?> get props => <Object?>[
    amountInput,
    amount,
    conversionResult,
    sourceCurrency,
    targetCurrency,
    lastUpdated,
    status,
    errorMessage,
    exchangeRates,
  ];
}