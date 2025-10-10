import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/tickets/train_model.dart';

class TrainRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _usersCollection = 'users';

  Future<void> addTrainsToUser(String userId, List<TrainModel> trains) async {
    try {
      final batch = _firestore.batch();

      for (var train in trains) {
        final docRef = _firestore
            .collection('trains')
            .doc(train.id);

        batch.set(docRef, train.toMap());
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to add trains: $e');
    }
  }

  // Get all trains of a user
  Stream<List<TrainModel>> getUserTrains(String userId) {
    return _firestore
        .collection('trains')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => TrainModel.fromMap(doc.data()))
        .toList());
  }

  // Add booking inside user subcollection
  Future<void> addBookingToUser(String userId, BookingModel booking) async {
    try {
      await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .collection('bookings')
          .doc(booking.id)
          .set(booking.toMap());
    } catch (e) {
      throw Exception('Failed to add booking: $e');
    }
  }

  // Get all bookings of a user
  Stream<List<BookingModel>> getUserBookings(String userId) {
    return _firestore
        .collection(_usersCollection)
        .doc(userId)
        .collection('bookings')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => BookingModel.fromMap(doc.data()))
        .toList());
  }
}
