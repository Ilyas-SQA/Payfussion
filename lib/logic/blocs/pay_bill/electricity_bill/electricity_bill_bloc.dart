import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/constants/tax.dart';
import '../../../../services/notification_service.dart';
import '../../notification/notification_bloc.dart';
import '../../notification/notification_event.dart';
import 'electricity_bill_event.dart';
import 'electricity_bill_state.dart';

class ElectricityBillBloc extends Bloc<ElectricityBillEvent, ElectricityBillState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final NotificationBloc _notificationBloc;

  ElectricityBillBloc(this._notificationBloc) : super(ElectricityBillInitial()) {
    on<FetchBillDetails>(_onFetchBillDetails);
    on<SetElectricityBillData>(_onSetElectricityBillData);
    on<SetSelectedCardForElectricityBill>(_onSetSelectedCard);
    on<ProcessElectricityBillPayment>(_onProcessElectricityBillPayment);
    on<ResetElectricityBill>(_onResetElectricityBill);
  }

  Future<void> _onFetchBillDetails(
      FetchBillDetails event,
      Emitter<ElectricityBillState> emit,
      ) async {
    try {
      emit(ElectricityBillProcessing());

      // Simulate API call - Replace with actual API call
      await Future.delayed(const Duration(seconds: 2));

      // Sample data - Replace with actual API response
      final double billAmount = 185.50;
      final String dueDate = '28 Nov 2025';
      final String billMonth = 'October 2025';
      final String consumerName = 'Sarah Johnson';
      final String address = '456 Oak Avenue, New York';
      final String unitsConsumed = '650 kWh';
      final String previousReading = '8,250';
      final String currentReading = '8,900';

      // Get region and average rate from provider name (you can pass these as parameters)
      final String region = 'New York';
      final String averageRate = '\$0.22/kWh';

      // Calculate tax
      final double taxAmount = double.parse(Taxes.billTax.toString());
      final double totalAmount = billAmount + taxAmount;

      emit(ElectricityBillDataSet(
        providerName: event.providerName,
        region: region,
        averageRate: averageRate,
        accountNumber: event.accountNumber,
        consumerName: consumerName,
        address: address,
        billMonth: billMonth,
        amount: billAmount,
        taxAmount: taxAmount,
        totalAmount: totalAmount,
        unitsConsumed: unitsConsumed,
        previousReading: previousReading,
        currentReading: currentReading,
        dueDate: dueDate,
      ));
    } catch (e) {
      emit(ElectricityBillError(e.toString()));
    }
  }

  Future<void> _onSetElectricityBillData(
      SetElectricityBillData event,
      Emitter<ElectricityBillState> emit,
      ) async {
    try {
      // Calculate tax
      final double taxAmount = double.parse(Taxes.billTax.toString());
      final double totalAmount = event.amount + taxAmount;

      emit(ElectricityBillDataSet(
        providerName: event.providerName,
        region: event.region,
        averageRate: event.averageRate,
        accountNumber: event.accountNumber,
        consumerName: event.consumerName,
        address: event.address,
        billMonth: event.billMonth,
        amount: event.amount,
        taxAmount: taxAmount,
        totalAmount: totalAmount,
        unitsConsumed: event.unitsConsumed,
        previousReading: event.previousReading,
        currentReading: event.currentReading,
        dueDate: event.dueDate,
      ));
    } catch (e) {
      emit(ElectricityBillError(e.toString()));
    }
  }

  Future<void> _onSetSelectedCard(
      SetSelectedCardForElectricityBill event,
      Emitter<ElectricityBillState> emit,
      ) async {
    if (state is ElectricityBillDataSet) {
      final ElectricityBillDataSet currentState = state as ElectricityBillDataSet;
      emit(currentState.copyWith(
        cardId: event.cardId,
        cardHolderName: event.cardHolderName,
        cardEnding: event.cardEnding,
      ));
    }
  }

  Future<void> _onProcessElectricityBillPayment(
      ProcessElectricityBillPayment event,
      Emitter<ElectricityBillState> emit,
      ) async {
    if (state is! ElectricityBillDataSet) {
      emit(const ElectricityBillError('Invalid state for payment processing'));
      return;
    }

    final ElectricityBillDataSet currentState = state as ElectricityBillDataSet;

    if (currentState.cardId == null) {
      emit(const ElectricityBillError('Please select a card'));
      return;
    }

    emit(ElectricityBillProcessing());

    try {
      final User? user = _auth.currentUser;
      if (user == null) {
        emit(const ElectricityBillError('User not authenticated'));
        return;
      }

      // Generate transaction ID
      final String transactionId = FirebaseFirestore.instance.collection("users").doc(FirebaseAuth.instance.currentUser?.uid).
      collection('payBills').doc().id;
      final DateTime now = DateTime.now();

      // Create transaction data
      final Map<String, dynamic> electricityBillData = <String, dynamic>{
        'id': transactionId,
        'userId': user.uid,
        'billType': 'Electricity',
        'providerName': currentState.providerName,
        'region': currentState.region,
        'averageRate': currentState.averageRate,
        'accountNumber': currentState.accountNumber,
        'consumerName': currentState.consumerName,
        'address': currentState.address,
        'billMonth': currentState.billMonth,
        'unitsConsumed': currentState.unitsConsumed,
        'previousReading': currentState.previousReading,
        'currentReading': currentState.currentReading,
        'dueDate': currentState.dueDate,
        'taxAmount': currentState.taxAmount,
        'amount': currentState.totalAmount,
        'currency': 'USD',
        'cardId': currentState.cardId!,
        'cardHolderName': currentState.cardHolderName!,
        'cardEnding': currentState.cardEnding!,
        'status': 'completed',
        'createdAt': now.toIso8601String(),
        'completedAt': now.toIso8601String(),
      };

      // Save to Firestore transactions collection
      await _firestore.collection("users").doc(FirebaseAuth.instance.currentUser?.uid)
          .collection('payBills')
          .doc(transactionId)
          .set(electricityBillData);

      // Local notification
      await LocalNotificationService.showTransactionNotification(
        transactionType: 'sent',
        amount: currentState.totalAmount,
        currency: 'USD',
      );

      // Firestore notification
      final String notificationMessage = _buildNotificationMessage(currentState);

      _notificationBloc.add(AddNotification(
        title: 'Electricity Bill Payment Successful - ${currentState.providerName}',
        message: notificationMessage,
        type: 'electricity_bill_success',
        data: <String, dynamic>{
          'transactionId': transactionId,
          'providerName': currentState.providerName,
          'accountNumber': currentState.accountNumber,
          'consumerName': currentState.consumerName,
          'billMonth': currentState.billMonth,
          'amount': currentState.amount,
          'taxAmount': currentState.taxAmount,
          'totalAmount': currentState.totalAmount,
          'unitsConsumed': currentState.unitsConsumed,
          'dueDate': currentState.dueDate,
          'cardEnding': currentState.cardEnding,
          'timestamp': now.toIso8601String(),
        },
      ));

      emit(ElectricityBillSuccess(
        transactionId: transactionId,
        message: 'Electricity bill payment completed successfully!',
      ));
    } catch (e) {
      // Error notification
      await LocalNotificationService.showCustomNotification(
        title: 'Payment Failed',
        body: 'Electricity bill payment failed: ${e.toString()}',
        payload: 'electricity_bill_failed',
      );

      _notificationBloc.add(AddNotification(
        title: 'Payment Failed',
        message: 'Electricity bill payment failed: ${e.toString()}',
        type: 'electricity_bill_failed',
        data: <String, dynamic>{
          'error': e.toString(),
          'timestamp': DateTime.now().toIso8601String(),
        },
      ));

      emit(ElectricityBillError(e.toString()));
    }
  }

  Future<void> _onResetElectricityBill(
      ResetElectricityBill event,
      Emitter<ElectricityBillState> emit,
      ) async {
    emit(ElectricityBillInitial());
  }

  String _buildNotificationMessage(ElectricityBillDataSet state) {
    final DateTime now = DateTime.now();

    return '''Electricity Bill Payment completed successfully!

  Provider: ${state.providerName}
Region: ${state.region}
Account Number: ${state.accountNumber}
Consumer Name: ${state.consumerName}
Bill Month: ${state.billMonth}
Units Consumed: ${state.unitsConsumed}
Previous Reading: ${state.previousReading}
Current Reading: ${state.currentReading}
Due Date: ${state.dueDate}
Amount: USD ${state.amount.toStringAsFixed(2)}
Tax: USD ${state.taxAmount.toStringAsFixed(2)}
Total Paid: USD ${state.totalAmount.toStringAsFixed(2)}
Card Ending: ****${state.cardEnding}
Completed at: ${now.toString().substring(0, 19)}

Thank you for using our service for your ${state.providerName} electricity bill payment!''';
  }
}