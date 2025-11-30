import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/constants/tax.dart';
import '../../../../services/notification_service.dart';
import '../../notification/notification_bloc.dart';
import '../../notification/notification_event.dart';
import 'gas_bill_event.dart';
import 'gas_bill_state.dart';

class GasBillBloc extends Bloc<GasBillEvent, GasBillState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final NotificationBloc _notificationBloc;

  GasBillBloc(this._notificationBloc) : super(GasBillInitial()) {
    on<SetGasBillData>(_onSetGasBillData);
    on<SetSelectedCardForGasBill>(_onSetSelectedCard);
    on<ProcessGasBillPayment>(_onProcessGasBillPayment);
    on<ResetGasBill>(_onResetGasBill);
  }

  Future<void> _onSetGasBillData(
      SetGasBillData event,
      Emitter<GasBillState> emit,
      ) async {
    try {
      // Calculate tax
      final double taxAmount = double.parse(Taxes.billTax.toString());
      final double totalAmount = event.amount + taxAmount;

      emit(GasBillDataSet(
        companyName: event.companyName,
        region: event.region,
        averageRate: event.averageRate,
        accountNumber: event.accountNumber,
        consumerName: event.consumerName,
        address: event.address,
        billMonth: event.billMonth,
        amount: event.amount,
        taxAmount: taxAmount,
        totalAmount: totalAmount,
        gasUsage: event.gasUsage,
        previousReading: event.previousReading,
        currentReading: event.currentReading,
        dueDate: event.dueDate,
      ));
    } catch (e) {
      emit(GasBillError(e.toString()));
    }
  }

  Future<void> _onSetSelectedCard(
      SetSelectedCardForGasBill event,
      Emitter<GasBillState> emit,
      ) async {
    if (state is GasBillDataSet) {
      final GasBillDataSet currentState = state as GasBillDataSet;
      emit(currentState.copyWith(
        cardId: event.cardId,
        cardHolderName: event.cardHolderName,
        cardEnding: event.cardEnding,
      ));
    }
  }

  Future<void> _onProcessGasBillPayment(
      ProcessGasBillPayment event,
      Emitter<GasBillState> emit,
      ) async {
    if (state is! GasBillDataSet) {
      emit(const GasBillError('Invalid state for payment processing'));
      return;
    }

    final GasBillDataSet currentState = state as GasBillDataSet;

    if (currentState.cardId == null) {
      emit(const GasBillError('Please select a card'));
      return;
    }

    emit(GasBillProcessing());

    try {
      final User? user = _auth.currentUser;
      if (user == null) {
        emit(const GasBillError('User not authenticated'));
        return;
      }

      // Generate transaction ID
      final String transactionId = _firestore.collection('transactions').doc().id;
      final DateTime now = DateTime.now();

      // Create transaction data
      final Map<String, dynamic> transactionData = <String, dynamic>{
        'id': transactionId,
        'userId': user.uid,
        'payBills': 'Gas Bill',
        'companyName': currentState.companyName,
        'region': currentState.region,
        'averageRate': currentState.averageRate,
        'accountNumber': currentState.accountNumber,
        'consumerName': currentState.consumerName,
        'address': currentState.address,
        'billMonth': currentState.billMonth,
        // 'amount': currentState.amount,
        'taxAmount': currentState.taxAmount,
        'amount': currentState.totalAmount,
        'currency': 'USD',
        'gasUsage': currentState.gasUsage,
        'previousReading': currentState.previousReading,
        'currentReading': currentState.currentReading,
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
          .collection('payBills')
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
        title: 'Gas Bill Payment Successful - ${currentState.companyName}',
        message: notificationMessage,
        type: 'gas_bill_success',
        data: <String, dynamic>{
          'transactionId': transactionId,
          'companyName': currentState.companyName,
          'accountNumber': currentState.accountNumber,
          'consumerName': currentState.consumerName,
          'billMonth': currentState.billMonth,
          'amount': currentState.amount,
          'taxAmount': currentState.taxAmount,
          'totalAmount': currentState.totalAmount,
          'gasUsage': currentState.gasUsage,
          'dueDate': currentState.dueDate,
          'cardEnding': currentState.cardEnding,
          'timestamp': now.toIso8601String(),
        },
      ));

      emit(GasBillSuccess(
        transactionId: transactionId,
        message: 'Gas bill payment completed successfully!',
      ));
    } catch (e) {
      // Error notification
      await LocalNotificationService.showCustomNotification(
        title: 'Payment Failed',
        body: 'Gas bill payment failed: ${e.toString()}',
        payload: 'gas_bill_failed',
      );

      _notificationBloc.add(AddNotification(
        title: 'Payment Failed',
        message: 'Gas bill payment failed: ${e.toString()}',
        type: 'gas_bill_failed',
        data: <String, dynamic>{
          'error': e.toString(),
          'timestamp': DateTime.now().toIso8601String(),
        },
      ));

      emit(GasBillError(e.toString()));
    }
  }

  Future<void> _onResetGasBill(
      ResetGasBill event,
      Emitter<GasBillState> emit,
      ) async {
    emit(GasBillInitial());
  }

  String _buildNotificationMessage(GasBillDataSet state) {
    final DateTime now = DateTime.now();

    return '''Gas Bill Payment completed successfully!

Company: ${state.companyName}
Region: ${state.region}
Account Number: ${state.accountNumber}
Consumer Name: ${state.consumerName}
Bill Month: ${state.billMonth}
Gas Usage: ${state.gasUsage}
Previous Reading: ${state.previousReading}
Current Reading: ${state.currentReading}
Due Date: ${state.dueDate}
Amount: USD ${state.amount.toStringAsFixed(2)}
Tax: USD ${state.taxAmount.toStringAsFixed(2)}
Total Paid: USD ${state.totalAmount.toStringAsFixed(2)}
Card Ending: ****${state.cardEnding}
Completed at: ${now.toString().substring(0, 19)}

Thank you for using our service for your ${state.companyName} gas bill payment!''';
  }
}