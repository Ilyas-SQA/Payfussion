class CommentModel {
  final String commentId;
  final String userId;
  final String userName;
  final String userProfileImage;
  final String content;
  final DateTime createDate;
  final List<ReplyModel> replies;

  CommentModel({
    required this.commentId,
    required this.userId,
    required this.userName,
    required this.userProfileImage,
    required this.content,
    required this.createDate,
    this.replies = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'commentId': commentId,
      'userId': userId,
      'userName': userName,
      'userProfileImage': userProfileImage,
      'content': content,
      'createDate': createDate.toIso8601String(),
      'replies': replies.map((reply) => reply.toMap()).toList(),
    };
  }

  factory CommentModel.fromMap(Map<String, dynamic> map) {
    return CommentModel(
      commentId: map['commentId'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userProfileImage: map['userProfileImage'] ?? '',
      content: map['content'] ?? '',
      createDate: DateTime.parse(map['createDate']),
      replies: (map['replies'] as List<dynamic>?)
          ?.map((reply) => ReplyModel.fromMap(reply as Map<String, dynamic>))
          .toList() ?? [],
    );
  }
}

class ReplyModel {
  final String replyId;
  final String userId;
  final String userName;
  final String userProfileImage;
  final String content;
  final DateTime createDate;

  ReplyModel({
    required this.replyId,
    required this.userId,
    required this.userName,
    required this.userProfileImage,
    required this.content,
    required this.createDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'replyId': replyId,
      'userId': userId,
      'userName': userName,
      'userProfileImage': userProfileImage,
      'content': content,
      'createDate': createDate.toIso8601String(),
    };
  }

  factory ReplyModel.fromMap(Map<String, dynamic> map) {
    return ReplyModel(
      replyId: map['replyId'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userProfileImage: map['userProfileImage'] ?? '',
      content: map['content'] ?? '',
      createDate: DateTime.parse(map['createDate']),
    );
  }
}