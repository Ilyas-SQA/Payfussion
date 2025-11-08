import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../data/models/card/card_model.dart';

class CardServices{

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get _currentUserId => _auth.currentUser?.uid;

  // Get user's cards collection reference
  CollectionReference get _cardsCollection {
    if (_currentUserId == null) {
      throw Exception('User not authenticated');
    }
    return _firestore
        .collection('users')
        .doc(_currentUserId)
        .collection('card');
  }

  // Get all cards for current user
  Future<List<CardModel>> getUserCards() async {
    try {
      final QuerySnapshot<Object?> querySnapshot = await _cardsCollection
          .orderBy('create_date', descending: true)
          .get();

      return querySnapshot.docs.map((QueryDocumentSnapshot<Object?> doc) {
        return CardModel.fromFirestore(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch cards: $e');
    }
  }

  // Get cards stream for real-time updates
  Stream<List<CardModel>> getUserCardsStream() {
    try {
      return _cardsCollection
          .orderBy('create_date', descending: true)
          .snapshots()
          .map((QuerySnapshot<Object?> querySnapshot) {
        return querySnapshot.docs.map((QueryDocumentSnapshot<Object?> doc) {
          return CardModel.fromFirestore(
            doc.data() as Map<String, dynamic>,
            doc.id,
          );
        }).toList();
      });
    } catch (e) {
      throw Exception('Failed to get cards stream: $e');
    }
  }

  // Get default card
  Future<CardModel?> getDefaultCard() async {
    try {
      final QuerySnapshot<Object?> querySnapshot = await _cardsCollection
          .where('is_default', isEqualTo: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final QueryDocumentSnapshot<Object?> doc = querySnapshot.docs.first;
        return CardModel.fromFirestore(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch default card: $e');
    }
  }

  // Add new card
  Future<String> addCard(CardModel card) async {
    try {
      final DocumentReference<Object?> docRef = await _cardsCollection.add(card.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add card: $e');
    }
  }

  // Update card
  Future<void> updateCard(String cardId, CardModel card) async {
    try {
      await _cardsCollection.doc(cardId).update(card.toFirestore());
    } catch (e) {
      throw Exception('Failed to update card: $e');
    }
  }

  // Delete card
  Future<void> deleteCard(String cardId) async {
    try {
      await _cardsCollection.doc(cardId).delete();
    } catch (e) {
      throw Exception('Failed to delete card: $e');
    }
  }

  // Set default card
  Future<void> setDefaultCard(String cardId) async {
    try {
      final WriteBatch batch = _firestore.batch();

      // First, remove default from all cards
      final QuerySnapshot<Object?> allCards = await _cardsCollection.get();
      for (final QueryDocumentSnapshot<Object?> doc in allCards.docs) {
        batch.update(doc.reference, <String, dynamic>{'is_default': false});
      }

      // Then set the selected card as default
      batch.update(_cardsCollection.doc(cardId), <String, dynamic>{'is_default': true});

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to set default card: $e');
    }
  }

  // Get card by ID
  Future<CardModel?> getCardById(String cardId) async {
    try {
      final DocumentSnapshot<Object?> doc = await _cardsCollection.doc(cardId).get();
      if (doc.exists) {
        return CardModel.fromFirestore(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch card: $e');
    }
  }
}