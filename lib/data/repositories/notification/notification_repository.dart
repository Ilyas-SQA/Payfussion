import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/notification/notification_model.dart';

class NotificationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get _currentUserId => _auth.currentUser?.uid;

  // Get notifications collection reference for current user
  CollectionReference get _notificationsCollection {
    if (_currentUserId == null) {
      throw Exception('User not authenticated');
    }
    return _firestore
        .collection('users')
        .doc(_currentUserId)
        .collection('notifications');
  }

  // Add notification to Firestore
  Future<String> addNotification(NotificationModel notification) async {
    try {
      final DocumentReference<Object?> docRef = await _notificationsCollection.add(notification.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add notification: $e');
    }
  }

  // Get all notifications for current user
  Future<List<NotificationModel>> getUserNotifications() async {
    try {
      final QuerySnapshot<Object?> querySnapshot = await _notificationsCollection
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((QueryDocumentSnapshot<Object?> doc) => NotificationModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to load notifications: $e');
    }
  }

  // Get notifications by type
  Future<List<NotificationModel>> getNotificationsByType(String type) async {
    try {
      final QuerySnapshot<Object?> querySnapshot = await _notificationsCollection
          .where('type', isEqualTo: type)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((QueryDocumentSnapshot<Object?> doc) => NotificationModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to load notifications by type: $e');
    }
  }

  // Get unread notifications count
  Future<int> getUnreadNotificationsCount() async {
    try {
      final QuerySnapshot<Object?> querySnapshot = await _notificationsCollection
          .where('isRead', isEqualTo: false)
          .get();

      return querySnapshot.size;
    } catch (e) {
      throw Exception('Failed to get unread count: $e');
    }
  }

  // Mark notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _notificationsCollection.doc(notificationId).update(<Object, Object?>{
        'isRead': true,
        'readAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  // Mark all notifications as read
  Future<void> markAllNotificationsAsRead() async {
    try {
      final QuerySnapshot<Object?> querySnapshot = await _notificationsCollection
          .where('isRead', isEqualTo: false)
          .get();

      final WriteBatch batch = _firestore.batch();

      for (final QueryDocumentSnapshot<Object?> doc in querySnapshot.docs) {
        batch.update(doc.reference, <String, dynamic>{
          'isRead': true,
          'readAt': Timestamp.now(),
        });
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to mark all notifications as read: $e');
    }
  }

  // Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _notificationsCollection.doc(notificationId).delete();
    } catch (e) {
      throw Exception('Failed to delete notification: $e');
    }
  }

  // Clear all notifications
  Future<void> clearAllNotifications() async {
    try {
      final QuerySnapshot<Object?> querySnapshot = await _notificationsCollection.get();
      final WriteBatch batch = _firestore.batch();

      for (final QueryDocumentSnapshot<Object?> doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to clear all notifications: $e');
    }
  }

  // Listen to notifications in real-time
  Stream<List<NotificationModel>> notificationsStream() {
    try {
      return _notificationsCollection
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((QuerySnapshot<Object?> snapshot) => snapshot.docs
          .map((QueryDocumentSnapshot<Object?> doc) => NotificationModel.fromFirestore(doc))
          .toList());
    } catch (e) {
      throw Exception('Failed to listen to notifications: $e');
    }
  }

  // Listen to unread notifications count in real-time
  Stream<int> unreadCountStream() {
    try {
      return _notificationsCollection
          .where('isRead', isEqualTo: false)
          .snapshots()
          .map((QuerySnapshot<Object?> snapshot) => snapshot.size);
    } catch (e) {
      throw Exception('Failed to listen to unread count: $e');
    }
  }
}