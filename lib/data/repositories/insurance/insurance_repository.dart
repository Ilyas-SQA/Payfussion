import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/insurance/insurance_model.dart';

class InsurancePaymentRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get _userId => _auth.currentUser?.uid;

  // Collection reference - now using subcollection under user document
  CollectionReference? get _insurancePaymentsCollection {
    if (_userId == null) return null;
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('insurance');
  }

  // Add insurance payment to Firestore
  Future<void> addInsurancePayment(InsurancePaymentModel payment) async {
    try {
      if (_userId == null) throw Exception('User not authenticated');
      if (_insurancePaymentsCollection == null) throw Exception('Collection not available');

      final paymentData = payment.toMap();
      paymentData['timestamp'] = FieldValue.serverTimestamp();

      await _insurancePaymentsCollection!.doc(payment.id).set(paymentData);
    } catch (e) {
      throw Exception('Failed to add insurance payment: $e');
    }
  }

  // Get all insurance payments for current user
  Future<List<InsurancePaymentModel>> getInsurancePayments() async {
    try {
      if (_userId == null) throw Exception('User not authenticated');
      if (_insurancePaymentsCollection == null) throw Exception('Collection not available');

      final querySnapshot = await _insurancePaymentsCollection!
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => InsurancePaymentModel.fromSnapshot(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch insurance payments: $e');
    }
  }

  // Get insurance payment by ID
  Future<InsurancePaymentModel?> getInsurancePaymentById(String paymentId) async {
    try {
      if (_userId == null) throw Exception('User not authenticated');
      if (_insurancePaymentsCollection == null) throw Exception('Collection not available');

      final doc = await _insurancePaymentsCollection!.doc(paymentId).get();

      if (doc.exists && doc.data() != null) {
        return InsurancePaymentModel.fromSnapshot(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch insurance payment: $e');
    }
  }

  // Update insurance payment
  Future<void> updateInsurancePayment(InsurancePaymentModel payment) async {
    try {
      if (_userId == null) throw Exception('User not authenticated');
      if (_insurancePaymentsCollection == null) throw Exception('Collection not available');

      final paymentData = payment.toMap();
      paymentData['updatedAt'] = FieldValue.serverTimestamp();

      await _insurancePaymentsCollection!.doc(payment.id).update(paymentData);
    } catch (e) {
      throw Exception('Failed to update insurance payment: $e');
    }
  }

  // Delete insurance payment
  Future<void> deleteInsurancePayment(String paymentId) async {
    try {
      if (_userId == null) throw Exception('User not authenticated');
      if (_insurancePaymentsCollection == null) throw Exception('Collection not available');

      // Check if payment exists
      final payment = await getInsurancePaymentById(paymentId);
      if (payment == null) {
        throw Exception('Payment not found');
      }

      await _insurancePaymentsCollection!.doc(paymentId).delete();
    } catch (e) {
      throw Exception('Failed to delete insurance payment: $e');
    }
  }

  // Get insurance payments by company
  Future<List<InsurancePaymentModel>> getInsurancePaymentsByCompany(String companyName) async {
    try {
      if (_userId == null) throw Exception('User not authenticated');
      if (_insurancePaymentsCollection == null) throw Exception('Collection not available');

      final querySnapshot = await _insurancePaymentsCollection!
          .where('companyName', isEqualTo: companyName)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => InsurancePaymentModel.fromSnapshot(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch payments by company: $e');
    }
  }

  // Get insurance payments by type
  Future<List<InsurancePaymentModel>> getInsurancePaymentsByType(String insuranceType) async {
    try {
      if (_userId == null) throw Exception('User not authenticated');
      if (_insurancePaymentsCollection == null) throw Exception('Collection not available');

      final querySnapshot = await _insurancePaymentsCollection!
          .where('insuranceType', isEqualTo: insuranceType)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => InsurancePaymentModel.fromSnapshot(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch payments by type: $e');
    }
  }

  // Get insurance payments by status
  Future<List<InsurancePaymentModel>> getInsurancePaymentsByStatus(String status) async {
    try {
      if (_userId == null) throw Exception('User not authenticated');
      if (_insurancePaymentsCollection == null) throw Exception('Collection not available');

      final querySnapshot = await _insurancePaymentsCollection!
          .where('status', isEqualTo: status)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => InsurancePaymentModel.fromSnapshot(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch payments by status: $e');
    }
  }

  // Get insurance payments in date range
  Future<List<InsurancePaymentModel>> getInsurancePaymentsInDateRange(
      DateTime startDate, DateTime endDate) async {
    try {
      if (_userId == null) throw Exception('User not authenticated');
      if (_insurancePaymentsCollection == null) throw Exception('Collection not available');

      final querySnapshot = await _insurancePaymentsCollection!
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => InsurancePaymentModel.fromSnapshot(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch payments by date range: $e');
    }
  }

  // Process payment (update status to completed)
  Future<InsurancePaymentModel> processPayment(
      String paymentId, String paymentMethod, String cardId) async {
    try {
      if (_userId == null) throw Exception('User not authenticated');

      final payment = await getInsurancePaymentById(paymentId);
      if (payment == null) {
        throw Exception('Payment not found');
      }

      // Simulate payment processing delay
      await Future.delayed(const Duration(seconds: 2));

      // Update payment status
      final updatedPayment = payment.copyWith(
        status: 'completed',
        paymentMethod: paymentMethod,
        cardId: cardId,
        paidAt: DateTime.now(),
      );

      await updateInsurancePayment(updatedPayment);
      return updatedPayment;
    } catch (e) {
      throw Exception('Failed to process payment: $e');
    }
  }

  // Get payment statistics
  Future<Map<String, dynamic>> getPaymentStatistics() async {
    try {
      if (_userId == null) throw Exception('User not authenticated');
      if (_insurancePaymentsCollection == null) throw Exception('Collection not available');

      final querySnapshot = await _insurancePaymentsCollection!.get();

      final payments = querySnapshot.docs
          .map((doc) => InsurancePaymentModel.fromSnapshot(doc))
          .toList();

      double totalPaid = 0;
      double totalFees = 0;
      Map<String, double> paymentsByCompany = {};
      Map<String, double> paymentsByType = {};
      Map<String, int> transactionsByStatus = {};

      for (final payment in payments) {
        totalPaid += payment.premiumAmount;
        totalFees += payment.feeAmount;

        // Group by company
        paymentsByCompany[payment.companyName] =
            (paymentsByCompany[payment.companyName] ?? 0) + payment.premiumAmount;

        // Group by type
        paymentsByType[payment.insuranceType] =
            (paymentsByType[payment.insuranceType] ?? 0) + payment.premiumAmount;

        // Group by status
        transactionsByStatus[payment.status] =
            (transactionsByStatus[payment.status] ?? 0) + 1;
      }

      return {
        'totalPaid': totalPaid,
        'totalFees': totalFees,
        'totalTransactions': payments.length,
        'paymentsByCompany': paymentsByCompany,
        'paymentsByType': paymentsByType,
        'transactionsByStatus': transactionsByStatus,
        'payments': payments,
      };
    } catch (e) {
      throw Exception('Failed to fetch payment statistics: $e');
    }
  }

  // Search insurance payments
  Future<List<InsurancePaymentModel>> searchInsurancePayments(String query) async {
    try {
      if (_userId == null) throw Exception('User not authenticated');
      if (_insurancePaymentsCollection == null) throw Exception('Collection not available');

      final querySnapshot = await _insurancePaymentsCollection!.get();

      final allPayments = querySnapshot.docs
          .map((doc) => InsurancePaymentModel.fromSnapshot(doc))
          .toList();

      // Filter payments based on query
      final searchResults = allPayments.where((payment) {
        final searchTerm = query.toLowerCase();
        return payment.companyName.toLowerCase().contains(searchTerm) ||
            payment.insuranceType.toLowerCase().contains(searchTerm) ||
            payment.policyNumber.toLowerCase().contains(searchTerm) ||
            payment.status.toLowerCase().contains(searchTerm);
      }).toList();

      return searchResults;
    } catch (e) {
      throw Exception('Failed to search insurance payments: $e');
    }
  }

  // Get payments stream for real-time updates
  Stream<List<InsurancePaymentModel>> getInsurancePaymentsStream() {
    if (_userId == null) {
      return Stream.error('User not authenticated');
    }
    if (_insurancePaymentsCollection == null) {
      return Stream.error('Collection not available');
    }

    return _insurancePaymentsCollection!
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => InsurancePaymentModel.fromSnapshot(doc))
        .toList());
  }

  // Bulk operations
  Future<void> addMultipleInsurancePayments(List<InsurancePaymentModel> payments) async {
    try {
      if (_userId == null) throw Exception('User not authenticated');
      if (_insurancePaymentsCollection == null) throw Exception('Collection not available');

      final batch = _firestore.batch();

      for (final payment in payments) {
        final paymentData = payment.toMap();
        paymentData['timestamp'] = FieldValue.serverTimestamp();

        batch.set(_insurancePaymentsCollection!.doc(payment.id), paymentData);
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to add multiple insurance payments: $e');
    }
  }

  // Delete multiple payments
  Future<void> deleteMultipleInsurancePayments(List<String> paymentIds) async {
    try {
      if (_userId == null) throw Exception('User not authenticated');
      if (_insurancePaymentsCollection == null) throw Exception('Collection not available');

      final batch = _firestore.batch();

      for (final paymentId in paymentIds) {
        batch.delete(_insurancePaymentsCollection!.doc(paymentId));
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to delete multiple insurance payments: $e');
    }
  }

  // Check if payment exists
  Future<bool> paymentExists(String paymentId) async {
    try {
      if (_userId == null) return false;
      if (_insurancePaymentsCollection == null) return false;

      final doc = await _insurancePaymentsCollection!.doc(paymentId).get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  // Get upcoming premium payments (based on due dates)
  Future<List<InsurancePaymentModel>> getUpcomingPayments({int daysAhead = 30}) async {
    try {
      if (_userId == null) throw Exception('User not authenticated');
      if (_insurancePaymentsCollection == null) throw Exception('Collection not available');

      final now = DateTime.now();
      final futureDate = now.add(Duration(days: daysAhead));

      final querySnapshot = await _insurancePaymentsCollection!
          .where('dueDate', isGreaterThan: Timestamp.fromDate(now))
          .where('dueDate', isLessThanOrEqualTo: Timestamp.fromDate(futureDate))
          .where('status', whereIn: ['pending', 'due'])
          .orderBy('dueDate')
          .get();

      return querySnapshot.docs
          .map((doc) => InsurancePaymentModel.fromSnapshot(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch upcoming payments: $e');
    }
  }

  // Get overdue payments
  Future<List<InsurancePaymentModel>> getOverduePayments() async {
    try {
      if (_userId == null) throw Exception('User not authenticated');
      if (_insurancePaymentsCollection == null) throw Exception('Collection not available');

      final now = DateTime.now();

      final querySnapshot = await _insurancePaymentsCollection!
          .where('dueDate', isLessThan: Timestamp.fromDate(now))
          .where('status', whereNotIn: ['completed', 'cancelled'])
          .orderBy('dueDate')
          .get();

      return querySnapshot.docs
          .map((doc) => InsurancePaymentModel.fromSnapshot(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch overdue payments: $e');
    }
  }

  // Create user document if it doesn't exist (optional helper method)
  Future<void> ensureUserDocumentExists() async {
    try {
      if (_userId == null) throw Exception('User not authenticated');

      final userDoc = _firestore.collection('users').doc(_userId!);
      final docSnapshot = await userDoc.get();

      if (!docSnapshot.exists) {
        await userDoc.set({
          'createdAt': FieldValue.serverTimestamp(),
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      throw Exception('Failed to ensure user document exists: $e');
    }
  }
}