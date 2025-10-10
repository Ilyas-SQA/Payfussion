// Updated DeviceModel class with copyWith method
class DeviceModel {
  final String deviceId;           /// Unique device identifier
  final String model;              /// Device model (Pixel 6, iPhone 14)
  final String os;                 /// OS info (Android 14, iOS 17)
  final String osVersion;          /// OS build/version
  final String manufacturer;       /// Brand (Samsung, Apple)
  final DateTime lastLogin;        /// Last login time
  final bool isActive;             /// Currently active or not
  final String? appVersion;        /// Installed app version
  final String? ipAddress;         /// Last login IP
  final String? location;          /// City/Country
  final Map<String, dynamic>? appData; /// Device specific app data (cart, stock, etc.)

  DeviceModel({
    required this.deviceId,
    required this.model,
    required this.os,
    required this.osVersion,
    required this.manufacturer,
    required this.lastLogin,
    required this.isActive,
    this.appVersion,
    this.ipAddress,
    this.location,
    this.appData,
  });

  // Add copyWith method
  DeviceModel copyWith({
    String? deviceId,
    String? model,
    String? os,
    String? osVersion,
    String? manufacturer,
    DateTime? lastLogin,
    bool? isActive,
    String? appVersion,
    String? ipAddress,
    String? location,
    Map<String, dynamic>? appData,
  }) {
    return DeviceModel(
      deviceId: deviceId ?? this.deviceId,
      model: model ?? this.model,
      os: os ?? this.os,
      osVersion: osVersion ?? this.osVersion,
      manufacturer: manufacturer ?? this.manufacturer,
      lastLogin: lastLogin ?? this.lastLogin,
      isActive: isActive ?? this.isActive,
      appVersion: appVersion ?? this.appVersion,
      ipAddress: ipAddress ?? this.ipAddress,
      location: location ?? this.location,
      appData: appData ?? this.appData,
    );
  }

  /// Convert DeviceModel to Map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'deviceId': deviceId,
      'model': model,
      'os': os,
      'osVersion': osVersion,
      'manufacturer': manufacturer,
      'lastLogin': lastLogin.toIso8601String(),
      'isActive': isActive,
      'appVersion': appVersion,
      'ipAddress': ipAddress,
      'location': location,
      'appData': appData,
    };
  }

  /// Create DeviceModel from Firebase Document
  factory DeviceModel.fromMap(Map<String, dynamic> map) {
    return DeviceModel(
      deviceId: map['deviceId'] ?? '',
      model: map['model'] ?? '',
      os: map['os'] ?? '',
      osVersion: map['osVersion'] ?? '',
      manufacturer: map['manufacturer'] ?? '',
      lastLogin: DateTime.tryParse(map['lastLogin'] ?? '') ?? DateTime.now(),
      isActive: map['isActive'] ?? false,
      appVersion: map['appVersion'],
      ipAddress: map['ipAddress'],
      location: map['location'],
      appData: map['appData'] != null ? Map<String, dynamic>.from(map['appData']) : null,
    );
  }
}