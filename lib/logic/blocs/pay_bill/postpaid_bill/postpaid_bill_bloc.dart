import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/constants/tax.dart';
import '../../../../services/notification_service.dart';
import '../../notification/notification_bloc.dart';
import '../../notification/notification_event.dart';
import 'postpaid_bill_event.dart';
import 'postpaid_bill_state.dart';

class PostpaidBillBloc extends Bloc<PostpaidBillEvent, PostpaidBillState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final NotificationBloc _notificationBloc;

  PostpaidBillBloc(this._notificationBloc) : super(PostpaidBillInitial()) {
    on<SetPostpaidBillData>(_onSetPostpaidBillData);
    on<SetSelectedCardForPostpaidBill>(_onSetSelectedCard);
    on<ProcessPostpaidBillPayment>(_onProcessPayment);
    on<ResetPostpaidBill>(_onResetPostpaidBill);
  }

  Future<void> _onSetPostpaidBillData(
      SetPostpaidBillData event,
      Emitter<PostpaidBillState> emit,
      ) async {
    try {
      // Calculate tax
      final double taxAmount = double.parse(Taxes.billTax.toString());
      final double totalAmount = event.amount + taxAmount;

      emit(PostpaidBillDataSet(
        providerName: event.providerName,
        planType: event.planType,
        startingPrice: event.startingPrice,
        features: event.features,
        mobileNumber: event.mobileNumber,
        billNumber: event.billNumber,
        accountHolderName: event.accountHolderName,
        billCycle: event.billCycle,
        amount: event.amount,
        taxAmount: taxAmount,
        totalAmount: totalAmount,
        email: event.email,
        saveForFuture: event.saveForFuture,
      ));
    } catch (e) {
      emit(PostpaidBillError(e.toString()));
    }
  }

  Future<void> _onSetSelectedCard(
      SetSelectedCardForPostpaidBill event,
      Emitter<PostpaidBillState> emit,
      ) async {
    if (state is PostpaidBillDataSet) {
      final PostpaidBillDataSet currentState = state as PostpaidBillDataSet;
      emit(currentState.copyWith(
        cardId: event.cardId,
        cardHolderName: event.cardHolderName,
        cardEnding: event.cardEnding,
      ));
    }
  }

  Future<void> _onProcessPayment(
      ProcessPostpaidBillPayment event,
      Emitter<PostpaidBillState> emit,
      ) async {
    if (state is! PostpaidBillDataSet) {
      emit(const PostpaidBillError('Invalid state for payment processing'));
      return;
    }

    final PostpaidBillDataSet currentState = state as PostpaidBillDataSet;

    if (currentState.cardId == null) {
      emit(const PostpaidBillError('Please select a card'));
      return;
    }

    emit(PostpaidBillProcessing());

    try {
      final User? user = _auth.currentUser;
      if (user == null) {
        emit(const PostpaidBillError('User not authenticated'));
        return;
      }

      // Generate transaction ID
      final String transactionId = FirebaseFirestore.instance.collection("users").doc(FirebaseAuth.instance.currentUser?.uid).
      collection('payBills').doc().id;
      final DateTime now = DateTime.now();

      // Create transaction data
      final Map<String, dynamic> postpaidBillData = <String, dynamic>{
        'id': transactionId,
        'userId': user.uid,
        'billType': 'Postpaid Bill',
        'providerName': currentState.providerName,
        'planType': currentState.planType,
        'startingPrice': currentState.startingPrice,
        'features': currentState.features,
        'mobileNumber': currentState.mobileNumber,
        'billNumber': currentState.billNumber,
        'accountHolderName': currentState.accountHolderName,
        'billCycle': currentState.billCycle,
        'email': currentState.email,
        'saveForFuture': currentState.saveForFuture,
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
          .set(postpaidBillData);

      // Save for future payments if requested
      if (currentState.saveForFuture) {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('saved_bills')
            .doc()
            .set(<String, dynamic>{
          'providerName': currentState.providerName,
          'billNumber': currentState.billNumber,
          'accountHolderName': currentState.accountHolderName,
          'mobileNumber': currentState.mobileNumber,
          'billType': 'postpaid',
          'createdAt': now.toIso8601String(),
        });
      }

      // Local notification
      await LocalNotificationService.showTransactionNotification(
        transactionType: 'sent',
        amount: currentState.totalAmount,
        currency: 'USD',
      );

      // Firestore notification
      final String notificationMessage = _buildNotificationMessage(currentState);

      _notificationBloc.add(AddNotification(
        title: 'Postpaid Bill Payment Successful - ${currentState.providerName}',
        message: notificationMessage,
        type: 'postpaid_bill_success',
        data: <String, dynamic>{
          'transactionId': transactionId,
          'providerName': currentState.providerName,
          'planType': currentState.planType,
          'mobileNumber': currentState.mobileNumber,
          'billNumber': currentState.billNumber,
          'accountHolderName': currentState.accountHolderName,
          'billCycle': currentState.billCycle,
          'amount': currentState.amount,
          'taxAmount': currentState.taxAmount,
          'totalAmount': currentState.totalAmount,
          'cardEnding': currentState.cardEnding,
          'timestamp': now.toIso8601String(),
        },
      ));

      emit(PostpaidBillSuccess(
        transactionId: transactionId,
        message: 'Postpaid bill payment completed successfully!',
      ));
    } catch (e) {
      // Error notification
      await LocalNotificationService.showCustomNotification(
        title: 'Payment Failed',
        body: 'Postpaid bill payment failed: ${e.toString()}',
        payload: 'payment_failed',
      );

      _notificationBloc.add(AddNotification(
        title: 'Payment Failed',
        message: 'Postpaid bill payment failed: ${e.toString()}',
        type: 'postpaid_bill_failed',
        data: <String, dynamic>{
          'error': e.toString(),
          'timestamp': DateTime.now().toIso8601String(),
        },
      ));

      emit(PostpaidBillError(e.toString()));
    }
  }

  Future<void> _onResetPostpaidBill(
      ResetPostpaidBill event,
      Emitter<PostpaidBillState> emit,
      ) async {
    emit(PostpaidBillInitial());
  }

  String _buildNotificationMessage(PostpaidBillDataSet state) {
    final DateTime now = DateTime.now();

    String message = '''Postpaid Bill Payment completed successfully!

Provider: ${state.providerName}
Plan Type: ${state.planType}
Mobile Number: ${state.mobileNumber}
Bill Number: ${state.billNumber}
Account Holder: ${state.accountHolderName}
Bill Cycle: ${state.billCycle}
Amount: USD ${state.amount.toStringAsFixed(2)}
Tax: USD ${state.taxAmount.toStringAsFixed(2)}
Total Paid: USD ${state.totalAmount.toStringAsFixed(2)}
Card Ending: ****${state.cardEnding}''';

    if (state.email != null && state.email!.isNotEmpty) {
      message += '\n Receipt sent to: ${state.email}';
    }

    message += '''
Completed at: ${now.toString().substring(0, 19)}

Thank you for using our service for your ${state.providerName} postpaid bill payment!''';

    return message;
  }
}