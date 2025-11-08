import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/tickets/car_model.dart';

class RideFirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _usersCollection = 'users';

  Future<void> addRidesToUser(String userId, List<RideModel> rides) async {
    try {
      final WriteBatch batch = _firestore.batch();

      for (RideModel ride in rides) {
        final DocumentReference<Map<String, dynamic>> docRef = _firestore
            .collection('rides')
            .doc(ride.id);

        batch.set(docRef, ride.toMap());
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to add rides: $e');
    }
  }

  Stream<List<RideModel>> getUserRides(String userId) {
    return _firestore
        .collection('rides')
        .snapshots()
        .map((QuerySnapshot<Map<String, dynamic>> snapshot) => snapshot.docs
        .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) => RideModel.fromMap(doc.data()))
        .toList());
  }

  Future<void> addBookingToUser(String userId, RideBookingModel booking) async {
    try {
      await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .collection('ride_bookings')
          .doc(booking.id)
          .set(booking.toMap());
    } catch (e) {
      throw Exception('Failed to add ride booking: $e');
    }
  }

  Stream<List<RideBookingModel>> getUserBookings(String userId) {
    return _firestore
        .collection(_usersCollection)
        .doc(userId)
        .collection('ride_bookings')
        .snapshots()
        .map((QuerySnapshot<Map<String, dynamic>> snapshot) => snapshot.docs
        .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) => RideBookingModel.fromMap(doc.data()))
        .toList());
  }
}