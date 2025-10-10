import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../models/recipient/recipient_model.dart';

class RecipientRepositoryFB {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  RecipientRepositoryFB({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  /// Firestore path pieces
  static const String _usersCol = 'users';
  static const String _userListCol = 'recipients';
  static const String _banksCol = 'banks'; // Global banks collection

  // Default banks for initialization
  static const List<Bank> defaultBanks = <Bank>[
    Bank(id: '1', name: 'Chase Bank'),
    Bank(id: '2', name: 'Bank of America'),
    Bank(id: '3', name: 'Wells Fargo'),
    Bank(id: '4', name: 'Citibank'),
    Bank(id: '5', name: 'TD Bank'),
    Bank(id: '6', name: 'Capital One'),
    Bank(id: '7', name: 'PNC Bank'),
    Bank(id: '8', name: 'U.S. Bank'),
    Bank(id: '9', name: 'Bank of New York Mellon'),
    Bank(id: '10', name: 'HSBC Bank'),
    Bank(id: '11', name: 'Truist Bank'),
    Bank(id: '12', name: 'Fifth Third Bank'),
    Bank(id: '13', name: 'Huntington National Bank'),
    Bank(id: '14', name: 'KeyBank'),
    Bank(id: '15', name: 'Regions Bank'),
    Bank(id: '16', name: 'M&T Bank'),
    Bank(id: '17', name: 'Ally Bank'),
    Bank(id: '18', name: 'Charles Schwab Bank'),
    Bank(id: '19', name: 'Synchrony Bank'),
    Bank(id: '20', name: 'Discover Bank'),
  ];

  /// Get banks from Firebase with auto-initialization
  Future<List<Bank>> getBanks() async {
    try {
      final querySnapshot = await _firestore
          .collection(_banksCol)
          .orderBy('name')
          .get();

      // If no banks exist, initialize with default banks
      if (querySnapshot.docs.isEmpty) {
        await _initializeDefaultBanks();
        return defaultBanks;
      }

      // Convert Firestore documents to Bank objects with all fields
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return Bank(
          id: doc.id,
          name: data['name'] ?? '',
          code: data['code'] ?? '',
          branchName: data['branchName'] ?? '',
          branchCode: data['branchCode'] ?? '',
          address: data['address'] ?? '',
          city: data['city'] ?? '',
        );
      }).toList();
    } catch (e) {
      print('Error loading banks from Firebase: $e');
      // Return default banks if Firebase fails
      return defaultBanks;
    }
  }


  /// Initialize Firestore with default banks
  Future<void> _initializeDefaultBanks() async {
    try {
      final batch = _firestore.batch();

      for (final bank in defaultBanks) {
        final docRef = _firestore.collection(_banksCol).doc();
        batch.set(docRef, {
          'name': bank.name,
          'createdAt': FieldValue.serverTimestamp(),
          'isDefault': true,
        });
      }

      await batch.commit();
      print('Default banks initialized successfully');
    } catch (e) {
      print('Error initializing default banks: $e');
    }
  }

  /// Add a new bank to Firebase
  Future<Bank> addNewBank(String bankName) async {
    try {
      // Check if bank already exists
      final existingQuery = await _firestore
          .collection(_banksCol)
          .where('name', isEqualTo: bankName.trim())
          .limit(1)
          .get();

      if (existingQuery.docs.isNotEmpty) {
        throw Exception('Bank "$bankName" already exists');
      }

      // Add new bank
      final docRef = _firestore.collection(_banksCol).doc();
      await docRef.set({
        'name': bankName.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'isDefault': false,
      });

      return Bank(id: docRef.id, name: bankName.trim());
    } catch (e) {
      print('Error adding new bank: $e');
      if (e.toString().contains('already exists')) {
        rethrow;
      }
      throw Exception('Failed to add bank. Please check your connection.');
    }
  }

  /// Stream banks for real-time updates
  Stream<List<Bank>> streamBanks() {
    return _firestore
        .collection(_banksCol)
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Bank(
          id: doc.id,
          name: data['name'] ?? '',
          code: data['code'] ?? '',
          branchName: data['branchName'] ?? '',
          branchCode: data['branchCode'] ?? '',
          address: data['address'] ?? '',
          city: data['city'] ?? '',
        );
      }).toList();
    });
  }

  /// Delete a bank (optional - for admin functionality)
  Future<void> deleteBank(String bankId) async {
    try {
      await _firestore.collection(_banksCol).doc(bankId).delete();
    } catch (e) {
      print('Error deleting bank: $e');
      throw Exception('Failed to delete bank');
    }
  }

  /// Update bank name (optional - for admin functionality)
  Future<void> updateBank(String bankId, String newName) async {
    try {
      await _firestore.collection(_banksCol).doc(bankId).update({
        'name': newName.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating bank: $e');
      throw Exception('Failed to update bank');
    }
  }

  /// Duplicate check by bankName + accountNumber
  Future<bool> isRecipientExist({
    required String userId,
    required String bankName,
    required String accountNumber,
  }) async {
    final qs = await _firestore
        .collection(_usersCol)
        .doc(userId)
        .collection(_userListCol)
        .where('institutionName', isEqualTo: bankName)
        .where('accountNumber', isEqualTo: accountNumber)
        .limit(1)
        .get();
    return qs.docs.isNotEmpty;
  }

  Future<Bank> addNewBankWithDetails(Map<String, String> bankData) async {
    try {
      // Check if bank already exists
      final existingQuery = await _firestore
          .collection(_banksCol)
          .where('name', isEqualTo: bankData['name']!.trim())
          .limit(1)
          .get();

      if (existingQuery.docs.isNotEmpty) {
        throw Exception('Bank "${bankData['name']}" already exists');
      }

      // Add new bank with all details
      final docRef = _firestore.collection(_banksCol).doc();
      await docRef.set({
        'name': bankData['name']!.trim(),
        'code': bankData['code']?.trim() ?? '',
        'branchName': bankData['branchName']?.trim() ?? '',
        'branchCode': bankData['branchCode']?.trim() ?? '',
        'address': bankData['address']?.trim() ?? '',
        'city': bankData['city']?.trim() ?? '',
        'createdAt': FieldValue.serverTimestamp(),
        'isDefault': false,
      });

      // Return Bank object with all fields
      return Bank(
        id: docRef.id,
        name: bankData['name']!.trim(),
        code: bankData['code']?.trim() ?? '',
        branchName: bankData['branchName']?.trim() ?? '',
        branchCode: bankData['branchCode']?.trim() ?? '',
        address: bankData['address']?.trim() ?? '',
        city: bankData['city']?.trim() ?? '',
      );
    } catch (e) {
      print('Error adding new bank: $e');
      if (e.toString().contains('already exists')) {
        rethrow;
      }
      throw Exception('Failed to add bank. Please check your connection.');
    }
  }

  /// Simulated verification: exactly 16 digits
  Future<bool> verifyAccountNumber(String accountNumber) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final digitsOnly = int.tryParse(accountNumber);
    return accountNumber.length == 16 && digitsOnly != null;
  }

  Future<String> _uploadImage({
    required String userId,
    required String recipientId,
    required File file,
  }) async {
    final ref = _storage.ref().child('users/$userId/recipients/$recipientId.jpg');
    await ref.putFile(file);
    return ref.getDownloadURL();
  }

  /// Add a recipient under users/{userId}/userList/{recipientId}
  Future<RecipientModel> addRecipient({
    required String userId,
    required String name,
    required String bankName,
    required String accountNumber,
    File? imageFile,
  }) async {
    final docRef = _firestore
        .collection(_usersCol)
        .doc(userId)
        .collection(_userListCol)
        .doc();

    String imageUrl = '';
    if (imageFile != null) {
      imageUrl = await _uploadImage(
        userId: userId,
        recipientId: docRef.id,
        file: imageFile,
      );
    }

    final recipient = RecipientModel(
      id: docRef.id,
      name: name,
      imageUrl: imageUrl,
      accountNumber: accountNumber,
      institutionName: bankName,
    );

    final data = _safeMap(recipient);
    await docRef.set(data);
    return recipient;
  }

  /// Live stream: users/{userId}/userList
  Stream<List<RecipientModel>> streamRecipients({required String userId}) {
    return _firestore
        .collection(_usersCol)
        .doc(userId)
        .collection(_userListCol)
        .orderBy('name')
        .snapshots()
        .map((qs) => qs.docs.map((d) {
      final m = d.data();
      return RecipientModel(
        id: (m['id'] ?? d.id).toString(),
        name: (m['name'] ?? '').toString(),
        imageUrl: (m['imageUrl'] ?? '').toString(),
        accountNumber: (m['accountNumber'] ?? '').toString(),
        institutionName: (m['institutionName'] ?? '').toString(),
      );
    }).toList());
  }

  Future<void> updateRecipient({
    required String userId,
    required String recipientId,
    String? name,
    String? bankName,
    String? accountNumber,
    File? newImageFile,
  }) async {
    final docRef = _firestore
        .collection(_usersCol)
        .doc(userId)
        .collection(_userListCol)
        .doc(recipientId);

    final Map<String, dynamic> patch = {};

    if (name != null) patch['name'] = name;
    if (bankName != null) patch['institutionName'] = bankName;
    if (accountNumber != null) patch['accountNumber'] = accountNumber;

    if (newImageFile != null) {
      final imageUrl = await _uploadImage(
        userId: userId,
        recipientId: recipientId,
        file: newImageFile,
      );
      patch['imageUrl'] = imageUrl;
    }

    if (patch.isNotEmpty) {
      await docRef.update(patch);
    }
  }

  Future<void> deleteRecipient({
    required String userId,
    required String recipientId,
  }) async {
    final docRef = _firestore
        .collection(_usersCol)
        .doc(userId)
        .collection(_userListCol)
        .doc(recipientId);
    await docRef.delete();
  }

  /// Safely convert Recipient to Map
  Map<String, dynamic> _safeMap(RecipientModel r) {
    try {
      final dyn = (r as dynamic);
      if (dyn.toJson != null) return Map<String, dynamic>.from(dyn.toJson());
    } catch (_) {}
    try {
      final dyn = (r as dynamic);
      if (dyn.toMap != null) return Map<String, dynamic>.from(dyn.toMap());
    } catch (_) {}
    return {
      'id': r.id,
      'name': r.name,
      'imageUrl': r.imageUrl,
      'accountNumber': r.accountNumber,
      'institutionName': r.institutionName,
    };
  }
}