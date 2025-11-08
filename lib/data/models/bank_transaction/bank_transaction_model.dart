import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

import '../recipient/recipient_model.dart';

class BankTransactionModel extends Equatable {
  final String id;
  final String userId;
  final Bank bank;
  final String accountNumber;
  final String recipientName;
  final String recipientPhone;
  final String paymentPurpose;
  final double amount;
  final double fee;
  final double totalAmount;
  final String currency;
  final String status; // 'pending', 'processing', 'success', 'failed'
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? transactionReference;
  final String? note;
  final Map<String, dynamic>? metadata;

  const BankTransactionModel({
    required this.id,
    required this.userId,
    required this.bank,
    required this.accountNumber,
    required this.recipientName,
    required this.recipientPhone,
    required this.paymentPurpose,
    required this.amount,
    required this.fee,
    required this.totalAmount,
    this.currency = 'USD',
    this.status = 'pending',
    required this.createdAt,
    this.completedAt,
    this.transactionReference,
    this.note,
    this.metadata,
  });

  factory BankTransactionModel.fromJson(Map<String, dynamic> json) {
    return BankTransactionModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      bank: Bank.fromJson(json['bank']),
      accountNumber: json['accountNumber'] ?? '',
      recipientName: json['recipientName'] ?? '',
      recipientPhone: json['recipientPhone'] ?? '',
      paymentPurpose: json['paymentPurpose'] ?? '',
      amount: (json['amount'] ?? 0.0).toDouble(),
      fee: (json['fee'] ?? 0.0).toDouble(),
      totalAmount: (json['totalAmount'] ?? 0.0).toDouble(),
      currency: json['currency'] ?? 'USD',
      status: json['status'] ?? 'pending',
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.parse(json['createdAt']),
      completedAt: json['completedAt'] != null
          ? json['completedAt'] is Timestamp
          ? (json['completedAt'] as Timestamp).toDate()
          : DateTime.parse(json['completedAt'])
          : null,
      transactionReference: json['transactionReference'],
      note: json['note'],
      metadata: json['metadata'],
    );
  }

  factory BankTransactionModel.fromFirestore(DocumentSnapshot doc) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return BankTransactionModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      bank: Bank.fromJson(data['bank']),
      accountNumber: data['accountNumber'] ?? '',
      recipientName: data['recipientName'] ?? '',
      recipientPhone: data['recipientPhone'] ?? '',
      paymentPurpose: data['paymentPurpose'] ?? '',
      amount: (data['amount'] ?? 0.0).toDouble(),
      fee: (data['fee'] ?? 0.0).toDouble(),
      totalAmount: (data['totalAmount'] ?? 0.0).toDouble(),
      currency: data['currency'] ?? 'USD',
      status: data['status'] ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      completedAt: data['completedAt'] != null
          ? (data['completedAt'] as Timestamp).toDate()
          : null,
      transactionReference: data['transactionReference'],
      note: data['note'],
      metadata: data['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'userId': userId,
      'bank': bank.toJson(),
      'accountNumber': accountNumber,
      'recipientName': recipientName,
      'recipientPhone': recipientPhone,
      'paymentPurpose': paymentPurpose,
      'amount': amount,
      'fee': fee,
      'totalAmount': totalAmount,
      'currency': currency,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'transactionReference': transactionReference,
      'note': note,
      'metadata': metadata,
    };
  }

  Map<String, dynamic> toFirestore() {
    return <String, dynamic>{
      'userId': userId,
      'bank': bank.toJson(),
      'accountNumber': accountNumber,
      'recipientName': recipientName,
      'recipientPhone': recipientPhone,
      'paymentPurpose': paymentPurpose,
      'amount': amount,
      'fee': fee,
      'totalAmount': totalAmount,
      'currency': currency,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'transactionReference': transactionReference,
      'note': note,
      'metadata': metadata,
    };
  }

  BankTransactionModel copyWith({
    String? id,
    String? userId,
    Bank? bank,
    String? accountNumber,
    String? recipientName,
    String? recipientPhone,
    String? paymentPurpose,
    double? amount,
    double? fee,
    double? totalAmount,
    String? currency,
    String? status,
    DateTime? createdAt,
    DateTime? completedAt,
    String? transactionReference,
    String? note,
    Map<String, dynamic>? metadata,
  }) {
    return BankTransactionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      bank: bank ?? this.bank,
      accountNumber: accountNumber ?? this.accountNumber,
      recipientName: recipientName ?? this.recipientName,
      recipientPhone: recipientPhone ?? this.recipientPhone,
      paymentPurpose: paymentPurpose ?? this.paymentPurpose,
      amount: amount ?? this.amount,
      fee: fee ?? this.fee,
      totalAmount: totalAmount ?? this.totalAmount,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      transactionReference: transactionReference ?? this.transactionReference,
      note: note ?? this.note,
      metadata: metadata ?? this.metadata,
    );
  }

  // Helper getters
  bool get isPending => status == 'pending';
  bool get isProcessing => status == 'processing';
  bool get isSuccess => status == 'success';
  bool get isFailed => status == 'failed';
  bool get isCompleted => isSuccess || isFailed;

  String get formattedAmount => '$currency${amount.toStringAsFixed(2)}';
  String get formattedFee => '$currency${fee.toStringAsFixed(2)}';
  String get formattedTotalAmount => '$currency${totalAmount.toStringAsFixed(2)}';

  String get displayStatus {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'processing':
        return 'Processing';
      case 'success':
        return 'Completed';
      case 'failed':
        return 'Failed';
      default:
        return 'Unknown';
    }
  }

  @override
  List<Object?> get props => <Object?>[
    id,
    userId,
    bank,
    accountNumber,
    recipientName,
    recipientPhone,
    paymentPurpose,
    amount,
    fee,
    totalAmount,
    currency,
    status,
    createdAt,
    completedAt,
    transactionReference,
    note,
    metadata,
  ];
}