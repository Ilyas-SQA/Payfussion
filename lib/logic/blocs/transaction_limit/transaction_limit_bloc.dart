import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:payfussion/logic/blocs/transaction_limit/transaction_limit_event.dart';
import 'package:payfussion/logic/blocs/transaction_limit/transaction_limit_state.dart';
import '../../../data/repositories/transsaction_limit/transaction_limit.dart';

class LimitBloc extends Bloc<LimitEvent, LimitState> {
  final LimitRepository repository;

  LimitBloc({required this.repository}) : super(LimitInitial()) {
    on<LoadLimitEvent>(_onLoadLimit);
    on<UpdateLimitEvent>(_onUpdateLimit);
    on<SelectTempLimitEvent>(_onSelectTempLimit);
    on<LoadAvailableLimitsEvent>(_onLoadAvailableLimits);
  }

  Future<void> _onLoadLimit(
      LoadLimitEvent event,
      Emitter<LimitState> emit,
      ) async {
    emit(LimitLoading());
    try {
      final limitData = await repository.getUserLimit(event.userId);
      final availableLimits = await repository.getAvailableLimits(event.userId);

      emit(LimitLoaded(
        limitData: limitData,
        availableLimits: availableLimits,
      ));
    } catch (e) {
      emit(LimitError(e.toString()));
    }
  }

  Future<void> _onLoadAvailableLimits(
      LoadAvailableLimitsEvent event,
      Emitter<LimitState> emit,
      ) async {
    if (state is LimitLoaded) {
      try {
        final availableLimits = await repository.getAvailableLimits(event.userId);
        final currentState = state as LimitLoaded;
        emit(currentState.copyWith(availableLimits: availableLimits));
      } catch (e) {
        // Keep current state if fetching fails
      }
    }
  }

  Future<void> _onUpdateLimit(
      UpdateLimitEvent event,
      Emitter<LimitState> emit,
      ) async {
    if (state is LimitLoaded) {
      final currentState = state as LimitLoaded;
      emit(LimitUpdating());
      try {
        await repository.updateUserLimit(event.userId, event.selectedLimit);

        // Load fresh data after update
        final updatedLimitData = await repository.getUserLimit(event.userId);

        emit(LimitLoaded(
          limitData: updatedLimitData,
          availableLimits: currentState.availableLimits,
        ));
      } catch (e) {
        emit(LimitError(e.toString()));
        // Restore previous state
        emit(currentState);
      }
    }
  }

  void _onSelectTempLimit(
      SelectTempLimitEvent event,
      Emitter<LimitState> emit,
      ) {
    if (state is LimitLoaded) {
      final currentState = state as LimitLoaded;
      emit(currentState.copyWith(tempSelectedLimit: event.limit));
    }
  }
}
