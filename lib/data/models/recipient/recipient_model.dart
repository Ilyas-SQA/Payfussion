import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class RecipientModel extends Equatable {
  final String id;
  final String name;
  final String imageUrl;
  final String accountNumber;
  final String institutionName;

  const RecipientModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.accountNumber,
    required this.institutionName,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'imageUrl': imageUrl,
    'accountNumber': accountNumber,
    'institutionName': institutionName,
  };

  @override
  List<Object?> get props => [id, name, imageUrl, accountNumber, institutionName];
}

class Bank extends Equatable {
  final String id;
  final String name;
  final String code;
  final String branchName;
  final String branchCode;
  final String address;
  final String city;

  const Bank({
    required this.id,
    required this.name,
    this.code = '',
    this.branchName = '',
    this.branchCode = '',
    this.address = '',
    this.city = '',
  });

  // Factory constructor for JSON
  factory Bank.fromJson(Map<String, dynamic> json) {
    return Bank(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      branchName: json['branchName'] ?? '',
      branchCode: json['branchCode'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
    );
  }

  // Factory constructor for Firestore
  factory Bank.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Bank(
      id: doc.id,
      name: data['name'] ?? '',
      code: data['code'] ?? '',
      branchName: data['branchName'] ?? '',
      branchCode: data['branchCode'] ?? '',
      address: data['address'] ?? '',
      city: data['city'] ?? '',
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'branchName': branchName,
      'branchCode': branchCode,
      'address': address,
      'city': city,
    };
  }

  @override
  List<Object?> get props => [
    id,
    name,
    code,
    branchName,
    branchCode,
    address,
    city,
  ];

  // Copy with method
  Bank copyWith({
    String? id,
    String? name,
    String? code,
    String? branchName,
    String? branchCode,
    String? address,
    String? city,
  }) {
    return Bank(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      branchName: branchName ?? this.branchName,
      branchCode: branchCode ?? this.branchCode,
      address: address ?? this.address,
      city: city ?? this.city,
    );
  }
}