import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:payfussion/data/models/recipient/recipient_model.dart';
import 'package:payfussion/logic/blocs/recipient/recipient_event.dart';
import 'package:payfussion/logic/blocs/recipient/recipient_state.dart';

import '../../../data/repositories/recipient/recipient_repository.dart';

class RecipientBloc extends Bloc<AddRecipientEvent, AddRecipientState> {
  final RecipientRepositoryFB _repo;
  final String userId;

  StreamSubscription<List<RecipientModel>>? _recipientsSub;
  StreamSubscription<List<Bank>>? _banksSub;

  RecipientBloc({
    required RecipientRepositoryFB repo,
    required this.userId,
  })  : _repo = repo,
        super(const AddRecipientState(banksLoading: true)) {

    // Form events
    on<LoadBanksRequested>(_onLoadBanks);
    on<BankStreamRequested>(_onBankStream);
    on<AddNewBankEvent>(_onAddNewBank);
    on<BankSearchChanged>(_onBankSearchChanged);
    on<NameChanged>(_onNameChanged);
    on<BankChanged>(_onBankChanged);
    on<AccountNumberChanged>(_onAccountChanged);
    on<PickImageRequested>(_onPickImage);
    on<RemovePhotoRequested>(_onRemovePhoto);
    on<VerifyAccountRequested>(_onVerify);
    on<SubmitPressed>(_onSubmit);

    // Recipients events
    on<RecipientsSubscriptionRequested>(_onRecipientsSubscribe);
    on<RecipientsSearchChanged>(_onRecipientsSearch);

    // Start streams
    add(BankStreamRequested());
    add(RecipientsSubscriptionRequested());
  }

  String _formatAccount(String value) {
    final String digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return '';

    final StringBuffer sb = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) sb.write(' ');
      sb.write(digits[i]);
    }
    return sb.toString();
  }

  void _validateAll(Emitter<AddRecipientState> emit, {AddRecipientState? s}) {
    final AddRecipientState st = s ?? state;
    String? nameErr;
    String? bankErr;
    String? accErr;

    // Name validation
    final String trimmedName = st.name.trim();
    if (trimmedName.isEmpty) {
      nameErr = 'Name is required';
    } else if (trimmedName.length < 2) {
      nameErr = 'Name must be at least 2 characters';
    } else if (trimmedName.length > 50) {
      nameErr = 'Name cannot exceed 50 characters';
    } else if (!RegExp(r'^[a-zA-Z\s\.]+$').hasMatch(trimmedName)) {
      nameErr = 'Name can only contain letters, spaces and dots';
    }

    // Bank validation
    if (st.selectedBank == null) {
      bankErr = 'Please select a bank';
    }

    // Account validation
    final String rawAccount = st.accountNumber.replaceAll(' ', '');
    if (rawAccount.isEmpty) {
      accErr = 'Account number is required';
    } else if (rawAccount.length < 8) {
      accErr = 'Account number must be at least 8 digits';
    } else if (rawAccount.length > 20) {
      accErr = 'Account number cannot exceed 20 digits';
    } else if (!RegExp(r'^\d+$').hasMatch(rawAccount)) {
      accErr = 'Account number must contain only digits';
    }

    emit(st.copyWith(
        nameError: nameErr,
        bankError: bankErr,
        accountError: accErr
    ));
  }

  // Legacy method - kept for backward compatibility
  Future<void> _onLoadBanks(
      LoadBanksRequested event,
      Emitter<AddRecipientState> emit,
      ) async {
    emit(state.copyWith(banksLoading: true));

    try {
      final List<Bank> banks = await _repo.getBanks();
      print('✅ Loaded ${banks.length} banks');

      // Print first bank details for debugging
      if (banks.isNotEmpty) {
        final Bank firstBank = banks.first;
        print('First bank: ${firstBank.name}');
        print('First bank image: ${firstBank.image}');
      }

      emit(state.copyWith(
        banks: banks,
        banksLoading: false,
        filteredBanks: banks,
        errorMessage: null,
      ));
    } catch (e) {
      print('❌ Error loading banks: $e');
      emit(state.copyWith(
          banks: <Bank>[],
          filteredBanks: <Bank>[],
          banksLoading: false,
          errorMessage: 'Failed to load banks. Please check your connection.'
      ));
    }
  }

  // Stream banks from Firestore
  Future<void> _onBankStream(
      BankStreamRequested event,
      Emitter<AddRecipientState> emit,
      ) async {
    emit(state.copyWith(banksLoading: true));

    await emit.forEach<List<Bank>>(
      _repo.streamBanks(),
      onData: (List<Bank> banks) {
        print('🔄 Banks stream updated: ${banks.length} banks');

        // Debug: Print first bank
        if (banks.isNotEmpty) {
          print('First bank from stream: ${banks.first.name}');
          print('First bank image from stream: ${banks.first.image}');
        }

        // Apply current search filter to new bank list
        final List<Bank> filteredBanks = _filterBanks(banks, state.bankSearchQuery);

        return state.copyWith(
          banks: banks,
          filteredBanks: filteredBanks,
          banksLoading: false,
          errorMessage: null,
        );
      },
      onError: (Object error, StackTrace stackTrace) {
        print('❌ Banks stream error: $error');
        print('Stack trace: $stackTrace');
        return state.copyWith(
          banksLoading: false,
          errorMessage: 'Failed to load banks. Please check your connection.',
        );
      },
    );
  }

  // Add new bank
  Future<void> _onAddNewBank(
      AddNewBankEvent event,
      Emitter<AddRecipientState> emit,
      ) async {
    emit(state.copyWith(isAddingBank: true, errorMessage: null));

    try {
      final Map<String, String> bankData = event.bankData;
      print('Adding new bank: ${bankData['name']}');

      final Bank newBank = await _repo.addNewBankWithDetails(bankData);

      print('✅ Bank added successfully: ${newBank.name}');

      emit(state.copyWith(
        isAddingBank: false,
        errorMessage: 'Bank "${newBank.name}" added successfully!',
        selectedBank: newBank,
      ));
    } catch (e) {
      print('❌ Error adding bank: $e');
      String errorMsg = 'Failed to add bank. Please try again.';

      if (e.toString().contains('already exists')) {
        errorMsg = e.toString().replaceAll('Exception: ', '');
      }

      emit(state.copyWith(
        isAddingBank: false,
        errorMessage: errorMsg,
      ));
    }
  }

  // Bank search
  void _onBankSearchChanged(
      BankSearchChanged event,
      Emitter<AddRecipientState> emit,
      ) {
    final List<Bank> filteredBanks = _filterBanks(state.banks, event.query);

    print('🔍 Bank search: "${event.query}" - Found ${filteredBanks.length} results');

    emit(state.copyWith(
      bankSearchQuery: event.query,
      filteredBanks: filteredBanks,
    ));
  }

  // Helper method to filter banks
  List<Bank> _filterBanks(List<Bank> banks, String query) {
    if (query.trim().isEmpty) return banks;

    final String lowercaseQuery = query.toLowerCase().trim();
    return banks.where((Bank bank) =>
    bank.name.toLowerCase().contains(lowercaseQuery) ||
        bank.code.toLowerCase().contains(lowercaseQuery)
    ).toList();
  }

  void _onNameChanged(NameChanged e, Emitter<AddRecipientState> emit) {
    final AddRecipientState s = state.copyWith(name: e.name, errorMessage: null);
    emit(s);
    _validateAll(emit, s: s);
  }

  void _onBankChanged(BankChanged e, Emitter<AddRecipientState> emit) {
    print('Bank changed to: ${e.bank!.name}');

    final AddRecipientState s = state.copyWith(
      selectedBank: e.bank,
      verifyStatus: VerifyStatus.idle,
      duplicateFound: false,
      accountError: null,
      errorMessage: null,
    );
    emit(s);
    _validateAll(emit, s: s);
  }

  void _onAccountChanged(AccountNumberChanged e, Emitter<AddRecipientState> emit) {
    final String formatted = _formatAccount(e.account);
    final AddRecipientState s = state.copyWith(
      accountNumber: formatted,
      verifyStatus: VerifyStatus.idle,
      duplicateFound: false,
      accountError: null,
      errorMessage: null,
    );
    emit(s);
    _validateAll(emit, s: s);
  }

  void _onPickImage(PickImageRequested e, Emitter<AddRecipientState> emit) {
    emit(state.copyWith(imageFile: e.file));
  }

  void _onRemovePhoto(RemovePhotoRequested e, Emitter<AddRecipientState> emit) {
    emit(state.copyWith(imageFile: null));
  }

  Future<void> _onVerify(
      VerifyAccountRequested e,
      Emitter<AddRecipientState> emit,
      ) async {
    _validateAll(emit);
    if (!state.isFormValid) {
      emit(state.copyWith(
          verifyStatus: VerifyStatus.failed,
          errorMessage: 'Please fix form errors before verification'
      ));
      return;
    }

    emit(state.copyWith(
      verifyStatus: VerifyStatus.verifying,
      accountError: null,
      errorMessage: null,
      duplicateFound: false,
    ));

    try {
      final String rawAccount = state.accountNumber.replaceAll(' ', '');
      final String bankName = state.selectedBank!.name;

      print('🔍 Verifying: $rawAccount for bank: $bankName');

      final bool isDuplicate = await _repo.isRecipientExist(
        userId: userId,
        bankName: bankName,
        accountNumber: rawAccount,
      );

      if (isDuplicate) {
        print('⚠️ Duplicate recipient found');
        emit(state.copyWith(
          verifyStatus: VerifyStatus.failed,
          duplicateFound: true,
          accountError: 'This recipient already exists in your list',
        ));
        return;
      }

      final bool isValid = await _repo.verifyAccountNumber(rawAccount);

      if (isValid) {
        print('✅ Account verified successfully');
        emit(state.copyWith(
          verifyStatus: VerifyStatus.verified,
          accountError: null,
          errorMessage: 'Account verified successfully!',
        ));
      } else {
        print('❌ Invalid account number');
        emit(state.copyWith(
          verifyStatus: VerifyStatus.failed,
          accountError: 'Invalid account number for selected bank',
        ));
      }

    } on TimeoutException {
      print('⏱️ Verification timeout');
      emit(state.copyWith(
        verifyStatus: VerifyStatus.failed,
        accountError: 'Verification timeout. Please try again.',
      ));
    } catch (e) {
      print('❌ Verification error: $e');
      emit(state.copyWith(
        verifyStatus: VerifyStatus.failed,
        accountError: 'Verification failed. Please check your connection.',
      ));
    }
  }

  Future<void> _onSubmit(
      SubmitPressed e,
      Emitter<AddRecipientState> emit,
      ) async {
    _validateAll(emit);
    if (!state.isFormValid) {
      emit(state.copyWith(
          errorMessage: 'Please fix all form errors before submitting'
      ));
      return;
    }

    if (state.verifyStatus != VerifyStatus.verified) {
      await _onVerify(VerifyAccountRequested(), emit);
      if (state.verifyStatus != VerifyStatus.verified) {
        return;
      }
    }

    emit(state.copyWith(
        submitStatus: SubmitStatus.submitting,
        errorMessage: null
    ));

    try {
      await _repo.addRecipient(
        userId: userId,
        name: state.name.trim(),
        bankName: state.selectedBank!.name,
        accountNumber: state.accountNumber.replaceAll(' ', ''),
        imageFile: state.imageFile,
      );

      print('✅ Recipient added successfully');

      emit(state.copyWith(
          submitStatus: SubmitStatus.success,
          errorMessage: 'Recipient added successfully!'
      ));

      if (e.addAnother) {
        await Future.delayed(const Duration(milliseconds: 500));
        emit(AddRecipientState(
          banks: state.banks,
          filteredBanks: state.filteredBanks,
          banksLoading: false,
          bankSearchQuery: state.bankSearchQuery,
          recipientsStatus: state.recipientsStatus,
          allRecipients: state.allRecipients,
          filteredRecipients: state.filteredRecipients,
          searchQuery: state.searchQuery,
          submitStatus: SubmitStatus.idle,
        ));
      }
    } catch (e) {
      print('❌ Submit error: $e');
      emit(state.copyWith(
        submitStatus: SubmitStatus.failure,
        errorMessage: 'Failed to add recipient. Please try again.',
      ));
    }
  }

  Future<void> _onRecipientsSubscribe(
      RecipientsSubscriptionRequested event,
      Emitter<AddRecipientState> emit,
      ) async {
    emit(state.copyWith(recipientsStatus: RecipientsStatus.loading));

    await emit.forEach<List<RecipientModel>>(
      _repo.streamRecipients(userId: userId),
      onData: (List<RecipientModel> items) {
        print('🔄 Recipients updated: ${items.length} recipients');

        final String q = state.searchQuery.trim().toLowerCase();
        final List<RecipientModel> filtered = q.isEmpty
            ? items
            : items.where((RecipientModel r) =>
            r.name.toLowerCase().contains(q)).toList();

        return state.copyWith(
          recipientsStatus: RecipientsStatus.success,
          allRecipients: items,
          filteredRecipients: filtered,
        );
      },
      onError: (Object error, StackTrace stackTrace) {
        print('❌ Recipients stream error: $error');
        return state.copyWith(
            recipientsStatus: RecipientsStatus.failure,
            errorMessage: 'Failed to load recipients'
        );
      },
    );
  }

  void _onRecipientsSearch(
      RecipientsSearchChanged event,
      Emitter<AddRecipientState> emit,
      ) {
    final String q = event.query.trim().toLowerCase();
    final List<RecipientModel> filtered = q.isEmpty
        ? state.allRecipients
        : state.allRecipients
        .where((RecipientModel r) => r.name.toLowerCase().contains(q))
        .toList();

    emit(state.copyWith(
      searchQuery: event.query,
      filteredRecipients: filtered,
    ));
  }

  @override
  Future<void> close() async {
    await _recipientsSub?.cancel();
    await _banksSub?.cancel();
    return super.close();
  }
}