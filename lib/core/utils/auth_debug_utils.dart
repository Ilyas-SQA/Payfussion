// Debug utilities for authentication issues
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthDebugUtils {
  static void logAuthError(dynamic error) {
    if (kDebugMode) {
      print('🔴 Auth Error Details:');
      print('Error type: ${error.runtimeType}');
      print('Error message: $error');

      if (error is FirebaseAuthException) {
        print('Firebase Auth Error Code: ${error.code}');
        print('Firebase Auth Error Message: ${error.message}');
        print('Firebase Auth Error Details: ${error.toString()}');
      }
    }
  }

  static void logAuthSuccess(User? user) {
    if (kDebugMode && user != null) {
      print('✅ Auth Success:');
      print('User ID: ${user.uid}');
      print('Email: ${user.email}');
      print('Email Verified: ${user.emailVerified}');
      print('Display Name: ${user.displayName}');
    }
  }

  static void logAuthAttempt(String email) {
    if (kDebugMode) {
      print('🔑 Auth Attempt:');
      print('Email: $email');
      print('Timestamp: ${DateTime.now()}');
    }
  }

  /// Test if Firebase Auth is properly initialized
  static Future<bool> testFirebaseAuth() async {
    try {
      final FirebaseAuth auth = FirebaseAuth.instance;
      final User? currentUser = auth.currentUser;

      if (kDebugMode) {
        print('🔧 Firebase Auth Test:');
        print('Auth instance: ${auth.toString()}');
        print('Current user: ${currentUser?.uid ?? "No user"}');
        print('Auth state changes stream: ${auth.authStateChanges()}');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Firebase Auth Test Failed: $e');
      }
      return false;
    }
  }

  /// Create a test user for debugging
  static Future<void> createTestUser() async {
    if (kDebugMode) {
      try {
        const String testEmail = 'test@payfussion.app';
        const String testPassword = 'Test123456!';

        print('🧪 Creating test user...');

        final UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
              email: testEmail,
              password: testPassword,
            );

        print('✅ Test user created: ${userCredential.user?.uid}');

        // Send verification email
        await userCredential.user?.sendEmailVerification();
        print('📧 Verification email sent');
      } catch (e) {
        print('❌ Test user creation failed: $e');
      }
    }
  }
}
