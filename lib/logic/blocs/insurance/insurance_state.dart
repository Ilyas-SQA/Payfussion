// insurance_payment_state.dart
import 'package:equatable/equatable.dart';
import '../../../data/models/insurance/insurance_model.dart';

abstract class InsurancePaymentState extends Equatable {
  const InsurancePaymentState();

  @override
  List<Object?> get props => <Object?>[];
}

class InsurancePaymentInitial extends InsurancePaymentState {
  const InsurancePaymentInitial();
}

class InsurancePaymentLoading extends InsurancePaymentState {
  const InsurancePaymentLoading();
}

class InsurancePaymentLoaded extends InsurancePaymentState {
  final List<InsurancePaymentModel> payments;

  const InsurancePaymentLoaded(this.payments);

  @override
  List<Object> get props => <Object>[payments];
}

class InsurancePaymentProcessing extends InsurancePaymentState {
  final String message;

  const InsurancePaymentProcessing([this.message = 'Processing payment...']);

  @override
  List<Object> get props => <Object>[message];
}

class InsurancePaymentSuccess extends InsurancePaymentState {
  final String message;
  final InsurancePaymentModel? payment;

  const InsurancePaymentSuccess(this.message, [this.payment]);

  @override
  List<Object?> get props => <Object?>[message, payment];
}

class InsurancePaymentProcessSuccess extends InsurancePaymentState {
  final InsurancePaymentModel payment;
  final String message;

  const InsurancePaymentProcessSuccess(this.payment, [this.message = 'Payment processed successfully']);

  @override
  List<Object> get props => <Object>[payment, message];
}

class InsurancePaymentError extends InsurancePaymentState {
  final String error;

  const InsurancePaymentError(this.error);

  @override
  List<Object> get props => <Object>[error];
}

class InsurancePaymentProcessFailed extends InsurancePaymentState {
  final String error;

  const InsurancePaymentProcessFailed(this.error);

  @override
  List<Object> get props => <Object>[error];
}

class InsurancePaymentDeleted extends InsurancePaymentState {
  final String message;

  const InsurancePaymentDeleted(this.message);

  @override
  List<Object> get props => <Object>[message];
}

class InsurancePaymentFound extends InsurancePaymentState {
  final InsurancePaymentModel payment;

  const InsurancePaymentFound(this.payment);

  @override
  List<Object> get props => <Object>[payment];
}

class InsurancePaymentNotFound extends InsurancePaymentState {
  final String message;

  const InsurancePaymentNotFound(this.message);

  @override
  List<Object> get props => <Object>[message];
}

class InsurancePaymentFiltered extends InsurancePaymentState {
  final List<InsurancePaymentModel> filteredPayments;
  final String filterCriteria;

  const InsurancePaymentFiltered(this.filteredPayments, this.filterCriteria);

  @override
  List<Object> get props => <Object>[filteredPayments, filterCriteria];
}

class InsurancePaymentSorted extends InsurancePaymentState {
  final List<InsurancePaymentModel> sortedPayments;
  final String sortCriteria;

  const InsurancePaymentSorted(this.sortedPayments, this.sortCriteria);

  @override
  List<Object> get props => <Object>[sortedPayments, sortCriteria];
}

class InsurancePaymentSearchResults extends InsurancePaymentState {
  final List<InsurancePaymentModel> searchResults;
  final String query;

  const InsurancePaymentSearchResults(this.searchResults, this.query);

  @override
  List<Object> get props => <Object>[searchResults, query];
}

class InsurancePaymentSummary extends InsurancePaymentState {
  final double totalPaid;
  final double totalFees;
  final int totalTransactions;
  final Map<String, double> paymentsByCompany;
  final Map<String, double> paymentsByType;
  final Map<String, int> transactionsByStatus;

  const InsurancePaymentSummary({
    required this.totalPaid,
    required this.totalFees,
    required this.totalTransactions,
    required this.paymentsByCompany,
    required this.paymentsByType,
    required this.transactionsByStatus,
  });

  @override
  List<Object> get props => <Object>[
    totalPaid,
    totalFees,
    totalTransactions,
    paymentsByCompany,
    paymentsByType,
    transactionsByStatus,
  ];
}

class InsurancePaymentEmpty extends InsurancePaymentState {
  final String message;

  const InsurancePaymentEmpty([this.message = 'No insurance payments found']);

  @override
  List<Object> get props => <Object>[message];
}

class InsurancePaymentOffline extends InsurancePaymentState {
  final String message;

  const InsurancePaymentOffline([this.message = 'You are offline. Some features may not be available.']);

  @override
  List<Object> get props => <Object>[message];
}

class InsurancePaymentUnauthorized extends InsurancePaymentState {
  final String message;

  const InsurancePaymentUnauthorized([this.message = 'Unauthorized access. Please login again.']);

  @override
  List<Object> get props => <Object>[message];
}