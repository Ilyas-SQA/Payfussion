import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:payfussion/logic/blocs/recipient/recipient_event.dart';

import '../../../data/models/recipient/recipient_model.dart';

class AddRecipientState extends Equatable {
  // Form
  final String name;
  final Bank? selectedBank;
  final String accountNumber;
  final File? imageFile;

  // Validation
  final String? nameError;
  final String? bankError;
  final String? accountError;

  // Status
  final VerifyStatus verifyStatus;
  final SubmitStatus submitStatus;
  final String? errorMessage;

  // Banks (updated for Firebase)
  final List<Bank> banks;
  final List<Bank> filteredBanks; // New: filtered banks for search
  final bool banksLoading;
  final bool isAddingBank; // New: for add bank loading state
  final String bankSearchQuery; // New: current search query

  // Duplicate flag
  final bool duplicateFound;

  // Recipients list (NON-nullable lists)
  final RecipientsStatus recipientsStatus;
  final List<RecipientModel> allRecipients;
  final List<RecipientModel> filteredRecipients;
  final String searchQuery;

  const AddRecipientState({
    this.name = '',
    this.selectedBank,
    this.accountNumber = '',
    this.imageFile,
    this.nameError,
    this.bankError,
    this.accountError,
    this.verifyStatus = VerifyStatus.idle,
    this.submitStatus = SubmitStatus.idle,
    this.errorMessage,
    this.banks = const <Bank>[],
    this.filteredBanks = const <Bank>[],
    this.banksLoading = false,
    this.isAddingBank = false,
    this.bankSearchQuery = '',
    this.duplicateFound = false,
    this.recipientsStatus = RecipientsStatus.loading,
    this.allRecipients = const <RecipientModel>[],
    this.filteredRecipients = const <RecipientModel>[],
    this.searchQuery = '',
  });

  bool get isFormValid =>
      (nameError == null && name.isNotEmpty) &&
          (bankError == null && selectedBank != null) &&
          (accountError == null && accountNumber.replaceAll(' ', '').isNotEmpty);

  AddRecipientState copyWith({
    String? name,
    Bank? selectedBank,
    String? accountNumber,
    File? imageFile,
    String? nameError,
    String? bankError,
    String? accountError,
    VerifyStatus? verifyStatus,
    SubmitStatus? submitStatus,
    String? errorMessage,
    List<Bank>? banks,
    List<Bank>? filteredBanks,
    bool? banksLoading,
    bool? isAddingBank,
    String? bankSearchQuery,
    bool? duplicateFound,
    RecipientsStatus? recipientsStatus,
    List<RecipientModel>? allRecipients,
    List<RecipientModel>? filteredRecipients,
    String? searchQuery,
  }) {
    return AddRecipientState(
      name: name ?? this.name,
      selectedBank: selectedBank ?? this.selectedBank,
      accountNumber: accountNumber ?? this.accountNumber,
      imageFile: imageFile ?? this.imageFile,
      nameError: nameError,
      bankError: bankError,
      accountError: accountError,
      verifyStatus: verifyStatus ?? this.verifyStatus,
      submitStatus: submitStatus ?? this.submitStatus,
      errorMessage: errorMessage,
      banks: banks ?? this.banks,
      filteredBanks: filteredBanks ?? this.filteredBanks,
      banksLoading: banksLoading ?? this.banksLoading,
      isAddingBank: isAddingBank ?? this.isAddingBank,
      bankSearchQuery: bankSearchQuery ?? this.bankSearchQuery,
      duplicateFound: duplicateFound ?? this.duplicateFound,
      recipientsStatus: recipientsStatus ?? this.recipientsStatus,
      allRecipients: allRecipients ?? this.allRecipients,
      filteredRecipients: filteredRecipients ?? this.filteredRecipients,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    name,
    selectedBank,
    accountNumber,
    imageFile,
    nameError,
    bankError,
    accountError,
    verifyStatus,
    submitStatus,
    errorMessage,
    banks,
    filteredBanks,
    banksLoading,
    isAddingBank,
    bankSearchQuery,
    duplicateFound,
    recipientsStatus,
    allRecipients,
    filteredRecipients,
    searchQuery,
  ];
}