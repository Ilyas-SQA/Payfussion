import 'package:equatable/equatable.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();
  @override
  List<Object?> get props => [];
}

class LinkedAccountToggled extends SettingsEvent {
  final String accountId;
  final bool enabled;

  const LinkedAccountToggled({
    required this.accountId,
    required this.enabled,
  });

  @override
  List<Object?> get props => [accountId, enabled];
}

class LoadBiometricSettings extends SettingsEvent {
  const LoadBiometricSettings();
}

class AuthenticateWithBiometric extends SettingsEvent {
  const AuthenticateWithBiometric();
}

class SecurityOptionToggled extends SettingsEvent {
  const SecurityOptionToggled({required this.optionKey, required this.enabled});
  final String optionKey; // e.g. "fingerprint", "2fa", "lock"
  final bool enabled;

  @override
  List<Object?> get props => [optionKey, enabled];
}

/// dropdown / selector events
class CurrencyChanged extends SettingsEvent {
  const CurrencyChanged(this.currencyCode);
  final String currencyCode;

  @override
  List<Object?> get props => [currencyCode];
}

class TransactionPrivacyModeChanged extends SettingsEvent {
  final String mode;

  const TransactionPrivacyModeChanged(this.mode);

  @override
  List<Object?> get props => [mode];
}

class InitializeSettings extends SettingsEvent {
  const InitializeSettings();
}

class LoadTwoFactorStatus extends SettingsEvent {}

class UpdateTwoFactorStatus extends SettingsEvent {
  final bool value;
  UpdateTwoFactorStatus(this.value);
}