abstract class CurrencyState {}

class CurrencyInitialState extends CurrencyState {
  final String currency;

  CurrencyInitialState(this.currency);
}

class CurrencyLoadingState extends CurrencyState {}

class CurrencyUpdatedState extends CurrencyState {
  final String currency;

  CurrencyUpdatedState(this.currency);
}

class CurrencyErrorState extends CurrencyState {
  final String message;

  CurrencyErrorState(this.message);
}
