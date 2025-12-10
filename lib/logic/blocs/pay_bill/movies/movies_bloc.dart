import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/constants/tax.dart';
import '../../../../services/notification_service.dart';
import '../../notification/notification_bloc.dart';
import '../../notification/notification_event.dart';
import 'movies_event.dart';
import 'movies_state.dart';

class MoviesBloc extends Bloc<MoviesEvent, MoviesState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final NotificationBloc _notificationBloc;

  MoviesBloc(this._notificationBloc) : super(MoviesInitial()) {
    on<SetSubscriptionData>(_onSetSubscriptionData);
    on<SetSelectedCardForMovies>(_onSetSelectedCard);
    on<ProcessSubscriptionPayment>(_onProcessSubscriptionPayment);
    on<ResetSubscription>(_onResetSubscription);
  }

  Future<void> _onSetSubscriptionData(
      SetSubscriptionData event,
      Emitter<MoviesState> emit,
      ) async {
    try {
      // Calculate tax
      final double taxAmount = double.parse(Taxes.billTax.toString());
      final double totalAmount = event.planPrice + taxAmount;

      emit(MoviesDataSet(
        serviceName: event.serviceName,
        category: event.category,
        email: event.email,
        planName: event.planName,
        planPrice: event.planPrice,
        planDuration: event.planDuration,
        planDescription: event.planDescription,
        autoRenew: event.autoRenew,
        taxAmount: taxAmount,
        totalAmount: totalAmount,
      ));
    } catch (e) {
      emit(MoviesError(e.toString()));
    }
  }

  Future<void> _onSetSelectedCard(
      SetSelectedCardForMovies event,
      Emitter<MoviesState> emit,
      ) async {
    if (state is MoviesDataSet) {
      final MoviesDataSet currentState = state as MoviesDataSet;
      emit(currentState.copyWith(
        cardId: event.cardId,
        cardHolderName: event.cardHolderName,
        cardEnding: event.cardEnding,
      ));
    }
  }

  Future<void> _onProcessSubscriptionPayment(
      ProcessSubscriptionPayment event,
      Emitter<MoviesState> emit,
      ) async {
    if (state is! MoviesDataSet) {
      emit(const MoviesError('Invalid state for payment processing'));
      return;
    }

    final MoviesDataSet currentState = state as MoviesDataSet;

    if (currentState.cardId == null) {
      emit(const MoviesError('Please select a card'));
      return;
    }

    emit(MoviesProcessing());

    try {
      final User? user = _auth.currentUser;
      if (user == null) {
        emit(const MoviesError('User not authenticated'));
        return;
      }

      // Generate transaction ID
      final String transactionId = FirebaseFirestore.instance.collection("users").doc(FirebaseAuth.instance.currentUser?.uid).
      collection('payBills').doc().id;
      final DateTime now = DateTime.now();

      // Calculate subscription end date
      final DateTime subscriptionEndDate = _calculateEndDate(now, currentState.planDuration);

      // Create transaction data
      final Map<String, dynamic> moviesData = <String, dynamic>{
        'id': transactionId,
        'userId': user.uid,
        'billType': 'Streaming Subscription',
        'serviceName': currentState.serviceName,
        'category': currentState.category,
        'email': currentState.email,
        'planName': currentState.planName,
        'planPrice': currentState.planPrice,
        'planDuration': currentState.planDuration,
        'planDescription': currentState.planDescription,
        'autoRenew': currentState.autoRenew,
        'subscriptionStartDate': now.toIso8601String(),
        'subscriptionEndDate': subscriptionEndDate.toIso8601String(),
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
          .set(moviesData);

      // Local notification
      await LocalNotificationService.showTransactionNotification(
        transactionType: 'sent',
        amount: currentState.totalAmount,
        currency: 'USD',
      );

      // Firestore notification
      final String notificationMessage = _buildNotificationMessage(currentState);

      _notificationBloc.add(AddNotification(
        title: 'Subscription Active - ${currentState.serviceName}',
        message: notificationMessage,
        type: 'streaming_subscription_success',
        data: <String, dynamic>{
          'transactionId': transactionId,
          'serviceName': currentState.serviceName,
          'category': currentState.category,
          'email': currentState.email,
          'planName': currentState.planName,
          'planPrice': currentState.planPrice,
          'planDuration': currentState.planDuration,
          'autoRenew': currentState.autoRenew,
          'taxAmount': currentState.taxAmount,
          'totalAmount': currentState.totalAmount,
          'cardEnding': currentState.cardEnding,
          'subscriptionStartDate': now.toIso8601String(),
          'subscriptionEndDate': subscriptionEndDate.toIso8601String(),
          'timestamp': now.toIso8601String(),
        },
      ));

      emit(MoviesSuccess(
        transactionId: transactionId,
        message: 'Subscription activated successfully!',
      ));
    } catch (e) {
      // Error notification
      await LocalNotificationService.showCustomNotification(
        title: 'Subscription Failed',
        body: 'Subscription failed: ${e.toString()}',
        payload: 'subscription_failed',
      );

      _notificationBloc.add(AddNotification(
        title: 'Subscription Failed',
        message: 'Subscription failed: ${e.toString()}',
        type: 'streaming_subscription_failed',
        data: <String, dynamic>{
          'error': e.toString(),
          'timestamp': DateTime.now().toIso8601String(),
        },
      ));

      emit(MoviesError(e.toString()));
    }
  }

  Future<void> _onResetSubscription(
      ResetSubscription event,
      Emitter<MoviesState> emit,
      ) async {
    emit(MoviesInitial());
  }

  DateTime _calculateEndDate(DateTime startDate, String duration) {
    if (duration.contains('Month')) {
      final int months = int.parse(duration.split(' ')[0]);
      return DateTime(startDate.year, startDate.month + months, startDate.day);
    } else if (duration.contains('Year')) {
      return DateTime(startDate.year + 1, startDate.month, startDate.day);
    }
    return startDate.add(const Duration(days: 30)); // Default to 30 days
  }

  String _buildNotificationMessage(MoviesDataSet state) {
    final DateTime now = DateTime.now();
    final DateTime endDate = _calculateEndDate(now, state.planDuration);

    final String message = '''Subscription activated successfully!

Service: ${state.serviceName}
Category: ${state.category}
Email: ${state.email}
Plan: ${state.planName}
 Duration: ${state.planDuration}
${state.autoRenew ? 'Auto-Renew: Enabled' : 'Auto-Renew: Disabled'}

Plan Price: USD ${state.planPrice.toStringAsFixed(2)}
Tax: USD ${state.taxAmount.toStringAsFixed(2)}
Total Paid: USD ${state.totalAmount.toStringAsFixed(2)}
Card Ending: ****${state.cardEnding}

Subscription Start: ${now.toString().substring(0, 19)}
Subscription End: ${endDate.toString().substring(0, 19)}

Thank you for subscribing to ${state.serviceName}!''';

    return message;
  }
}