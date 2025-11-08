// 1. Updated BiometricService with proper imports
import 'package:local_auth/local_auth.dart';
import 'package:payfussion/services/service_locator.dart';

import 'local_storage.dart';

class BiometricService {
  final LocalAuthentication _localAuth = LocalAuthentication();
  final LocalStorage _localDb = getIt<LocalStorage>();

  static const String _biometricEnabledKey = 'biometric_enabled';

  /// Check if biometric authentication is available on device
  Future<bool> isBiometricAvailable() async {
    try {
      final bool isAvailable = await _localAuth.canCheckBiometrics;
      final bool isDeviceSupported = await _localAuth.isDeviceSupported();
      return isAvailable && isDeviceSupported;
    } catch (e) {
      print('Error checking biometric availability: $e');
      return false;
    }
  }

  /// Check if user has enrolled biometrics on device
  Future<bool> hasBiometricsEnrolled() async {
    try {
      final List<BiometricType> availableBiometrics =
      await _localAuth.getAvailableBiometrics();
      return availableBiometrics.isNotEmpty;
    } catch (e) {
      print('Error checking enrolled biometrics: $e');
      return false;
    }
  }

  /// Get available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      print('Error getting available biometrics: $e');
      return <BiometricType>[];
    }
  }

  /// Authenticate user with biometrics
  Future<Map<String, dynamic>> authenticate({
    required String reason,
    bool biometricOnly = true,
  }) async {
    try {
      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: reason,
        options: AuthenticationOptions(
          biometricOnly: biometricOnly,
          stickyAuth: true,
        ),
      );

      if (didAuthenticate) {
        return <String, dynamic>{'success': true, 'error': ''};
      } else {
        return <String, dynamic>{'success': false, 'error': 'Authentication failed'};
      }
    } catch (e) {
      String errorMessage = 'Authentication error occurred';

      // Handle specific error types
      if (e.toString().contains('NotAvailable')) {
        errorMessage = 'Biometric authentication not available';
      } else if (e.toString().contains('NotEnrolled')) {
        errorMessage = 'No biometrics enrolled on this device';
      } else if (e.toString().contains('LockedOut')) {
        errorMessage = 'Too many failed attempts. Try again later';
      } else if (e.toString().contains('PermanentlyLockedOut')) {
        errorMessage = 'Biometric authentication permanently locked';
      }

      print('Biometric authentication error: $e');
      return <String, dynamic>{'success': false, 'error': errorMessage};
    }
  }

  /// Save biometric enabled preference
  Future<void> setBiometricEnabled(bool enabled) async {
    await _localDb.setValue(_biometricEnabledKey, enabled.toString());
  }

  /// Get biometric enabled preference
  Future<bool> isBiometricEnabled() async {
    final String? value = await _localDb.readValue(_biometricEnabledKey);
    return value == 'true';
  }

  /// Get biometric type name for UI display
  Future<String> getBiometricTypeName() async {
    try {
      final List<BiometricType> types = await getAvailableBiometrics();

      if (types.contains(BiometricType.face)) {
        return 'Face ID';
      } else if (types.contains(BiometricType.fingerprint)) {
        return 'Fingerprint';
      } else if (types.contains(BiometricType.iris)) {
        return 'Iris';
      } else if (types.contains(BiometricType.strong) ||
          types.contains(BiometricType.weak)) {
        return 'Biometric';
      }
      return 'Biometric';
    } catch (e) {
      return 'Biometric';
    }
  }
}
