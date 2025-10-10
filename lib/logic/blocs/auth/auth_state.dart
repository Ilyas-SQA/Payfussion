import 'package:local_auth/local_auth.dart';

// Abstract base class
abstract class AuthState {
  const AuthState();
}

// Initial state when no action has been taken
class AuthInitial extends AuthState {
  const AuthInitial() : super();
}

// Loading state for actions like updating the profile or changing the name
class AuthLoading extends AuthState {
  const AuthLoading() : super();
}

// Success states for actions
class SignInSuccess extends AuthState {
  final bool shouldEnableBiometric;
  const SignInSuccess({this.shouldEnableBiometric = false}) : super();
}

class SignUpSuccess extends AuthState {
  const SignUpSuccess() : super();
}

// Biometric states
class BiometricSetupInProgress extends AuthState {
  const BiometricSetupInProgress() : super();
}

class BiometricAuthSuccess extends AuthState {
  const BiometricAuthSuccess() : super();
}

class BiometricEnabled extends AuthState {
  const BiometricEnabled() : super();
}

class BiometricDisabled extends AuthState {
  const BiometricDisabled() : super();
}

class AuthSuccess extends AuthState {
  const AuthSuccess() : super();
}

class ForgotFailure extends AuthState {
  final String message;
  ForgotFailure(this.message);
}

class ForgotSuccess extends AuthState {}

class ForgotLoading extends AuthState {}

// Failure states, for example, errors when updating the profile or name
class AuthStateFailure extends AuthState {
  final String message;
  AuthStateFailure(this.message);
}

// Biometric states
class BiometricCheckInProgress extends AuthState {}

class BiometricAvailable extends AuthState {
  final List<BiometricType> availableBiometrics;
  BiometricAvailable(this.availableBiometrics);
}

class BiometricAuthFailure extends AuthState {
  final String message;
  BiometricAuthFailure(this.message);
}

// For enabling/disabling biometric authentication settings
class EnableBiometricState extends AuthState {
  final bool isEnabled;
  EnableBiometricState(this.isEnabled);
}

class BiometricSetupNeeded extends AuthState {}

class BiometricSetupSuccess extends AuthState {}

class LogoutSuccess extends AuthState {}

class BiometricNotAvailable extends AuthState {
  BiometricNotAvailable();
}

class TwoFactorVerificationRequired extends AuthState {
  final String userId;
  TwoFactorVerificationRequired(this.userId);
}

class OtpInitial extends AuthState {}

class OtpLoading extends AuthState {}

class OtpSent extends AuthState {
  final String verificationId;
  final String message;
  OtpSent({required this.verificationId, required this.message});
}

class OtpVerified extends AuthState {
  final String message;
  OtpVerified({required this.message});
}

class OtpError extends AuthState {
  final String error;
  OtpError({required this.error});
}

