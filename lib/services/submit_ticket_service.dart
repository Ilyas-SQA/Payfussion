import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/models/submit_ticket/submit_ticket_model.dart';

class TicketRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const String _collectionName = 'submitTicket';

  /// Submit a new ticket to Firestore
  Future<String> submitTicket({
    required String title,
    required String description,
  }) async {
    try {
      // Get current user ID
      final User? user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Create ticket model
      final TicketModel ticket = TicketModel(
        userId: user.uid,
        title: title,
        description: description,
        date: DateTime.now(),
        status: 'pending',
      );

      // Add to Firestore
      final DocumentReference<Map<String, dynamic>> docRef = await _firestore
          .collection(_collectionName)
          .add(ticket.toMap());

      print('✅ Ticket submitted successfully with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('❌ Failed to submit ticket: $e');
      throw Exception('Failed to submit ticket: $e');
    }
  }

  // Get all tickets as a stream (for real-time updates)
  Stream<QuerySnapshot> getTicketsStream() {
    return _firestore
        .collection('submitTicket')
        .orderBy('date', descending: true)
        .snapshots();
  }

  // Get tickets for a specific user as a stream
  Stream<QuerySnapshot> getUserTicketsStream(String userId) {
    return _firestore
        .collection('submitTicket')
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots();
  }

  // Get a single ticket by ID
  Future<DocumentSnapshot> getTicketById(String ticketId) async {
    try {
      return await _firestore
          .collection('submitTicket')
          .doc(ticketId)
          .get();
    } catch (e) {
      throw Exception('Failed to get ticket: ${e.toString()}');
    }
  }

  // Update ticket status
  Future<void> updateTicketStatus(String ticketId, String status) async {
    try {
      await _firestore
          .collection('submitTicket')
          .doc(ticketId)
          .update(<Object, Object?>{
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update ticket status: ${e.toString()}');
    }
  }

  // Delete a ticket
  Future<void> deleteTicket(String ticketId) async {
    try {
      await _firestore
          .collection('submitTicket')
          .doc(ticketId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete ticket: ${e.toString()}');
    }
  }

  // Get tickets by status
  Stream<QuerySnapshot> getTicketsByStatus(String status) {
    return _firestore
        .collection('submitTicket')
        .where('status', isEqualTo: status)
        .orderBy('date', descending: true)
        .snapshots();
  }

  // Search tickets by title
  Stream<QuerySnapshot> searchTickets(String searchTerm) {
    return _firestore
        .collection('submitTicket')
        .where('title', isGreaterThanOrEqualTo: searchTerm)
        .where('title', isLessThanOrEqualTo: searchTerm + '\uf8ff')
        .orderBy('title')
        .snapshots();
  }

  Stream<QuerySnapshot> getCurrentUserTicketsStream() {
    final User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      return const Stream.empty();
    }

    return _firestore
        .collection('submitTicket')
        .where('userId', isEqualTo: currentUser.uid)
        .snapshots();
  }

  // Option B: If you really need server-side ordering, create the index first
  Stream<QuerySnapshot> getCurrentUserTicketsStreamWithOrdering() {
    final User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      return const Stream.empty();
    }

    return _firestore
        .collection('submitTicket')
        .where('userId', isEqualTo: currentUser.uid)
        .orderBy('date', descending: true)
        .snapshots();
  }

  // Option C: Alternative - order by document creation time instead
  Stream<QuerySnapshot> getCurrentUserTicketsStreamAlternative() {
    final User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      return const Stream.empty();
    }

    return _firestore
        .collection('submitTicket')
        .where('userId', isEqualTo: currentUser.uid)
        .orderBy(FieldPath.documentId, descending: true)
        .snapshots();
  }
}