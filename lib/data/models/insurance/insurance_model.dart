// insurance_payment_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class InsurancePaymentModel {
  final String id;
  final String companyName;
  final String insuranceType;
  final String policyNumber;
  final double premiumAmount;
  final String cardId;
  final String cardEnding;
  final DateTime createdAt;
  final DateTime paidAt;
  final String paymentMethod;
  final String status;
  final bool hasFee;
  final double feeAmount;
  final DateTime dueDate;
  final DateTime policyStartDate;
  final DateTime policyEndDate;

  InsurancePaymentModel({
    required this.id,
    required this.companyName,
    required this.insuranceType,
    required this.policyNumber,
    required this.premiumAmount,
    required this.cardId,
    required this.cardEnding,
    required this.createdAt,
    required this.paidAt,
    required this.paymentMethod,
    required this.status,
    required this.hasFee,
    required this.feeAmount,
    required this.dueDate,
    required this.policyStartDate,
    required this.policyEndDate,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'companyName': companyName,
      'insuranceType': insuranceType,
      'policyNumber': policyNumber,
      'premiumAmount': premiumAmount,
      'cardId': cardId,
      'cardEnding': cardEnding,
      'createdAt': Timestamp.fromDate(createdAt),
      'paidAt': Timestamp.fromDate(paidAt),
      'paymentMethod': paymentMethod,
      'status': status,
      'hasFee': hasFee,
      'feeAmount': feeAmount,
      'dueDate': Timestamp.fromDate(dueDate),
      'policyStartDate': Timestamp.fromDate(policyStartDate),
      'policyEndDate': Timestamp.fromDate(policyEndDate),
    };
  }

  // Create from Firestore Document
  factory InsurancePaymentModel.fromMap(Map<String, dynamic> map) {
    return InsurancePaymentModel(
      id: map['id'] ?? '',
      companyName: map['companyName'] ?? '',
      insuranceType: map['insuranceType'] ?? '',
      policyNumber: map['policyNumber'] ?? '',
      premiumAmount: (map['premiumAmount'] ?? 0).toDouble(),
      cardId: map['cardId'] ?? '',
      cardEnding: map['cardEnding'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      paidAt: (map['paidAt'] as Timestamp).toDate(),
      paymentMethod: map['paymentMethod'] ?? '',
      status: map['status'] ?? '',
      hasFee: map['hasFee'] ?? false,
      feeAmount: (map['feeAmount'] ?? 0).toDouble(),
      dueDate: (map['dueDate'] as Timestamp).toDate(),
      policyStartDate: (map['policyStartDate'] as Timestamp).toDate(),
      policyEndDate: (map['policyEndDate'] as Timestamp).toDate(),
    );
  }

  // Create from Firestore DocumentSnapshot
  factory InsurancePaymentModel.fromSnapshot(DocumentSnapshot doc) {
    return InsurancePaymentModel.fromMap(doc.data() as Map<String, dynamic>);
  }

  // Copy with method for updates
  InsurancePaymentModel copyWith({
    String? id,
    String? companyName,
    String? insuranceType,
    String? policyNumber,
    double? premiumAmount,
    String? cardId,
    String? cardEnding,
    DateTime? createdAt,
    DateTime? paidAt,
    String? paymentMethod,
    String? status,
    bool? hasFee,
    double? feeAmount,
    DateTime? dueDate,
    DateTime? policyStartDate,
    DateTime? policyEndDate,
  }) {
    return InsurancePaymentModel(
      id: id ?? this.id,
      companyName: companyName ?? this.companyName,
      insuranceType: insuranceType ?? this.insuranceType,
      policyNumber: policyNumber ?? this.policyNumber,
      premiumAmount: premiumAmount ?? this.premiumAmount,
      cardId: cardId ?? this.cardId,
      cardEnding: cardEnding ?? this.cardEnding,
      createdAt: createdAt ?? this.createdAt,
      paidAt: paidAt ?? this.paidAt,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      hasFee: hasFee ?? this.hasFee,
      feeAmount: feeAmount ?? this.feeAmount,
      dueDate: dueDate ?? this.dueDate,
      policyStartDate: policyStartDate ?? this.policyStartDate,
      policyEndDate: policyEndDate ?? this.policyEndDate,
    );
  }

  // Formatted getters for display
  String get formattedPremiumAmount => '\$${premiumAmount.toStringAsFixed(2)}';
  String get formattedFeeAmount => '\$${feeAmount.toStringAsFixed(2)}';
  String get totalAmount => '\$${(premiumAmount + feeAmount).toStringAsFixed(2)}';

  String get formattedDueDate {
    return '${dueDate.day}/${dueDate.month}/${dueDate.year}';
  }

  String get formattedPolicyPeriod {
    return '${policyStartDate.day}/${policyStartDate.month}/${policyStartDate.year} - ${policyEndDate.day}/${policyEndDate.month}/${policyEndDate.year}';
  }

  String get statusIcon {
    switch (status.toLowerCase()) {
      case 'completed':
        return '✅';
      case 'pending':
        return '⏳';
      case 'failed':
        return '❌';
      default:
        return '📄';
    }
  }

  @override
  String toString() {
    return 'InsurancePaymentModel(id: $id, companyName: $companyName, insuranceType: $insuranceType, premiumAmount: $premiumAmount, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is InsurancePaymentModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}