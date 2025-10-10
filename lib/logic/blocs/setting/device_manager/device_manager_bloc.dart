import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../data/models/device_manager/deevice_manager_model.dart';
import '../../../../data/repositories/setting_repositories/device_manager/device_manager_repository.dart';
import 'device_manager_event.dart';
import 'device_manager_state.dart';

class DeviceBloc extends Bloc<DeviceEvent, DeviceState> {
  final DeviceRepository repository;
  final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

  DeviceBloc(this.repository) : super(DeviceInitial()) {
    on<FetchDevices>(_onFetchDevices);
    on<AddOrUpdateDevice>(_onAddOrUpdateDevice);
    on<MarkDeviceInactive>(_onMarkDeviceInactive); // Add new event handler
  }

  Future<void> _onFetchDevices(FetchDevices event, Emitter<DeviceState> emit) async {
    try {
      emit(DeviceLoading());
      final devices = await repository.getDevices();
      emit(DeviceLoaded(devices));
    } catch (e) {
      emit(DeviceError(e.toString()));
    }
  }

  Future<void> _onAddOrUpdateDevice(AddOrUpdateDevice event, Emitter<DeviceState> emit) async {
    try {
      emit(DeviceLoading());

      /// Auto collect device info
      final deviceId = await _getDeviceId();
      final model = await _getModel();
      final os = await _getOS();
      final osVersion = await _getOSVersion();
      final manufacturer = await _getManufacturer();
      final appVersion = await _getAppVersion();
      final ipAddress = await _getIpAddress();
      final location = await _getLocation();

      final device = DeviceModel(
        deviceId: deviceId,
        model: model,
        os: os,
        osVersion: osVersion,
        manufacturer: manufacturer,
        lastLogin: DateTime.now(),
        isActive: true, // Mark as active on login
        appVersion: appVersion,
        ipAddress: ipAddress,
        location: location,
      );

      await repository.saveDevice(device);
      final devices = await repository.getDevices();
      emit(DeviceLoaded(devices));
    } catch (e) {
      emit(DeviceError(e.toString()));
    }
  }

// Simplified and corrected _onMarkDeviceInactive method
  Future<void> _onMarkDeviceInactive(MarkDeviceInactive event, Emitter<DeviceState> emit) async {
    try {
      emit(DeviceLoading());

      // Get current device ID
      final currentDeviceId = await _getDeviceId();
      print('Marking device inactive: $currentDeviceId');

      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .collection('devices')
          .doc(currentDeviceId)
          .update({
        'isActive': false,
        'lastLogin': DateTime.now().toIso8601String(),
      });

      print('✅ Device marked inactive directly in Firebase');

      // Refresh and emit updated devices list
      final refreshedDevices = await repository.getDevices();
      emit(DeviceLoaded(refreshedDevices));
    } catch (e) {
      print('❌ Error marking device inactive: $e');
      emit(DeviceError(e.toString()));
    }
  }
  /// Helpers for device info
  Future<String> _getDeviceId() async {
    if (Platform.isAndroid) {
      final info = await deviceInfo.androidInfo;
      return info.id;
    } else {
      final info = await deviceInfo.iosInfo;
      return info.identifierForVendor ?? "unknown";
    }
  }

  Future<String> _getModel() async {
    if (Platform.isAndroid) {
      final info = await deviceInfo.androidInfo;
      return info.model ?? "unknown";
    } else {
      final info = await deviceInfo.iosInfo;
      return info.utsname.machine ?? "unknown";
    }
  }

  Future<String> _getOS() async {
    return Platform.isAndroid ? "Android" : "iOS";
  }

  Future<String> _getOSVersion() async {
    if (Platform.isAndroid) {
      final info = await deviceInfo.androidInfo;
      return info.version.release ?? "unknown";
    } else {
      final info = await deviceInfo.iosInfo;
      return info.systemVersion ?? "unknown";
    }
  }

  Future<String> _getManufacturer() async {
    if (Platform.isAndroid) {
      final info = await deviceInfo.androidInfo;
      return info.manufacturer ?? "unknown";
    } else {
      return "Apple";
    }
  }

  Future<String> _getAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  /// Get Public IP Address
  Future<String> _getIpAddress() async {
    try {
      final response = await http.get(Uri.parse('https://api.ipify.org?format=json'));
      if (response.statusCode == 200) {
        return json.decode(response.body)['ip'] ?? "unknown";
      }
      return "unknown";
    } catch (_) {
      return "unknown";
    }
  }

  /// Get Location (Latitude, Longitude)
  /// Get Human-readable Location (City, Country) from latitude & longitude
  Future<String> _getLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return "Location disabled";
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return "Permission denied";
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return "Permission permanently denied";
      }

      Position position = await Geolocator.getCurrentPosition();

      // Reverse geocoding
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final city = place.locality ?? "Unknown city";
        final country = place.country ?? "Unknown country";
        return "$city, $country";
      } else {
        return "Unknown location";
      }
    } catch (e) {
      return "unknown";
    }
  }
}
