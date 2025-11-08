import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/payment_request/payment_request_model.dart';
import '../../models/recipient/recipient_model.dart';

class FirestorePaymentRepository {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  FirestorePaymentRepository({
    FirebaseFirestore? db,
    FirebaseAuth? auth,
  })  : _db = db ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  String get _uid {
    final String? u = _auth.currentUser?.uid;
    if (u == null) throw StateError('User not signed in');
    return u;
  }

  /// Payment Requests: users/{uid}/paymentRequests
  Stream<List<PaymentRequestModel>> streamPaymentRequests() {
    return _db
        .collection('users')
        .doc(_uid)
        .collection('paymentRequests')
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((QuerySnapshot<Map<String, dynamic>> qs) => qs.docs.map(_mapPaymentRequest).toList());
  }

  /// Create payment request document
  Future<void> createPaymentRequest({
    required double amount,
    required String currencyCode,
    required String description,
    required int expiryDays,
    required RecipientModel recipient,
    Map<String, dynamic>? accountSnapshot, // selected card/account snapshot
    String? paymentLink,
    String? qrCodeData,
  }) async {
    try {
      final DocumentReference<Map<String, dynamic>> ref = _db.collection('users').doc(_uid).collection('paymentRequests').doc();
      final DateTime now = DateTime.now().toUtc();
      final DateTime expiresAt = now.add(Duration(days: expiryDays));

      final Map<String, Object?> paymentRequestData = <String, Object?>{
        'id': ref.id,
        'amount': amount,
        'currency_code': currencyCode,
        'description': description,
        'status': 'Pending',
        'created_at': Timestamp.fromDate(now),
        'expires_at': Timestamp.fromDate(expiresAt),
        'payer': recipient.name,
        'payer_image_url': recipient.imageUrl,
        'recipient_id': recipient.id,
        'recipient_institution': recipient.institutionName,
        'account_snapshot': accountSnapshot,
        'payment_link': paymentLink,
        'qr_code_data': qrCodeData,
        'completed_at': null,
        'declined_at': null,
      };

      await ref.set(paymentRequestData);

      print('Payment request created successfully with ID: ${ref.id}');
    } catch (e) {
      print('Error creating payment request: $e');
      throw Exception('Failed to create payment request: ${e.toString()}');
    }
  }

  /// Get payment requests list
  Future<List<PaymentRequestModel>> getPaymentRequests() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot = await _db
          .collection('users')
          .doc(_uid)
          .collection('paymentRequests')
          .orderBy('created_at', descending: true)
          .get();

      return snapshot.docs.map(_mapPaymentRequest).toList();
    } catch (e) {
      throw Exception('Failed to fetch payment requests: ${e.toString()}');
    }
  }

  /// Update payment request status
  Future<void> updatePaymentRequestStatus({
    required String requestId,
    required String status,
    DateTime? completedAt,
    DateTime? declinedAt,
  }) async {
    try {
      final DocumentReference<Map<String, dynamic>> ref = _db
          .collection('users')
          .doc(_uid)
          .collection('paymentRequests')
          .doc(requestId);

      final Map<String, dynamic> updateData = <String, dynamic>{
        'status': status,
      };

      if (completedAt != null) {
        updateData['completed_at'] = Timestamp.fromDate(completedAt);
      }

      if (declinedAt != null) {
        updateData['declined_at'] = Timestamp.fromDate(declinedAt);
      }

      await ref.update(updateData);
    } catch (e) {
      throw Exception('Failed to update payment request: ${e.toString()}');
    }
  }

  /// Delete payment request
  Future<void> deletePaymentRequest(String requestId) async {
    try {
      await _db
          .collection('users')
          .doc(_uid)
          .collection('paymentRequests')
          .doc(requestId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete payment request: ${e.toString()}');
    }
  }

  /// Get single payment request by ID
  Future<PaymentRequestModel?> getPaymentRequestById(String requestId) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> doc = await _db
          .collection('users')
          .doc(_uid)
          .collection('paymentRequests')
          .doc(requestId)
          .get();

      if (doc.exists) {
        return _mapPaymentRequest(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch payment request: ${e.toString()}');
    }
  }

  // ----------------- Helpers -----------------
  PaymentRequestModel _mapPaymentRequest(DocumentSnapshot doc) {
    final Map<String, dynamic> d = (doc.data() as Map<String, dynamic>? ?? <String, dynamic>{});

    String _toIso(dynamic v) {
      if (v == null) return DateTime.now().toUtc().toIso8601String();
      if (v is Timestamp) return v.toDate().toUtc().toIso8601String();
      if (v is String) return v;
      return DateTime.now().toUtc().toIso8601String();
    }

    return PaymentRequestModel(
      id: (d['id'] ?? doc.id) as String,
      payer: (d['payer'] ?? '') as String,
      payerImageUrl: d['payer_image_url'] as String?,
      amount: (d['amount'] as num?)?.toDouble() ?? 0,
      description: (d['description'] ?? '') as String,
      status: (d['status'] ?? 'Pending') as String,
      currencyCode: (d['currency_code'] ?? 'USD') as String,
      createdAt: _toIso(d['created_at']),
      expiresAt: _toIso(d['expires_at']),
      completedAt: d['completed_at'] != null ? _toIso(d['completed_at']) : null,
      declinedAt: d['declined_at'] != null ? _toIso(d['declined_at']) : null,
      recipientId: d['recipient_id'] as String?,
      recipientInstitution: d['recipient_institution'] as String?,
      accountSnapshot: d['account_snapshot'] as Map<String, dynamic>?,
      paymentLink: d['payment_link'] as String?,
      qrCodeData: d['qr_code_data'] as String?,
    );
  }
}