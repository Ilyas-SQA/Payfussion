import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/tickets/movies_model.dart';

class MovieRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _usersCollection = 'users';

  Future<void> addMoviesToUser(String userId, List<MovieModel> movies) async {
    try {
      final batch = _firestore.batch();

      for (var movie in movies) {
        final docRef = _firestore
            .collection('movies')
            .doc(movie.id);

        batch.set(docRef, movie.toMap());
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to add movies: $e');
    }
  }

  Stream<List<MovieModel>> getUserMovies(String userId) {
    return _firestore
        .collection('movies')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => MovieModel.fromMap(doc.data()))
        .toList());
  }

  Future<void> addBookingToUser(String userId, MovieBookingModel booking) async {
    try {
      await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .collection('movie_bookings')
          .doc(booking.id)
          .set(booking.toMap());
    } catch (e) {
      throw Exception('Failed to add movie booking: $e');
    }
  }

  Stream<List<MovieBookingModel>> getUserBookings(String userId) {
    return _firestore
        .collection(_usersCollection)
        .doc(userId)
        .collection('movie_bookings')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => MovieBookingModel.fromMap(doc.data()))
        .toList());
  }
}