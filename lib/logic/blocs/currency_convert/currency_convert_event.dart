import 'package:equatable/equatable.dart';

abstract class CurrencyConversionEvent extends Equatable {
  const CurrencyConversionEvent();

  @override
  List<Object> get props => [];
}

class LoadExchangeRates extends CurrencyConversionEvent {
  const LoadExchangeRates();
}

class ConvertCurrency extends CurrencyConversionEvent {
  final String fromCurrency;
  final String toCurrency;
  final double amount;

  const ConvertCurrency({
    required this.fromCurrency,
    required this.toCurrency,
    required this.amount,
  });

  @override
  List<Object> get props => [fromCurrency, toCurrency, amount];
}

class UpdateFromCurrency extends CurrencyConversionEvent {
  final String currencyCode;

  const UpdateFromCurrency(this.currencyCode);

  @override
  List<Object> get props => [currencyCode];
}

class UpdateToCurrency extends CurrencyConversionEvent {
  final String currencyCode;

  const UpdateToCurrency(this.currencyCode);

  @override
  List<Object> get props => [currencyCode];
}

class UpdateAmount extends CurrencyConversionEvent {
  final double amount;

  const UpdateAmount(this.amount);

  @override
  List<Object> get props => [amount];
}
