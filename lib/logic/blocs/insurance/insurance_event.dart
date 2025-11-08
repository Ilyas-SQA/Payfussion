// insurance_payment_event.dart
import 'package:equatable/equatable.dart';
import '../../../data/models/insurance/insurance_model.dart';

abstract class InsurancePaymentEvent extends Equatable {
  const InsurancePaymentEvent();

  @override
  List<Object?> get props => <Object?>[];
}

class LoadInsurancePayments extends InsurancePaymentEvent {
  final String? userId;

  const LoadInsurancePayments([this.userId]);

  @override
  List<Object?> get props => <Object?>[userId];
}

class AddInsurancePayment extends InsurancePaymentEvent {
  final InsurancePaymentModel payment;

  const AddInsurancePayment(this.payment);

  @override
  List<Object> get props => <Object>[payment];
}

class UpdateInsurancePayment extends InsurancePaymentEvent {
  final InsurancePaymentModel payment;

  const UpdateInsurancePayment(this.payment);

  @override
  List<Object> get props => <Object>[payment];
}

class DeleteInsurancePayment extends InsurancePaymentEvent {
  final String paymentId;

  const DeleteInsurancePayment(this.paymentId);

  @override
  List<Object> get props => <Object>[paymentId];
}

class ProcessInsurancePayment extends InsurancePaymentEvent {
  final String paymentId;
  final String paymentMethod;
  final String cardId;

  const ProcessInsurancePayment(this.paymentId, this.paymentMethod, this.cardId);

  @override
  List<Object> get props => <Object>[paymentId, paymentMethod, cardId];
}

class GetInsurancePaymentById extends InsurancePaymentEvent {
  final String paymentId;

  const GetInsurancePaymentById(this.paymentId);

  @override
  List<Object> get props => <Object>[paymentId];
}

class GetInsurancePaymentsByCompany extends InsurancePaymentEvent {
  final String companyName;

  const GetInsurancePaymentsByCompany(this.companyName);

  @override
  List<Object> get props => <Object>[companyName];
}

class GetInsurancePaymentsByType extends InsurancePaymentEvent {
  final String insuranceType;

  const GetInsurancePaymentsByType(this.insuranceType);

  @override
  List<Object> get props => <Object>[insuranceType];
}

class GetInsurancePaymentsByStatus extends InsurancePaymentEvent {
  final String status;

  const GetInsurancePaymentsByStatus(this.status);

  @override
  List<Object> get props => <Object>[status];
}

class GetInsurancePaymentsInDateRange extends InsurancePaymentEvent {
  final DateTime startDate;
  final DateTime endDate;

  const GetInsurancePaymentsInDateRange(this.startDate, this.endDate);

  @override
  List<Object> get props => <Object>[startDate, endDate];
}

class CalculateInsurancePaymentSummary extends InsurancePaymentEvent {
  final List<InsurancePaymentModel> payments;

  const CalculateInsurancePaymentSummary(this.payments);

  @override
  List<Object> get props => <Object>[payments];
}

class RefreshInsurancePayments extends InsurancePaymentEvent {
  const RefreshInsurancePayments();
}

class SearchInsurancePayments extends InsurancePaymentEvent {
  final String query;

  const SearchInsurancePayments(this.query);

  @override
  List<Object> get props => <Object>[query];
}

class FilterInsurancePayments extends InsurancePaymentEvent {
  final String? companyFilter;
  final String? typeFilter;
  final String? statusFilter;
  final DateTime? startDate;
  final DateTime? endDate;

  const FilterInsurancePayments({
    this.companyFilter,
    this.typeFilter,
    this.statusFilter,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => <Object?>[companyFilter, typeFilter, statusFilter, startDate, endDate];
}

class SortInsurancePayments extends InsurancePaymentEvent {
  final String sortBy; // 'date', 'amount', 'company', 'type'
  final bool ascending;

  const SortInsurancePayments(this.sortBy, {this.ascending = true});

  @override
  List<Object> get props => <Object>[sortBy, ascending];
}