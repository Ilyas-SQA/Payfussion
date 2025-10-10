import 'package:cloud_firestore/cloud_firestore.dart';

class PayBillModel {
  final String id;
  final String companyName;
  final String companyIcon;
  final String billNumber;
  final double amount;
  final String currency;
  final String cardId;
  final String cardEnding;
  final String status; // 'pending', 'completed', 'failed'
  final DateTime createdAt;
  final DateTime? paidAt;
  final String paymentMethod; // 'fingerprint', 'pin'
  final bool hasFee;
  final double feeAmount;
  final String billType; // Added bill type field

  PayBillModel({
    required this.id,
    required this.companyName,
    required this.companyIcon,
    required this.billNumber,
    required this.amount,
    this.currency = 'USD',
    required this.cardId,
    required this.cardEnding,
    this.status = 'pending',
    required this.createdAt,
    this.paidAt,
    this.paymentMethod = 'fingerprint',
    this.hasFee = false,
    this.feeAmount = 0.0,
    required this.billType, // Required parameter for bill type
  });

  // Convert to Map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'companyName': companyName,
      'companyIcon': companyIcon,
      'billNumber': billNumber,
      'amount': amount,
      'currency': currency,
      'cardId': cardId,
      'cardEnding': cardEnding,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'paidAt': paidAt?.toIso8601String(),
      'paymentMethod': paymentMethod,
      'hasFee': hasFee,
      'feeAmount': feeAmount,
      'billType': billType, // Include bill type in Firebase map
    };
  }

  // Convert from Firebase Map
  factory PayBillModel.fromMap(Map<String, dynamic> map) {
    return PayBillModel(
      id: map['id'] ?? '',
      companyName: map['companyName'] ?? '',
      companyIcon: map['companyIcon'] ?? '',
      billNumber: map['billNumber'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      currency: map['currency'] ?? 'USD',
      cardId: map['cardId'] ?? '',
      cardEnding: map['cardEnding'] ?? '',
      status: map['status'] ?? 'pending',
      createdAt: DateTime.parse(map['createdAt']),
      paidAt: map['paidAt'] != null ? DateTime.parse(map['paidAt']) : null,
      paymentMethod: map['paymentMethod'] ?? 'fingerprint',
      hasFee: map['hasFee'] ?? false,
      feeAmount: (map['feeAmount'] ?? 0).toDouble(),
      billType: map['billType'] ?? '', // Include bill type when reading from Firebase
    );
  }

  // Convert from Firestore DocumentSnapshot
  factory PayBillModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return PayBillModel.fromMap(data);
  }

  // Copy with method for updates
  PayBillModel copyWith({
    String? id,
    String? companyName,
    String? companyIcon,
    String? billNumber,
    double? amount,
    String? currency,
    String? cardId,
    String? cardEnding,
    String? status,
    DateTime? createdAt,
    DateTime? paidAt,
    String? paymentMethod,
    bool? hasFee,
    double? feeAmount,
    String? billType, // Added bill type parameter
  }) {
    return PayBillModel(
      id: id ?? this.id,
      companyName: companyName ?? this.companyName,
      companyIcon: companyIcon ?? this.companyIcon,
      billNumber: billNumber ?? this.billNumber,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      cardId: cardId ?? this.cardId,
      cardEnding: cardEnding ?? this.cardEnding,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      paidAt: paidAt ?? this.paidAt,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      hasFee: hasFee ?? this.hasFee,
      feeAmount: feeAmount ?? this.feeAmount,
      billType: billType ?? this.billType, // Include bill type in copyWith
    );
  }
}