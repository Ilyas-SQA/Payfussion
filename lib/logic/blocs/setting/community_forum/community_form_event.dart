import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

abstract class CommunityFormEvent extends Equatable {
  @override
  List<Object?> get props => <Object?>[];
}

class AddPostEvent extends CommunityFormEvent {
  final String question;
  final String content;

  AddPostEvent({required this.question, required this.content});

  @override
  List<Object?> get props => <Object?>[question, content];
}

class GetPostsEvent extends CommunityFormEvent {}

class AddCommentEvent extends CommunityFormEvent {
  final String postId;
  final String content;

  AddCommentEvent({required this.postId, required this.content});

  @override
  List<Object?> get props => <Object?>[postId, content];
}

class AddReplyEvent extends CommunityFormEvent {
  final String postId;
  final String commentId;
  final String content;

  AddReplyEvent({
    required this.postId,
    required this.commentId,
    required this.content,
  });

  @override
  List<Object?> get props => <Object?>[postId, commentId, content];
}

// Post Like/Dislike Events
class LikePostEvent extends CommunityFormEvent {
  final String postId;

  LikePostEvent({required this.postId});

  @override
  List<Object?> get props => <Object?>[postId];
}

class DislikePostEvent extends CommunityFormEvent {
  final String postId;

  DislikePostEvent({required this.postId});

  @override
  List<Object?> get props => <Object?>[postId];
}

// Comment Like/Dislike Events - NEW
class LikeCommentEvent extends CommunityFormEvent {
  final String postId;
  final String commentId;

  LikeCommentEvent({required this.postId, required this.commentId});

  @override
  List<Object?> get props => <Object?>[postId, commentId];
}

class DislikeCommentEvent extends CommunityFormEvent {
  final String postId;
  final String commentId;

  DislikeCommentEvent({required this.postId, required this.commentId});

  @override
  List<Object?> get props => <Object?>[postId, commentId];
}

// Reply Like/Dislike Events - NEW
class LikeReplyEvent extends CommunityFormEvent {
  final String postId;
  final String commentId;
  final String replyId;

  LikeReplyEvent({
    required this.postId,
    required this.commentId,
    required this.replyId
  });

  @override
  List<Object?> get props => <Object?>[postId, commentId, replyId];
}

class DislikeReplyEvent extends CommunityFormEvent {
  final String postId;
  final String commentId;
  final String replyId;

  DislikeReplyEvent({
    required this.postId,
    required this.commentId,
    required this.replyId
  });

  @override
  List<Object?> get props => <Object?>[postId, commentId, replyId];
}

class StartListeningPostsEvent extends CommunityFormEvent {}

class StopListeningPostsEvent extends CommunityFormEvent {}

class PostsUpdatedEvent extends CommunityFormEvent {
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> docs;
  final String? error;

  PostsUpdatedEvent(this.docs, {this.error});

  @override
  List<Object?> get props => <Object?>[docs, error];
}