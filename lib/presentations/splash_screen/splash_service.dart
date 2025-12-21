import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/routes_name.dart';
import '../../logic/blocs/auth/auth_bloc.dart';
import '../../logic/blocs/auth/auth_event.dart';
import '../../services/session_manager_service.dart';
import '../../services/biometric_service.dart';
import '../../services/service_locator.dart';

/// A class containing services related to the splash screen.
class SplashServices {
  final BiometricService _biometricService = getIt<BiometricService>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void checkAuthentication(BuildContext context) async {
    final User? auth = FirebaseAuth.instance.currentUser;

    Timer(const Duration(seconds: 3), () async {
      if (auth != null) {
        // Reload user to get latest email verification status
        await auth.reload();
        final User? updatedUser = FirebaseAuth.instance.currentUser;

        // ✅ CHECK 1: Email Verified?
        if (updatedUser?.emailVerified != true) {
          // Email not verified, redirect to verification screen
          if (context.mounted) {
            context.go(
              RouteNames.emailVerification,
              extra: {
                'email': updatedUser?.email ?? '',
                'uid': updatedUser?.uid ?? '',
              },
            );
          }
          return;
        }

        // ✅ CHECK 2-4: Firestore validations
        try {
          final userDoc = await _firestore.collection('users').doc(auth.uid).get();

          // Check if document exists
          if (!userDoc.exists) {
            await FirebaseAuth.instance.signOut();
            if (context.mounted) {
              _showErrorDialog(
                context,
                'Account Error',
                'User data not found. Please sign in again.',
                RouteNames.signIn,
              );
            }
            return;
          }

          final userData = userDoc.data()!;

          // Check if account is suspended
          if (userData['suspendAccount'] == true) {
            await FirebaseAuth.instance.signOut();
            if (context.mounted) {
              _showErrorDialog(
                context,
                'Account Suspended',
                'Your account has been suspended. Please contact support at support@payfussion.com',
                RouteNames.signIn,
              );
            }
            return;
          }

          // Check if account is verified by admin
          if (userData['accountVerified'] == false) {
            await FirebaseAuth.instance.signOut();
            if (context.mounted) {
              _showErrorDialog(
                context,
                'Pending Approval',
                'Your account is pending admin approval. Please wait for verification.',
                RouteNames.signIn,
              );
            }
            return;
          }

          // Update email verified status in Firestore if needed
          if (userData['isEmailVerified'] != true) {
            await _firestore.collection('users').doc(auth.uid).update({
              'isEmailVerified': true,
              'updateAt': FieldValue.serverTimestamp(),
            });
          }

        } catch (e) {
          print('Error checking user status: $e');
          await FirebaseAuth.instance.signOut();
          if (context.mounted) {
            _showErrorDialog(
              context,
              'Error',
              'An error occurred. Please sign in again.',
              RouteNames.signIn,
            );
          }
          return;
        }

        // ✅ All checks passed - Continue with normal flow

        /// User session retrieve karo
        await SessionController().getUserFromPreference();

        /// Check karo ke user ne biometric enable kiya hai ya nahi
        final bool isBiometricEnabled = await SessionController().getBiometric();

        if (isBiometricEnabled) {
          /// Biometric enabled hai, to authenticate karo
          await _performBiometricAuthentication(context);
        } else {
          /// Biometric enabled nahi hai, directly home screen par jao
          if (context.mounted) {
            context.go(RouteNames.bottomNavigationBarScreen);
          }
        }
      } else {
        /// Firebase user nahi hai, sign in screen par jao
        if (context.mounted) {
          context.go(RouteNames.signIn);
        }
      }
    });
  }

  void _showErrorDialog(
      BuildContext context,
      String title,
      String message,
      String route,
      ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.go(route);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performBiometricAuthentication(BuildContext context) async {
    try {
      /// Check karo device par biometric available hai ya nahi
      final bool isAvailable = await _biometricService.isBiometricAvailable();
      final bool hasEnrolled = await _biometricService.hasBiometricsEnrolled();

      if (!isAvailable || !hasEnrolled) {
        /// Biometric available nahi hai, sign in par bhej do
        if (context.mounted) {
          _showBiometricUnavailableDialog(context);
        }
        return;
      }

      /// Biometric authentication perform karo
      final Map<String, dynamic> result = await _biometricService.authenticate(
        reason: 'Please authenticate to access your account',
        biometricOnly: true,
      );

      if (context.mounted) {
        if (result['success'] == true) {
          /// Authentication successful
          context.go(RouteNames.bottomNavigationBarScreen);
        } else {
          /// Authentication failed
          _showAuthenticationFailedDialog(context, result['error'] ?? 'Authentication failed');
        }
      }
    } catch (e) {
      print('Biometric authentication error: $e');
      if (context.mounted) {
        _showAuthenticationErrorDialog(context);
      }
    }
  }

  void _showBiometricUnavailableDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Biometric Unavailable'),
          content: const Text(
            'Biometric authentication is not available or not set up on this device. Please sign in with your credentials.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.go(RouteNames.signIn);
              },
              child: const Text('Sign In'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                /// Disable biometric and go to home
                await SessionController().saveBiometric(false);
                if (context.mounted) {
                  context.go(RouteNames.bottomNavigationBarScreen);
                }
              },
              child: const Text('Continue Without Biometric'),
            ),
          ],
        );
      },
    );
  }

  void _showAuthenticationFailedDialog(BuildContext context, String error) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Authentication Failed'),
          content: Text(error),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.go(RouteNames.signIn);
              },
              child: const Text('Sign In'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                // Retry biometric authentication
                _performBiometricAuthentication(context);
              },
              child: const Text('Try Again'),
            ),
          ],
        );
      },
    );
  }

  void _showAuthenticationErrorDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Authentication Error'),
          content: const Text(
            'An error occurred during biometric authentication. Please sign in with your credentials.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.go(RouteNames.signIn);
              },
              child: const Text('Sign In'),
            ),
          ],
        );
      },
    );
  }
}