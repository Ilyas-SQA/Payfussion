import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

import 'currency_convert_event.dart';
import 'currency_convert_state.dart';

class CurrencyConversionBloc extends Bloc<CurrencyConversionEvent, CurrencyConversionState> {
  CurrencyConversionBloc() : super(const CurrencyConversionState()) {
    on<LoadExchangeRates>(_onLoadExchangeRates);
    on<ConvertCurrency>(_onConvertCurrency);
    on<UpdateFromCurrency>(_onUpdateFromCurrency);
    on<UpdateToCurrency>(_onUpdateToCurrency);
    on<UpdateAmount>(_onUpdateAmount);
  }

  Future<void> _onLoadExchangeRates(
      LoadExchangeRates event,
      Emitter<CurrencyConversionState> emit,
      ) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      // Using a free API for exchange rates - you might want to use a different API
      final response = await http.get(
        Uri.parse('https://api.exchangerate-api.com/v4/latest/USD'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final rates = Map<String, double>.from(
          data['rates'].map((key, value) => MapEntry(key, value.toDouble())),
        );

        emit(state.copyWith(
          isLoading: false,
          exchangeRates: rates,
        ));

        // Automatically convert if amount is set
        if (state.amount > 0) {
          add(ConvertCurrency(
            fromCurrency: state.fromCurrency,
            toCurrency: state.toCurrency,
            amount: state.amount,
          ));
        }
      } else {
        emit(state.copyWith(
          isLoading: false,
          error: 'Failed to load exchange rates',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Error loading exchange rates: $e',
      ));
    }
  }

  Future<void> _onConvertCurrency(
      ConvertCurrency event,
      Emitter<CurrencyConversionState> emit,
      ) async {
    if (state.exchangeRates.isEmpty) {
      add(const LoadExchangeRates());
      return;
    }

    try {
      final fromRate = event.fromCurrency == 'USD' ? 1.0 : state.exchangeRates[event.fromCurrency] ?? 1.0;
      final toRate = event.toCurrency == 'USD' ? 1.0 : state.exchangeRates[event.toCurrency] ?? 1.0;

      /// Convert to USD first, then to target currency
      final usdAmount = event.amount / fromRate;
      final convertedAmount = usdAmount * toRate;
      final rate = toRate / fromRate;

      /// Calculate change percentage (mock data - in real app, you'd fetch historical data)
      final changePercent = _calculateMockChangePercent(event.fromCurrency, event.toCurrency);

      final currentRate = ExchangeRate(
        from: event.fromCurrency,
        to: event.toCurrency,
        rate: rate,
        changePercent: changePercent,
        lastUpdated: DateTime.now(),
      );

      emit(state.copyWith(
        fromCurrency: event.fromCurrency,
        toCurrency: event.toCurrency,
        amount: event.amount,
        convertedAmount: convertedAmount,
        currentRate: currentRate,
      ));
    } catch (e) {
      emit(state.copyWith(
        error: 'Error converting currency: $e',
      ));
    }
  }

  void _onUpdateFromCurrency(
      UpdateFromCurrency event,
      Emitter<CurrencyConversionState> emit,
      ) {
    emit(state.copyWith(fromCurrency: event.currencyCode));

    if (state.amount > 0) {
      add(ConvertCurrency(
        fromCurrency: event.currencyCode,
        toCurrency: state.toCurrency,
        amount: state.amount,
      ));
    }
  }

  void _onUpdateToCurrency(UpdateToCurrency event, Emitter<CurrencyConversionState> emit,) {
    emit(state.copyWith(toCurrency: event.currencyCode));

    if (state.amount > 0) {
      add(ConvertCurrency(
        fromCurrency: state.fromCurrency,
        toCurrency: event.currencyCode,
        amount: state.amount,
      ));
    }
  }

  void _onUpdateAmount(UpdateAmount event, Emitter<CurrencyConversionState> emit,) {
    emit(state.copyWith(amount: event.amount));

    if (event.amount > 0) {
      add(ConvertCurrency(
        fromCurrency: state.fromCurrency,
        toCurrency: state.toCurrency,
        amount: event.amount,
      ));
    }
  }

  /// Mock function to generate change percentage - replace with real API data
  double _calculateMockChangePercent(String from, String to) {
    // This is mock data - in a real app, you'd fetch historical data
    final mockChanges = {
      'USDEUR': -0.15,
      'EURUSD': 0.12,
      'USDGBP': -0.08,
      'GBPUSD': 0.09,
      'USDAED': -0.02,
      'AEDUSD': 0.02,
    };

    final key = '$from$to';
    return mockChanges[key] ?? (DateTime.now().millisecond % 100 - 50) / 100;
  }
}

/// currency_repository.dart
class CurrencyRepository {
  static const String _baseUrl = 'https://api.exchangerate-api.com/v4';

  Future<Map<String, double>> getExchangeRates({String baseCurrency = 'USD'}) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/latest/$baseCurrency'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Map<String, double>.from(
          data['rates'].map((key, value) => MapEntry(key, value.toDouble())),
        );
      } else {
        throw Exception('Failed to load exchange rates');
      }
    } catch (e) {
      throw Exception('Error fetching exchange rates: $e');
    }
  }

  Future<double> convertCurrency({
    required String from,
    required String to,
    required double amount,
  }) async {
    final rates = await getExchangeRates(baseCurrency: from);
    final rate = rates[to];
    if (rate == null) {
      throw Exception('Exchange rate not found for $from to $to');
    }
    return amount * rate;
  }
}