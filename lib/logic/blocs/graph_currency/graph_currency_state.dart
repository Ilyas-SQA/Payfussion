import '../../../data/models/graph_currency/graph_currency_model.dart';

abstract class GraphCurrencyState {}

class CurrencyInitial extends GraphCurrencyState {}

class CurrencyLoading extends GraphCurrencyState {}

class CurrencyLoaded extends GraphCurrencyState {
  final List<GraphCurrencyModel> currencies;
  final GraphCurrencyModel? selectedCurrency;
  final bool isLoadingSelected;
  final DateTime? lastUpdated;

  CurrencyLoaded(
      this.currencies, {
        this.selectedCurrency,
        this.isLoadingSelected = false,
        this.lastUpdated,
      });

  CurrencyLoaded copyWith({
    List<GraphCurrencyModel>? currencies,
    GraphCurrencyModel? selectedCurrency,
    bool? isLoadingSelected,
    DateTime? lastUpdated,
  }) {
    return CurrencyLoaded(
      currencies ?? this.currencies,
      selectedCurrency: selectedCurrency ?? this.selectedCurrency,
      isLoadingSelected: isLoadingSelected ?? this.isLoadingSelected,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

class CurrencyError extends GraphCurrencyState {
  final String message;
  final DateTime timestamp;

  CurrencyError(this.message) : timestamp = DateTime.now();
}