import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionUtils {
  static List<Permission> get allPermissions => <Permission>[
    Permission.camera,
    Permission.contacts,
    Permission.location,
    Permission.notification,
    Permission.storage,
    Permission.microphone,
  ];

  static String getPermissionTitle(Permission permission) {
    switch(permission) {
      case Permission.camera: return 'Camera';
      case Permission.contacts: return 'Contacts';
      case Permission.location: return 'Location';
      case Permission.notification: return 'Notifications';
      case Permission.storage: return 'Storage';
      case Permission.microphone: return 'Microphone';
      default: return 'Unknown';
    }
  }

  static String getPermissionDescription(Permission permission) {
    switch(permission) {
      case Permission.camera:
        return 'Allows scanning QR codes for payments, document verification, and adding payment cards.';
      case Permission.contacts:
        return 'Allows you to send money to contacts and find friends on PayFusion.';
      case Permission.location:
        return 'Used for fraud protection, nearby merchant discovery, and transaction verification.';
      case Permission.notification:
        return 'Receive alerts about transactions, security events, and account updates.';
      case Permission.storage:
        return 'Access to save documents, receipts, and export transaction records.';
      case Permission.microphone:
        return 'Used for voice commands and customer support calls within the app.';
      default:
        return '';
    }
  }

  static IconData getPermissionIcon(Permission permission) {
    switch(permission) {
      case Permission.camera: return Icons.camera_alt_outlined;
      case Permission.contacts: return Icons.contacts_outlined;
      case Permission.location: return Icons.location_on_outlined;
      case Permission.notification: return Icons.notifications_outlined;
      case Permission.storage: return Icons.folder_outlined;
      case Permission.microphone: return Icons.mic_outlined;
      default: return Icons.help_outline;
    }
  }
}