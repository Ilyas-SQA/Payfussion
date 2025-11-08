// Updated lib/logic/blocs/setting/state.dart
import 'package:equatable/equatable.dart';

class SettingsState extends Equatable {
  const SettingsState({
    required this.linkedAccounts,
    required this.security,
    required this.currencyCode,
    required this.transactionPrivacyMode,
    required this.isTwoFactorEnabled,
    this.errorMessage = '',
    this.successMessage = '', /// Add success message for positive feedback
    this.biometricSupported = false, /// Add biometric support flag
    this.biometricAuthSuccess = false, /// Add for login authentication
    this.isLoading = false, /// Add loading state for biometric operations
  });

  final Map<String, bool> linkedAccounts;
  final Map<String, bool> security;
  final String currencyCode;
  final String transactionPrivacyMode;
  final bool isTwoFactorEnabled;
  final String errorMessage;
  final String successMessage; // Add this line
  final bool biometricSupported; // Add this line
  final bool biometricAuthSuccess; // Add this line
  final bool isLoading; // Add this line

  SettingsState copyWith({
    Map<String, bool>? linkedAccounts,
    Map<String, bool>? security,
    String? currencyCode,
    String? transactionPrivacyMode,
    bool? isTwoFactorEnabled,
    String? errorMessage,
    String? successMessage, // Add this parameter
    bool? biometricSupported, // Add this parameter
    bool? biometricAuthSuccess, // Add this parameter
    bool? isLoading, // Add this parameter
  }) =>
      SettingsState(
        linkedAccounts: linkedAccounts ?? this.linkedAccounts,
        security: security ?? this.security,
        currencyCode: currencyCode ?? this.currencyCode,
        transactionPrivacyMode: transactionPrivacyMode ?? this.transactionPrivacyMode,
        isTwoFactorEnabled: isTwoFactorEnabled ?? this.isTwoFactorEnabled,
        errorMessage: errorMessage ?? this.errorMessage,
        successMessage: successMessage ?? this.successMessage, // Add this line
        biometricSupported: biometricSupported ?? this.biometricSupported, // Add this line
        biometricAuthSuccess: biometricAuthSuccess ?? this.biometricAuthSuccess, // Add this line
        isLoading: isLoading ?? this.isLoading, // Add this line
      );

  @override
  List<Object?> get props => <Object?>[
    linkedAccounts,
    security,
    currencyCode,
    transactionPrivacyMode,
    errorMessage,
    successMessage, // Add this
    biometricSupported, // Add this
    biometricAuthSuccess, // Add this
    isLoading,
    isTwoFactorEnabled,
  ];

  factory SettingsState.initial() => const SettingsState(
    linkedAccounts: <String, bool>{
      'cityBank': true,
      'paypal': false,
      'fingerprint': false, // This will be updated based on user preference
      '2fa': false,
      'lock': false,
    },
    security: <String, bool>{
      'fingerprint': false, // Initially false, will be loaded from preferences
      '2fa': true,
      'lock': true,
    },
    currencyCode: 'USD',
    transactionPrivacyMode: 'Public',
    errorMessage: '',
    successMessage: '', // Add this line
    biometricSupported: false, // Add this line
    biometricAuthSuccess: false, // Add this line
    isLoading: false,
    isTwoFactorEnabled: false,
  );

  // Convenience methods for cleaner code
  bool get isFingerprintEnabled => security['fingerprint'] ?? false;
  bool get canUseBiometric => biometricSupported && isFingerprintEnabled;

  // Method to clear messages (useful for resetting state)
  SettingsState clearMessages() => copyWith(
    errorMessage: '',
    successMessage: '',
    biometricAuthSuccess: false,
  );
}