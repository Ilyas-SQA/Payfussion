import 'package:equatable/equatable.dart';

import '../../../data/models/payment_request/payment_request_model.dart';

enum PaymentRequestStatus { initial, loading, success, failure }

class PaymentRequestState extends Equatable {
  final PaymentRequestStatus status;
  final List<PaymentRequestModel> requests;
  final String? errorMessage;

  const PaymentRequestState({
    this.status = PaymentRequestStatus.initial,
    this.requests = const <PaymentRequestModel>[],
    this.errorMessage,
  });

  PaymentRequestState copyWith({
    PaymentRequestStatus? status,
    List<PaymentRequestModel>? requests,
    String? errorMessage,
  }) {
    return PaymentRequestState(
      status: status ?? this.status,
      requests: requests ?? this.requests,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => <Object?>[status, requests, errorMessage];
}