import 'package:equatable/equatable.dart';

import '../../../data/models/pay_bills/bill_item.dart';

abstract class PayBillState extends Equatable {
  const PayBillState();

  @override
  List<Object?> get props => [];
}

// Initial state
class PayBillInitial extends PayBillState {}

// Loading state
class PayBillLoading extends PayBillState {}

// Loaded state with pay bills
class PayBillLoaded extends PayBillState {
  final List<PayBillModel> payBills;

  const PayBillLoaded(this.payBills);

  @override
  List<Object?> get props => [payBills];
}

// Payment processing state
class PayBillProcessing extends PayBillState {
  final String billId;

  const PayBillProcessing(this.billId);

  @override
  List<Object?> get props => [billId];
}

// Payment success state
class PayBillPaymentSuccess extends PayBillState {
  final PayBillModel payBill;
  final String message;

  const PayBillPaymentSuccess(this.payBill, {this.message = 'Payment successful!'});

  @override
  List<Object?> get props => [payBill, message];
}

// Payment failed state
class PayBillPaymentFailed extends PayBillState {
  final String error;
  final String billId;

  const PayBillPaymentFailed(this.error, this.billId);

  @override
  List<Object?> get props => [error, billId];
}

// Error state
class PayBillError extends PayBillState {
  final String error;

  const PayBillError(this.error);

  @override
  List<Object?> get props => [error];
}

// Success state for general operations
class PayBillSuccess extends PayBillState {
  final String message;

  const PayBillSuccess(this.message);

  @override
  List<Object?> get props => [message];
}