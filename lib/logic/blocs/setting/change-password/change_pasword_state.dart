import 'package:equatable/equatable.dart';

enum PasswordStrengthStatus {
  initial,
  weak,
  medium,
  strong,
  invalid,
} // For more detailed strength

class ChangePasswordState extends Equatable {
  final bool isLoading;
  final bool isSuccess;
  final String? errorMessage; // For general errors (e.g., from API)
  final bool passwordsDoNotMatchError;
  final PasswordStrengthStatus
  passwordStrengthStatus; // To reflect strength or general validity
  final bool isLogout;

  const ChangePasswordState({
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMessage,
    this.passwordsDoNotMatchError = false,
    this.passwordStrengthStatus = PasswordStrengthStatus.initial,
    this.isLogout = false,
  });

  ChangePasswordState copyWith({
    bool? isLoading,
    bool? isSuccess,
    bool? isLogout,
    String? errorMessage,
    bool? passwordsDoNotMatchError,
    PasswordStrengthStatus? passwordStrengthStatus,
    bool clearErrorMessage = false, // Helper to nullify error message
  }) {
    return ChangePasswordState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
      passwordsDoNotMatchError:
          passwordsDoNotMatchError ?? this.passwordsDoNotMatchError,
      passwordStrengthStatus:
          passwordStrengthStatus ?? this.passwordStrengthStatus,
      isLogout: isLogout ?? this.isLogout,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    isSuccess,
    errorMessage,
    passwordsDoNotMatchError,
    passwordStrengthStatus,
    isLogout,
  ];
}
