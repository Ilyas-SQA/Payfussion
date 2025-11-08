import 'package:equatable/equatable.dart';

class ExchangeRate {
  final String from;
  final String to;
  final double rate;
  final double changePercent;
  final DateTime lastUpdated;

  const ExchangeRate({
    required this.from,
    required this.to,
    required this.rate,
    required this.changePercent,
    required this.lastUpdated,
  });
}

class CurrencyConversionState extends Equatable {
  final bool isLoading;
  final Map<String, double> exchangeRates;
  final String fromCurrency;
  final String toCurrency;
  final double amount;
  final double convertedAmount;
  final ExchangeRate? currentRate;
  final String? error;

  const CurrencyConversionState({
    this.isLoading = false,
    this.exchangeRates = const <String, double>{},
    this.fromCurrency = 'USD',
    this.toCurrency = 'EUR',
    this.amount = 0.0,
    this.convertedAmount = 0.0,
    this.currentRate,
    this.error,
  });

  CurrencyConversionState copyWith({
    bool? isLoading,
    Map<String, double>? exchangeRates,
    String? fromCurrency,
    String? toCurrency,
    double? amount,
    double? convertedAmount,
    ExchangeRate? currentRate,
    String? error,
  }) {
    return CurrencyConversionState(
      isLoading: isLoading ?? this.isLoading,
      exchangeRates: exchangeRates ?? this.exchangeRates,
      fromCurrency: fromCurrency ?? this.fromCurrency,
      toCurrency: toCurrency ?? this.toCurrency,
      amount: amount ?? this.amount,
      convertedAmount: convertedAmount ?? this.convertedAmount,
      currentRate: currentRate ?? this.currentRate,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    isLoading,
    exchangeRates,
    fromCurrency,
    toCurrency,
    amount,
    convertedAmount,
    currentRate,
    error,
  ];
}