// import 'dart:async';
//
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:go_router/go_router.dart';
//
// import '../../core/constants/routes_name.dart';
// import '../../logic/blocs/auth/auth_bloc.dart';
// import '../../logic/blocs/auth/auth_event.dart';
// import '../../services/session_manager_service.dart';
// import '../../services/biometric_service.dart';
// import '../../services/service_locator.dart';
//
// /// A class containing services related to the splash screen.
// class SplashServices {
//   final BiometricService _biometricService = getIt<BiometricService>();
//
//   void checkAuthentication(BuildContext context) async {
//     final User? auth = FirebaseAuth.instance.currentUser;
//
//     Timer(const Duration(seconds: 3), () async {
//       if (auth != null) {
//         /// User session retrieve karo
//         await SessionController().getUserFromPreference();
//
//         /// Check karo ke user ne biometric enable kiya hai ya nahi
//         final bool isBiometricEnabled = await SessionController().getBiometric();
//
//         if (isBiometricEnabled) {
//           /// Biometric enabled hai, to authenticate karo
//           await _performBiometricAuthentication(context);
//         } else {
//           /// Biometric enabled nahi hai, directly home screen par jao
//           if (context.mounted) {
//             context.go(RouteNames.homeScreen);
//           }
//         }
//       } else {
//         /// Firebase user nahi hai, sign in screen par jao
//         if (context.mounted) {
//           context.go(RouteNames.signIn);
//         }
//       }
//     });
//   }
//
//   Future<void> _performBiometricAuthentication(BuildContext context) async {
//     try {
//       /// Check karo device par biometric available hai ya nahi
//       final bool isAvailable = await _biometricService.isBiometricAvailable();
//       final bool hasEnrolled = await _biometricService.hasBiometricsEnrolled();
//
//       if (!isAvailable || !hasEnrolled) {
//         /// Biometric available nahi hai, sign in par bhej do
//         if (context.mounted) {
//           _showBiometricUnavailableDialog(context);
//         }
//         return;
//       }
//
//       /// Biometric authentication perform karo
//       final Map<String, dynamic> result = await _biometricService.authenticate(
//         reason: 'Please authenticate to access your account',
//         biometricOnly: true,
//       );
//
//       if (context.mounted) {
//         if (result['success'] == true) {
//           /// Authentication successful
//           context.go(RouteNames.homeScreen);
//         } else {
//           /// Authentication failed
//           _showAuthenticationFailedDialog(context, result['error'] ?? 'Authentication failed');
//         }
//       }
//     } catch (e) {
//       print('Biometric authentication error: $e');
//       if (context.mounted) {
//         _showAuthenticationErrorDialog(context);
//       }
//     }
//   }
//
//
//
//   void _showBiometricUnavailableDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext dialogContext) {
//         return AlertDialog(
//           title: const Text('Biometric Unavailable'),
//           content: const Text(
//             'Biometric authentication is not available or not set up on this device. Please sign in with your credentials.',
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(dialogContext).pop();
//                 context.go(RouteNames.signIn);
//               },
//               child: const Text('Sign In'),
//             ),
//             TextButton(
//               onPressed: () async {
//                 Navigator.of(dialogContext).pop();
//                 /// Disable biometric and go to home
//                 await SessionController().saveBiometric(false);
//                 if (context.mounted) {
//                   context.read<AuthBloc>().add(LoginWithBiometric());
//                   context.go(RouteNames.homeScreen);
//                 }
//               },
//               child: const Text('Continue Without Biometric'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   void _showAuthenticationFailedDialog(BuildContext context, String error) {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext dialogContext) {
//         return AlertDialog(
//           title: const Text('Authentication Failed'),
//           content: Text(error),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(dialogContext).pop();
//                 context.go(RouteNames.signIn);
//               },
//               child: const Text('Sign In',style: TextStyle(color: Colors.black),),
//             ),
//             TextButton(
//               onPressed: () {
//                 Navigator.of(dialogContext).pop();
//                 // Retry biometric authentication
//                 _performBiometricAuthentication(context);
//               },
//               child: const Text('Try Again',style: TextStyle(color: Colors.black)),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   void _showAuthenticationErrorDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext dialogContext) {
//         return AlertDialog(
//           title: const Text('Authentication Error'),
//           content: const Text(
//             'An error occurred during biometric authentication. Please sign in with your credentials.',
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(dialogContext).pop();
//                 context.go(RouteNames.signIn);
//               },
//               child: const Text('Sign In'),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
//


import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/routes_name.dart';
import '../../services/session_manager_service.dart';

/// A class containing services related to the splash screen.
class SplashServices {
  void checkAuthentication(BuildContext context) async {
    final User? auth = FirebaseAuth.instance.currentUser;

    Timer(const Duration(seconds: 3), () async {
      if (auth != null) {
        /// User is authenticated, proceed to the home screen
        await SessionController().getUserFromPreference();
        context.go(RouteNames.signIn);
      } else {
        /// User is not authenticated, redirect to the sign-in screen
        context.go(RouteNames.signIn);
      }
    });
  }
}
