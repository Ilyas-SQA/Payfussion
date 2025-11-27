import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/constants/tax.dart';
import '../../../../services/notification_service.dart';
import '../../notification/notification_bloc.dart';
import '../../notification/notification_event.dart';
import 'mobile_recharge_event.dart';
import 'mobile_recharge_state.dart';


class MobileRechargeBloc extends Bloc<MobileRechargeEvent, MobileRechargeState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final NotificationBloc _notificationBloc;

  MobileRechargeBloc(this._notificationBloc) : super(MobileRechargeInitial()) {
    on<SetRechargeData>(_onSetRechargeData);
    on<SetSelectedCard>(_onSetSelectedCard);
    on<ProcessRechargePayment>(_onProcessRechargePayment);
    on<ResetRecharge>(_onResetRecharge);
  }

  Future<void> _onSetRechargeData(
      SetRechargeData event,
      Emitter<MobileRechargeState> emit,
      ) async {
    try {
      // Calculate tax
      final double taxAmount = double.parse(Taxes.billTax.toString());
      final double totalAmount = event.amount + taxAmount;

      emit(MobileRechargeDataSet(
        companyName: event.companyName,
        network: event.network,
        phoneNumber: event.phoneNumber,
        amount: event.amount,
        taxAmount: taxAmount,
        totalAmount: totalAmount,
        packageName: event.packageName,
        packageData: event.packageData,
        packageValidity: event.packageValidity,
      ));
    } catch (e) {
      emit(MobileRechargeError(e.toString()));
    }
  }

  Future<void> _onSetSelectedCard(
      SetSelectedCard event,
      Emitter<MobileRechargeState> emit,
      ) async {
    if (state is MobileRechargeDataSet) {
      final MobileRechargeDataSet currentState = state as MobileRechargeDataSet;
      emit(currentState.copyWith(
        cardId: event.cardId,
        cardHolderName: event.cardHolderName,
        cardEnding: event.cardEnding,
      ));
    }
  }

  Future<void> _onProcessRechargePayment(
      ProcessRechargePayment event,
      Emitter<MobileRechargeState> emit,
      ) async {
    if (state is! MobileRechargeDataSet) {
      emit(const MobileRechargeError('Invalid state for payment processing'));
      return;
    }

    final MobileRechargeDataSet currentState = state as MobileRechargeDataSet;

    if (currentState.cardId == null) {
      emit(const MobileRechargeError('Please select a card'));
      return;
    }

    emit(MobileRechargeProcessing());

    try {
      final User? user = _auth.currentUser;
      if (user == null) {
        emit(const MobileRechargeError('User not authenticated'));
        return;
      }

      // Generate transaction ID
      final String transactionId = _firestore.collection('transactions').doc().id;
      final DateTime now = DateTime.now();

      // Determine transaction type
      final String transactionType = currentState.packageName != null
          ? 'Package'
          : 'Mobile Recharge';

      // Create transaction data
      final Map<String, dynamic> transactionData = <String, dynamic>{
        'id': transactionId,
        'userId': user.uid,
        'billType': transactionType,
        'companyName': currentState.companyName,
        'network': currentState.network,
        'phoneNumber': currentState.phoneNumber,
        // 'amount': currentState.amount,
        'taxAmount': currentState.taxAmount,
        'amount': currentState.totalAmount,
        'currency': 'USD',
        'packageName': currentState.packageName,
        'packageData': currentState.packageData,
        'packageValidity': currentState.packageValidity,
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
      final String notificationMessage = _buildNotificationMessage(
        currentState,
        transactionType,
      );

      _notificationBloc.add(AddNotification(
        title: 'Mobile Recharge Successful - ${currentState.companyName}',
        message: notificationMessage,
        type: 'mobile_recharge_success',
        data: <String, dynamic>{
          'transactionId': transactionId,
          'companyName': currentState.companyName,
          'network': currentState.network,
          'phoneNumber': currentState.phoneNumber,
          'amount': currentState.amount,
          'taxAmount': currentState.taxAmount,
          'totalAmount': currentState.totalAmount,
          'packageName': currentState.packageName,
          'packageData': currentState.packageData,
          'packageValidity': currentState.packageValidity,
          'cardEnding': currentState.cardEnding,
          'type': transactionType,
          'timestamp': now.toIso8601String(),
        },
      ));

      emit(MobileRechargeSuccess(
        transactionId: transactionId,
        message: 'Mobile recharge completed successfully!',
      ));
    } catch (e) {
      // Error notification
      await LocalNotificationService.showCustomNotification(
        title: 'Recharge Failed',
        body: 'Mobile recharge failed: ${e.toString()}',
        payload: 'recharge_failed',
      );

      _notificationBloc.add(AddNotification(
        title: 'Recharge Failed',
        message: 'Mobile recharge failed: ${e.toString()}',
        type: 'mobile_recharge_failed',
        data: <String, dynamic>{
          'error': e.toString(),
          'timestamp': DateTime.now().toIso8601String(),
        },
      ));

      emit(MobileRechargeError(e.toString()));
    }
  }

  Future<void> _onResetRecharge(
      ResetRecharge event,
      Emitter<MobileRechargeState> emit,
      ) async {
    emit(MobileRechargeInitial());
  }

  String _buildNotificationMessage(
      MobileRechargeDataSet state,
      String type,
      ) {
    final String typeLabel = type == 'package' ? 'Package' : 'Recharge';
    final DateTime now = DateTime.now();

    String message = '''Mobile $typeLabel completed successfully!

Company: ${state.companyName}
Network: ${state.network}
Phone Number: ${state.phoneNumber}''';

    if (state.packageName != null) {
      message += '''
Package: ${state.packageName}
Data: ${state.packageData}
 Validity: ${state.packageValidity}''';
    }

    message += '''
Amount: USD ${state.amount.toStringAsFixed(2)}
Tax: USD ${state.taxAmount.toStringAsFixed(2)}
Total Paid: USD ${state.totalAmount.toStringAsFixed(2)}
Card Ending: ****${state.cardEnding}
Completed at: ${now.toString().substring(0, 19)}

Thank you for using our service for your ${state.companyName} recharge!''';

    return message;
  }
}