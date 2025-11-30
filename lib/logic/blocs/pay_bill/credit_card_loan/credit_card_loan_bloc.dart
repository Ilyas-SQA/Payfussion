import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/constants/tax.dart';
import '../../../../services/notification_service.dart';
import '../../notification/notification_bloc.dart';
import '../../notification/notification_event.dart';
import 'credit_card_loan_event.dart';
import 'credit_card_loan_state.dart';

class CreditCardLoanBloc extends Bloc<CreditCardLoanEvent, CreditCardLoanState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final NotificationBloc _notificationBloc;

  CreditCardLoanBloc(this._notificationBloc) : super(CreditCardLoanInitial()) {
    on<SetLoanPaymentData>(_onSetLoanPaymentData);
    on<SetSelectedCardForLoan>(_onSetSelectedCard);
    on<ProcessLoanPayment>(_onProcessLoanPayment);
    on<ResetLoanPayment>(_onResetLoanPayment);
  }

  Future<void> _onSetLoanPaymentData(
      SetLoanPaymentData event,
      Emitter<CreditCardLoanState> emit,
      ) async {
    try {
      // Calculate tax
      final double taxAmount = double.parse(Taxes.billTax.toString());
      final double totalAmount = event.amount + taxAmount;

      emit(CreditCardLoanDataSet(
        bankName: event.bankName,
        branchName: event.branchName,
        accountNumber: event.accountNumber,
        cardNumber: event.cardNumber,
        amount: event.amount,
        paymentType: event.paymentType,
        taxAmount: taxAmount,
        totalAmount: totalAmount,
      ));
    } catch (e) {
      emit(CreditCardLoanError(e.toString()));
    }
  }

  Future<void> _onSetSelectedCard(
      SetSelectedCardForLoan event,
      Emitter<CreditCardLoanState> emit,
      ) async {
    if (state is CreditCardLoanDataSet) {
      final CreditCardLoanDataSet currentState = state as CreditCardLoanDataSet;
      emit(currentState.copyWith(
        cardId: event.cardId,
        cardHolderName: event.cardHolderName,
        cardEnding: event.cardEnding,
      ));
    }
  }

  Future<void> _onProcessLoanPayment(
      ProcessLoanPayment event,
      Emitter<CreditCardLoanState> emit,
      ) async {
    if (state is! CreditCardLoanDataSet) {
      emit(const CreditCardLoanError('Invalid state for payment processing'));
      return;
    }

    final CreditCardLoanDataSet currentState = state as CreditCardLoanDataSet;

    if (currentState.cardId == null) {
      emit(const CreditCardLoanError('Please select a card'));
      return;
    }

    emit(CreditCardLoanProcessing());

    try {
      final User? user = _auth.currentUser;
      if (user == null) {
        emit(const CreditCardLoanError('User not authenticated'));
        return;
      }

      // Generate transaction ID
      final String transactionId = _firestore.collection('transactions').doc().id;
      final DateTime now = DateTime.now();

      // Create transaction data
      final Map<String, dynamic> transactionData = <String, dynamic>{
        'id': transactionId,
        'userId': user.uid,
        'billType': 'Credit Card Loan',
        'bankName': currentState.bankName,
        'branchName': currentState.branchName,
        'accountNumber': currentState.accountNumber,
        'cardNumber': currentState.cardNumber,
        // 'amount': currentState.amount,
        'paymentType': currentState.paymentType,
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
        title: 'Credit Card/Loan Payment Successful - ${currentState.bankName}',
        message: notificationMessage,
        type: 'credit_loan_success',
        data: <String, dynamic>{
          'transactionId': transactionId,
          'bankName': currentState.bankName,
          'branchName': currentState.branchName,
          'accountNumber': currentState.accountNumber,
          'cardNumber': currentState.cardNumber,
          'amount': currentState.amount,
          'paymentType': currentState.paymentType,
          'taxAmount': currentState.taxAmount,
          'totalAmount': currentState.totalAmount,
          'cardEnding': currentState.cardEnding,
          'timestamp': now.toIso8601String(),
        },
      ));

      emit(CreditCardLoanSuccess(
        transactionId: transactionId,
        message: 'Credit card/loan payment completed successfully!',
      ));
    } catch (e) {
      // Error notification
      await LocalNotificationService.showCustomNotification(
        title: 'Payment Failed',
        body: 'Credit card/loan payment failed: ${e.toString()}',
        payload: 'loan_payment_failed',
      );

      _notificationBloc.add(AddNotification(
        title: 'Payment Failed',
        message: 'Credit card/loan payment failed: ${e.toString()}',
        type: 'credit_loan_failed',
        data: <String, dynamic>{
          'error': e.toString(),
          'timestamp': DateTime.now().toIso8601String(),
        },
      ));

      emit(CreditCardLoanError(e.toString()));
    }
  }

  Future<void> _onResetLoanPayment(
      ResetLoanPayment event,
      Emitter<CreditCardLoanState> emit,
      ) async {
    emit(CreditCardLoanInitial());
  }

  String _buildNotificationMessage(CreditCardLoanDataSet state) {
    final DateTime now = DateTime.now();
    final String paymentTypeLabel = _getPaymentTypeLabel(state.paymentType);

    final String message = '''Credit Card/Loan Payment completed successfully!

Bank: ${state.bankName}
Branch: ${state.branchName}
Account: ${state.accountNumber}
Card: ${state.cardNumber}
Payment Type: $paymentTypeLabel
Amount: USD ${state.amount.toStringAsFixed(2)}
Tax: USD ${state.taxAmount.toStringAsFixed(2)}
Total Paid: USD ${state.totalAmount.toStringAsFixed(2)}
Paid with Card: ****${state.cardEnding}
Completed at: ${now.toString().substring(0, 19)}

Thank you for using our service for your ${state.bankName} payment!''';

    return message;
  }

  String _getPaymentTypeLabel(String paymentType) {
    switch (paymentType) {
      case 'minimum':
        return 'Minimum Payment';
      case 'full':
        return 'Full Payment';
      case 'custom':
        return 'Custom Amount';
      default:
        return 'Payment';
    }
  }
}