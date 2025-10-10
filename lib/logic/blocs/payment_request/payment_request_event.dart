import 'package:equatable/equatable.dart';

import '../../../data/models/payment_request/payment_request_model.dart';

abstract class PaymentRequestEvent extends Equatable {
  const PaymentRequestEvent();

  @override
  List<Object?> get props => [];
}

class LoadPaymentRequests extends PaymentRequestEvent {
  const LoadPaymentRequests();
}

class PaymentRequestsUpdated extends PaymentRequestEvent {
  final List<PaymentRequestModel> requests;

  const PaymentRequestsUpdated(this.requests);

  @override
  List<Object> get props => [requests];
}

class CreatePaymentRequest extends PaymentRequestEvent {
  final PaymentRequestModel paymentRequest;

  const CreatePaymentRequest(this.paymentRequest);

  @override
  List<Object> get props => [paymentRequest];
}

class AcceptPaymentRequest extends PaymentRequestEvent {
  final String requestId;

  const AcceptPaymentRequest(this.requestId);

  @override
  List<Object> get props => [requestId];
}

class RejectPaymentRequest extends PaymentRequestEvent {
  final String requestId;

  const RejectPaymentRequest(this.requestId);

  @override
  List<Object> get props => [requestId];
}