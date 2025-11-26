// lib/logic/blocs/exchange_currency/exchange_currency_bloc.dart

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../services/currency_exchange_service.dart';
import 'exchange_currency_event.dart';
import 'exchange_currency_state.dart';

class ExchangeCurrencyBloc extends Bloc<ExchangeCurrencyEvent, ExchangeCurrencyState> {
  final CurrencyApiService _apiService;
  Timer? _autoRefreshTimer;

  ExchangeCurrencyBloc({CurrencyApiService? apiService})
      : _apiService = apiService ?? CurrencyApiService(),
        super(const ExchangeCurrencyState()) {

    on<NumberPressed>(_onNumberPressed);
    on<DecimalPressed>(_onDecimalPressed);
    on<ClearPressed>(_onClearPressed);
    on<BackspacePressed>(_onBackspacePressed);
    on<SourceCurrencyChanged>(_onSourceCurrencyChanged);
    on<TargetCurrencyChanged>(_onTargetCurrencyChanged);
    on<SwapCurrencies>(_onSwapCurrencies);
    on<FetchExchangeRates>(_onFetchExchangeRates);
    on<RefreshExchangeRates>(_onRefreshExchangeRates);

    // Auto-fetch rates on initialization
    add(const FetchExchangeRates());

    // Auto-refresh every 5 minutes
    _startAutoRefresh();
  }

  void _startAutoRefresh() {
    _autoRefreshTimer = Timer.periodic(
      const Duration(minutes: 5),
          (_) => add(const RefreshExchangeRates()),
    );
  }

  @override
  Future<void> close() {
    _autoRefreshTimer?.cancel();
    return super.close();
  }

  void _onNumberPressed(NumberPressed event, Emitter<ExchangeCurrencyState> emit) {
    String newInput = state.amountInput;

    // Prevent multiple leading zeros
    if (state.amountInput == '0' && event.number == '0') {
      return;
    }

    // Replace initial zero with new number
    if (state.amountInput == '0') {
      newInput = event.number;
    } else {
      newInput = state.amountInput + event.number;
    }

    final double amount = double.tryParse(newInput) ?? 0;
    final double converted = _convertAmount(amount);

    emit(state.copyWith(
      amountInput: newInput,
      amount: amount,
      conversionResult: converted,
    ));
  }

  void _onDecimalPressed(DecimalPressed event, Emitter<ExchangeCurrencyState> emit) {
    // Add decimal point only if it doesn't already exist
    if (!state.amountInput.contains('.')) {
      final String newInput = state.amountInput + '.';
      emit(state.copyWith(amountInput: newInput));
    }
  }

  void _onClearPressed(ClearPressed event, Emitter<ExchangeCurrencyState> emit) {
    emit(state.copyWith(
      amountInput: '0',
      amount: 0,
      conversionResult: 0,
    ));
  }

  void _onBackspacePressed(BackspacePressed event, Emitter<ExchangeCurrencyState> emit) {
    String newInput = state.amountInput;

    if (newInput.length > 1) {
      newInput = newInput.substring(0, newInput.length - 1);
    } else {
      newInput = '0';
    }

    final double amount = double.tryParse(newInput) ?? 0;
    final double converted = _convertAmount(amount);

    emit(state.copyWith(
      amountInput: newInput,
      amount: amount,
      conversionResult: converted,
    ));
  }

  Future<void> _onSourceCurrencyChanged(
      SourceCurrencyChanged event,
      Emitter<ExchangeCurrencyState> emit,
      ) async {
    emit(state.copyWith(
      sourceCurrency: event.currency,
      status: ExchangeStatus.loading,
    ));

    try {
      final Map<String, dynamic> data = await _apiService.getExchangeRates(event.currency);
      final Map<String, double> rates = (data['rates'] as Map<String, dynamic>).map(
            (String key, value) => MapEntry(key, (value as num).toDouble()),
      );
      final DateTime lastUpdated = await _apiService.getLastUpdateTime(event.currency);

      final double converted = _convertAmount(state.amount, rates: rates);

      emit(state.copyWith(
        exchangeRates: rates,
        lastUpdated: lastUpdated,
        conversionResult: converted,
        status: ExchangeStatus.success,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ExchangeStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onTargetCurrencyChanged(
      TargetCurrencyChanged event,
      Emitter<ExchangeCurrencyState> emit,
      ) async {
    emit(state.copyWith(
      targetCurrency: event.currency,
    ));

    final double converted = _convertAmount(state.amount);
    emit(state.copyWith(conversionResult: converted));
  }

  void _onSwapCurrencies(
      SwapCurrencies event,
      Emitter<ExchangeCurrencyState> emit,
      ) {
    final String currentSource = state.sourceCurrency;
    final String currentTarget = state.targetCurrency;

    // Swap the currencies
    emit(state.copyWith(
      sourceCurrency: currentTarget,
      targetCurrency: currentSource,
    ));

    // Trigger source currency changed to fetch new rates
    add(SourceCurrencyChanged(currency: currentTarget));
  }

  Future<void> _onFetchExchangeRates(
      FetchExchangeRates event,
      Emitter<ExchangeCurrencyState> emit,
      ) async {
    emit(state.copyWith(status: ExchangeStatus.loading));

    try {
      final Map<String, dynamic> data = await _apiService.getExchangeRates(state.sourceCurrency);
      final Map<String, double> rates = (data['rates'] as Map<String, dynamic>).map(
            (String key, value) => MapEntry(key, (value as num).toDouble()),
      );
      final DateTime lastUpdated = await _apiService.getLastUpdateTime(state.sourceCurrency);

      final double converted = _convertAmount(state.amount, rates: rates);

      emit(state.copyWith(
        exchangeRates: rates,
        lastUpdated: lastUpdated,
        conversionResult: converted,
        status: ExchangeStatus.success,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ExchangeStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onRefreshExchangeRates(
      RefreshExchangeRates event,
      Emitter<ExchangeCurrencyState> emit,
      ) async {
    // Show loading indicator during refresh
    emit(state.copyWith(status: ExchangeStatus.loading));

    try {
      final Map<String, dynamic> data = await _apiService.getExchangeRates(state.sourceCurrency);
      final Map<String, double> rates = (data['rates'] as Map<String, dynamic>).map(
            (String key, value) => MapEntry(key, (value as num).toDouble()),
      );
      final DateTime lastUpdated = await _apiService.getLastUpdateTime(state.sourceCurrency);

      final double converted = _convertAmount(state.amount, rates: rates);

      emit(state.copyWith(
        exchangeRates: rates,
        lastUpdated: lastUpdated,
        conversionResult: converted,
        status: ExchangeStatus.success,
      ));
    } catch (e) {
      // Silent fail for auto-refresh, but still show error
      emit(state.copyWith(
        status: ExchangeStatus.error,
        errorMessage: 'Failed to refresh rates: ${e.toString()}',
      ));
    }
  }

  double _convertAmount(double amount, {Map<String, double>? rates}) {
    final Map<String, double>? currentRates = rates ?? state.exchangeRates;
    if (currentRates == null) return 0;

    final double? targetRate = currentRates[state.targetCurrency];
    if (targetRate == null) return 0;

    return amount * targetRate;
  }
}