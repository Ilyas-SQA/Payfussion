import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/transaction/transaction_model.dart';

class TransactionRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<List<TransactionModel>> getTransactions(String userId) async {
    try {
      print('Fetching transactions for user: $userId');

      final QuerySnapshot<Map<String, dynamic>> snapshot = await _db
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .orderBy('createdAt', descending: true)
          .get();

      print('Found ${snapshot.docs.length} transactions');

      final List<TransactionModel> transactions = snapshot.docs.map((QueryDocumentSnapshot<Map<String, dynamic>> doc) {
        print('Transaction doc: ${doc.id}, data: ${doc.data()}');
        return TransactionModel.fromDoc(doc);
      }).toList();

      return transactions;
    } catch (e) {
      print('Error fetching transactions: $e');
      rethrow;
    }
  }

  Future<String> addTransaction(TransactionModel tx) async {
    try {
      print('Starting transaction save process...');

      // Check if user is authenticated
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final String userId = currentUser.uid;
      print('User ID: $userId');

      // Create document reference
      final DocumentReference<Map<String, dynamic>> userTxRef = _db
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .doc();

      print('Generated transaction ID: ${userTxRef.id}');

      // Prepare transaction data
      final TransactionModel txToSave = tx.copyWith(
        id: userTxRef.id,
        userId: userId,
      );

      print('Transaction data to save: ${txToSave.toMap()}');

      // Save to user's transactions subcollection
      await userTxRef.set(txToSave.toMap());
      print('Saved to user transactions collection');

      // Save to global transactions collection (optional)
      try {
        await _db.collection('transactions').doc(userTxRef.id).set(<String, dynamic>{
          ...txToSave.toMap(),
          'user_id': userId,
        });
        print('Saved to global transactions collection');
      } catch (globalError) {
        print(' Warning: Failed to save to global collection: $globalError');
        // Don't throw here - user transaction is already saved
      }

      print('Transaction saved successfully with ID: ${userTxRef.id}');
      return userTxRef.id;

    } catch (e) {
      print('Error adding transaction: $e');
      print('Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  // Helper method to check Firestore connection
  Future<bool> testConnection() async {
    try {
      await _db.collection('test').limit(1).get();
      return true;
    } catch (e) {
      print('Firestore connection test failed: $e');
      return false;
    }
  }

  // Helper method to check user permissions
  Future<void> checkUserPermissions(String userId) async {
    try {
      // Try to read user document
      final DocumentSnapshot<Map<String, dynamic>> userDoc = await _db.collection('users').doc(userId).get();
      print('User document exists: ${userDoc.exists}');

      // Try to write to transactions subcollection
      final DocumentReference<Map<String, dynamic>> testRef = _db
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .doc('test');

      await testRef.set(<String, dynamic>{'test': true});
      await testRef.delete();
      print('User has write permissions');
    } catch (e) {
      print('Permission check failed: $e');
      throw Exception('User does not have required permissions: $e');
    }
  }
}