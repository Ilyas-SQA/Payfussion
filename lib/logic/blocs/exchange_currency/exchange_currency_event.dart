// lib/logic/blocs/exchange_currency/exchange_currency_event.dart

import 'package:equatable/equatable.dart';

abstract class ExchangeCurrencyEvent extends Equatable {
  const ExchangeCurrencyEvent();

  @override
  List<Object?> get props => <Object?>[];
}

class NumberPressed extends ExchangeCurrencyEvent {
  final String number;

  const NumberPressed({required this.number});

  @override
  List<Object?> get props => <Object?>[number];
}

class DecimalPressed extends ExchangeCurrencyEvent {
  const DecimalPressed();
}

class ClearPressed extends ExchangeCurrencyEvent {
  const ClearPressed();
}

class BackspacePressed extends ExchangeCurrencyEvent {
  const BackspacePressed();
}

class SourceCurrencyChanged extends ExchangeCurrencyEvent {
  final String currency;

  const SourceCurrencyChanged({required this.currency});

  @override
  List<Object?> get props => <Object?>[currency];
}

class TargetCurrencyChanged extends ExchangeCurrencyEvent {
  final String currency;

  const TargetCurrencyChanged({required this.currency});

  @override
  List<Object?> get props => <Object?>[currency];
}

class SwapCurrencies extends ExchangeCurrencyEvent {
  const SwapCurrencies();
}

class FetchExchangeRates extends ExchangeCurrencyEvent {
  const FetchExchangeRates();
}

class RefreshExchangeRates extends ExchangeCurrencyEvent {
  const RefreshExchangeRates();
}