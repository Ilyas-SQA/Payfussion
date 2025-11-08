import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String id;            // Firestore doc id (repo fills)
  final String userId;        // payer uid
  final String recipientId;   // REQUIRED
  final String recipientName; // snapshot for history UI
  final String cardId;        // which card was used
  final double amount;
  final String currency;      // e.g. "USD"
  final String status;        // "success", "panding"
  final String? note;
  final DateTime createdAt;
  final double fee;
  final double totalAmount;

  const TransactionModel({
    required this.id,
    required this.userId,
    required this.recipientId,
    required this.recipientName,
    required this.cardId,
    required this.amount,
    required this.currency,
    required this.status,
    required this.createdAt,
    this.note,
    this.fee = 0.0,
    this.totalAmount = 0.0,
  });

  TransactionModel copyWith({
    String? id,
    String? userId,
    String? recipientId,
    String? recipientName,
    String? cardId,
    double? amount,
    String? currency,
    String? status,
    String? note,
    DateTime? createdAt,
    double? fee,
    double? totalAmount,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      recipientId: recipientId ?? this.recipientId,
      recipientName: recipientName ?? this.recipientName,
      cardId: cardId ?? this.cardId,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      fee: fee ?? this.fee,
      totalAmount: totalAmount ?? this.totalAmount,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'user_id': userId,
      'recipient_id': recipientId,
      'recipient_name': recipientName,
      'card_id': cardId,
      'amount': amount,
      'currency': currency,
      'status': status,
      'note': note,
      'fee': fee,
      'total_amount': totalAmount,
      'created_at': Timestamp.fromDate(createdAt),
    };
  }

  factory TransactionModel.fromDoc(DocumentSnapshot doc) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>; // Accessing the document's data

    // Check if 'created_at' is a Timestamp
    final DateTime createdAt = data['created_at'] is Timestamp
        ? (data['created_at'] as Timestamp).toDate()
        : DateTime.now(); // Default to current time if it's not a valid timestamp

    return TransactionModel(
      id: doc.id,
      userId: data['user_id'] ?? '',
      recipientId: data['recipient_id'] ?? '',
      recipientName: data['recipient_name'] ?? '',
      cardId: data['card_id'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      currency: data['currency'] ?? 'USD',
      status: data['status'] ?? 'unknown',
      note: data['note'],
      fee: (data['fee'] ?? 0).toDouble(),
      totalAmount: (data['total_amount'] ?? 0).toDouble(),
      createdAt: createdAt,
    );
  }
}
