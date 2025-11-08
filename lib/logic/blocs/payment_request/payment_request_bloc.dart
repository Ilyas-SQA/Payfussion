import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:payfussion/logic/blocs/payment_request/payment_request_event.dart';
import 'package:payfussion/logic/blocs/payment_request/payment_request_state.dart';

import '../../../data/models/payment_request/payment_request_model.dart';
import '../../../data/repositories/payment_request/payment_request_repository.dart';

class PaymentRequestBloc extends Bloc<PaymentRequestEvent, PaymentRequestState> {
  final FirestorePaymentRepository _repository;

  PaymentRequestBloc({
    required FirestorePaymentRepository repository,
  })  : _repository = repository,
        super(const PaymentRequestState()) {

    on<LoadPaymentRequests>(_onLoadPaymentRequests);
    on<PaymentRequestsUpdated>(_onPaymentRequestsUpdated);
  }

  void _onLoadPaymentRequests(
      LoadPaymentRequests event,
      Emitter<PaymentRequestState> emit,
      ) async {
    emit(state.copyWith(status: PaymentRequestStatus.loading));

    try {
      await emit.forEach(
        _repository.streamPaymentRequests(),
        onData: (List<PaymentRequestModel> requests) {
          return state.copyWith(
            status: PaymentRequestStatus.success,
            requests: requests,
            errorMessage: null,
          );
        },
        onError: (Object error, StackTrace stackTrace) {
          return state.copyWith(
            status: PaymentRequestStatus.failure,
            errorMessage: error.toString(),
          );
        },
      );
    } catch (e) {
      emit(state.copyWith(
        status: PaymentRequestStatus.failure,
        errorMessage: 'Failed to load payment requests: ${e.toString()}',
      ));
    }
  }

  void _onPaymentRequestsUpdated(
      PaymentRequestsUpdated event,
      Emitter<PaymentRequestState> emit,
      ) {
    emit(state.copyWith(
      status: PaymentRequestStatus.success,
      requests: event.requests,
      errorMessage: null,
    ));
  }
}