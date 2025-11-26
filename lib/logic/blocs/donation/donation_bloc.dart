import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/constants/tax.dart';
import '../../../../services/notification_service.dart';
import '../notification/notification_bloc.dart';
import '../notification/notification_event.dart';
import 'donation_event.dart';
import 'donation_status.dart';

class DonationBloc extends Bloc<DonationEvent, DonationState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final NotificationBloc _notificationBloc;

  DonationBloc(this._notificationBloc) : super(DonationInitial()) {
    on<SetDonationData>(_onSetDonationData);
    on<SetSelectedCardForDonation>(_onSetSelectedCard);
    on<ProcessDonationPayment>(_onProcessDonationPayment);
    on<ResetDonation>(_onResetDonation);
  }

  Future<void> _onSetDonationData(
      SetDonationData event,
      Emitter<DonationState> emit,
      ) async {
    try {
      // Calculate tax
      final double taxAmount = double.parse(Taxes.billTax.toString());
      final double totalAmount = event.amount + taxAmount;

      emit(DonationDataSet(
        foundationName: event.foundationName,
        category: event.category,
        description: event.description,
        website: event.website,
        amount: event.amount,
        taxAmount: taxAmount,
        totalAmount: totalAmount,
      ));
    } catch (e) {
      emit(DonationError(e.toString()));
    }
  }

  Future<void> _onSetSelectedCard(
      SetSelectedCardForDonation event,
      Emitter<DonationState> emit,
      ) async {
    if (state is DonationDataSet) {
      final DonationDataSet currentState = state as DonationDataSet;
      emit(currentState.copyWith(
        cardId: event.cardId,
        cardHolderName: event.cardHolderName,
        cardEnding: event.cardEnding,
      ));
    }
  }

  Future<void> _onProcessDonationPayment(
      ProcessDonationPayment event,
      Emitter<DonationState> emit,
      ) async {
    if (state is! DonationDataSet) {
      emit(const DonationError('Invalid state for payment processing'));
      return;
    }

    final DonationDataSet currentState = state as DonationDataSet;

    if (currentState.cardId == null) {
      emit(const DonationError('Please select a card'));
      return;
    }

    emit(DonationProcessing());

    try {
      final User? user = _auth.currentUser;
      if (user == null) {
        emit(const DonationError('User not authenticated'));
        return;
      }

      // Generate transaction ID
      final String transactionId = _firestore.collection('transactions').doc().id;
      final DateTime now = DateTime.now();

      // Create transaction data
      final Map<String, dynamic> transactionData = <String, dynamic>{
        'id': transactionId,
        'userId': user.uid,
        'type': 'donation',
        'foundationName': currentState.foundationName,
        'category': currentState.category,
        'description': currentState.description,
        'website': currentState.website,
        'amount': currentState.amount,
        'taxAmount': currentState.taxAmount,
        'totalAmount': currentState.totalAmount,
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
        title: 'Donation Successful - ${currentState.foundationName}',
        message: notificationMessage,
        type: 'donation_success',
        data: <String, dynamic>{
          'transactionId': transactionId,
          'foundationName': currentState.foundationName,
          'category': currentState.category,
          'amount': currentState.amount,
          'taxAmount': currentState.taxAmount,
          'totalAmount': currentState.totalAmount,
          'cardEnding': currentState.cardEnding,
          'timestamp': now.toIso8601String(),
        },
      ));

      emit(DonationSuccess(
        transactionId: transactionId,
        message: 'Donation completed successfully!',
      ));
    } catch (e) {
      // Error notification
      await LocalNotificationService.showCustomNotification(
        title: 'Payment Failed',
        body: 'Donation payment failed: ${e.toString()}',
        payload: 'donation_failed',
      );

      _notificationBloc.add(AddNotification(
        title: 'Payment Failed',
        message: 'Donation payment failed: ${e.toString()}',
        type: 'donation_failed',
        data: <String, dynamic>{
          'error': e.toString(),
          'timestamp': DateTime.now().toIso8601String(),
        },
      ));

      emit(DonationError(e.toString()));
    }
  }

  Future<void> _onResetDonation(
      ResetDonation event,
      Emitter<DonationState> emit,
      ) async {
    emit(DonationInitial());
  }

  String _buildNotificationMessage(DonationDataSet state) {
    final DateTime now = DateTime.now();

    return '''Donation completed successfully!

Foundation: ${state.foundationName}
Category: ${state.category}
Amount: USD ${state.amount.toStringAsFixed(2)}
Tax: USD ${state.taxAmount.toStringAsFixed(2)}
Total Donated: USD ${state.totalAmount.toStringAsFixed(2)}
Card Ending: ****${state.cardEnding}
Completed at: ${now.toString().substring(0, 19)}

Thank you for your generous donation to ${state.foundationName}!''';
  }
}