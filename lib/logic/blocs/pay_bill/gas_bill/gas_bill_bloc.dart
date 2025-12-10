import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/constants/tax.dart';
import '../../../../services/biometric_service.dart';
import '../../../../services/notification_service.dart';
import '../../notification/notification_bloc.dart';
import '../../notification/notification_event.dart';
import 'gas_bill_event.dart';
import 'gas_bill_state.dart';

class GasBillBloc extends Bloc<GasBillEvent, GasBillState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final NotificationBloc _notificationBloc;
  final BiometricService _biometricService;


  GasBillBloc(this._notificationBloc,this._biometricService,) : super(GasBillInitial()) {
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

      // ========== BIOMETRIC AUTHENTICATION ==========
      // Check if biometric is enabled for this user
      final bool isBiometricEnabled = await _biometricService.isBiometricEnabled();

      if (isBiometricEnabled) {
        // Check if biometric is available on device
        final bool isAvailable = await _biometricService.isBiometricAvailable();
        final bool isEnrolled = await _biometricService.hasBiometricsEnrolled();

        if (isAvailable && isEnrolled) {
          // Perform biometric authentication
          final Map<String, dynamic> biometricResult = await _biometricService.authenticate(
            reason: 'Authenticate to confirm ${currentState.companyName} gas bill payment of \$${currentState.totalAmount.toStringAsFixed(2)}',
          );

          if (!biometricResult['success']) {
            // Biometric authentication failed
            emit(GasBillError(
              biometricResult['error'] ?? 'Biometric authentication failed. Payment cancelled.',
            ));

            // Send failure notification
            await LocalNotificationService.showCustomNotification(
              title: 'Authentication Failed',
              body: 'Biometric authentication failed. Payment was cancelled.',
              payload: 'biometric_auth_failed',
            );

            return; // Stop payment processing
          }

          // Biometric authentication successful - continue with payment
        } else {
          // Biometric not available but was enabled - inform user
          emit(const GasBillError(
            'Biometric authentication is not available. Please check your device settings.',
          ));
          return;
        }
      }
      // If biometric is not enabled, proceed without biometric check
      // ========== END BIOMETRIC AUTHENTICATION ==========

      // Generate transaction ID
      final String transactionId = _firestore
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .collection('payBills')
          .doc()
          .id;
      final DateTime now = DateTime.now();

      // Create transaction data
      final Map<String, dynamic> gasBillData = <String, dynamic>{
        'id': transactionId,
        'userId': user.uid,
        'billType': 'Gas Bill',
        'companyName': currentState.companyName,
        'region': currentState.region,
        'averageRate': currentState.averageRate,
        'accountNumber': currentState.accountNumber,
        'consumerName': currentState.consumerName,
        'address': currentState.address,
        'billMonth': currentState.billMonth,
        'gasUsage': currentState.gasUsage,
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
        'authenticatedWithBiometric': isBiometricEnabled,
        'createdAt': now.toIso8601String(),
        'completedAt': now.toIso8601String(),
      };

      // Save to Firestore transactions collection
      await _firestore
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .collection('payBills')
          .doc(transactionId)
          .set(gasBillData);

      // Local notification
      await LocalNotificationService.showTransactionNotification(
        transactionType: 'sent',
        amount: currentState.totalAmount,
        currency: 'USD',
      );

      // Firestore notification
      final String notificationMessage = _buildNotificationMessage(currentState, isBiometricEnabled);

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
          'authenticatedWithBiometric': isBiometricEnabled,
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

  String _buildNotificationMessage(GasBillDataSet state, bool authenticatedWithBiometric) {
    final DateTime now = DateTime.now();

    final String authMethod = authenticatedWithBiometric
        ? '✓ Secured with Biometric Authentication'
        : '';

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

$authMethod

Thank you for using our service for your ${state.companyName} gas bill payment!''';
  }
}