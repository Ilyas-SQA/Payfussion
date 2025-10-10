import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../services/local_storage.dart';
import 'currency_event.dart';
import 'currency_state.dart';

class CurrencyBloc extends Bloc<CurrencyEvent, CurrencyState> {
  final LocalStorage localStorage;
  static const String _currencyKey = 'currency_key';

  CurrencyBloc({required this.localStorage}) : super(CurrencyLoadingState()) {
    on<LoadCurrencyEvent>(_onLoadCurrency);
    on<SetCurrencyEvent>(_onSetCurrency);
  }

  Future<void> _onLoadCurrency(
    LoadCurrencyEvent event,
    Emitter<CurrencyState> emit,
  ) async {
    try {
      final currency = await localStorage.readValue(_currencyKey) ?? 'USD';
      emit(CurrencyInitialState(currency));
    } catch (e) {
      emit(CurrencyErrorState("Failed to load currency"));
    }
  }

  Future<void> _onSetCurrency(
    SetCurrencyEvent event,
    Emitter<CurrencyState> emit,
  ) async {
    try {
      await localStorage.setValue(_currencyKey, event.currency);
      emit(CurrencyUpdatedState(event.currency));
    } catch (e) {
      emit(CurrencyErrorState("Failed to update currency"));
    }
  }
}
