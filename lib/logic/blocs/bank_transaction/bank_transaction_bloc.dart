import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../data/models/notification/notification_model.dart';
import '../../../data/models/recipient/recipient_model.dart';
import '../../../data/models/transaction/transaction_model.dart';
import '../../../data/repositories/notification/notification_repository.dart';
import '../../../services/biometric_service.dart';
import '../../../services/notification_service.dart';
import 'bank_transaction_event.dart';
import 'bank_transaction_state.dart';

class BankTransactionBloc extends Bloc<BankTransactionEvent, BankTransactionState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final BiometricService _biometricService;
  final NotificationRepository _notificationRepository;
  final Uuid _uuid = const Uuid();

  BankTransactionBloc({
    required BiometricService biometricService,
    required NotificationRepository notificationRepository,
  })  : _biometricService = biometricService,
        _notificationRepository = notificationRepository,
        super(BankTransactionState.initial()) {

    // Bank selection events
    on<FetchBanks>(_onFetchBanks);
    on<BankSelected>(_onBankSelected);
    on<BankUnselected>(_onBankUnselected);


    // Bank details events
    on<BankDetailsSubmitted>(_onBankDetailsSubmitted);
    on<ValidateAccountNumber>(_onValidateAccountNumber);

    // Amount events
    on<BankTransferAmountChanged>(_onBankTransferAmountChanged);
    on<BankTransferAmountSet>(_onBankTransferAmountSet);

    // Transaction processing events
    on<ProcessBankTransfer>(_onProcessBankTransfer);
    on<BankTransferCompleted>(_onBankTransferCompleted);
    on<BankTransferFailed>(_onBankTransferFailed);

    // Fetch transaction events
    on<FetchBankTransactions>(_onFetchBankTransactions);
    on<FetchBankTransactionsByDate>(_onFetchBankTransactionsByDate);

    // Favorites events
    on<AddBankToFavorites>(_onAddBankToFavorites);
    on<RemoveBankFromFavorites>(_onRemoveBankFromFavorites);
    on<FetchFavoriteBanks>(_onFetchFavoriteBanks);

    // Reset events
    on<ResetBankTransaction>(_onResetBankTransaction);
    on<ClearBankTransactionError>(_onClearBankTransactionError);
  }

  Future<void> _onFetchBanks(FetchBanks event, Emitter<BankTransactionState> emit) async {
    try {
      emit(state.copyWith(isLoadingBanks: true, errorMessage: null));

      final QuerySnapshot snapshot = await _firestore
          .collection('banks')
          .orderBy('name')
          .get();

      final List<Bank> banks = snapshot.docs
          .map((doc) => Bank.fromFirestore(doc))
          .toList();

      emit(state.copyWith(
        availableBanks: banks,
        isLoadingBanks: false,
        status: BankTransactionStatus.initial,
      ));

    } catch (e) {
      print('Error fetching banks: $e');
      emit(state.copyWith(
        isLoadingBanks: false,
        errorMessage: 'Failed to load banks: ${e.toString()}',
      ));
    }
  }

  void _onBankSelected(
      BankSelected event,
      Emitter<BankTransactionState> emit,
      ) {
    print('Bank selected: ${event.bank?.name ?? "null"}'); // Debug

    if (event.bank == null) {
      // Unselect bank using the new clearSelectedBank flag
      emit(state.copyWith(
        clearSelectedBank: true,
        clearAccountNumber: true,
        clearPaymentPurpose: true,
        clearPhoneNumber: true,
        amount: 0.0,
        clearAmountError: true,
      ));
    } else {
      // Select bank
      emit(state.copyWith(selectedBank: event.bank));
    }
  }
  void _onBankDetailsSubmitted(BankDetailsSubmitted event, Emitter<BankTransactionState> emit) {
    print('Bank details submitted:');
    print('Bank: ${event.bank.name}');
    print('Account: ${event.accountNumber}');
    print('Purpose: ${event.paymentPurpose}');
    print('Phone: ${event.phoneNumber}');

    emit(state.copyWith(
      selectedBank: event.bank,
      accountNumber: event.accountNumber,
      paymentPurpose: event.paymentPurpose,
      phoneNumber: event.phoneNumber,
      status: BankTransactionStatus.detailsSubmitted,
      errorMessage: null,
    ));
  }

  Future<void> _onValidateAccountNumber(ValidateAccountNumber event, Emitter<BankTransactionState> emit) async {
    try {
      emit(state.copyWith(isValidatingAccount: true));

      // Simulate account validation with bank API
      await Future.delayed(const Duration(seconds: 2));

      // For demo purposes, validate account number format
      final bool isValid = _validateAccountNumberFormat(event.accountNumber);

      emit(state.copyWith(
        isValidatingAccount: false,
        isAccountValid: isValid,
      ));

    } catch (e) {
      emit(state.copyWith(
        isValidatingAccount: false,
        isAccountValid: false,
        errorMessage: 'Account validation failed: ${e.toString()}',
      ));
    }
  }

  void _onBankTransferAmountChanged(BankTransferAmountChanged event, Emitter<BankTransactionState> emit) {
    final String sanitized = event.rawAmount.replaceAll(RegExp(r'[^\d.]'), '');
    double amount = 0.0;
    String? error;

    if (sanitized.isEmpty) {
      amount = 0.0;
      error = null;
    } else {
      try {
        amount = double.parse(sanitized);
        error = _validateAmount(amount);
      } catch (_) {
        error = 'Please enter a valid amount';
      }
    }

    print('Bank transfer amount changed to: \$${amount.toStringAsFixed(2)}');
    emit(state.copyWith(
      amount: amount,
      amountError: error,
      status: amount > 0 && error == null ? BankTransactionStatus.amountSet : state.status,
    ));
  }

  void _onBankTransferAmountSet(BankTransferAmountSet event, Emitter<BankTransactionState> emit) {
    final error = _validateAmount(event.amount);

    emit(state.copyWith(
      amount: event.amount,
      amountError: error,
      status: error == null ? BankTransactionStatus.amountSet : state.status,
    ));
  }

  Future<void> _onProcessBankTransfer(ProcessBankTransfer event, Emitter<BankTransactionState> emit) async {
    try {
      print('Processing bank transfer...');
      print('Amount: \$${state.amount.toStringAsFixed(2)}');
      print('Bank: ${state.selectedBank?.name}');
      print('Account: ${state.accountNumber}');

      // Validate state
      if (!state.canProcessTransfer) {
        emit(state.copyWith(
          errorMessage: 'Please complete all required fields',
        ));
        return;
      }

      emit(state.copyWith(
        isProcessing: true,
        status: BankTransactionStatus.processing,
        errorMessage: null,
      ));

      // Check authentication
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated. Please log in again.');
      }

      // Biometric authentication
      await _performBiometricAuthentication(state.totalAmount, state.selectedBank!.name);

      // Create bank transfer transaction using existing TransactionModel structure
      final TransactionModel transaction = TransactionModel(
        id: '', // Will be set by Firestore
        userId: currentUser.uid,
        recipientId: 'bank_transfer', // Special ID for bank transfers
        recipientName: '${state.selectedBank!.name} - ${state.accountNumber}',
        cardId: 'bank_transfer', // Special ID for bank transfers
        amount: state.amount,
        fee: state.transactionFee,
        totalAmount: state.totalAmount,
        currency: 'USD',
        status: 'success',
        createdAt: DateTime.now(),
        note: 'Bank Transfer: ${state.paymentPurpose}',
      );

      // Save to existing transactions collection with bank transfer metadata
      final String transactionId = await _saveBankTransferToFirestore(transaction);

      // Create notification
      await _createSuccessNotification(transactionId);

      // Send local notification
      await _sendLocalNotifications(transactionId);

      add(BankTransferCompleted(transactionId));

    } catch (e) {
      print('Bank transfer failed: $e');
      add(BankTransferFailed(e.toString()));
    }
  }

  void _onBankTransferCompleted(BankTransferCompleted event, Emitter<BankTransactionState> emit) {
    print('Bank transfer completed successfully: ${event.transactionId}');
    emit(state.copyWith(
      isProcessing: false,
      isSuccess: true,
      status: BankTransactionStatus.success,
      transactionId: event.transactionId,
    ));
  }

  void _onBankTransferFailed(BankTransferFailed event, Emitter<BankTransactionState> emit) {
    print('Bank transfer failed: ${event.errorMessage}');

    // Create failure notification
    _createFailureNotification(event.errorMessage);

    emit(state.copyWith(
      isProcessing: false,
      isSuccess: false,
      status: BankTransactionStatus.failure,
      errorMessage: _getUserFriendlyErrorMessage(event.errorMessage),
    ));
  }

  Future<void> _onFetchBankTransactions(FetchBankTransactions event, Emitter<BankTransactionState> emit) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      final QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('transactions')
          .where('recipient_id', isEqualTo: 'bank_transfer')
          .orderBy('created_at', descending: true)
          .get();

      final List<TransactionModel> transactions = snapshot.docs
          .map((doc) => TransactionModel.fromDoc(doc))
          .toList();

      emit(state.copyWith(transactions: transactions));

    } catch (e) {
      print('Error fetching bank transactions: $e');
      emit(state.copyWith(
        errorMessage: 'Failed to load transactions: ${e.toString()}',
      ));
    }
  }

  Future<void> _onFetchBankTransactionsByDate(FetchBankTransactionsByDate event, Emitter<BankTransactionState> emit) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      final QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('transactions')
          .where('recipient_id', isEqualTo: 'bank_transfer')
          .where('created_at', isGreaterThanOrEqualTo: Timestamp.fromDate(event.startDate))
          .where('created_at', isLessThanOrEqualTo: Timestamp.fromDate(event.endDate))
          .orderBy('created_at', descending: true)
          .get();

      final List<TransactionModel> transactions = snapshot.docs
          .map((doc) => TransactionModel.fromDoc(doc))
          .toList();

      emit(state.copyWith(transactions: transactions));

    } catch (e) {
      print('Error fetching bank transactions by date: $e');
      emit(state.copyWith(
        errorMessage: 'Failed to load transactions: ${e.toString()}',
      ));
    }
  }

  void _onBankUnselected(
      BankUnselected event,
      Emitter<BankTransactionState> emit,
      ) {
    print('Bank unselected event received'); // Debug

    emit(state.copyWith(
      clearSelectedBank: true,
      clearAccountNumber: true,
      clearPaymentPurpose: true,
      clearPhoneNumber: true,
      amount: 0.0,
      clearAmountError: true,
    ));
  }
  
  Future<void> _onAddBankToFavorites(AddBankToFavorites event, Emitter<BankTransactionState> emit) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      final favoriteBank = FavoriteBank(
        id: _uuid.v4(),
        bank: event.bank,
        accountNumber: event.accountNumber,
        recipientName: event.recipientName,
        addedAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('favorite_banks')
          .doc(favoriteBank.id)
          .set(favoriteBank.toJson());

      // Update local state
      final updatedFavorites = List<FavoriteBank>.from(state.favoriteBanks)
        ..add(favoriteBank);

      emit(state.copyWith(favoriteBanks: updatedFavorites));

    } catch (e) {
      print('Error adding bank to favorites: $e');
      emit(state.copyWith(
        errorMessage: 'Failed to add bank to favorites: ${e.toString()}',
      ));
    }
  }

  Future<void> _onRemoveBankFromFavorites(RemoveBankFromFavorites event, Emitter<BankTransactionState> emit) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('favorite_banks')
          .doc(event.favoriteId)
          .delete();

      // Update local state
      final updatedFavorites = state.favoriteBanks
          .where((favorite) => favorite.id != event.favoriteId)
          .toList();

      emit(state.copyWith(favoriteBanks: updatedFavorites));

    } catch (e) {
      print('Error removing bank from favorites: $e');
      emit(state.copyWith(
        errorMessage: 'Failed to remove bank from favorites: ${e.toString()}',
      ));
    }
  }

  Future<void> _onFetchFavoriteBanks(FetchFavoriteBanks event, Emitter<BankTransactionState> emit) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      final QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('favorite_banks')
          .orderBy('addedAt', descending: true)
          .get();

      final List<FavoriteBank> favoriteBanks = snapshot.docs
          .map((doc) => FavoriteBank.fromJson({...doc.data() as Map<String, dynamic>, 'id': doc.id}))
          .toList();

      emit(state.copyWith(favoriteBanks: favoriteBanks));

    } catch (e) {
      print('Error fetching favorite banks: $e');
      emit(state.copyWith(
        errorMessage: 'Failed to load favorite banks: ${e.toString()}',
      ));
    }
  }

  void _onResetBankTransaction(ResetBankTransaction event, Emitter<BankTransactionState> emit) {
    print('Resetting bank transaction state');
    emit(BankTransactionState.initial());
  }

  void _onClearBankTransactionError(ClearBankTransactionError event, Emitter<BankTransactionState> emit) {
    emit(state.copyWith(errorMessage: null));
  }

  // Helper methods
  String? _validateAmount(double amount) {
    if (amount <= 0) return 'Please enter a valid amount';
    if (amount < 1.0) return 'Minimum transfer amount is \$1';
    if (amount > 50000) return 'Amount exceeds maximum limit of \$50,000';
    return null;
  }

  bool _validateAccountNumberFormat(String accountNumber) {
    return accountNumber.length >= 10 &&
        accountNumber.length <= 20 &&
        RegExp(r'^[0-9]+$').hasMatch(accountNumber);
  }

  Future<void> _performBiometricAuthentication(double amount, String bankName) async {
    print('Starting biometric authentication...');

    final isBioAvailable = await _biometricService.isBiometricAvailable();
    final hasBiometrics = await _biometricService.hasBiometricsEnrolled();

    if (isBioAvailable && hasBiometrics) {
      final auth = await _biometricService.authenticate(
        reason: 'Authenticate to transfer \$${amount.toStringAsFixed(2)} to $bankName',
      );

      if (!(auth['success'] == true)) {
        throw Exception('Authentication failed: ${auth['error']}');
      }
      print('Biometric authentication successful');
    } else {
      print('Biometric authentication not available');
    }
  }

  String _generateTransactionReference() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'BT${timestamp.toString().substring(8)}';
  }

  Future<String> _saveBankTransferToFirestore(TransactionModel transaction) async {
    print('Saving bank transfer to existing transactions collection...');

    final currentUser = FirebaseAuth.instance.currentUser!;

    // Create transaction data using the model's toMap method
    final Map<String, dynamic> transactionData = transaction.toMap();

    // Add bank transfer metadata using snake_case to match your existing structure
    transactionData.addAll({
      'transaction_type': 'bank_transfer',
      'bank_transfer_details': {
        'bank_id': state.selectedBank!.id,
        'bank_name': state.selectedBank!.name,
        'bank_code': state.selectedBank!.code,
        'branch_name': state.selectedBank!.branchName,
        'branch_code': state.selectedBank!.branchCode,
        'account_number': state.accountNumber,
        'payment_purpose': state.paymentPurpose,
        'recipient_phone': state.phoneNumber,
        'transaction_reference': _generateTransactionReference(),
      },
    });

    final DocumentReference docRef = await _firestore
        .collection('users')
        .doc(currentUser.uid)
        .collection('transactions')
        .add(transactionData);

    print('Bank transfer saved to transactions collection with ID: ${docRef.id}');
    return docRef.id;
  }

  Future<void> _createSuccessNotification(String transactionId) async {
    try {
      final notification = NotificationModel(
        title: 'Bank Transfer Successful',
        message: 'Successfully transferred \$${state.amount.toStringAsFixed(2)} to ${state.selectedBank!.name}',
        type: 'bank_transfer',
        isRead: false,
        createdAt: DateTime.now(),
        data: {
          'transactionId': transactionId,
          'bankName': state.selectedBank!.name,
          'accountNumber': state.accountNumber,
          'amount': state.amount,
          'fee': state.transactionFee,
          'totalAmount': state.totalAmount,
          'transactionType': 'bank_transfer',
          'status': 'success',
        },
      );

      await _notificationRepository.addNotification(notification);
      print('Success notification created');

    } catch (e) {
      print('Failed to create success notification: $e');
    }
  }

  Future<void> _createFailureNotification(String errorMessage) async {
    try {
      final notification = NotificationModel(
        title: 'Bank Transfer Failed',
        message: 'Your bank transfer could not be processed',
        type: 'bank_transfer',
        isRead: false,
        createdAt: DateTime.now(),
        data: {
          'transactionType': 'bank_transfer',
          'status': 'failed',
          'errorMessage': errorMessage,
        },
      );

      await _notificationRepository.addNotification(notification);
      print('Failure notification created');

    } catch (e) {
      print('Failed to create failure notification: $e');
    }
  }

  Future<void> _sendLocalNotifications(String transactionId) async {
    try {
      // Send local notification
      await LocalNotificationService.showCustomNotification(
        title: 'Bank Transfer Successful!',
        body: 'You transferred \$${state.amount.toStringAsFixed(2)} to ${state.selectedBank!.name}',
        payload: 'bank_transaction_$transactionId',
      );

      // Send transaction notification
      await LocalNotificationService.showTransactionNotification(
        transactionType: 'bank_transfer',
        amount: state.totalAmount,
        currency: '\$',
      );

      print('Local notifications sent successfully');

    } catch (e) {
      print('Failed to send local notifications: $e');
    }
  }

  String _getUserFriendlyErrorMessage(String error) {
    if (error.contains('permission')) {
      return 'Permission denied. Please check your account settings.';
    } else if (error.contains('network') || error.contains('connection')) {
      return 'Network error. Please check your internet connection.';
    } else if (error.contains('authenticated')) {
      return 'Authentication error. Please log in again.';
    } else if (error.contains('insufficient')) {
      return 'Insufficient funds. Please check your balance.';
    } else {
      return 'Transfer failed. Please try again later.';
    }
  }
}