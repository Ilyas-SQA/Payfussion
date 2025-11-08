import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/tickets/bus_model.dart';

class BusRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _usersCollection = 'users';

  Future<void> addBusesToUser(String userId, List<BusModel> buses) async {
    try {
      final WriteBatch batch = _firestore.batch();

      for (BusModel bus in buses) {
        final DocumentReference<Map<String, dynamic>> docRef = _firestore
            .collection('buses')
            .doc(bus.id);

        batch.set(docRef, bus.toMap());
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to add buses: $e');
    }
  }

  Stream<List<BusModel>> getUserBuses(String userId) {
    return _firestore
        .collection('buses')
        .snapshots()
        .map((QuerySnapshot<Map<String, dynamic>> snapshot) => snapshot.docs
        .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) => BusModel.fromMap(doc.data()))
        .toList());
  }

  Future<void> addBookingToUser(String userId, BusBookingModel booking) async {
    try {
      await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .collection('bus_bookings')
          .doc(booking.id)
          .set(booking.toMap());
    } catch (e) {
      throw Exception('Failed to add bus booking: $e');
    }
  }

  Stream<List<BusBookingModel>> getUserBookings(String userId) {
    return _firestore
        .collection(_usersCollection)
        .doc(userId)
        .collection('bus_bookings')
        .snapshots()
        .map((QuerySnapshot<Map<String, dynamic>> snapshot) => snapshot.docs
        .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) => BusBookingModel.fromMap(doc.data()))
        .toList());
  }
}