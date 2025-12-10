import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:payfussion/core/constants/tax.dart';
import 'package:payfussion/data/models/pay_bills/bill_item.dart';
import 'package:payfussion/data/repositories/pay_bill/pay_bill_repository.dart';
import 'package:payfussion/services/notification_service.dart';
import '../../../../services/biometric_service.dart';
import '../../notification/notification_bloc.dart';
import '../../notification/notification_event.dart';
import 'rent_payment_event.dart';
import 'rent_payment_state.dart';

class RentPaymentBloc extends Bloc<RentPaymentEvent, RentPaymentState> {
  final PayBillRepository _payBillRepository;
  final NotificationBloc _notificationBloc;
  final BiometricService _biometricService;


  RentPaymentBloc(
      this._payBillRepository,
      this._notificationBloc,
      this._biometricService,
      )
      : super(RentPaymentInitial()) {
    on<SetRentPaymentData>(_onSetRentPaymentData);
    on<SetRentPaymentCard>(_onSetRentPaymentCard);
    on<ProcessRentPayment>(_onProcessRentPayment);
    on<ResetRentPayment>(_onResetRentPayment);
  }

  // Set rent payment data
  Future<void> _onSetRentPaymentData(
      SetRentPaymentData event,
      Emitter<RentPaymentState> emit,
      ) async {
    try {
      // Calculate tax (2.5% as per mobile recharge)
      final double taxAmount = double.parse(Taxes.billTax.toString());
      final double totalAmount = event.amount + taxAmount;

      emit(RentPaymentDataSet(
        companyName: event.companyName,
        category: event.category,
        propertyAddress: event.propertyAddress,
        landlordName: event.landlordName,
        landlordEmail: event.landlordEmail,
        landlordPhone: event.landlordPhone,
        amount: event.amount,
        notes: event.notes,
        taxAmount: taxAmount,
        totalAmount: totalAmount,
        currency: 'USD',
      ));
    } catch (e) {
      emit(RentPaymentError(e.toString()));
    }
  }

  // Set payment card
  Future<void> _onSetRentPaymentCard(
      SetRentPaymentCard event,
      Emitter<RentPaymentState> emit,
      ) async {
    try {
      if (state is RentPaymentDataSet) {
        final RentPaymentDataSet currentState = state as RentPaymentDataSet;
        emit(currentState.copyWith(
          cardId: event.cardId,
          cardHolderName: event.cardHolderName,
          cardEnding: event.cardEnding,
        ));
      }
    } catch (e) {
      emit(RentPaymentError(e.toString()));
    }
  }

  // Process rent payment
  Future<void> _onProcessRentPayment(
      ProcessRentPayment event,
      Emitter<RentPaymentState> emit,
      ) async {
    if (state is! RentPaymentDataSet) {
      emit(const RentPaymentError('Payment data not set'));
      return;
    }

    final RentPaymentDataSet currentState = state as RentPaymentDataSet;

    if (currentState.cardId == null) {
      emit(const RentPaymentError('Please select a payment card'));
      return;
    }

    emit(RentPaymentProcessing());

    try {
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
            reason: 'Authenticate to confirm rent payment of ${currentState.currency} ${currentState.totalAmount.toStringAsFixed(2)}',
          );

          if (!biometricResult['success']) {
            // Biometric authentication failed
            emit(RentPaymentError(
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
          emit(const RentPaymentError(
            'Biometric authentication is not available. Please check your device settings.',
          ));
          return;
        }
      }
      // If biometric is not enabled, proceed without biometric check
      // ========== END BIOMETRIC AUTHENTICATION ==========

      // Simulate payment processing
      await Future.delayed(const Duration(seconds: 2));

      // Generate transaction ID
      final String transactionId = FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .collection('payBills')
          .doc()
          .id;
      final DateTime now = DateTime.now();

      // Create bill model for rent payment
      final Map<String, dynamic> rentPaymentData = <String, dynamic>{
        'id': transactionId,
        'userId': FirebaseAuth.instance.currentUser?.uid,
        'billType': 'Rent',
        'companyName': currentState.companyName,
        'category': currentState.category,
        'propertyAddress': currentState.propertyAddress,
        'landlordName': currentState.landlordName,
        'landlordEmail': currentState.landlordEmail,
        'landlordPhone': currentState.landlordPhone,
        'notes': currentState.notes,
        'taxAmount': currentState.taxAmount,
        'amount': currentState.totalAmount,
        'currency': currentState.currency,
        'cardId': currentState.cardId!,
        'cardHolderName': currentState.cardHolderName!,
        'cardEnding': currentState.cardEnding!,
        'status': 'completed',
        'authenticatedWithBiometric': isBiometricEnabled,
        'createdAt': now.toIso8601String(),
        'completedAt': now.toIso8601String(),
      };

      // Add to repository
      await FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .collection('payBills')
          .doc(transactionId)
          .set(rentPaymentData);

      // LOCAL NOTIFICATION
      await LocalNotificationService.showTransactionNotification(
        transactionType: 'sent',
        amount: currentState.totalAmount,
        currency: currentState.currency,
      );

      // FIRESTORE NOTIFICATION
      _notificationBloc.add(AddNotification(
        title: 'Rent Payment Successful - ${currentState.companyName}',
        message: _buildDetailedNotificationMessage(currentState, isBiometricEnabled),
        type: 'rent_payment_success',
        data: <String, dynamic>{
          'transactionId': transactionId,
          'companyName': currentState.companyName,
          'category': currentState.category,
          'propertyAddress': currentState.propertyAddress,
          'landlordName': currentState.landlordName,
          'landlordEmail': currentState.landlordEmail,
          'landlordPhone': currentState.landlordPhone,
          'amount': currentState.amount,
          'taxAmount': currentState.taxAmount,
          'totalAmount': currentState.totalAmount,
          'currency': currentState.currency,
          'notes': currentState.notes,
          'paymentMethod': 'Card ending in ${currentState.cardEnding}',
          'cardId': currentState.cardId,
          'authenticatedWithBiometric': isBiometricEnabled,
          'paidAt': DateTime.now().toIso8601String(),
          'status': 'completed',
        },
      ));

      emit(RentPaymentSuccess(
        message:
        'Rent payment of ${currentState.currency} ${currentState.totalAmount.toStringAsFixed(2)} sent successfully to ${currentState.landlordName}',
        transactionId: transactionId,
      ));
    } catch (e) {
      // Error notification
      await LocalNotificationService.showCustomNotification(
        title: 'Payment Failed',
        body: 'Rent payment failed: ${e.toString()}',
        payload: 'rent_payment_failed',
      );

      _notificationBloc.add(AddNotification(
        title: 'Rent Payment Failed',
        message: 'Payment failed: ${e.toString()}',
        type: 'rent_payment_failed',
        data: <String, dynamic>{
          'error': e.toString(),
          'timestamp': DateTime.now().toIso8601String(),
        },
      ));

      emit(RentPaymentError(e.toString()));
    }
  }

  // Reset rent payment
  Future<void> _onResetRentPayment(
      ResetRentPayment event,
      Emitter<RentPaymentState> emit,
      ) async {
    emit(RentPaymentInitial());
  }

  // Build detailed notification message
  String _buildDetailedNotificationMessage(RentPaymentDataSet state, bool authenticatedWithBiometric) {
    final DateTime paymentTime = DateTime.now();

    final String authMethod = authenticatedWithBiometric
        ? '✓ Secured with Biometric Authentication'
        : '';

    return '''Rent Payment completed successfully!

Property: ${state.propertyAddress}
Platform: ${state.companyName}
Category: ${state.category}

Landlord: ${state.landlordName}
Email: ${state.landlordEmail}
Phone: ${state.landlordPhone}

Rent Amount: ${state.currency} ${state.amount.toStringAsFixed(2)}
Tax: ${state.currency} ${state.taxAmount.toStringAsFixed(2)}
Total Paid: ${state.currency} ${state.totalAmount.toStringAsFixed(2)}

${state.notes != null && state.notes!.isNotEmpty ? 'Notes: ${state.notes}\n' : ''}Payment completed at ${paymentTime.toString().substring(0, 19)}

$authMethod

Thank you for using our service!''';
  }
}