import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/tickets/flight_model.dart';

class FlightFirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _usersCollection = 'users';

  Future<void> addFlightsToUser(String userId, List<FlightModel> flights) async {
    try {
      final batch = _firestore.batch();

      for (var flight in flights) {
        final docRef = _firestore
            .collection('flights')
            .doc(flight.id);

        batch.set(docRef, flight.toMap());
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to add flights: $e');
    }
  }

  Stream<List<FlightModel>> getUserFlights(String userId) {
    return _firestore
        .collection('flights')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => FlightModel.fromMap(doc.data()))
        .toList());
  }

  Future<void> addBookingToUser(String userId, FlightBookingModel booking) async {
    try {
      await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .collection('flight_bookings')
          .doc(booking.id)
          .set(booking.toMap());
    } catch (e) {
      throw Exception('Failed to add flight booking: $e');
    }
  }

  Stream<List<FlightBookingModel>> getUserBookings(String userId) {
    return _firestore
        .collection(_usersCollection)
        .doc(userId)
        .collection('flight_bookings')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => FlightBookingModel.fromMap(doc.data()))
        .toList());
  }
}