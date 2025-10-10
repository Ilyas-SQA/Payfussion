import '../../../data/models/graph_currency/graph_currency_model.dart';

abstract class GraphCurrencyEvent {}

class LoadCurrencies extends GraphCurrencyEvent {}

class SelectCurrency extends GraphCurrencyEvent {
  final GraphCurrencyModel currency;
  SelectCurrency(this.currency);
}

class RefreshCurrencyData extends GraphCurrencyEvent {}

class LoadSpecificCurrency extends GraphCurrencyEvent {
  final String currencyCode;
  LoadSpecificCurrency(this.currencyCode);
}