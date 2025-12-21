import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String? uid;
  String? profileImageUrl;
  String? fullName;

  String? _firstName;
  String? _lastName;

  String? email;
  String? phoneNumber;

  bool? isEmailVerified;
  bool? accountVerified;
  bool? kycVerification;
  bool? suspendAccount;
  bool? transaction;
  bool? twoStepAuthentication;

  String? createdAt;
  String? updatedAt;

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
    this.uid,
    this.profileImageUrl,
    this.fullName,
    String? firstName,
    String? lastName,
    this.email,
    this.phoneNumber,
    this.isEmailVerified,
    this.accountVerified,
    this.kycVerification,
    this.suspendAccount,
    this.transaction,
    this.twoStepAuthentication,
    this.createdAt,
    this.updatedAt,
  }) : _firstName = firstName,
        _lastName = lastName {
    updateFullName();
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    String parseDate(dynamic value) {
      if (value == null) return '';
      if (value is Timestamp) {
        return value.toDate().toIso8601String();
      }
      return value.toString();
    }

    return UserModel(
      uid: json['uid'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      profileImageUrl: json['profileUrl'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      isEmailVerified: json['isEmailVerified'],
      accountVerified: json['accountVerified'],
      kycVerification: json['kycVerification'],
      suspendAccount: json['suspendAccount'],
      transaction: json['transaction'],
      twoStepAuthentication: json['twoStepAuthentication'],
      createdAt: parseDate(json['createdAt']),
      updatedAt: parseDate(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'phoneNumber': phoneNumber,
      'profileUrl': profileImageUrl,
      'firstName': firstName,
      'lastName': lastName,
      'fullName': fullName,
      'isEmailVerified': isEmailVerified,
      'accountVerified': accountVerified,
      'kycVerification': kycVerification,
      'suspendAccount': suspendAccount,
      'transaction': transaction,
      'twoStepAuthentication': twoStepAuthentication,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  void updateFullName() {
    fullName = '${firstName ?? ''} ${lastName ?? ''}'.trim();
  }
}
