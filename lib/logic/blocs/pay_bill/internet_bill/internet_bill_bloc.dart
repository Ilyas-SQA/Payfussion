import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/constants/tax.dart';
import '../../../../services/notification_service.dart';
import '../../notification/notification_bloc.dart';
import '../../notification/notification_event.dart';
import 'internet_bill_event.dart';
import 'internet_bill_state.dart';

class InternetBillBloc extends Bloc<InternetBillEvent, InternetBillState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final NotificationBloc _notificationBloc;

  InternetBillBloc(this._notificationBloc) : super(InternetBillInitial()) {
    on<SetInternetBillData>(_onSetInternetBillData);
    on<SetSelectedCardForInternetBill>(_onSetSelectedCard);
    on<ProcessInternetBillPayment>(_onProcessInternetBillPayment);
    on<ResetInternetBill>(_onResetInternetBill);
  }

  Future<void> _onSetInternetBillData(
      SetInternetBillData event,
      Emitter<InternetBillState> emit,
      ) async {
    try {
      // Calculate tax
      final double taxAmount = double.parse(Taxes.billTax.toString());
      final double totalAmount = event.amount + taxAmount;

      emit(InternetBillDataSet(
        companyName: event.companyName,
        connectionType: event.connectionType,
        maxSpeed: event.maxSpeed,
        coverage: event.coverage,
        accountNumber: event.accountNumber,
        consumerName: event.consumerName,
        address: event.address,
        billMonth: event.billMonth,
        amount: event.amount,
        taxAmount: taxAmount,
        totalAmount: totalAmount,
        planName: event.planName,
        dataUsage: event.dataUsage,
        downloadSpeed: event.downloadSpeed,
        uploadSpeed: event.uploadSpeed,
        dueDate: event.dueDate,
      ));
    } catch (e) {
      emit(InternetBillError(e.toString()));
    }
  }

  Future<void> _onSetSelectedCard(
      SetSelectedCardForInternetBill event,
      Emitter<InternetBillState> emit,
      ) async {
    if (state is InternetBillDataSet) {
      final InternetBillDataSet currentState = state as InternetBillDataSet;
      emit(currentState.copyWith(
        cardId: event.cardId,
        cardHolderName: event.cardHolderName,
        cardEnding: event.cardEnding,
      ));
    }
  }

  Future<void> _onProcessInternetBillPayment(
      ProcessInternetBillPayment event,
      Emitter<InternetBillState> emit,
      ) async {
    if (state is! InternetBillDataSet) {
      emit(const InternetBillError('Invalid state for payment processing'));
      return;
    }

    final InternetBillDataSet currentState = state as InternetBillDataSet;

    if (currentState.cardId == null) {
      emit(const InternetBillError('Please select a card'));
      return;
    }

    emit(InternetBillProcessing());

    try {
      final User? user = _auth.currentUser;
      if (user == null) {
        emit(const InternetBillError('User not authenticated'));
        return;
      }

      // Generate transaction ID
      final String transactionId = _firestore.collection('transactions').doc().id;
      final DateTime now = DateTime.now();

      // Create transaction data
      final Map<String, dynamic> transactionData = <String, dynamic>{
        'id': transactionId,
        'userId': user.uid,
        'type': 'internet_bill',
        'companyName': currentState.companyName,
        'connectionType': currentState.connectionType,
        'maxSpeed': currentState.maxSpeed,
        'coverage': currentState.coverage,
        'accountNumber': currentState.accountNumber,
        'consumerName': currentState.consumerName,
        'address': currentState.address,
        'billMonth': currentState.billMonth,
        'amount': currentState.amount,
        'taxAmount': currentState.taxAmount,
        'totalAmount': currentState.totalAmount,
        'currency': 'USD',
        'planName': currentState.planName,
        'dataUsage': currentState.dataUsage,
        'downloadSpeed': currentState.downloadSpeed,
        'uploadSpeed': currentState.uploadSpeed,
        'dueDate': currentState.dueDate,
        'cardId': currentState.cardId!,
        'cardHolderName': currentState.cardHolderName!,
        'cardEnding': currentState.cardEnding!,
        'status': 'completed',
        'createdAt': now.toIso8601String(),
        'completedAt': now.toIso8601String(),
      };

      // Save to Firestore transactions collection
      await _firestore.collection("users").doc(FirebaseAuth.instance.currentUser?.uid)
          .collection('transactions')
          .doc(transactionId)
          .set(transactionData);

      // Local notification
      await LocalNotificationService.showTransactionNotification(
        transactionType: 'sent',
        amount: currentState.totalAmount,
        currency: 'USD',
      );

      // Firestore notification
      final String notificationMessage = _buildNotificationMessage(currentState);

      _notificationBloc.add(AddNotification(
        title: 'Internet Bill Payment Successful - ${currentState.companyName}',
        message: notificationMessage,
        type: 'internet_bill_success',
        data: <String, dynamic>{
          'transactionId': transactionId,
          'companyName': currentState.companyName,
          'accountNumber': currentState.accountNumber,
          'consumerName': currentState.consumerName,
          'billMonth': currentState.billMonth,
          'amount': currentState.amount,
          'taxAmount': currentState.taxAmount,
          'totalAmount': currentState.totalAmount,
          'planName': currentState.planName,
          'dataUsage': currentState.dataUsage,
          'dueDate': currentState.dueDate,
          'cardEnding': currentState.cardEnding,
          'timestamp': now.toIso8601String(),
        },
      ));

      emit(InternetBillSuccess(
        transactionId: transactionId,
        message: 'Internet bill payment completed successfully!',
      ));
    } catch (e) {
      // Error notification
      await LocalNotificationService.showCustomNotification(
        title: 'Payment Failed',
        body: 'Internet bill payment failed: ${e.toString()}',
        payload: 'internet_bill_failed',
      );

      _notificationBloc.add(AddNotification(
        title: 'Payment Failed',
        message: 'Internet bill payment failed: ${e.toString()}',
        type: 'internet_bill_failed',
        data: <String, dynamic>{
          'error': e.toString(),
          'timestamp': DateTime.now().toIso8601String(),
        },
      ));

      emit(InternetBillError(e.toString()));
    }
  }

  Future<void> _onResetInternetBill(
      ResetInternetBill event,
      Emitter<InternetBillState> emit,
      ) async {
    emit(InternetBillInitial());
  }

  String _buildNotificationMessage(InternetBillDataSet state) {
    final DateTime now = DateTime.now();

    return '''Internet Bill Payment completed successfully!

Provider: ${state.companyName}
Connection Type: ${state.connectionType}
Max Speed: ${state.maxSpeed}
Account Number: ${state.accountNumber}
Consumer Name: ${state.consumerName}
Bill Month: ${state.billMonth}
Plan: ${state.planName}
Data Usage: ${state.dataUsage}
 Download Speed: ${state.downloadSpeed}
 Upload Speed: ${state.uploadSpeed}
Due Date: ${state.dueDate}
Amount: USD ${state.amount.toStringAsFixed(2)}
Tax: USD ${state.taxAmount.toStringAsFixed(2)}
Total Paid: USD ${state.totalAmount.toStringAsFixed(2)}
Card Ending: ****${state.cardEnding}
Completed at: ${now.toString().substring(0, 19)}

Thank you for using our service for your ${state.companyName} internet bill payment!''';
  }
}