import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:payfussion/logic/blocs/pay_bill/pay_bill_event.dart';
import 'package:payfussion/logic/blocs/pay_bill/pay_bill_state.dart';

import '../../../core/constants/tax.dart';
import '../../../data/models/pay_bills/bill_item.dart';
import '../../../data/repositories/pay_bill/pay_bill_repository.dart';
import '../../../services/notification_service.dart';
import '../notification/notification_bloc.dart';
import '../notification/notification_event.dart';

class PayBillBloc extends Bloc<PayBillEvent, PayBillState> {
  final PayBillRepository _payBillRepository;
  final NotificationBloc _notificationBloc;

  PayBillBloc(this._payBillRepository, this._notificationBloc) : super(PayBillInitial()) {
    on<LoadPayBills>(_onLoadPayBills);
    on<AddPayBill>(_onAddPayBill);
    on<UpdatePayBillStatus>(_onUpdatePayBillStatus);
    on<LoadPayBillsByStatus>(_onLoadPayBillsByStatus);
    on<DeletePayBill>(_onDeletePayBill);
    on<ProcessPayment>(_onProcessPayment);
  }

  // Load all pay bills
  Future<void> _onLoadPayBills(
      LoadPayBills event,
      Emitter<PayBillState> emit,
      ) async {
    emit(PayBillLoading());
    try {
      final List<PayBillModel> payBills = await _payBillRepository.getUserPayBills();
      emit(PayBillLoaded(payBills));
    } catch (e) {
      emit(PayBillError(e.toString()));
    }
  }

  // Add new pay bill - SILENT (no notification)
  Future<void> _onAddPayBill(
      AddPayBill event,
      Emitter<PayBillState> emit,
      ) async {
    emit(PayBillLoading());
    try {
      // Calculate total with tax
      final double originalAmount = event.payBill.amount ?? 0.0;
      final double taxAmount = double.parse(Taxes.billTax.toString());
      final double totalAmount = originalAmount + taxAmount;

      // Update bill with tax included - companyName preserved from event
      final PayBillModel updatedBill = event.payBill.copyWith(
        amount: totalAmount,
        feeAmount: taxAmount,
        hasFee: true,
        companyName: event.payBill.companyName, // Explicitly preserve company name
      );

      await _payBillRepository.addPayBill(updatedBill);

      // Reload all pay bills after adding
      final List<PayBillModel> payBills = await _payBillRepository.getUserPayBills();
      emit(PayBillLoaded(payBills));

      // NO NOTIFICATION HERE - Silent operation
      emit(PayBillSuccess('Bill payment added successfully for ${event.payBill.companyName ?? 'Unknown Company'}'));
    } catch (e) {
      emit(PayBillError(e.toString()));
    }
  }

  // Update pay bill status - SILENT
  Future<void> _onUpdatePayBillStatus(
      UpdatePayBillStatus event,
      Emitter<PayBillState> emit,
      ) async {
    try {
      await _payBillRepository.updatePayBillStatus(
        event.billId,
        event.status,
        paidAt: event.paidAt,
      );

      // Reload all pay bills after updating
      final List<PayBillModel> payBills = await _payBillRepository.getUserPayBills();
      emit(PayBillLoaded(payBills));

      // NO NOTIFICATION HERE - Silent operation
      emit(const PayBillSuccess('Bill status updated successfully'));
    } catch (e) {
      emit(PayBillError(e.toString()));
    }
  }

  // Load pay bills by status
  Future<void> _onLoadPayBillsByStatus(
      LoadPayBillsByStatus event,
      Emitter<PayBillState> emit,
      ) async {
    emit(PayBillLoading());
    try {
      final List<PayBillModel> payBills = await _payBillRepository.getPayBillsByStatus(event.status);
      emit(PayBillLoaded(payBills));
    } catch (e) {
      emit(PayBillError(e.toString()));
    }
  }

  // Delete pay bill - SILENT
  Future<void> _onDeletePayBill(
      DeletePayBill event,
      Emitter<PayBillState> emit,
      ) async {
    emit(PayBillLoading());
    try {
      await _payBillRepository.deletePayBill(event.billId);

      // Reload all pay bills after deleting
      final List<PayBillModel> payBills = await _payBillRepository.getUserPayBills();
      emit(PayBillLoaded(payBills));

      // NO NOTIFICATION HERE - Silent operation
      emit(const PayBillSuccess('Bill payment deleted successfully'));
    } catch (e) {
      emit(PayBillError(e.toString()));
    }
  }

  // Process payment - COMPREHENSIVE NOTIFICATION SYSTEM
  Future<void> _onProcessPayment(
      ProcessPayment event,
      Emitter<PayBillState> emit,
      ) async {
    emit(PayBillProcessing(event.billId));
    try {
      // Direct repository call - no events
      await _payBillRepository.updatePayBillStatus(
        event.billId,
        'completed',
        paidAt: DateTime.now(),
      );

      // Get the updated bill with complete company information
      final PayBillModel? updatedBill = await _payBillRepository.getPayBillById(event.billId);

      if (updatedBill != null) {
        // Extract company name for notifications
        final String companyName = updatedBill.companyName ?? 'Unknown Company';

        // Get bill type from company name
        final String billType = _getBillType(companyName);

        print('🔔 Processing payment notification for: $companyName');
        print('💰 Amount: ${updatedBill.amount}');
        print('📋 Bill Type: $billType');

        // LOCAL NOTIFICATION with company details
        await LocalNotificationService.showTransactionNotification(
          transactionType: 'sent',
          amount: updatedBill.amount ?? 0.0,
          currency: updatedBill.currency ?? 'USD',
        );

        // COMPREHENSIVE FIRESTORE NOTIFICATION
        try {
          print('🔥 Adding notification to Firestore for company: $companyName');

          final Map<String, Object> notificationData = <String, Object>{
            'billId': event.billId,
            'amount': updatedBill.amount ?? 0.0,
            'originalAmount': (updatedBill.amount ?? 0.0) - (updatedBill.feeAmount ?? 0.0),
            'taxAmount': updatedBill.feeAmount ?? 0.0,
            'currency': updatedBill.currency ?? 'USD',
            'billType': billType,
            'companyName': companyName, // Company name prominently included
            'accountNumber': updatedBill.billNumber ?? '',
            'paymentMethod': event.paymentMethod,
            'cardId': event.cardId,
            'paidAt': DateTime.now().toIso8601String(),
            'transactionId': event.billId,
            'status': 'completed',
          };

          print('📊 Notification data prepared: $notificationData');

          // Add notification with company name in title
          _notificationBloc.add(AddNotification(
            title: 'Payment Successful - $companyName',
            message: _buildDetailedNotificationMessage(updatedBill, billType, companyName),
            type: 'bill_payment_success',
            data: notificationData,
          ));

          print('✅ Notification event added successfully for $companyName');
        } catch (notificationError) {
          print('❌ Error adding notification: $notificationError');
        }

        // Update state silently
        final List<PayBillModel> payBills = await _payBillRepository.getUserPayBills();
        emit(PayBillLoaded(payBills));
        emit(PayBillPaymentSuccess(updatedBill));
      } else {
        print('❌ Updated bill is null - cannot retrieve company information');
        emit(PayBillPaymentFailed('Bill not found after payment', event.billId));
      }
    } catch (e) {
      print('❌ Payment processing error: $e');

      // Error notification with available context
      await LocalNotificationService.showCustomNotification(
        title: 'Payment Failed',
        body: 'Bill payment failed: ${e.toString()}',
        payload: 'bill_payment_failed|${event.billId}',
      );

      // Error notification to Firestore
      _notificationBloc.add(AddNotification(
        title: 'Payment Failed',
        message: 'Bill payment failed: ${e.toString()}',
        type: 'bill_payment_failed',
        data: <String, dynamic>{
          'billId': event.billId,
          'error': e.toString(),
          'timestamp': DateTime.now().toIso8601String(),
        },
      ));

      emit(PayBillPaymentFailed(e.toString(), event.billId));
    }
  }

  // Enhanced bill type detection with company name mapping
  String _getBillType(String companyName) {
    if (companyName.isEmpty) return 'Bill Payment';

    final String company = companyName.toLowerCase().trim();

    // Electricity providers
    if (company.contains('electric') ||
        company.contains('k-electric') ||
        company.contains('wapda') ||
        company.contains('lesco') ||
        company.contains('gepco') ||
        company.contains('fesco')) {
      return 'Electricity Bill';
    }
    // Gas providers
    else if (company.contains('gas') ||
        company.contains('sui') ||
        company.contains('sngpl') ||
        company.contains('ssgc')) {
      return 'Gas Bill';
    }
    // Mobile/Telecom providers
    else if (company.contains('jazz') ||
        company.contains('telenor') ||
        company.contains('zong') ||
        company.contains('ufone') ||
        company.contains('mobilink') ||
        company.contains('warid')) {
      return 'Mobile Recharge';
    }
    // Internet/Broadband providers
    else if (company.contains('ptcl') ||
        company.contains('internet') ||
        company.contains('wifi') ||
        company.contains('broadband') ||
        company.contains('nayatel') ||
        company.contains('stormfiber')) {
      return 'Internet Bill';
    }
    // Entertainment
    else if (company.contains('cinema') ||
        company.contains('movie') ||
        company.contains('netflix') ||
        company.contains('entertainment')) {
      return 'Entertainment';
    }
    // Transportation
    else if (company.contains('train') ||
        company.contains('railway') ||
        company.contains('pakistan railways')) {
      return 'Train Ticket';
    }
    else if (company.contains('bus') ||
        company.contains('transport') ||
        company.contains('daewoo') ||
        company.contains('niazi')) {
      return 'Bus Ticket';
    }
    else if (company.contains('flight') ||
        company.contains('airline') ||
        company.contains('pia') ||
        company.contains('serene') ||
        company.contains('airblue')) {
      return 'Flight Ticket';
    }
    else if (company.contains('car') ||
        company.contains('rental') ||
        company.contains('uber') ||
        company.contains('careem')) {
      return 'Transportation';
    }
    else {
      return 'Bill Payment';
    }
  }

  // Enhanced notification message with complete company information
  String _buildDetailedNotificationMessage(PayBillModel bill, String billType, String companyName) {
    final double originalAmount = (bill.amount ?? 0.0) - (bill.feeAmount ?? 0.0);
    final double taxAmount = bill.feeAmount ?? 0.0;
    final double totalAmount = bill.amount ?? 0.0;
    final String currency = bill.currency ?? 'USD';
    final String billNumber = bill.billNumber ?? 'N/A';
    final DateTime paymentTime = DateTime.now();

    return '''$billType payment completed successfully!

 Company: $companyName
 Account/Bill Number: $billNumber
 Amount: $currency ${originalAmount.toStringAsFixed(2)}
 Tax: $currency ${taxAmount.toStringAsFixed(2)}
 Total Paid: $currency ${totalAmount.toStringAsFixed(2)}
 Payment completed at ${paymentTime.toString().substring(0, 19)}
 Transaction ID: ${bill.id}

Thank you for using our service for your $companyName payment!''';
  }
}