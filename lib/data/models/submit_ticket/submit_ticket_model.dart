class TicketModel {
  final String? id;
  final String userId;
  final String title;
  final String description;
  final String status;
  final DateTime date;
  final DateTime? updatedAt;

  TicketModel({
    this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.status,
    required this.date,
    this.updatedAt,
  });

  // Convert TicketModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'userId': userId,
      'title': title,
      'description': description,
      'status': status,
      'date': date,
      if (updatedAt != null) 'updatedAt': updatedAt,
    };
  }

  // Create TicketModel from Firestore document
  factory TicketModel.fromMap(Map<String, dynamic> map, String documentId) {
    return TicketModel(
      id: documentId,
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      status: map['status'] ?? 'pending',
      date: (map['date'] as dynamic)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as dynamic)?.toDate(),
    );
  }

  // Create a copy with updated fields
  TicketModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    String? status,
    DateTime? date,
    DateTime? updatedAt,
  }) {
    return TicketModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      date: date ?? this.date,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'TicketModel{id: $id, userId: $userId, title: $title, description: $description, status: $status, date: $date, updatedAt: $updatedAt}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TicketModel &&
        other.id == id &&
        other.userId == userId &&
        other.title == title &&
        other.description == description &&
        other.status == status &&
        other.date == date &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
    userId.hashCode ^
    title.hashCode ^
    description.hashCode ^
    status.hashCode ^
    date.hashCode ^
    updatedAt.hashCode;
  }
}