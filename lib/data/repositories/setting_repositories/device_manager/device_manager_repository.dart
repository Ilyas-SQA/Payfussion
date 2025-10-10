import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../models/device_manager/deevice_manager_model.dart';

class DeviceRepository {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<void> saveDevice(DeviceModel device) async {
    final user = _auth.currentUser;
    await _firestore.collection('users').
    doc(user!.uid).collection('devices').
    doc(device.deviceId).
    set(device.toMap(), SetOptions(merge: true));
  }

  Future<List<DeviceModel>> getDevices() async {
    final user = _auth.currentUser;
    final snapshot = await _firestore.collection('users').doc(user!.uid).
    collection('devices').get();

    return snapshot.docs
        .map((doc) => DeviceModel.fromMap(doc.data()))
        .toList();
  }

  Future<void> markDeviceInactive(String deviceId) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users')
          .doc(user.uid)
          .collection('devices')
          .doc(deviceId)
          .update({
        'isActive': false,
        'lastLogin': DateTime.now().toIso8601String(),
      });
    }
  }

  Future<String> getCurrentDeviceId() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      final info = await deviceInfo.androidInfo;
      return info.id;
    } else {
      final info = await deviceInfo.iosInfo;
      return info.identifierForVendor ?? "unknown";
    }
  }
}
