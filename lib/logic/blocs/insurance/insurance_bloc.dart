// insurance_payment_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/insurance/insurance_model.dart';
import '../../../data/repositories/insurance/insurance_repository.dart';
import 'insurance_event.dart';
import 'insurance_state.dart';

class InsurancePaymentBloc extends Bloc<InsurancePaymentEvent, InsurancePaymentState> {
  final InsurancePaymentRepository _repository;
  List<InsurancePaymentModel> _allPayments = [];

  InsurancePaymentBloc(this._repository) : super(const InsurancePaymentInitial()) {
    on<LoadInsurancePayments>(_onLoadInsurancePayments);
    on<AddInsurancePayment>(_onAddInsurancePayment);
    on<UpdateInsurancePayment>(_onUpdateInsurancePayment);
    on<DeleteInsurancePayment>(_onDeleteInsurancePayment);
    on<ProcessInsurancePayment>(_onProcessInsurancePayment);
    on<GetInsurancePaymentById>(_onGetInsurancePaymentById);
    on<GetInsurancePaymentsByCompany>(_onGetInsurancePaymentsByCompany);
    on<GetInsurancePaymentsByType>(_onGetInsurancePaymentsByType);
    on<GetInsurancePaymentsByStatus>(_onGetInsurancePaymentsByStatus);
    on<GetInsurancePaymentsInDateRange>(_onGetInsurancePaymentsInDateRange);
    on<CalculateInsurancePaymentSummary>(_onCalculateInsurancePaymentSummary);
    on<RefreshInsurancePayments>(_onRefreshInsurancePayments);
    on<SearchInsurancePayments>(_onSearchInsurancePayments);
    on<FilterInsurancePayments>(_onFilterInsurancePayments);
    on<SortInsurancePayments>(_onSortInsurancePayments);
  }

  Future<void> _onLoadInsurancePayments(
      LoadInsurancePayments event,
      Emitter<InsurancePaymentState> emit,
      ) async {
    try {
      emit(const InsurancePaymentLoading());

      final payments = await _repository.getInsurancePayments();
      _allPayments = payments;

      if (payments.isEmpty) {
        emit(const InsurancePaymentEmpty());
      } else {
        emit(InsurancePaymentLoaded(payments));
      }
    } catch (e) {
      emit(InsurancePaymentError(e.toString()));
    }
  }

  Future<void> _onAddInsurancePayment(
      AddInsurancePayment event,
      Emitter<InsurancePaymentState> emit,
      ) async {
    try {
      emit(const InsurancePaymentProcessing('Adding insurance payment...'));

      await _repository.addInsurancePayment(event.payment);

      // Update local list
      _allPayments.insert(0, event.payment);

      emit(const InsurancePaymentSuccess('Insurance payment added successfully'));
      emit(InsurancePaymentLoaded(_allPayments));
    } catch (e) {
      emit(InsurancePaymentError('Failed to add insurance payment: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateInsurancePayment(
      UpdateInsurancePayment event,
      Emitter<InsurancePaymentState> emit,
      ) async {
    try {
      emit(const InsurancePaymentProcessing('Updating insurance payment...'));

      await _repository.updateInsurancePayment(event.payment);

      // Update local list
      final index = _allPayments.indexWhere((p) => p.id == event.payment.id);
      if (index != -1) {
        _allPayments[index] = event.payment;
      }

      emit(const InsurancePaymentSuccess('Insurance payment updated successfully'));
      emit(InsurancePaymentLoaded(_allPayments));
    } catch (e) {
      emit(InsurancePaymentError('Failed to update insurance payment: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteInsurancePayment(
      DeleteInsurancePayment event,
      Emitter<InsurancePaymentState> emit,
      ) async {
    try {
      emit(const InsurancePaymentProcessing('Deleting insurance payment...'));

      await _repository.deleteInsurancePayment(event.paymentId);

      // Remove from local list
      _allPayments.removeWhere((payment) => payment.id == event.paymentId);

      emit(const InsurancePaymentDeleted('Insurance payment deleted successfully'));

      if (_allPayments.isEmpty) {
        emit(const InsurancePaymentEmpty());
      } else {
        emit(InsurancePaymentLoaded(_allPayments));
      }
    } catch (e) {
      emit(InsurancePaymentError('Failed to delete insurance payment: ${e.toString()}'));
    }
  }

  Future<void> _onProcessInsurancePayment(
      ProcessInsurancePayment event,
      Emitter<InsurancePaymentState> emit,
      ) async {
    try {
      emit(const InsurancePaymentProcessing('Processing payment...'));

      final updatedPayment = await _repository.processPayment(
        event.paymentId,
        event.paymentMethod,
        event.cardId,
      );

      // Update local list
      final index = _allPayments.indexWhere((p) => p.id == event.paymentId);
      if (index != -1) {
        _allPayments[index] = updatedPayment;
      }

      emit(InsurancePaymentProcessSuccess(updatedPayment));
    } catch (e) {
      emit(InsurancePaymentProcessFailed('Payment processing failed: ${e.toString()}'));
    }
  }

  Future<void> _onGetInsurancePaymentById(
      GetInsurancePaymentById event,
      Emitter<InsurancePaymentState> emit,
      ) async {
    try {
      emit(const InsurancePaymentLoading());

      final payment = await _repository.getInsurancePaymentById(event.paymentId);

      if (payment != null) {
        emit(InsurancePaymentFound(payment));
      } else {
        emit(const InsurancePaymentNotFound('Insurance payment not found'));
      }
    } catch (e) {
      emit(InsurancePaymentError('Failed to fetch insurance payment: ${e.toString()}'));
    }
  }

  Future<void> _onGetInsurancePaymentsByCompany(
      GetInsurancePaymentsByCompany event,
      Emitter<InsurancePaymentState> emit,
      ) async {
    try {
      emit(const InsurancePaymentLoading());

      final payments = await _repository.getInsurancePaymentsByCompany(event.companyName);

      if (payments.isEmpty) {
        emit(const InsurancePaymentEmpty('No payments found for this company'));
      } else {
        emit(InsurancePaymentFiltered(payments, 'Company: ${event.companyName}'));
      }
    } catch (e) {
      emit(InsurancePaymentError('Failed to fetch payments by company: ${e.toString()}'));
    }
  }

  Future<void> _onGetInsurancePaymentsByType(
      GetInsurancePaymentsByType event,
      Emitter<InsurancePaymentState> emit,
      ) async {
    try {
      emit(const InsurancePaymentLoading());

      final payments = await _repository.getInsurancePaymentsByType(event.insuranceType);

      if (payments.isEmpty) {
        emit(const InsurancePaymentEmpty('No payments found for this insurance type'));
      } else {
        emit(InsurancePaymentFiltered(payments, 'Type: ${event.insuranceType}'));
      }
    } catch (e) {
      emit(InsurancePaymentError('Failed to fetch payments by type: ${e.toString()}'));
    }
  }

  Future<void> _onGetInsurancePaymentsByStatus(
      GetInsurancePaymentsByStatus event,
      Emitter<InsurancePaymentState> emit,
      ) async {
    try {
      emit(const InsurancePaymentLoading());

      final payments = await _repository.getInsurancePaymentsByStatus(event.status);

      if (payments.isEmpty) {
        emit(const InsurancePaymentEmpty('No payments found with this status'));
      } else {
        emit(InsurancePaymentFiltered(payments, 'Status: ${event.status}'));
      }
    } catch (e) {
      emit(InsurancePaymentError('Failed to fetch payments by status: ${e.toString()}'));
    }
  }

  Future<void> _onGetInsurancePaymentsInDateRange(
      GetInsurancePaymentsInDateRange event,
      Emitter<InsurancePaymentState> emit,
      ) async {
    try {
      emit(const InsurancePaymentLoading());

      final payments = await _repository.getInsurancePaymentsInDateRange(
        event.startDate,
        event.endDate,
      );

      if (payments.isEmpty) {
        emit(const InsurancePaymentEmpty('No payments found in this date range'));
      } else {
        emit(InsurancePaymentFiltered(
          payments,
          'Date Range: ${event.startDate.day}/${event.startDate.month}/${event.startDate.year} - ${event.endDate.day}/${event.endDate.month}/${event.endDate.year}',
        ));
      }
    } catch (e) {
      emit(InsurancePaymentError('Failed to fetch payments by date range: ${e.toString()}'));
    }
  }

  Future<void> _onCalculateInsurancePaymentSummary(
      CalculateInsurancePaymentSummary event,
      Emitter<InsurancePaymentState> emit,
      ) async {
    try {
      emit(const InsurancePaymentLoading());

      final statistics = await _repository.getPaymentStatistics();

      emit(InsurancePaymentSummary(
        totalPaid: statistics['totalPaid'],
        totalFees: statistics['totalFees'],
        totalTransactions: statistics['totalTransactions'],
        paymentsByCompany: Map<String, double>.from(statistics['paymentsByCompany']),
        paymentsByType: Map<String, double>.from(statistics['paymentsByType']),
        transactionsByStatus: Map<String, int>.from(statistics['transactionsByStatus']),
      ));
    } catch (e) {
      emit(InsurancePaymentError('Failed to calculate payment summary: ${e.toString()}'));
    }
  }

  Future<void> _onRefreshInsurancePayments(
      RefreshInsurancePayments event,
      Emitter<InsurancePaymentState> emit,
      ) async {
    try {
      final payments = await _repository.getInsurancePayments();
      _allPayments = payments;

      if (payments.isEmpty) {
        emit(const InsurancePaymentEmpty());
      } else {
        emit(InsurancePaymentLoaded(payments));
      }
    } catch (e) {
      emit(InsurancePaymentError('Failed to refresh payments: ${e.toString()}'));
    }
  }

  Future<void> _onSearchInsurancePayments(
      SearchInsurancePayments event,
      Emitter<InsurancePaymentState> emit,
      ) async {
    try {
      emit(const InsurancePaymentLoading());

      final searchResults = await _repository.searchInsurancePayments(event.query);

      if (searchResults.isEmpty) {
        emit(InsurancePaymentSearchResults([], event.query));
      } else {
        emit(InsurancePaymentSearchResults(searchResults, event.query));
      }
    } catch (e) {
      emit(InsurancePaymentError('Search failed: ${e.toString()}'));
    }
  }

  void _onFilterInsurancePayments(
      FilterInsurancePayments event,
      Emitter<InsurancePaymentState> emit,
      ) {
    try {
      List<InsurancePaymentModel> filteredPayments = List.from(_allPayments);
      List<String> filterCriteria = [];

      // Filter by company
      if (event.companyFilter != null && event.companyFilter!.isNotEmpty) {
        filteredPayments = filteredPayments
            .where((payment) => payment.companyName
            .toLowerCase()
            .contains(event.companyFilter!.toLowerCase()))
            .toList();
        filterCriteria.add('Company: ${event.companyFilter}');
      }

      // Filter by type
      if (event.typeFilter != null && event.typeFilter!.isNotEmpty) {
        filteredPayments = filteredPayments
            .where((payment) => payment.insuranceType
            .toLowerCase()
            .contains(event.typeFilter!.toLowerCase()))
            .toList();
        filterCriteria.add('Type: ${event.typeFilter}');
      }

      // Filter by status
      if (event.statusFilter != null && event.statusFilter!.isNotEmpty) {
        filteredPayments = filteredPayments
            .where((payment) => payment.status.toLowerCase() == event.statusFilter!.toLowerCase())
            .toList();
        filterCriteria.add('Status: ${event.statusFilter}');
      }

      // Filter by date range
      if (event.startDate != null && event.endDate != null) {
        filteredPayments = filteredPayments
            .where((payment) =>
        payment.createdAt.isAfter(event.startDate!) &&
            payment.createdAt.isBefore(event.endDate!.add(const Duration(days: 1))))
            .toList();
        filterCriteria.add(
            'Date: ${event.startDate!.day}/${event.startDate!.month}/${event.startDate!.year} - ${event.endDate!.day}/${event.endDate!.month}/${event.endDate!.year}');
      }

      final criteriaString = filterCriteria.join(', ');

      if (filteredPayments.isEmpty) {
        emit(const InsurancePaymentEmpty('No payments match the selected filters'));
      } else {
        emit(InsurancePaymentFiltered(filteredPayments, criteriaString));
      }
    } catch (e) {
      emit(InsurancePaymentError('Filter failed: ${e.toString()}'));
    }
  }

  void _onSortInsurancePayments(
      SortInsurancePayments event,
      Emitter<InsurancePaymentState> emit,
      ) {
    try {
      List<InsurancePaymentModel> sortedPayments = List.from(_allPayments);

      switch (event.sortBy.toLowerCase()) {
        case 'date':
          sortedPayments.sort((a, b) => event.ascending
              ? a.createdAt.compareTo(b.createdAt)
              : b.createdAt.compareTo(a.createdAt));
          break;
        case 'amount':
          sortedPayments.sort((a, b) => event.ascending
              ? a.premiumAmount.compareTo(b.premiumAmount)
              : b.premiumAmount.compareTo(a.premiumAmount));
          break;
        case 'company':
          sortedPayments.sort((a, b) => event.ascending
              ? a.companyName.compareTo(b.companyName)
              : b.companyName.compareTo(a.companyName));
          break;
        case 'type':
          sortedPayments.sort((a, b) => event.ascending
              ? a.insuranceType.compareTo(b.insuranceType)
              : b.insuranceType.compareTo(a.insuranceType));
          break;
        default:
          sortedPayments.sort((a, b) => event.ascending
              ? a.createdAt.compareTo(b.createdAt)
              : b.createdAt.compareTo(a.createdAt));
      }

      final sortCriteria = '${event.sortBy.toLowerCase()} (${event.ascending ? 'ascending' : 'descending'})';
      emit(InsurancePaymentSorted(sortedPayments, sortCriteria));
    } catch (e) {
      emit(InsurancePaymentError('Sort failed: ${e.toString()}'));
    }
  }
}