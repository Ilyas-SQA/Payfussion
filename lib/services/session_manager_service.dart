import 'dart:convert';

import 'package:flutter/material.dart';

import '../../data/models/user/user_model.dart';
import 'local_storage.dart';
import 'service_locator.dart';

class SessionController {
  final _localDb = getIt<LocalStorage>();

  /// Flag indicating whether the user is logged in or not.
  static bool? isBiometric = false;

  /// Model representing the user data.
  static UserModel user = UserModel();

  Future<void> saveUserInPreference(dynamic user) async {
    await _localDb.setValue('userData', jsonEncode(user));
    // Don't automatically enable biometric here
    await _localDb.setValue('isLoggedIn', 'true');
  }

  Future<void> saveBiometric(bool isBiometric) async {
    await _localDb.setValue('isBiometric', isBiometric.toString());
    SessionController.isBiometric = isBiometric;
  }

  Future<bool> getBiometric() async {
    final String? value = await _localDb.readValue('isBiometric');
    final bool isEnabled = value == 'true';
    SessionController.isBiometric = isEnabled;
    return isEnabled;
  }

  Future<UserModel?> getUserFromPreference() async {
    try {
      var userData = await _localDb.readValue('userData');
      var isBiometric = await _localDb.readValue('isBiometric');

      if (userData != null && userData.isNotEmpty) {
        SessionController.user = UserModel.fromJson(jsonDecode(userData));
        SessionController.isBiometric = isBiometric == 'true';

        print('User data retrieved successfully: ${SessionController.user.toJson()}');
        print('Is biometric enabled: $isBiometric');
        return SessionController.user;
      } else {
        print("No user data found.");
        return null;
      }
    } catch (e) {
      debugPrint("Error reading user data: ${e.toString()}");
      return null;
    }
  }

  Future<void> clearUserPreference() async {
    await _localDb.clearValue('userData');
    await _localDb.clearValue('isLoggedIn');
    SessionController.user = UserModel();
  }

  Future<void> logout() async {
    await clearUserPreference();
    // Keep biometric preference on logout
  }

  Future<void> completeLogout() async {
    await clearUserPreference();
    await _localDb.clearValue('isBiometric');
    SessionController.isBiometric = false;
  }

  Future<bool> isLoggedIn() async {
    final String? value = await _localDb.readValue('isLoggedIn');
    return value == 'true';
  }
}
