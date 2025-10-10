// ../../../logic/blocs/setting/user_profile/change_password/bloc.dart
import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:payfussion/domain/repository/auth/auth_repository.dart';
import 'package:payfussion/logic/blocs/setting/change-password/change_pasword_state.dart';

import '../../../../services/service_locator.dart';
import '../../../../services/session_manager_service.dart';
import 'change_pasword_event.dart';

enum PasswordStrength { weak, medium, strong } // Simplified for this example

PasswordStrength _checkPasswordStrength(String password) {
  final hasUppercase = password.contains(RegExp(r'[A-Z]'));
  final hasLowercase = password.contains(RegExp(r'[a-z]'));
  final hasDigit = password.contains(RegExp(r'\d'));
  final hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
  final hasMinLength = password.length >= 8;

  if (hasUppercase &&
      hasLowercase &&
      hasDigit &&
      hasSpecialChar &&
      hasMinLength) {
    return PasswordStrength.strong;
  } else if ((hasLowercase || hasUppercase) && hasDigit && hasMinLength) {
    return PasswordStrength.medium;
  } else {
    return PasswordStrength.weak;
  }
}

class ChangePasswordBloc
    extends Bloc<ChangePasswordEvent, ChangePasswordState> {
  final AuthRepository _authRepository;
  final sessionController = getIt<SessionController>();
  ChangePasswordBloc(this._authRepository)
    : super(const ChangePasswordState()) {
    on<PasswordFieldsChangedEvent>(_onPasswordFieldsChanged);
    on<SubmitChangePasswordEvent>(_onSubmitChangePassword);
    on<ClearPasswordMismatchErrorEvent>(_onClearPasswordMismatchError);
  }

  // Future<void> _handleLogout(
  //   Logout event,
  //   Emitter<ChangePasswordState> emit,
  // ) async {
  //   emit(state.copyWith(isLoading: true, isLogout: false));
  //   final result = await _authRepository.signOut();
  //   if (result.isLeft()) {
  //     final failure = result.fold((f) => f, (_) => null);
  //     emit(
  //       state.copyWith(
  //         isLoading: false,
  //         isLogout: true,
  //         errorMessage: "Logout failed: ${failure?.message ?? 'Unknown error'}",
  //       ),
  //     );
  //     return;
  //   }
  //   await sessionController.clearUserPreference();
  //   emit(state.copyWith(isLogout: true, isLoading: false));
  // }

  void _onPasswordFieldsChanged(
    PasswordFieldsChangedEvent event,
    Emitter<ChangePasswordState> emit,
  ) {
    final mismatchError =
        event.newPassword.isNotEmpty &&
        event.confirmNewPassword.isNotEmpty &&
        event.newPassword != event.confirmNewPassword;

    // You can also add immediate strength check here if desired
    // If you want to track password strength, add passwordStrengthStatus to state

    emit(
      state.copyWith(
        passwordsDoNotMatchError: mismatchError,
        isSuccess: false, // Reset success status
        clearErrorMessage: true, // Clear general errors when fields change
      ),
    );
  }

  void _onClearPasswordMismatchError(
    ClearPasswordMismatchErrorEvent event,
    Emitter<ChangePasswordState> emit,
  ) {
    emit(state.copyWith(passwordsDoNotMatchError: false));
  }

  Future<void> _onSubmitChangePassword(
    SubmitChangePasswordEvent event,
    Emitter<ChangePasswordState> emit,
  ) async {
    // Basic frontend validation (can be more extensive)
    if (event.oldPassword.isEmpty || event.newPassword.isEmpty) {
      emit(
        state.copyWith(
          errorMessage: 'Please fill all required fields.',
          isSuccess: false,
        ),
      );
      return;
    }

    if (state.passwordsDoNotMatchError) {
      emit(
        state.copyWith(
          errorMessage: 'Passwords do not match.',
          isSuccess: false,
        ),
      );
      return;
    }

    final passwordStrength = _checkPasswordStrength(event.newPassword);
    if (passwordStrength != PasswordStrength.strong) {
      emit(
        state.copyWith(
          errorMessage:
              'Password must be at least 8 characters, include uppercase, lowercase, digit, and special character.',
          isSuccess: false,
          passwordStrengthStatus: PasswordStrengthStatus.invalid,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        isLoading: true,
        isSuccess: false,
        clearErrorMessage: true,
      ),
    );

    final result = await _authRepository.changePassword(
      newPassword: event.newPassword,
      oldPassword: event.oldPassword,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          isLoading: false,
          isSuccess: false,
          errorMessage: failure.message,
        ),
      ),
      (_) => emit(
        state.copyWith(isLoading: false, isSuccess: true, errorMessage: ''),
      ),
    );
  }
}
