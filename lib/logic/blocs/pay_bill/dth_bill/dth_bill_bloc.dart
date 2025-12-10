import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/constants/tax.dart';
import '../../../../services/biometric_service.dart';
import '../../../../services/notification_service.dart';
import '../../notification/notification_bloc.dart';
import '../../notification/notification_event.dart';
import 'dth_bill_event.dart';
import 'dth_bill_state.dart';


class DthRechargeBloc extends Bloc<DthRechargeEvent, DthRechargeState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final NotificationBloc _notificationBloc;
  final BiometricService _biometricService;


  DthRechargeBloc(
      this._notificationBloc,
      this._biometricService,
      ) : super(DthRechargeInitial()) {
    on<SetDthRechargeData>(_onSetDthRechargeData);
    on<SetSelectedCardForDth>(_onSetSelectedCardForDth);
    on<ProcessDthPayment>(_onProcessDthPayment);
    on<ResetDthRecharge>(_onResetDthRecharge);
  }

  Future<void> _onSetDthRechargeData(
      SetDthRechargeData event,
      Emitter<DthRechargeState> emit,
      ) async {
    try {
      // Calculate tax
      final double taxAmount = double.parse(Taxes.billTax.toString());
      final double totalAmount = event.amount + taxAmount;

      emit(DthRechargeDataSet(
        providerName: event.providerName,
        subscriberId: event.subscriberId,
        customerName: event.customerName,
        selectedPlan: event.selectedPlan,
        amount: event.amount,
        taxAmount: taxAmount,
        totalAmount: totalAmount,
        rating: event.rating,
      ));
    } catch (e) {
      emit(DthRechargeError(e.toString()));
    }
  }

  Future<void> _onSetSelectedCardForDth(
      SetSelectedCardForDth event,
      Emitter<DthRechargeState> emit,
      ) async {
    if (state is DthRechargeDataSet) {
      final DthRechargeDataSet currentState = state as DthRechargeDataSet;
      emit(currentState.copyWith(
        cardId: event.cardId,
        cardHolderName: event.cardHolderName,
        cardEnding: event.cardEnding,
      ));
    }
  }

  Future<void> _onProcessDthPayment(
      ProcessDthPayment event,
      Emitter<DthRechargeState> emit,
      ) async {
    if (state is! DthRechargeDataSet) {
      emit(const DthRechargeError('Invalid state for payment processing'));
      return;
    }

    final DthRechargeDataSet currentState = state as DthRechargeDataSet;

    if (currentState.cardId == null) {
      emit(const DthRechargeError('Please select a card'));
      return;
    }

    emit(DthRechargeProcessing());

    try {
      final User? user = _auth.currentUser;
      if (user == null) {
        emit(const DthRechargeError('User not authenticated'));
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
            reason: 'Authenticate to confirm ${currentState.providerName} DTH recharge of \$${currentState.totalAmount.toStringAsFixed(2)}',
          );

          if (!biometricResult['success']) {
            // Biometric authentication failed
            emit(DthRechargeError(
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
          emit(const DthRechargeError(
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
      final Map<String, dynamic> dthRechargeData = <String, dynamic>{
        'id': transactionId,
        'userId': user.uid,
        'billType': 'DTH Recharge',
        'providerName': currentState.providerName,
        'subscriberId': currentState.subscriberId,
        'customerName': currentState.customerName,
        'selectedPlan': currentState.selectedPlan,
        'rating': currentState.rating,
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
          .set(dthRechargeData);

      // Local notification
      await LocalNotificationService.showTransactionNotification(
        transactionType: 'sent',
        amount: currentState.totalAmount,
        currency: 'USD',
      );

      // Firestore notification
      final String notificationMessage = _buildNotificationMessage(currentState, isBiometricEnabled);

      _notificationBloc.add(AddNotification(
        title: 'DTH Recharge Successful - ${currentState.providerName}',
        message: notificationMessage,
        type: 'dth_recharge_success',
        data: <String, dynamic>{
          'transactionId': transactionId,
          'providerName': currentState.providerName,
          'subscriberId': currentState.subscriberId,
          'customerName': currentState.customerName,
          'selectedPlan': currentState.selectedPlan,
          'amount': currentState.amount,
          'taxAmount': currentState.taxAmount,
          'totalAmount': currentState.totalAmount,
          'rating': currentState.rating,
          'cardEnding': currentState.cardEnding,
          'authenticatedWithBiometric': isBiometricEnabled,
          'timestamp': now.toIso8601String(),
        },
      ));

      emit(DthRechargeSuccess(
        transactionId: transactionId,
        message: 'DTH recharge completed successfully!',
      ));
    } catch (e) {
      // Error notification
      await LocalNotificationService.showCustomNotification(
        title: 'DTH Recharge Failed',
        body: 'DTH recharge failed: ${e.toString()}',
        payload: 'dth_recharge_failed',
      );

      _notificationBloc.add(AddNotification(
        title: 'DTH Recharge Failed',
        message: 'DTH recharge failed: ${e.toString()}',
        type: 'dth_recharge_failed',
        data: <String, dynamic>{
          'error': e.toString(),
          'timestamp': DateTime.now().toIso8601String(),
        },
      ));

      emit(DthRechargeError(e.toString()));
    }
  }
  Future<void> _onResetDthRecharge(
      ResetDthRecharge event,
      Emitter<DthRechargeState> emit,
      ) async {
    emit(DthRechargeInitial());
  }

  String _buildNotificationMessage(DthRechargeDataSet state, bool authenticatedWithBiometric) {
    final DateTime now = DateTime.now();

    final String authMethod = authenticatedWithBiometric
        ? '✓ Secured with Biometric Authentication'
        : '';

    final String message = '''DTH Recharge completed successfully!

Provider: ${state.providerName}
Subscriber ID: ${state.subscriberId}
Customer: ${state.customerName}
Plan: ${state.selectedPlan}
Rating: ${state.rating}
Amount: USD ${state.amount.toStringAsFixed(2)}
Tax: USD ${state.taxAmount.toStringAsFixed(2)}
Total Paid: USD ${state.totalAmount.toStringAsFixed(2)}
Card Ending: ****${state.cardEnding}
Completed at: ${now.toString().substring(0, 19)}

$authMethod

Thank you for using our service for your ${state.providerName} recharge!''';

    return message;
  }
}