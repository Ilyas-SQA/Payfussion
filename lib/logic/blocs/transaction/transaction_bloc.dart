import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:payfussion/logic/blocs/transaction/transaction_event.dart';
import 'package:payfussion/logic/blocs/transaction/transaction_state.dart';

import '../../../../../data/models/transaction/transaction_model.dart';
import '../../../../../data/repositories/transaction/transaction_repository.dart';
import '../../../../../services/biometric_service.dart';
import '../../../core/constants/tax.dart';
import '../../../data/models/notification/notification_model.dart';
import '../../../data/repositories/notification/notification_repository.dart';
import '../../../services/notification_service.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final BiometricService biometricService;
  final TransactionRepository txRepo;
  final NotificationRepository notificationRepo;

  TransactionBloc({
    required this.biometricService,
    required this.txRepo,
    required this.notificationRepo,
  }) : super(TransactionState.initial()) {

    on<PaymentStarted>((event, emit) {
      print('Payment started for recipient: ${event.recipient.name}');
      emit(state.copyWith(
          recipient: event.recipient,
          amountError: null,
          errorMessage: null,
          isSuccess: false));
    });

    on<PaymentAmountChanged>((event, emit) {
      final sanitized = event.raw.replaceAll(RegExp(r'[^\d.]'), '');
      double amount = 0.0;
      String? err;

      if (sanitized.isEmpty) {
        amount = 0.0;
        err = null;
      } else {
        try {
          amount = double.parse(sanitized);
          err = _validateAmount(amount);
        } catch (_) {
          err = 'Please enter a valid amount';
        }
      }

      print('Amount changed to: \$${amount.toStringAsFixed(2)}');
      emit(state.copyWith(
          amount: amount,
          amountError: err,
          errorMessage: null,
          isSuccess: false));
    });

    on<PaymentSelectCard>((event, emit) {
      print('Card selected: ${event.card.brand} **** ${event.card.last4}');
      emit(state.copyWith(
          selectedCard: event.card,
          amountError: _validateAmount(state.amount)));
    });

    on<PaymentSubmit>(_onSubmit);

    on<PaymentReset>((event, emit) {
      print('Payment reset');
      emit(state.copyWith(
        amount: 0.0,
        amountError: null,
        isProcessing: false,
        isSuccess: false,
        errorMessage: null,
      ));
    });

    on<FetchTodaysTransactions>((event, emit) async {
      try {
        print('Fetching today\'s transactions...');

        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser == null) {
          throw Exception('User not authenticated');
        }

        final uid = currentUser.uid;
        final snapshot = await txRepo.getTransactions(uid);

        final today = DateTime.now();
        final todaysTransactions = snapshot.where((tx) {
          final txDate = tx.createdAt;
          return txDate.year == today.year &&
              txDate.month == today.month &&
              txDate.day == today.day;
        }).toList();

        print('Found ${todaysTransactions.length} transactions for today');
        emit(state.copyWith(todaysTransactions: todaysTransactions));
      } catch (e) {
        print('Error fetching transactions: $e');
        emit(state.copyWith(errorMessage: 'Error fetching transactions: $e'));
      }
    });
  }

  String? _validateAmount(double value) {
    if (value <= 0) return 'Please enter a valid amount';
    if (value < 1.0) return 'Amount must be at least \$1';
    if (value > 10000) return 'Amount exceeds your limit';
    return null;
  }

  double _calculateTotalAmount(double amount) {
    return amount + Taxes.transactionFee;
  }

  Future<void> _onSubmit(PaymentSubmit event, Emitter<TransactionState> emit) async {
    print('Payment submission started');
    print('Amount: \$${state.amount.toStringAsFixed(2)}');
    print('Recipient: ${state.recipient?.name}');
    print('Card: ${state.selectedCard?.brand} **** ${state.selectedCard?.last4}');

    // Validate inputs
    final err = _validateAmount(state.amount);
    if (err != null || state.selectedCard == null || state.recipient == null) {
      final errorMsg = err ?? (state.selectedCard == null ? 'Select a card' : 'Select a recipient');
      print('Validation failed: $errorMsg');
      emit(state.copyWith(
          amountError: err ?? state.amountError,
          errorMessage: state.selectedCard == null ? 'Select a card' : null));
      return;
    }

    // Calculate total amount with fee
    final totalAmount = _calculateTotalAmount(state.amount);
    print('Total amount with fee: \$${totalAmount.toStringAsFixed(2)} (Amount: \$${state.amount.toStringAsFixed(2)} + Fee: \$${Taxes.transactionFee.toStringAsFixed(2)})');

    emit(state.copyWith(isProcessing: true, errorMessage: null));

    try {
      // Check if user is authenticated
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated. Please log in again.');
      }

      print('Starting biometric authentication...');

      // Biometric authentication
      final isBioAvailable = await biometricService.isBiometricAvailable();
      final hasBiometrics = await biometricService.hasBiometricsEnrolled();

      if (isBioAvailable && hasBiometrics) {
        final auth = await biometricService.authenticate(
          reason: 'Authenticate to send \$${totalAmount.toStringAsFixed(2)} to ${state.recipient!.name} (includes \$${Taxes.transactionFee.toStringAsFixed(2)} fee)',
        );
        if (!(auth['success'] == true)) {
          print('Biometric authentication failed: ${auth['error']}');
          emit(state.copyWith(
              isProcessing: false,
              errorMessage: 'Authentication failed: ${auth['error']}'));
          return;
        }
        print('Biometric authentication successful');
      } else {
        print('Biometric authentication not available or not enrolled');
      }

      // Test repository connection
      final connectionTest = await txRepo.testConnection();
      if (!connectionTest) {
        throw Exception('Unable to connect to database. Please check your internet connection.');
      }

      // Check user permissions
      await txRepo.checkUserPermissions(currentUser.uid);

      print('Simulating payment processing...');
      await Future.delayed(const Duration(milliseconds: 1200));

      print('Creating transaction record...');
      final tx = TransactionModel(
        id: '',
        userId: currentUser.uid,
        recipientId: state.recipient!.id,
        recipientName: state.recipient!.name,
        cardId: state.selectedCard!.id,
        amount: state.amount,
        fee: Taxes.transactionFee,
        totalAmount: totalAmount,
        currency: 'USD',
        status: 'success',
        createdAt: DateTime.now(),
        note: null,
      );

      print('Saving transaction to repository...');
      final transactionId = await txRepo.addTransaction(tx);
      print('Transaction saved successfully with ID: $transactionId');

      // Create and save notification to Firebase
      await _createTransactionNotification(
        transactionId: transactionId,
        recipientName: state.recipient!.name,
        amount: state.amount,
        fee: Taxes.transactionFee,
        totalAmount: totalAmount,
        currency: 'USD',
      );

      // Show local notification
      try {
        await LocalNotificationService.showTransactionNotification(
          transactionType: 'sent',
          amount: totalAmount,
          currency: '\$',
        );
        print('Local notification sent successfully');
      } catch (e) {
        print('Failed to send local notification: $e');
      }

      // Custom local notification with recipient details
      try {
        await LocalNotificationService.showCustomNotification(
          title: 'Payment Sent Successfully!',
          body: 'You sent \$${state.amount.toStringAsFixed(2)} to ${state.recipient!.name} (Total: \$${totalAmount.toStringAsFixed(2)} including fee)',
          payload: 'transaction_$transactionId',
        );
      } catch (e) {
        print('Failed to send custom notification: $e');
      }

      emit(state.copyWith(isProcessing: false, isSuccess: true));

    } catch (e) {
      print('Payment failed with error: $e');
      print('Stack trace: ${StackTrace.current}');

      // Create failure notification
      await _createFailureNotification(
        recipientName: state.recipient?.name ?? 'Unknown',
        amount: state.amount,
        errorMessage: e.toString(),
      );

      // Show failure local notification
      try {
        await LocalNotificationService.showCustomNotification(
          title: 'Payment Failed',
          body: 'Your payment to ${state.recipient?.name ?? 'recipient'} could not be processed',
          payload: 'payment_failed',
        );
      } catch (notificationError) {
        print('Failed to send failure notification: $notificationError');
      }

      String userFriendlyMessage = 'Payment failed. Please try again.';

      // Provide more specific error messages
      if (e.toString().contains('permission')) {
        userFriendlyMessage = 'Permission denied. Please check your account settings.';
      } else if (e.toString().contains('network') || e.toString().contains('connection')) {
        userFriendlyMessage = 'Network error. Please check your internet connection.';
      } else if (e.toString().contains('authenticated')) {
        userFriendlyMessage = 'Authentication error. Please log in again.';
      }

      emit(state.copyWith(
          isProcessing: false,
          errorMessage: userFriendlyMessage));
    }
  }

  Future<void> _createTransactionNotification({
    required String transactionId,
    required String recipientName,
    required double amount,
    required double fee,
    required double totalAmount,
    required String currency,
  }) async {
    try {
      print('Creating transaction notification...');

      final notification = NotificationModel(
        title: 'Payment Sent Successfully',
        message: 'You sent $currency${amount.toStringAsFixed(2)} to $recipientName',
        type: 'transaction',
        isRead: false,
        createdAt: DateTime.now(),
        data: {
          'transactionId': transactionId,
          'recipientName': recipientName,
          'amount': amount,
          'fee': fee,
          'totalAmount': totalAmount,
          'currency': currency,
          'transactionType': 'sent',
          'status': 'success',
        },
      );

      final notificationId = await notificationRepo.addNotification(notification);
      print('Transaction notification saved to Firebase with ID: $notificationId');

    } catch (e) {
      print('Failed to create transaction notification: $e');
      // Don't fail the transaction if notification fails
    }
  }

  Future<void> _createFailureNotification({
    required String recipientName,
    required double amount,
    required String errorMessage,
  }) async {
    try {
      print('Creating failure notification...');

      final notification = NotificationModel(
        title: 'Payment Failed',
        message: 'Your payment of \$${amount.toStringAsFixed(2)} to $recipientName failed',
        type: 'transaction',
        isRead: false,
        createdAt: DateTime.now(),
        data: {
          'recipientName': recipientName,
          'amount': amount,
          'currency': 'USD',
          'transactionType': 'sent',
          'status': 'failed',
          'errorMessage': errorMessage,
        },
      );

      final notificationId = await notificationRepo.addNotification(notification);
      print('Failure notification saved to Firebase with ID: $notificationId');

    } catch (e) {
      print('Failed to create failure notification: $e');
    }
  }
}