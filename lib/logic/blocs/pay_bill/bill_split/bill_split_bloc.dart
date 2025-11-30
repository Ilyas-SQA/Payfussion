import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/constants/tax.dart';
import '../../../../services/notification_service.dart';
import '../../notification/notification_bloc.dart';
import '../../notification/notification_event.dart';
import 'bill_split_event.dart';
import 'bill_split_state.dart';

class BillSplitBloc extends Bloc<BillSplitEvent, BillSplitState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final NotificationBloc _notificationBloc;

  BillSplitBloc(this._notificationBloc) : super(BillSplitInitial()) {
    on<SetBillSplitData>(_onSetBillSplitData);
    on<SetSelectedCardForBillSplit>(_onSetSelectedCard);
    on<ProcessBillSplitPayment>(_onProcessBillSplitPayment);
    on<ResetBillSplit>(_onResetBillSplit);
  }

  Future<void> _onSetBillSplitData(
      SetBillSplitData event,
      Emitter<BillSplitState> emit,
      ) async {
    try {
      // Calculate amount per person
      double amountPerPerson;
      if (event.splitType == 'equal') {
        amountPerPerson = event.totalAmount / event.numberOfPeople;
      } else {
        // For custom split, calculate user's portion
        amountPerPerson = event.customAmounts?[_auth.currentUser?.displayName ?? 'You'] ?? 0.0;
      }

      // Calculate tax
      final double taxAmount = double.parse(Taxes.billTax.toString());
      final double totalWithTax = event.totalAmount + taxAmount;

      emit(BillSplitDataSet(
        billName: event.billName,
        totalAmount: event.totalAmount,
        numberOfPeople: event.numberOfPeople,
        participantNames: event.participantNames,
        splitType: event.splitType,
        customAmounts: event.customAmounts,
        amountPerPerson: amountPerPerson,
        taxAmount: taxAmount,
        totalWithTax: totalWithTax,
      ));
    } catch (e) {
      emit(BillSplitError(e.toString()));
    }
  }

  Future<void> _onSetSelectedCard(
      SetSelectedCardForBillSplit event,
      Emitter<BillSplitState> emit,
      ) async {
    if (state is BillSplitDataSet) {
      final BillSplitDataSet currentState = state as BillSplitDataSet;
      emit(currentState.copyWith(
        cardId: event.cardId,
        cardHolderName: event.cardHolderName,
        cardEnding: event.cardEnding,
      ));
    }
  }

  Future<void> _onProcessBillSplitPayment(
      ProcessBillSplitPayment event,
      Emitter<BillSplitState> emit,
      ) async {
    if (state is! BillSplitDataSet) {
      emit(const BillSplitError('Invalid state for payment processing'));
      return;
    }

    final BillSplitDataSet currentState = state as BillSplitDataSet;

    if (currentState.cardId == null) {
      emit(const BillSplitError('Please select a card'));
      return;
    }

    emit(BillSplitProcessing());

    try {
      final User? user = _auth.currentUser;
      if (user == null) {
        emit(const BillSplitError('User not authenticated'));
        return;
      }

      // Generate transaction ID
      final String transactionId = _firestore.collection('transactions').doc().id;
      final DateTime now = DateTime.now();

      // Create transaction data
      final Map<String, dynamic> transactionData = <String, dynamic>{
        'id': transactionId,
        'userId': user.uid,
        'type': 'bill_split',
        'billName': currentState.billName,
        "billType": "Bill Split",
        'totalAmount': currentState.totalAmount,
        'numberOfPeople': currentState.numberOfPeople,
        'participantNames': currentState.participantNames,
        'customAmounts': currentState.customAmounts,
        'amountPerPerson': currentState.amountPerPerson,
        'taxAmount': currentState.taxAmount,
        'amount': currentState.totalWithTax,
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
        amount: currentState.amountPerPerson,
        currency: 'USD',
      );

      // Firestore notification
      final String notificationMessage = _buildNotificationMessage(currentState);

      _notificationBloc.add(AddNotification(
        title: 'Bill Split Payment Successful',
        message: notificationMessage,
        type: 'bill_split_success',
        data: <String, dynamic>{
          'transactionId': transactionId,
          'billName': currentState.billName,
          'totalAmount': currentState.totalAmount,
          'amountPerPerson': currentState.amountPerPerson,
          'numberOfPeople': currentState.numberOfPeople,
          'participantNames': currentState.participantNames,
          'splitType': currentState.splitType,
          'cardEnding': currentState.cardEnding,
          'timestamp': now.toIso8601String(),
        },
      ));

      emit(BillSplitSuccess(
        transactionId: transactionId,
        message: 'Bill split payment completed successfully!',
      ));
    } catch (e) {
      // Error notification
      await LocalNotificationService.showCustomNotification(
        title: 'Payment Failed',
        body: 'Bill split payment failed: ${e.toString()}',
        payload: 'bill_split_failed',
      );

      _notificationBloc.add(AddNotification(
        title: 'Payment Failed',
        message: 'Bill split payment failed: ${e.toString()}',
        type: 'bill_split_failed',
        data: <String, dynamic>{
          'error': e.toString(),
          'timestamp': DateTime.now().toIso8601String(),
        },
      ));

      emit(BillSplitError(e.toString()));
    }
  }

  Future<void> _onResetBillSplit(
      ResetBillSplit event,
      Emitter<BillSplitState> emit,
      ) async {
    emit(BillSplitInitial());
  }

  String _buildNotificationMessage(BillSplitDataSet state) {
    final DateTime now = DateTime.now();

    final String message = '''Bill Split Payment completed successfully!

Bill Name: ${state.billName}
Total Amount: USD ${state.totalAmount.toStringAsFixed(2)}
Split Among: ${state.numberOfPeople} people
Your Share: USD ${state.amountPerPerson.toStringAsFixed(2)}
Split Type: ${state.splitType == 'equal' ? 'Equal Split' : 'Custom Split'}
Tax: USD ${state.taxAmount.toStringAsFixed(2)}
Total Paid: USD ${state.totalWithTax.toStringAsFixed(2)}
Card Ending: ****${state.cardEnding}
Completed at: ${now.toString().substring(0, 19)}

Participants: ${state.participantNames.join(', ')}

Thank you for using our bill split service!''';

    return message;
  }
}