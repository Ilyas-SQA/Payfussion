import 'package:equatable/equatable.dart';

import '../../../data/models/pay_bills/bill_item.dart';

abstract class PayBillEvent extends Equatable {
  const PayBillEvent();

  @override
  List<Object?> get props => [];
}

// Load all pay bills
class LoadPayBills extends PayBillEvent {}

// Add new pay bill
class AddPayBill extends PayBillEvent {
  final PayBillModel payBill;

  const AddPayBill(this.payBill);

  @override
  List<Object?> get props => [payBill];
}

// Update pay bill status
class UpdatePayBillStatus extends PayBillEvent {
  final String billId;
  final String status;
  final DateTime? paidAt;

  const UpdatePayBillStatus(this.billId, this.status, {this.paidAt});

  @override
  List<Object?> get props => [billId, status, paidAt];
}

// Load pay bills by status
class LoadPayBillsByStatus extends PayBillEvent {
  final String status;

  const LoadPayBillsByStatus(this.status);

  @override
  List<Object?> get props => [status];
}

// Delete pay bill
class DeletePayBill extends PayBillEvent {
  final String billId;

  const DeletePayBill(this.billId);

  @override
  List<Object?> get props => [billId];
}

// Process payment (complete the bill payment)
class ProcessPayment extends PayBillEvent {
  final String billId;
  final String paymentMethod;
  final String cardId;

  const ProcessPayment(this.billId, this.paymentMethod, this.cardId);

  @override
  List<Object?> get props => [billId, paymentMethod, cardId];
}