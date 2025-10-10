import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/pay_bills/bill_item.dart';

class PayBillRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Add new bill payment
  Future<void> addPayBill(PayBillModel payBill) async {
    try {
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('payBills')
          .doc(payBill.id)
          .set(payBill.toMap());
    } catch (e) {
      throw Exception('Failed to add pay bill: $e');
    }
  }

  // Update bill payment status
  Future<void> updatePayBillStatus(String billId, String status, {DateTime? paidAt}) async {
    try {
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      Map<String, dynamic> updateData = {
        'status': status,
        'updatedAt': DateTime.now().toIso8601String(),
      };

      if (paidAt != null) {
        updateData['paidAt'] = paidAt.toIso8601String();
      }

      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('payBills')
          .doc(billId)
          .update(updateData);
    } catch (e) {
      throw Exception('Failed to update pay bill status: $e');
    }
  }

  // Get all user's bill payments
  Future<List<PayBillModel>> getUserPayBills() async {
    try {
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('payBills')
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => PayBillModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get pay bills: $e');
    }
  }

  // Get bills by status
  Future<List<PayBillModel>> getPayBillsByStatus(String status) async {
    try {
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('payBills')
          .where('status', isEqualTo: status)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => PayBillModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get pay bills by status: $e');
    }
  }

  // Get single bill payment
  Future<PayBillModel?> getPayBillById(String billId) async {
    try {
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('payBills')
          .doc(billId)
          .get();

      if (doc.exists) {
        return PayBillModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get pay bill: $e');
    }
  }

  // Delete bill payment
  Future<void> deletePayBill(String billId) async {
    try {
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('payBills')
          .doc(billId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete pay bill: $e');
    }
  }

  // Stream of user's pay bills for real-time updates
  Stream<List<PayBillModel>> getUserPayBillsStream() {
    if (currentUserId == null) {
      return Stream.error('User not authenticated');
    }

    return _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('payBills')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => PayBillModel.fromFirestore(doc))
        .toList());
  }
}