import 'dart:io';

import 'package:equatable/equatable.dart';

import '../../../data/models/recipient/recipient_model.dart' show Bank;

enum SubmitStatus { idle, submitting, success, failure }
enum VerifyStatus { idle, verifying, verified, failed }
enum RecipientsStatus { loading, success, failure }

abstract class AddRecipientEvent extends Equatable {
  const AddRecipientEvent();
  @override
  List<Object?> get props => <Object?>[];
}

// Bank-related events
class LoadBanksRequested extends AddRecipientEvent {}
class BankStreamRequested extends AddRecipientEvent {}

class AddNewBankEvent extends AddRecipientEvent {
  final Map<String, String> bankData;
  const AddNewBankEvent(this.bankData);

  @override
  List<Object?> get props => <Object?>[bankData];
}

class BankSearchChanged extends AddRecipientEvent {
  final String query;
  const BankSearchChanged(this.query);
  @override
  List<Object?> get props => <Object?>[query];
}

// Form events
class NameChanged extends AddRecipientEvent {
  final String name;
  const NameChanged(this.name);
  @override
  List<Object?> get props => <Object?>[name];
}

class BankChanged extends AddRecipientEvent {
  final Bank? bank;
  const BankChanged(this.bank);
  @override
  List<Object?> get props => <Object?>[bank];
}

class AccountNumberChanged extends AddRecipientEvent {
  final String account;
  const AccountNumberChanged(this.account);
  @override
  List<Object?> get props => <Object?>[account];
}

class PickImageRequested extends AddRecipientEvent {
  final File file;
  const PickImageRequested(this.file);
  @override
  List<Object?> get props => <Object?>[file];
}

class RemovePhotoRequested extends AddRecipientEvent {}

class VerifyAccountRequested extends AddRecipientEvent {}

class SubmitPressed extends AddRecipientEvent {
  final bool addAnother;
  const SubmitPressed({this.addAnother = false});
  @override
  List<Object?> get props => <Object?>[addAnother];
}

/// Recipients (list/search)
class RecipientsSubscriptionRequested extends AddRecipientEvent {}
class RecipientsSearchChanged extends AddRecipientEvent {
  final String query;
  const RecipientsSearchChanged(this.query);
  @override
  List<Object?> get props => <Object?>[query];
}