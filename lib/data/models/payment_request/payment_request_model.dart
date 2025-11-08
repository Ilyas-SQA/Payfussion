// payment_request_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class PaymentRequestModel extends Equatable {
  final String id;
  final String payer;
  final String? payerImageUrl;
  final double amount;
  final String description;
  final String status;
  final String currencyCode;
  final String createdAt;
  final String expiresAt;
  final String? completedAt;
  final String? declinedAt;
  final String? recipientId;
  final String? recipientInstitution;
  final Map<String, dynamic>? accountSnapshot;
  final String? paymentLink;
  final String? qrCodeData;

  const PaymentRequestModel({
    required this.id,
    required this.payer,
    this.payerImageUrl,
    required this.amount,
    required this.description,
    required this.status,
    required this.currencyCode,
    required this.createdAt,
    required this.expiresAt,
    this.completedAt,
    this.declinedAt,
    this.recipientId,
    this.recipientInstitution,
    this.accountSnapshot,
    this.paymentLink,
    this.qrCodeData,
  });

  PaymentRequestModel copyWith({
    String? id,
    String? payer,
    String? payerImageUrl,
    double? amount,
    String? description,
    String? status,
    String? currencyCode,
    String? createdAt,
    String? expiresAt,
    String? completedAt,
    String? declinedAt,
    String? recipientId,
    String? recipientInstitution,
    Map<String, dynamic>? accountSnapshot,
    String? paymentLink,
    String? qrCodeData,
  }) {
    return PaymentRequestModel(
      id: id ?? this.id,
      payer: payer ?? this.payer,
      payerImageUrl: payerImageUrl ?? this.payerImageUrl,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      status: status ?? this.status,
      currencyCode: currencyCode ?? this.currencyCode,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      completedAt: completedAt ?? this.completedAt,
      declinedAt: declinedAt ?? this.declinedAt,
      recipientId: recipientId ?? this.recipientId,
      recipientInstitution: recipientInstitution ?? this.recipientInstitution,
      accountSnapshot: accountSnapshot ?? this.accountSnapshot,
      paymentLink: paymentLink ?? this.paymentLink,
      qrCodeData: qrCodeData ?? this.qrCodeData,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'payer': payer,
      'payer_image_url': payerImageUrl,
      'amount': amount,
      'description': description,
      'status': status,
      'currency_code': currencyCode,
      'created_at': createdAt,
      'expires_at': expiresAt,
      'completed_at': completedAt,
      'declined_at': declinedAt,
      'recipient_id': recipientId,
      'recipient_institution': recipientInstitution,
      'account_snapshot': accountSnapshot,
      'payment_link': paymentLink,
      'qr_code_data': qrCodeData,
    };
  }

  factory PaymentRequestModel.fromDoc(DocumentSnapshot doc) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    String _toIso(dynamic v) {
      if (v == null) return DateTime.now().toUtc().toIso8601String();
      if (v is Timestamp) return v.toDate().toUtc().toIso8601String();
      if (v is String) return v;
      return DateTime.now().toUtc().toIso8601String();
    }

    return PaymentRequestModel(
      id: doc.id,
      payer: data['payer'] ?? '',
      payerImageUrl: data['payer_image_url'],
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      description: data['description'] ?? '',
      status: data['status'] ?? 'Pending',
      currencyCode: data['currency_code'] ?? 'USD',
      createdAt: _toIso(data['created_at']),
      expiresAt: _toIso(data['expires_at']),
      completedAt: data['completed_at'] != null
          ? _toIso(data['completed_at'])
          : null,
      declinedAt: data['declined_at'] != null
          ? _toIso(data['declined_at'])
          : null,
      recipientId: data['recipient_id'],
      recipientInstitution: data['recipient_institution'],
      accountSnapshot: data['account_snapshot'] as Map<String, dynamic>?,
      paymentLink: data['payment_link'],
      qrCodeData: data['qr_code_data'],
    );
  }

  factory PaymentRequestModel.fromMap(Map<String, dynamic> map) {
    return PaymentRequestModel(
      id: map['id'] ?? '',
      payer: map['payer'] ?? '',
      payerImageUrl: map['payer_image_url'],
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      description: map['description'] ?? '',
      status: map['status'] ?? 'Pending',
      currencyCode: map['currency_code'] ?? 'USD',
      createdAt: map['created_at'] ?? DateTime.now().toUtc().toIso8601String(),
      expiresAt: map['expires_at'] ?? DateTime.now().toUtc().toIso8601String(),
      completedAt: map['completed_at'],
      declinedAt: map['declined_at'],
      recipientId: map['recipient_id'],
      recipientInstitution: map['recipient_institution'],
      accountSnapshot: map['account_snapshot'] as Map<String, dynamic>?,
      paymentLink: map['payment_link'],
      qrCodeData: map['qr_code_data'],
    );
  }

  // Helper methods
  bool get isExpired {
    try {
      final DateTime expiryDate = DateTime.parse(expiresAt);
      return DateTime.now().isAfter(expiryDate);
    } catch (e) {
      return false;
    }
  }

  bool get isPending => status.toLowerCase() == 'pending';

  bool get isCompleted => status.toLowerCase() == 'completed';

  bool get isDeclined => status.toLowerCase() == 'declined';

  String get formattedAmount => '\$${amount.toStringAsFixed(2)}';

  String get statusDisplayText {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'completed':
        return 'Completed';
      case 'declined':
        return 'Declined';
      case 'expired':
        return 'Expired';
      default:
        return status;
    }
  }

  @override
  List<Object?> get props =>
      <Object?>[
        id,
        payer,
        payerImageUrl,
        amount,
        description,
        status,
        currencyCode,
        createdAt,
        expiresAt,
        completedAt,
        declinedAt,
        recipientId,
        recipientInstitution,
        accountSnapshot,
        paymentLink,
        qrCodeData,
      ];

  @override
  String toString() {
    return 'PaymentRequestModel(id: $id, payer: $payer, amount: $amount, status: $status)';
  }
}