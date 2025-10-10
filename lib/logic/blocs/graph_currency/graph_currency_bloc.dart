import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/graph_currency/graph_currency_model.dart';
import '../../../data/repositories/graph_currency/graph_currency_repository.dart';
import 'graph_currency_event.dart';
import 'graph_currency_state.dart';

class GraphCurrencyBloc extends Bloc<GraphCurrencyEvent, GraphCurrencyState> {
  final CurrencyApiService _apiService = CurrencyApiService();

  GraphCurrencyBloc() : super(CurrencyInitial()) {
    on<LoadCurrencies>(_onLoadCurrencies);
    on<SelectCurrency>(_onSelectCurrency);
    on<RefreshCurrencyData>(_onRefreshCurrencyData);
  }

  void _onLoadCurrencies(LoadCurrencies event, Emitter<GraphCurrencyState> emit) async {
    emit(CurrencyLoading());

    try {
      // Define the currencies you want to support
      final supportedCurrencies = ['USD', 'EUR', 'JPY', 'GBP', 'CAD', 'AUD', 'CHF'];

      // Get real-time data for all currencies
      final currenciesData = await CurrencyApiService.getMultipleCurrenciesData(
          supportedCurrencies,
          'USD' // Base currency
      );

      // Create currency models with real data
      final currencies = <GraphCurrencyModel>[];

      // USD as base currency
      currencies.add(GraphCurrencyModel(
        code: 'USD',
        name: 'US Dollar',
        currentPrice: 1.0,
        symbol: '\$',
        weeklyPrices: currenciesData['USD']?['weeklyRates']?.cast<double>() ?? [1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0],
        lastUpdated: DateTime.now(),
      ));

      // Add other currencies with real API data
      final currencyMetadata = {
        'EUR': {'name': 'Euro', 'symbol': '€'},
        'JPY': {'name': 'Japanese Yen', 'symbol': '¥'},
        'GBP': {'name': 'British Pound', 'symbol': '£'},
        'CAD': {'name': 'Canadian Dollar', 'symbol': 'C\$'},
        'AUD': {'name': 'Australian Dollar', 'symbol': 'A\$'},
        'CHF': {'name': 'Swiss Franc', 'symbol': 'CHF'},
      };

      for (String code in supportedCurrencies) {
        if (code != 'USD' && currenciesData.containsKey(code)) {
          final data = currenciesData[code]!;
          final metadata = currencyMetadata[code]!;

          currencies.add(GraphCurrencyModel(
            code: code,
            name: metadata['name']!,
            currentPrice: data['currentRate'] as double,
            symbol: metadata['symbol']!,
            weeklyPrices: (data['weeklyRates'] as List).cast<double>(),
            lastUpdated: DateTime.parse(data['lastUpdated'] as String),
          ));
        }
      }

      // Automatically select USD as default
      final defaultCurrency = currencies.firstWhere(
            (currency) => currency.code == 'USD',
        orElse: () => currencies.first,
      );

      emit(CurrencyLoaded(currencies, selectedCurrency: defaultCurrency));
    } catch (e) {
      print('Error loading currencies: $e');
      emit(CurrencyError('Failed to load currencies: ${e.toString()}\n\nPlease check your internet connection and try again.'));
    }
  }

  void _onSelectCurrency(SelectCurrency event, Emitter<GraphCurrencyState> emit) async {
    if (state is CurrencyLoaded) {
      final currentState = state as CurrencyLoaded;

      // Emit loading state for the selected currency
      emit(CurrencyLoaded(
        currentState.currencies,
        selectedCurrency: event.currency,
        isLoadingSelected: true,
      ));

      try {
        // Get fresh data for the selected currency
        final currencyData = await CurrencyApiService.getCurrencyData(event.currency.code);

        // Update the selected currency with fresh data
        final updatedCurrency = GraphCurrencyModel(
          code: event.currency.code,
          name: event.currency.name,
          currentPrice: currencyData['currentRate'] as double,
          symbol: event.currency.symbol,
          weeklyPrices: (currencyData['weeklyRates'] as List).cast<double>(),
          lastUpdated: DateTime.parse(currencyData['lastUpdated'] as String),
        );

        // Update the currencies list with the fresh data
        final updatedCurrencies = currentState.currencies.map((currency) {
          if (currency.code == event.currency.code) {
            return updatedCurrency;
          }
          return currency;
        }).toList();

        emit(CurrencyLoaded(updatedCurrencies, selectedCurrency: updatedCurrency));
      } catch (e) {
        print('Error refreshing currency data: $e');
        // Fallback to the original currency if refresh fails
        emit(CurrencyLoaded(currentState.currencies, selectedCurrency: event.currency));
      }
    }
  }

  void _onRefreshCurrencyData(RefreshCurrencyData event, Emitter<GraphCurrencyState> emit) async {
    if (state is CurrencyLoaded) {
      final currentState = state as CurrencyLoaded;

      try {
        // Get fresh data for all currencies
        final supportedCurrencies = currentState.currencies.map((c) => c.code).toList();
        final currenciesData = await CurrencyApiService.getMultipleCurrenciesData(supportedCurrencies, 'USD');

        // Update all currencies with fresh data
        final updatedCurrencies = currentState.currencies.map((currency) {
          if (currenciesData.containsKey(currency.code)) {
            final data = currenciesData[currency.code]!;
            return GraphCurrencyModel(
              code: currency.code,
              name: currency.name,
              currentPrice: currency.code == 'USD' ? 1.0 : data['currentRate'] as double,
              symbol: currency.symbol,
              weeklyPrices: (data['weeklyRates'] as List).cast<double>(),
              lastUpdated: DateTime.parse(data['lastUpdated'] as String),
            );
          }
          return currency;
        }).toList();

        // Maintain the selected currency
        final selectedCurrency = currentState.selectedCurrency != null
            ? updatedCurrencies.firstWhere(
              (c) => c.code == currentState.selectedCurrency!.code,
          orElse: () => updatedCurrencies.first,
        )
            : null;

        emit(CurrencyLoaded(updatedCurrencies, selectedCurrency: selectedCurrency));
      } catch (e) {
        print('Error refreshing data: $e');
        // Keep current state if refresh fails
        emit(currentState);
      }
    }
  }
}