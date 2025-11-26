import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:payfussion/core/constants/tax.dart';
import 'package:payfussion/data/models/pay_bills/bill_item.dart';
import 'package:payfussion/data/repositories/pay_bill/pay_bill_repository.dart';
import 'package:payfussion/services/notification_service.dart';
import '../../notification/notification_bloc.dart';
import '../../notification/notification_event.dart';
import 'rent_payment_event.dart';
import 'rent_payment_state.dart';

class RentPaymentBloc extends Bloc<RentPaymentEvent, RentPaymentState> {
  final PayBillRepository _payBillRepository;
  final NotificationBloc _notificationBloc;

  RentPaymentBloc(this._payBillRepository, this._notificationBloc)
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
      // Simulate payment processing
      await Future.delayed(const Duration(seconds: 2));

      // Generate transaction ID
      final String transactionId =
          'RENT_${DateTime.now().millisecondsSinceEpoch}';

      // Create bill model for rent payment
      final PayBillModel rentBill = PayBillModel(
        id: transactionId,
        companyName: currentState.companyName,
        billType: 'rent',
        billNumber: currentState.propertyAddress,
        amount: currentState.totalAmount,
        feeAmount: currentState.taxAmount,
        hasFee: true,
        currency: currentState.currency,
        status: 'completed',
        paidAt: DateTime.now(),
        createdAt: DateTime.now(),
        cardId: currentState.cardId.toString(),
        companyIcon: '',
        cardEnding: currentState.cardEnding.toString(),
      );

      // Add to repository
      await _payBillRepository.addPayBill(rentBill);

      // LOCAL NOTIFICATION
      await LocalNotificationService.showTransactionNotification(
        transactionType: 'sent',
        amount: currentState.totalAmount,
        currency: currentState.currency,
      );

      // FIRESTORE NOTIFICATION
      _notificationBloc.add(AddNotification(
        title: 'Rent Payment Successful - ${currentState.companyName}',
        message: _buildDetailedNotificationMessage(currentState),
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
  String _buildDetailedNotificationMessage(RentPaymentDataSet state) {
    final DateTime paymentTime = DateTime.now();

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

${state.notes != null && state.notes!.isNotEmpty ? 'Notes: ${state.notes}\n' : ''} Payment completed at ${paymentTime.toString().substring(0, 19)}

Thank you for using our service!''';
  }
}