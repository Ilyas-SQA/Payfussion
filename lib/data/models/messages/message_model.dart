// models/message_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Message extends Equatable {
  final String id;
  final String text;
  final String sender; // 'user' or 'support'
  final DateTime timestamp;
  final String? userId; // User identifier

  const Message({
    required this.id,
    required this.text,
    required this.sender,
    required this.timestamp,
    this.userId,
  });

  // Convert Message to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'sender': sender,
      'timestamp': Timestamp.fromDate(timestamp),
      'userId': userId,
    };
  }

  // Create Message from Firestore document
  factory Message.fromMap(Map<String, dynamic> map, String documentId) {
    return Message(
      id: documentId,
      text: map['text'] ?? '',
      sender: map['sender'] ?? '',
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      userId: map['userId'],
    );
  }

  // Create Message from Firestore DocumentSnapshot
  factory Message.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return Message.fromMap(data, snapshot.id);
  }

  // Copy with method for updating properties
  Message copyWith({
    String? id,
    String? text,
    String? sender,
    DateTime? timestamp,
    String? userId,
  }) {
    return Message(
      id: id ?? this.id,
      text: text ?? this.text,
      sender: sender ?? this.sender,
      timestamp: timestamp ?? this.timestamp,
      userId: userId ?? this.userId,
    );
  }

  @override
  List<Object?> get props => [id, text, sender, timestamp, userId];

  @override
  String toString() {
    return 'Message(id: $id, text: $text, sender: $sender, timestamp: $timestamp, userId: $userId)';
  }
}