// auth_bloc.dart
import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_auth_platform_interface/types/biometric_type.dart';
import 'package:payfussion/core/exceptions/failure.dart';
import 'package:payfussion/data/models/user/user_model.dart';
import 'package:payfussion/domain/repository/auth/auth_repository.dart';

import '../../../data/models/device_manager/deevice_manager_model.dart';
import '../../../services/biometric_service.dart';
import '../../../services/session_manager_service.dart';
import '../setting/device_manager/device_manager_bloc.dart';
import '../setting/device_manager/device_manager_event.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SessionController sessionController;
  final BiometricService biometricService;
  final AuthRepository authRepository;
  final DeviceBloc deviceBloc;
  String? _verificationId;

  AuthBloc({
    required this.sessionController,
    required this.biometricService,
    required this.authRepository,
    required this.deviceBloc,
  }) : super(const AuthInitial()) {
    on<SignUpRequested>(_handleSignUp);
    on<SignInRequested>(_handleSignIn);
    on<ForgotPasswordWithEmail>(_handleForgotPasswordWithEmail);
    on<CheckBiometricAvailability>(_handleCheckBiometricAvailability);
    on<EnableBiometriCheckbox>(_handEnableCheckBox);
    on<LoginWithBiometric>(_handleBiometricSignIn);
    on<SendOtpEvent>(_onSendOtp);
    on<VerifyOtpEvent>(_onVerifyOtp);
    on<ResendOtpEvent>(_onResendOtp);
    on<Logout>(_handleLogout); // Added logout handler
  }

  /// Centralized error handler
  void _emitError(Emitter<AuthState> emit, String message) {
    emit(AuthStateFailure(message));
  }

  /// Centralized loading handler
  void _emitLoading(Emitter<AuthState> emit) {
    emit(const AuthLoading());
  }

  Future<void> _handleSignUp(SignUpRequested event, Emitter<AuthState> emit) async {
    _emitLoading(emit);

    try {
      final Either<Failure, Unit> result = await authRepository.signUp(
        email: event.email,
        password: event.password,
        firstName: event.firstName,
        lastName: event.lastName,
        phoneNumber: event.phoneNumber,
      );

      result.fold(
            (Failure failure) => _emitError(emit, failure.message),
            (_) => emit(const SignUpSuccess()),
      );
    } catch (e) {
      _emitError(emit, "An unexpected error occurred: ${e.toString()}");
    }
  }

  Future<void> _handleSignIn(SignInRequested event, Emitter<AuthState> emit) async {
    _emitLoading(emit);
    try {
      final Either<Failure, UserModel> result = await authRepository.signInWithEmail(
        event.email,
        event.password,
      );

      await result.fold(
            (Failure failure) async => _emitError(emit, failure.message),
            (UserModel user) async {
          try {
            // Save user data locally
            await sessionController.saveUserInPreference(user);
            await sessionController.getUserFromPreference();

            /// Check Two-Factor Authentication
            if (SessionController.user.twoStepAuthentication == true) {
              emit(TwoFactorVerificationRequired(SessionController.user.uid ?? ""));
              return; /// Stop further execution
            }

            /// If 2FA is not required, continue normal flow
            deviceBloc.add(AddOrUpdateDevice(
              DeviceModel(
                deviceId: "",
                model: "",
                os: "",
                osVersion: "",
                manufacturer: "",
                lastLogin: DateTime.now(),
                isActive: true,
              ),
            ));

            /// Handle biometric setup if requested
            if (event.enableBiometric) {
              final bool isAvailable = await biometricService.isBiometricAvailable();
              final bool isEnrolled = await biometricService.hasBiometricsEnrolled();

              if (isAvailable && isEnrolled) {
                emit(const BiometricSetupInProgress());

                final Map<String, dynamic> biometricResult = await biometricService.authenticate(
                  reason: 'Scan your fingerprint to enable biometric login',
                );

                if (biometricResult['success']) {
                  await biometricService.setBiometricEnabled(true);
                  emit(const SignInSuccess(shouldEnableBiometric: true));
                } else {
                  emit(const SignInSuccess(shouldEnableBiometric: false));
                  _emitError(
                    emit,
                    "Biometric setup failed: ${biometricResult['error']}",
                  );
                }
              } else {
                emit(const SignInSuccess(shouldEnableBiometric: false));
                _emitError(
                  emit,
                  "Biometric authentication is not available on this device",
                );
              }
            } else {
              emit(const SignInSuccess(shouldEnableBiometric: false));
            }
          } catch (e) {
            _emitError(emit, "Failed to complete sign in: ${e.toString()}");
          }
        },
      );
    } catch (e) {
      _emitError(emit, "An unexpected error occurred: ${e.toString()}");
    }
  }

  Future<void> _handleForgotPasswordWithEmail(ForgotPasswordWithEmail event, Emitter<AuthState> emit) async {
    _emitLoading(emit);
    try {
      final Either<Failure, Unit> result = await authRepository.forgotPassworWithEmail(event.email);
      await result.fold(
            (Failure failure) async => _emitError(emit, failure.message),
            (_) async => emit(ForgotSuccess()),
      );
    } catch (e) {
      _emitError(emit, "Failed to send reset email: ${e.toString()}");
    }
  }

  Future<void> _handEnableCheckBox(EnableBiometriCheckbox event, Emitter<AuthState> emit) async {
    emit(EnableBiometricState(event.isEnabled));
  }

  Future<void> _handleCheckBiometricAvailability(CheckBiometricAvailability event, Emitter<AuthState> emit) async {
    _emitLoading(emit);
    try {
      final bool isAvailable = await biometricService.isBiometricAvailable();
      if (isAvailable) {
        final List<BiometricType> biometrics = await biometricService.getAvailableBiometrics();
        emit(BiometricAvailable(biometrics));
      } else {
        emit(BiometricNotAvailable());
      }
    } catch (e) {
      _emitError(emit, "Failed to check biometric availability: ${e.toString()}");
    }
  }

  Future<void> _handleBiometricSignIn(LoginWithBiometric event, Emitter<AuthState> emit) async {
    _emitLoading(emit);
    try {
      // First check if biometric is available and enrolled
      final bool isAvailable = await biometricService.isBiometricAvailable();
      final bool isEnrolled = await biometricService.hasBiometricsEnrolled();

      if (!isAvailable || !isEnrolled) {
        _emitError(emit, "Biometric authentication is not available on this device.");
        return;
      }

      // Check if biometric is enabled in app (from local storage)
      final bool isBiometricEnabled = await biometricService.isBiometricEnabled();
      if (!isBiometricEnabled) {
        _emitError(emit, "Biometric login not enabled. Please sign in with email and password first.");
        return;
      }

      // Retrieve the user data from local storage
      final UserModel? user = await sessionController.getUserFromPreference();
      if (user == null) {
        _emitError(emit, "No user data found. Please sign in first.");
        return;
      }

      // Proceed with biometric authentication
      final Map<String, dynamic> biometricResult = await biometricService.authenticate(
        reason: "Please authenticate to sign in",
      );

      if (!biometricResult['success']) {
        _emitError(emit, biometricResult['error'] ?? "Biometric authentication failed");
        return;
      }

      emit(const BiometricAuthSuccess());
    } catch (e) {
      _emitError(emit, "An unexpected error occurred: ${e.toString()}");
    }
  }

  Future<void> _onSendOtp(SendOtpEvent event, Emitter<AuthState> emit) async {
    try {
      emit(OtpLoading());

      // Format phone number properly for Pakistan
      String formattedPhone = event.phoneNumber;
      if (!formattedPhone.startsWith('+')) {
        if (formattedPhone.startsWith('0')) {
          formattedPhone = '+92${formattedPhone.substring(1)}';
        } else {
          formattedPhone = '+92$formattedPhone';
        }
      }

      /// Create a Completer to handle the async callbacks
      final Completer<void> completer = Completer<void>();

      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: formattedPhone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          try {
            /// Check if emitter is still active before emitting
            if (!emit.isDone) {
              await FirebaseAuth.instance.signInWithCredential(credential);
              emit(OtpVerified(message: "Phone number verified automatically!"));
            }
            if (!completer.isCompleted) completer.complete();
          } catch (e) {
            if (!emit.isDone) {
              emit(OtpError(error: "Auto-verification failed: ${e.toString()}"));
            }
            if (!completer.isCompleted) completer.completeError(e);
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          String errorMessage;
          switch (e.code) {
            case 'invalid-phone-number':
              errorMessage = 'Invalid phone number format';
              break;
            case 'too-many-requests':
              errorMessage = 'Too many requests. Please try again later';
              break;
            case 'quota-exceeded':
              errorMessage = 'SMS quota exceeded. Try again tomorrow';
              break;
            default:
              errorMessage = e.message ?? 'Verification failed';
          }

          if (!emit.isDone) {
            emit(OtpError(error: errorMessage));
          }
          if (!completer.isCompleted) completer.complete();
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          if (!emit.isDone) {
            emit(OtpSent(
              verificationId: verificationId,
              message: "OTP sent successfully to $formattedPhone",
            ));
          }
          if (!completer.isCompleted) completer.complete();
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
          /// This doesn't necessarily complete the process
        },
        timeout: const Duration(seconds: 60),
      );

      /// Wait for one of the callbacks to complete
      await completer.future.timeout(
        const Duration(seconds: 65), /// Slightly longer than Firebase timeout
        onTimeout: () {
          if (!emit.isDone) {
            emit(OtpError(error: "Request timed out. Please try again."));
          }
        },
      );
    } catch (e) {
      if (!emit.isDone) {
        emit(OtpError(error: "Failed to send OTP: ${e.toString()}"));
      }
    }
  }

  Future<void> _onVerifyOtp(VerifyOtpEvent event, Emitter<AuthState> emit) async {
    try {
      emit(OtpLoading());

      final PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: event.verificationId,
        smsCode: event.otp,
      );

      final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

      /// Check if emitter is still active before emitting
      if (!emit.isDone) {
        emit(OtpVerified(message: "OTP verified successfully!"));

        // Save user data after successful OTP verification
        // You might want to update your session here
        // await sessionController.saveUserInPreference(userCredential.user);
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'invalid-verification-code':
          errorMessage = 'Invalid OTP. Please check and try again';
          break;
        case 'session-expired':
          errorMessage = 'OTP expired. Please request a new one';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many failed attempts. Try again later';
          break;
        default:
          errorMessage = 'Invalid OTP. Please try again';
      }

      if (!emit.isDone) {
        emit(OtpError(error: errorMessage));
      }
    } catch (e) {
      if (!emit.isDone) {
        emit(OtpError(error: "Verification failed: ${e.toString()}"));
      }
    }
  }

  Future<void> _onResendOtp(ResendOtpEvent event, Emitter<AuthState> emit) async {
    // Clear the previous verification ID
    _verificationId = null;

    // Resend OTP by calling the send OTP method
    await _onSendOtp(SendOtpEvent(phoneNumber: event.phoneNumber), emit);
  }

  // Added logout handler
  Future<void> _handleLogout(Logout event, Emitter<AuthState> emit) async {
    try {
      _emitLoading(emit);

      // Sign out from Firebase
      await FirebaseAuth.instance.signOut();

      // Clear local session data
      await sessionController.clearUserPreference();

      // Disable biometric if enabled
      await biometricService.setBiometricEnabled(false);

      emit(LogoutSuccess());
    } catch (e) {
      _emitError(emit, "Logout failed: ${e.toString()}");
    }
  }

  // Helper methods
  String? get verificationId => _verificationId;
  bool get isAuthenticated => FirebaseAuth.instance.currentUser != null;
  User? get currentUser => FirebaseAuth.instance.currentUser;
}