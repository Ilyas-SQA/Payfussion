import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:payfussion/logic/blocs/submit_a_ticket/submit_a_ticket_event.dart';
import 'package:payfussion/logic/blocs/submit_a_ticket/submit_a_ticket_state.dart';

import '../../../services/submit_ticket_service.dart';

class SubmitATicketBloc extends Bloc<SubmitATicketEvent, SubmitATicketState> {
  final TicketRepository _ticketRepository;

  SubmitATicketBloc({
    required TicketRepository ticketRepository,
  }) : _ticketRepository = ticketRepository,
        super(SubmitATicketState()) {
    on<SubmitTicketEvent>(_onSubmitTicketEvent);
    on<ResetStateEvent>(_onResetStateEvent);
  }

  Future<void> _onSubmitTicketEvent(
      SubmitTicketEvent event,
      Emitter<SubmitATicketState> emit,
      ) async {
    // Show loading state
    emit(state.copyWith(
      isLoading: true,
      isSuccess: false,
      errorMessage: null,
    ));

    try {
      // Submit ticket to Firestore
      final ticketId = await _ticketRepository.submitTicket(
        title: event.title,
        description: event.description,
      );

      // Show success state
      emit(state.copyWith(
        isLoading: false,
        isSuccess: true,
        ticketId: ticketId,
      ));
    } catch (e) {
      // Show error state
      emit(state.copyWith(
        isLoading: false,
        isSuccess: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  void _onResetStateEvent(
      ResetStateEvent event,
      Emitter<SubmitATicketState> emit,
      ) {
    emit(SubmitATicketState());
  }
}