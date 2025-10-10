class CommunityFormModel {
  String userId;
  String postId;
  DateTime createDate;
  List<Map<String, dynamic>> comments;
  String question;
  String content;
  List<String> likes;
  List<String> dislikes;

  // Additional fields for display
  String? userName;
  String? userProfileImage;

  CommunityFormModel({
    required this.userId,
    required this.postId,
    required this.createDate,
    required this.comments,
    required this.question,
    required this.content,
    this.likes = const [],
    this.dislikes = const [],
    this.userName,
    this.userProfileImage,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'postId': postId,
      'createDate': createDate.toIso8601String(),
      'comments': comments,
      'question': question,
      'content': content,
      'likes': likes,
      'dislikes': dislikes,
    };
  }

  // Create from Map (Firestore document)
  factory CommunityFormModel.fromMap(Map<String, dynamic> map) {
    return CommunityFormModel(
      userId: map['userId'] ?? '',
      postId: map['postId'] ?? '',
      createDate: DateTime.tryParse(map['createDate'] ?? '') ?? DateTime.now(),
      comments: List<Map<String, dynamic>>.from(map['comments'] ?? []),
      question: map['question'] ?? '',
      content: map['content'] ?? '',
      likes: List<String>.from(map['likes'] ?? []),
      dislikes: List<String>.from(map['dislikes'] ?? []),
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() => toMap();

  // Create from JSON
  factory CommunityFormModel.fromJson(Map<String, dynamic> json) => CommunityFormModel.fromMap(json);

  // Copy with method for updates
  CommunityFormModel copyWith({
    String? userId,
    String? postId,
    DateTime? createDate,
    List<Map<String, dynamic>>? comments,
    String? question,
    String? content,
    List<String>? likes,
    List<String>? dislikes,
    String? userName,
    String? userProfileImage,
  }) {
    return CommunityFormModel(
      userId: userId ?? this.userId,
      postId: postId ?? this.postId,
      createDate: createDate ?? this.createDate,
      comments: comments ?? this.comments,
      question: question ?? this.question,
      content: content ?? this.content,
      likes: likes ?? this.likes,
      dislikes: dislikes ?? this.dislikes,
      userName: userName ?? this.userName,
      userProfileImage: userProfileImage ?? this.userProfileImage,
    );
  }

  @override
  String toString() {
    return 'CommunityFormModel(userId: $userId, postId: $postId, question: $question, likesCount: ${likes.length}, dislikesCount: ${dislikes.length})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CommunityFormModel && other.postId == postId;
  }

  @override
  int get hashCode => postId.hashCode;
}