import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../models/device_manager/deevice_manager_model.dart';

class DeviceRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> saveDevice(DeviceModel device) async {
    final User? user = _auth.currentUser;
    await _firestore.collection('users').
    doc(user!.uid).collection('devices').
    doc(device.deviceId).
    set(device.toMap(), SetOptions(merge: true));
  }

  Future<List<DeviceModel>> getDevices() async {
    final User? user = _auth.currentUser;
    final QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore.collection('users').doc(user!.uid).
    collection('devices').get();

    return snapshot.docs
        .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) => DeviceModel.fromMap(doc.data()))
        .toList();
  }

  Future<void> markDeviceInactive(String deviceId) async {
    final User? user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users')
          .doc(user.uid)
          .collection('devices')
          .doc(deviceId)
          .update(<Object, Object?>{
        'isActive': false,
        'lastLogin': DateTime.now().toIso8601String(),
      });
    }
  }

  Future<String> getCurrentDeviceId() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      final AndroidDeviceInfo info = await deviceInfo.androidInfo;
      return info.id;
    } else {
      final IosDeviceInfo info = await deviceInfo.iosInfo;
      return info.identifierForVendor ?? "unknown";
    }
  }
}
