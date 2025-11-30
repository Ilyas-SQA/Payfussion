import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/constants/tax.dart';
import '../../../../services/notification_service.dart';
import '../notification/notification_bloc.dart';
import '../notification/notification_event.dart';
import 'governement_fee_event.dart';
import 'governement_fee_state.dart';


class GovernmentFeeBloc extends Bloc<GovernmentFeeEvent, GovernmentFeeState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final NotificationBloc _notificationBloc;

  GovernmentFeeBloc(this._notificationBloc) : super(GovernmentFeeInitial()) {
    on<SetGovernmentFeeData>(_onSetGovernmentFeeData);
    on<SetSelectedCardForGovernmentFee>(_onSetSelectedCard);
    on<ProcessGovernmentFeePayment>(_onProcessGovernmentFeePayment);
    on<ResetGovernmentFee>(_onResetGovernmentFee);
  }

  Future<void> _onSetGovernmentFeeData(
      SetGovernmentFeeData event,
      Emitter<GovernmentFeeState> emit,
      ) async {
    try {
      // Calculate tax
      final double taxAmount = double.parse(Taxes.billTax.toString());
      final double totalAmount = event.amount + taxAmount;

      emit(GovernmentFeeDataSet(
        serviceName: event.serviceName,
        agency: event.agency,
        inputLabel: event.inputLabel,
        inputValue: event.inputValue,
        amount: event.amount,
        taxAmount: taxAmount,
        totalAmount: totalAmount,
      ));
    } catch (e) {
      emit(GovernmentFeeError(e.toString()));
    }
  }

  Future<void> _onSetSelectedCard(
      SetSelectedCardForGovernmentFee event,
      Emitter<GovernmentFeeState> emit,
      ) async {
    if (state is GovernmentFeeDataSet) {
      final GovernmentFeeDataSet currentState = state as GovernmentFeeDataSet;
      emit(currentState.copyWith(
        cardId: event.cardId,
        cardHolderName: event.cardHolderName,
        cardEnding: event.cardEnding,
      ));
    }
  }

  Future<void> _onProcessGovernmentFeePayment(
      ProcessGovernmentFeePayment event,
      Emitter<GovernmentFeeState> emit,
      ) async {
    if (state is! GovernmentFeeDataSet) {
      emit(const GovernmentFeeError('Invalid state for payment processing'));
      return;
    }

    final GovernmentFeeDataSet currentState = state as GovernmentFeeDataSet;

    if (currentState.cardId == null) {
      emit(const GovernmentFeeError('Please select a card'));
      return;
    }

    emit(GovernmentFeeProcessing());

    try {
      final User? user = _auth.currentUser;
      if (user == null) {
        emit(const GovernmentFeeError('User not authenticated'));
        return;
      }

      // Generate transaction ID
      final String transactionId = _firestore.collection('transactions').doc().id;
      final DateTime now = DateTime.now();

      // Create transaction data
      final Map<String, dynamic> transactionData = <String, dynamic>{
        'id': transactionId,
        'userId': user.uid,
        'billType': 'Government Fee',
        'serviceName': currentState.serviceName,
        'agency': currentState.agency,
        'inputLabel': currentState.inputLabel,
        'inputValue': currentState.inputValue,
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
      await _firestore
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser?.uid)
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
        title: 'Government Fee Payment Successful - ${currentState.serviceName}',
        message: notificationMessage,
        type: 'government_fee_success',
        data: <String, dynamic>{
          'transactionId': transactionId,
          'serviceName': currentState.serviceName,
          'agency': currentState.agency,
          'inputLabel': currentState.inputLabel,
          'inputValue': currentState.inputValue,
          'amount': currentState.amount,
          'taxAmount': currentState.taxAmount,
          'totalAmount': currentState.totalAmount,
          'cardEnding': currentState.cardEnding,
          'timestamp': now.toIso8601String(),
        },
      ));

      emit(GovernmentFeeSuccess(
        transactionId: transactionId,
        message: 'Government fee payment completed successfully!',
      ));
    } catch (e) {
      // Error notification
      await LocalNotificationService.showCustomNotification(
        title: 'Payment Failed',
        body: 'Government fee payment failed: ${e.toString()}',
        payload: 'payment_failed',
      );

      _notificationBloc.add(AddNotification(
        title: 'Payment Failed',
        message: 'Government fee payment failed: ${e.toString()}',
        type: 'government_fee_failed',
        data: <String, dynamic>{
          'error': e.toString(),
          'timestamp': DateTime.now().toIso8601String(),
        },
      ));

      emit(GovernmentFeeError(e.toString()));
    }
  }

  Future<void> _onResetGovernmentFee(
      ResetGovernmentFee event,
      Emitter<GovernmentFeeState> emit,
      ) async {
    emit(GovernmentFeeInitial());
  }

  String _buildNotificationMessage(GovernmentFeeDataSet state) {
    final DateTime now = DateTime.now();

    String message = '''Government Fee Payment completed successfully!

Service: ${state.serviceName}
Agency: ${state.agency}
${state.inputLabel}: ${state.inputValue}
Amount: USD ${state.amount.toStringAsFixed(2)}
Tax: USD ${state.taxAmount.toStringAsFixed(2)}
Total Paid: USD ${state.totalAmount.toStringAsFixed(2)}
Card Ending: ****${state.cardEnding}
Completed at: ${now.toString().substring(0, 19)}

Thank you for using our service for your government fee payment!''';

    return message;
  }
}