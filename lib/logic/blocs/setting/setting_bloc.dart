import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:payfussion/logic/blocs/setting/setting_state.dart';

import '../../../services/biometric_service.dart';
import '../../../services/service_locator.dart';
import '../../../services/session_manager_service.dart';
import 'setting_event.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final BiometricService biometricService = getIt<BiometricService>();
  final SessionController sessionController = SessionController();


  SettingsBloc() : super(SettingsState.initial()) {

    // Added inside constructor block
    on<SecurityOptionToggled>((e, emit) {
      final updated = Map<String, bool>.from(state.security)..[e.optionKey] = e.enabled;
      emit(state.copyWith(security: updated, errorMessage: ''));
    });

    on<CurrencyChanged>((e, emit) {
      emit(state.copyWith(currencyCode: e.currencyCode, errorMessage: ''));
    });

    on<TransactionPrivacyModeChanged>((e, emit) {
      emit(state.copyWith(transactionPrivacyMode: e.mode, errorMessage: ''));
    });

    // Add this to initialize biometric settings
    on<InitializeSettings>((event, emit) async {
      final isBiometricEnabled = await biometricService.isBiometricEnabled();
      final updatedSecurity = Map<String, bool>.from(state.security);
      updatedSecurity['fingerprint'] = isBiometricEnabled;
      emit(state.copyWith(security: updatedSecurity, errorMessage: ''));
    });
    on<LinkedAccountToggled>(_onLinkedAccountToggled);
    on<LoadBiometricSettings>(_onLoadBiometricSettings);
    on<AuthenticateWithBiometric>(_onAuthenticateWithBiometric);
    on<LoadTwoFactorStatus>(_onLoadStatus);
    on<UpdateTwoFactorStatus>(_onUpdateStatus);
  }


  Future<void> _onLoadStatus(LoadTwoFactorStatus event, Emitter<SettingsState> emit) async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(SessionController.user.uid).get();
    final status = doc.data()?['twoStepAuthentication'] ?? false;
    emit(state.copyWith(isTwoFactorEnabled: status));
  }

  Future<void> _onUpdateStatus(UpdateTwoFactorStatus event, Emitter<SettingsState> emit) async {
    emit(state.copyWith(isLoading: true));
    await FirebaseFirestore.instance.collection('users').doc(SessionController.user.uid).update({
      'twoStepAuthentication': event.value,
    });
    emit(state.copyWith(isTwoFactorEnabled: event.value, isLoading: false));
  }


  Future<void> _onLinkedAccountToggled(LinkedAccountToggled event, Emitter<SettingsState> emit,) async {
    if (event.accountId == 'fingerprint') {
      /// Special handling for fingerprint toggle
      final isAvailable = await biometricService.isBiometricAvailable();
      print('Biometric available: $isAvailable'); // Debug log

      if (!isAvailable && event.enabled) {
        /// Can't enable if biometrics aren't available
        emit(
          state.copyWith(
            errorMessage:
            'Biometric authentication is not available on this device',
          ),
        );
        return;
      }

      if (event.enabled) {
        final hasBiometrics = await biometricService.hasBiometricsEnrolled();
        print('Has biometrics enrolled: $hasBiometrics'); // Debug log

        if (!hasBiometrics) {
          emit(
            state.copyWith(
              errorMessage:
              'No biometrics enrolled on this device. Please set up fingerprint/face in device settings.',
            ),
          );
          return;
        }

        /// Verify identity before enabling
        final result = await biometricService.authenticate(
          reason: 'Verify your identity to enable fingerprint login',
        );

        print('Authentication result: $result'); // Debug log

        if (result['success']) {
          await biometricService.setBiometricEnabled(true);
          await sessionController.saveBiometric(true);

          final updatedSecurity = Map<String, bool>.from(state.security);
          updatedSecurity['fingerprint'] = true;

          emit(state.copyWith(
            security: updatedSecurity,
            errorMessage: '',
            successMessage: 'Fingerprint login enabled successfully!',
          ));
        } else {
          emit(state.copyWith(errorMessage: result['error']));
        }
      } else {
        /// Just disable without verification
        await biometricService.setBiometricEnabled(false);
        await sessionController.saveBiometric(false);

        final updatedSecurity = Map<String, bool>.from(state.security);
        updatedSecurity['fingerprint'] = false;

        emit(state.copyWith(
          security: updatedSecurity,
          errorMessage: '',
          successMessage: 'Fingerprint login disabled',
        ));
      }
    } else {
      /// Handle other account toggles normally
      final updatedAccounts = Map<String, bool>.from(state.linkedAccounts);
      updatedAccounts[event.accountId] = event.enabled;
      emit(state.copyWith(linkedAccounts: updatedAccounts, errorMessage: ''));
    }
  }

  Future<void> _onLoadBiometricSettings(LoadBiometricSettings event, Emitter<SettingsState> emit,) async {
    try {
      final bool enabled = await sessionController.getBiometric();
      final bool supported = await biometricService.isBiometricAvailable();

      final updatedSecurity = Map<String, bool>.from(state.security);
      updatedSecurity['fingerprint'] = enabled;

      emit(state.copyWith(
        security: updatedSecurity,
        biometricSupported: supported,
        errorMessage: '',
      ));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Failed to load biometric settings: $e',
      ));
    }
  }

  Future<void> _onAuthenticateWithBiometric(AuthenticateWithBiometric event, Emitter<SettingsState> emit,) async {
    final bool isEnabled = await sessionController.getBiometric();
    if (!isEnabled) {
      emit(state.copyWith(
        errorMessage: 'Biometric authentication is not enabled',
      ));
      return;
    }

    final result = await biometricService.authenticate(
      reason: 'Please authenticate to access the app',
    );

    if (result['success']) {
      emit(state.copyWith(
        biometricAuthSuccess: true,
        errorMessage: '',
      ));
    } else {
      emit(state.copyWith(
        errorMessage: result['error'],
      ));
    }
  }

}
