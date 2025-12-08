import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/transaction_limit/transaction_limit_model.dart';

class LimitRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get user's current limit from Firestore
  Future<TransactionLimitData> getUserLimit(String userId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('transaction_limit')
          .doc('current_limit')
          .get();

      if (doc.exists && doc.data() != null) {
        return TransactionLimitData.fromMap(doc.data()!);
      } else {
        // Default values - user ne abhi limit select nahi ki
        return TransactionLimitData(
          totalLimit: 250000,
          usedAmount: 0,
          utilityBills: 5,
          period: 'Monthly',
          resetDate: DateTime(DateTime.now().year, DateTime.now().month + 1, 1),
          hasCustomLimit: false, // Default limit hai
        );
      }
    } catch (e) {
      throw Exception('Failed to load limit: $e');
    }
  }

  // Get available limits from Firestore (dynamic)
  Future<List<LimitOption>> getAvailableLimits(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('transaction_limit')
          .doc('available_options')
          .get();

      if (querySnapshot.exists && querySnapshot.data() != null) {
        final data = querySnapshot.data()!;
        final List<dynamic> options = data['limits'] ?? [];

        return options.map((opt) => LimitOption.fromMap(opt)).toList();
      } else {
        // Default options agar Firestore me nahi hain
        return _getDefaultLimits();
      }
    } catch (e) {
      // Error case me default return karo
      return _getDefaultLimits();
    }
  }

  // Default limits
  List<LimitOption> _getDefaultLimits() {
    return [
      LimitOption(amount: 1000000, utilityBills: 15, period: 'Monthly'),
      LimitOption(amount: 500000, utilityBills: 10, period: 'Monthly'),
      LimitOption(amount: 250000, utilityBills: 5, period: 'Monthly'),
      LimitOption(amount: 100000, utilityBills: 2, period: 'Monthly'),
      LimitOption(amount: 0, utilityBills: 0, period: 'Monthly'),
    ];
  }

  // Update user's limit in Firestore
  Future<void> updateUserLimit(String userId, LimitOption limit) async {
    try {
      final limitData = TransactionLimitData(
        totalLimit: limit.amount,
        usedAmount: 0, // Reset when new limit selected
        utilityBills: limit.utilityBills,
        period: limit.period,
        resetDate: DateTime(DateTime.now().year, DateTime.now().month + 1, 1),
        hasCustomLimit: true, // User ne select ki hai
      );

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('transaction_limit')
          .doc('current_limit')
          .set(limitData.toMap(), SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to update limit: $e');
    }
  }

  // // Add a transaction and update used amount
  // Future<void> addTransaction(
  // String _formatAmount(int amount) {
  // return amount.toString().replaceAllMapped(
  // RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
  // (Match m) => '${m[1]},',
  // );
  // }
}