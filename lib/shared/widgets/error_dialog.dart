import 'package:flutter/material.dart';

import '../../core/exceptions/failure.dart';

class ErrorDialog {
  static Future<void> show(BuildContext context, dynamic error) async {
    String title = 'Error';
    String message = 'An unexpected error occurred.';

    if (error is Failure) {
      // Handle different types of Failures
      if (error is AuthFailure) {
        title = 'Authentication Error';
      } else if (error is PlatformFailure) {
        title = 'Platform Error';
      } else if (error is FirebaseFailure) {
        title = 'Service Error';
      } else if (error is FormatFailure) {
        title = 'Format Error';
      }
      message = error.message;
    } else if (error is String) {
      message = error;
    } else {
      // For unexpected error types, log them for debugging
      debugPrint('Unexpected error type: ${error.runtimeType}');
      debugPrint('Error details: $error');
    }

    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

// Extension method to easily show error dialogs from any BuildContext
extension ErrorDialogExtension on BuildContext {
  Future<void> showErrorDialog(dynamic error) => ErrorDialog.show(this, error);
}
