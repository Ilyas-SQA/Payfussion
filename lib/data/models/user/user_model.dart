import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String? createdAt;
  String? email;
  bool? isEmailVerified;
  String? phoneNumber;
  String? uid;
  String? profileImageUrl;
  String? fullName;
  bool? transaction;
  bool? twoStepAuthentication;
  String? _firstName;
  String? _lastName;

  String? get firstName => _firstName;
  set firstName(String? value) {
    _firstName = value;
    updateFullName();
  }

  String? get lastName => _lastName;
  set lastName(String? value) {
    _lastName = value;
    updateFullName();
  }

  UserModel({
    this.createdAt,
    String? firstName,
    this.isEmailVerified,
    String? lastName,
    this.email,
    this.phoneNumber,
    this.uid,
    this.fullName,
    this.profileImageUrl,
    this.transaction,
    this.twoStepAuthentication,
  }) : _firstName = firstName,
       _lastName = lastName {
    updateFullName();
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    String? createdAtString;
    if (json['createdAt'] != null) {
      if (json['createdAt'] is String) {
        createdAtString = json['createdAt'];
      } else {
        try {
          final timestamp = json['createdAt'] as Timestamp;
          final dateTime = timestamp.toDate();
          createdAtString = dateTime.toIso8601String();
        } catch (e) {
          createdAtString = DateTime.now().toIso8601String();
        }
      }
    }

    return UserModel(
      createdAt: createdAtString ?? '',
      email: json['email'] ?? '',
      firstName: json['firstName'] ?? '',
      isEmailVerified: json['isEmailVerified'] ?? false,
      lastName: json['lastName'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      uid: json['uid'] ?? '',
      profileImageUrl: json['profileUrl'] ?? '',
      transaction: json['transaction'] ?? false,
      twoStepAuthentication: json['twoStepAuthentication'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'createdAt': createdAt,
      'email': email,
      'firstName': firstName,
      'isEmailVerified': isEmailVerified,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'uid': uid,
      'profileUrl': profileImageUrl,
      'transaction': transaction,
      'twoStepAuthentication': twoStepAuthentication,
    };
  }

  void updateFullName() {
    fullName = '${firstName ?? ''} ${lastName ?? ''}'.trim();
  }
}
