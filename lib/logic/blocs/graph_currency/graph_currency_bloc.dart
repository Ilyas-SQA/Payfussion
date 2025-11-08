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
      final List<String> supportedCurrencies = <String>['USD', 'EUR', 'JPY', 'GBP', 'CAD', 'AUD', 'CHF'];

      // Get real-time data for all currencies
      final Map<String, Map<String, dynamic>> currenciesData = await CurrencyApiService.getMultipleCurrenciesData(
          supportedCurrencies,
          'USD' // Base currency
      );

      // Create currency models with real data
      final List<GraphCurrencyModel> currencies = <GraphCurrencyModel>[];

      // USD as base currency
      currencies.add(GraphCurrencyModel(
        code: 'USD',
        name: 'US Dollar',
        currentPrice: 1.0,
        symbol: '\$',
        weeklyPrices: currenciesData['USD']?['weeklyRates']?.cast<double>() ?? <double>[1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0],
        lastUpdated: DateTime.now(),
      ));

      // Add other currencies with real API data
      final Map<String, Map<String, String>> currencyMetadata = <String, Map<String, String>>{
        'EUR': <String, String>{'name': 'Euro', 'symbol': '€'},
        'JPY': <String, String>{'name': 'Japanese Yen', 'symbol': '¥'},
        'GBP': <String, String>{'name': 'British Pound', 'symbol': '£'},
        'CAD': <String, String>{'name': 'Canadian Dollar', 'symbol': 'C\$'},
        'AUD': <String, String>{'name': 'Australian Dollar', 'symbol': 'A\$'},
        'CHF': <String, String>{'name': 'Swiss Franc', 'symbol': 'CHF'},
      };

      for (String code in supportedCurrencies) {
        if (code != 'USD' && currenciesData.containsKey(code)) {
          final Map<String, dynamic> data = currenciesData[code]!;
          final Map<String, String> metadata = currencyMetadata[code]!;

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
      final GraphCurrencyModel defaultCurrency = currencies.firstWhere(
            (GraphCurrencyModel currency) => currency.code == 'USD',
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
      final CurrencyLoaded currentState = state as CurrencyLoaded;

      // Emit loading state for the selected currency
      emit(CurrencyLoaded(
        currentState.currencies,
        selectedCurrency: event.currency,
        isLoadingSelected: true,
      ));

      try {
        // Get fresh data for the selected currency
        final Map<String, dynamic> currencyData = await CurrencyApiService.getCurrencyData(event.currency.code);

        // Update the selected currency with fresh data
        final GraphCurrencyModel updatedCurrency = GraphCurrencyModel(
          code: event.currency.code,
          name: event.currency.name,
          currentPrice: currencyData['currentRate'] as double,
          symbol: event.currency.symbol,
          weeklyPrices: (currencyData['weeklyRates'] as List).cast<double>(),
          lastUpdated: DateTime.parse(currencyData['lastUpdated'] as String),
        );

        // Update the currencies list with the fresh data
        final List<GraphCurrencyModel> updatedCurrencies = currentState.currencies.map((GraphCurrencyModel currency) {
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
      final CurrencyLoaded currentState = state as CurrencyLoaded;

      try {
        // Get fresh data for all currencies
        final List<String> supportedCurrencies = currentState.currencies.map((GraphCurrencyModel c) => c.code).toList();
        final Map<String, Map<String, dynamic>> currenciesData = await CurrencyApiService.getMultipleCurrenciesData(supportedCurrencies, 'USD');

        // Update all currencies with fresh data
        final List<GraphCurrencyModel> updatedCurrencies = currentState.currencies.map((GraphCurrencyModel currency) {
          if (currenciesData.containsKey(currency.code)) {
            final Map<String, dynamic> data = currenciesData[currency.code]!;
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
        final GraphCurrencyModel? selectedCurrency = currentState.selectedCurrency != null
            ? updatedCurrencies.firstWhere(
              (GraphCurrencyModel c) => c.code == currentState.selectedCurrency!.code,
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