import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/card/card_model.dart';

class CardRepository {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Stream<List<CardModel>> getUserCards() => firestore
      .collection("users")
      .doc(FirebaseAuth.instance.currentUser?.uid)
      .collection("card")
      .snapshots()
      .map((QuerySnapshot<Map<String, dynamic>> snapshot) => snapshot.docs
      .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) => CardModel.fromFirestore(doc.data(), doc.id))
      .toList());
}
