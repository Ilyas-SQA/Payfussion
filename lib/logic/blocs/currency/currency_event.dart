abstract class CurrencyEvent {}

class SetCurrencyEvent extends CurrencyEvent {
  final String currency;
  SetCurrencyEvent(this.currency);
}

class LoadCurrencyEvent extends CurrencyEvent {}
