import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/models/community_form/community_form_model.dart';
import '../../../../data/models/user/user_model.dart';
import 'community_form_event.dart';
import 'community_form_state.dart';

class CommunityFormBloc extends Bloc<CommunityFormEvent, CommunityFormState> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance.currentUser;
  StreamSubscription<QuerySnapshot>? _postsSubscription;

  CommunityFormBloc() : super(PostInitial()) {
    on<AddPostEvent>(_onAddPost);
    on<GetPostsEvent>(_onGetPosts);
    on<AddCommentEvent>(_onAddComment);
    on<AddReplyEvent>(_onAddReply);
    on<LikePostEvent>(_onLikePost);
    on<DislikePostEvent>(_onDislikePost);
    on<LikeCommentEvent>(_onLikeComment);
    on<DislikeCommentEvent>(_onDislikeComment);
    on<LikeReplyEvent>(_onLikeReply);
    on<DislikeReplyEvent>(_onDislikeReply);
    on<StartListeningPostsEvent>(_onStartListeningPosts);
    on<StopListeningPostsEvent>(_onStopListeningPosts);
    on<PostsUpdatedEvent>(_onPostsUpdated);
  }

  Future<void> _onAddPost(AddPostEvent event, Emitter<CommunityFormState> emit) async {
    try {
      final String postId = firestore.collection("communityForm").doc().id;
      final CommunityFormModel post = CommunityFormModel(
        userId: auth?.uid ?? "",
        postId: postId,
        createDate: DateTime.now(),
        comments: [],
        question: event.question,
        content: event.content,
        likes: [],
        dislikes: [],
      );

      await firestore.collection("communityForm").doc(postId).set(post.toMap());
      emit(PostAdded());

      // The stream will automatically pick up this new post and update the UI
    } catch (e) {
      emit(PostError("Failed to add post: $e"));
    }
  }

  Future<void> _onLikePost(LikePostEvent event, Emitter<CommunityFormState> emit) async {
    try {
      final userId = auth?.uid;
      if (userId == null) return;

      final postRef = firestore.collection("communityForm").doc(event.postId);

      await firestore.runTransaction((transaction) async {
        final postSnapshot = await transaction.get(postRef);
        if (!postSnapshot.exists) return;

        final postData = postSnapshot.data()!;
        List<String> likes = List<String>.from(postData['likes'] ?? []);
        List<String> dislikes = List<String>.from(postData['dislikes'] ?? []);

        // Remove from dislikes if present
        dislikes.remove(userId);

        // Toggle like
        if (likes.contains(userId)) {
          likes.remove(userId);
        } else {
          likes.add(userId);
        }

        transaction.update(postRef, {
          'likes': likes,
          'dislikes': dislikes,
        });
      });

      // The stream listener will automatically emit PostLoaded with updated data
    } catch (e) {
      emit(PostError("Failed to like post: $e"));
    }
  }

  Future<void> _onDislikePost(DislikePostEvent event, Emitter<CommunityFormState> emit) async {
    try {
      final userId = auth?.uid;
      if (userId == null) return;

      final postRef = firestore.collection("communityForm").doc(event.postId);

      await firestore.runTransaction((transaction) async {
        final postSnapshot = await transaction.get(postRef);
        if (!postSnapshot.exists) return;

        final postData = postSnapshot.data()!;
        List<String> likes = List<String>.from(postData['likes'] ?? []);
        List<String> dislikes = List<String>.from(postData['dislikes'] ?? []);

        // Remove from likes if present
        likes.remove(userId);

        // Toggle dislike
        if (dislikes.contains(userId)) {
          dislikes.remove(userId);
        } else {
          dislikes.add(userId);
        }

        transaction.update(postRef, {
          'likes': likes,
          'dislikes': dislikes,
        });
      });

      // Stream will automatically update UI
    } catch (e) {
      emit(PostError("Failed to dislike post: $e"));
    }
  }

  // UPDATED: Comment Like Function with immediate stream update
  Future<void> _onLikeComment(LikeCommentEvent event, Emitter<CommunityFormState> emit) async {
    try {
      final userId = auth?.uid;
      if (userId == null) return;

      final postRef = firestore.collection("communityForm").doc(event.postId);

      await firestore.runTransaction((transaction) async {
        final postSnapshot = await transaction.get(postRef);
        if (!postSnapshot.exists) return;

        final postData = postSnapshot.data()!;
        List<Map<String, dynamic>> comments = List<Map<String, dynamic>>.from(postData['comments'] ?? []);

        // Find and update the specific comment
        for (int i = 0; i < comments.length; i++) {
          if (comments[i]['commentId'] == event.commentId) {
            List<String> likes = List<String>.from(comments[i]['likes'] ?? []);
            List<String> dislikes = List<String>.from(comments[i]['dislikes'] ?? []);

            // Remove from dislikes if present
            dislikes.remove(userId);

            // Toggle like
            if (likes.contains(userId)) {
              likes.remove(userId);
            } else {
              likes.add(userId);
            }

            comments[i]['likes'] = likes;
            comments[i]['dislikes'] = dislikes;
            break;
          }
        }

        transaction.update(postRef, {'comments': comments});
      });

      // Stream will automatically update UI with new like count
    } catch (e) {
      emit(PostError("Failed to like comment: $e"));
    }
  }

  // UPDATED: Comment Dislike Function
  Future<void> _onDislikeComment(DislikeCommentEvent event, Emitter<CommunityFormState> emit) async {
    try {
      final userId = auth?.uid;
      if (userId == null) return;

      final postRef = firestore.collection("communityForm").doc(event.postId);

      await firestore.runTransaction((transaction) async {
        final postSnapshot = await transaction.get(postRef);
        if (!postSnapshot.exists) return;

        final postData = postSnapshot.data()!;
        List<Map<String, dynamic>> comments = List<Map<String, dynamic>>.from(postData['comments'] ?? []);

        // Find and update the specific comment
        for (int i = 0; i < comments.length; i++) {
          if (comments[i]['commentId'] == event.commentId) {
            List<String> likes = List<String>.from(comments[i]['likes'] ?? []);
            List<String> dislikes = List<String>.from(comments[i]['dislikes'] ?? []);

            // Remove from likes if present
            likes.remove(userId);

            // Toggle dislike
            if (dislikes.contains(userId)) {
              dislikes.remove(userId);
            } else {
              dislikes.add(userId);
            }

            comments[i]['likes'] = likes;
            comments[i]['dislikes'] = dislikes;
            break;
          }
        }

        transaction.update(postRef, {'comments': comments});
      });

      // Stream will automatically update UI
    } catch (e) {
      emit(PostError("Failed to dislike comment: $e"));
    }
  }

  // UPDATED: Reply Like Function
  Future<void> _onLikeReply(LikeReplyEvent event, Emitter<CommunityFormState> emit) async {
    try {
      final userId = auth?.uid;
      if (userId == null) return;

      final postRef = firestore.collection("communityForm").doc(event.postId);

      await firestore.runTransaction((transaction) async {
        final postSnapshot = await transaction.get(postRef);
        if (!postSnapshot.exists) return;

        final postData = postSnapshot.data()!;
        List<Map<String, dynamic>> comments = List<Map<String, dynamic>>.from(postData['comments'] ?? []);

        // Find the comment and then the reply
        for (int i = 0; i < comments.length; i++) {
          if (comments[i]['commentId'] == event.commentId) {
            List<Map<String, dynamic>> replies = List<Map<String, dynamic>>.from(comments[i]['replies'] ?? []);

            for (int j = 0; j < replies.length; j++) {
              if (replies[j]['replyId'] == event.replyId) {
                List<String> likes = List<String>.from(replies[j]['likes'] ?? []);
                List<String> dislikes = List<String>.from(replies[j]['dislikes'] ?? []);

                // Remove from dislikes if present
                dislikes.remove(userId);

                // Toggle like
                if (likes.contains(userId)) {
                  likes.remove(userId);
                } else {
                  likes.add(userId);
                }

                replies[j]['likes'] = likes;
                replies[j]['dislikes'] = dislikes;
                break;
              }
            }

            comments[i]['replies'] = replies;
            break;
          }
        }

        transaction.update(postRef, {'comments': comments});
      });

      // Stream will automatically update UI
    } catch (e) {
      emit(PostError("Failed to like reply: $e"));
    }
  }

  // UPDATED: Reply Dislike Function
  Future<void> _onDislikeReply(DislikeReplyEvent event, Emitter<CommunityFormState> emit) async {
    try {
      final userId = auth?.uid;
      if (userId == null) return;

      final postRef = firestore.collection("communityForm").doc(event.postId);

      await firestore.runTransaction((transaction) async {
        final postSnapshot = await transaction.get(postRef);
        if (!postSnapshot.exists) return;

        final postData = postSnapshot.data()!;
        List<Map<String, dynamic>> comments = List<Map<String, dynamic>>.from(postData['comments'] ?? []);

        // Find the comment and then the reply
        for (int i = 0; i < comments.length; i++) {
          if (comments[i]['commentId'] == event.commentId) {
            List<Map<String, dynamic>> replies = List<Map<String, dynamic>>.from(comments[i]['replies'] ?? []);

            for (int j = 0; j < replies.length; j++) {
              if (replies[j]['replyId'] == event.replyId) {
                List<String> likes = List<String>.from(replies[j]['likes'] ?? []);
                List<String> dislikes = List<String>.from(replies[j]['dislikes'] ?? []);

                // Remove from likes if present
                likes.remove(userId);

                // Toggle dislike
                if (dislikes.contains(userId)) {
                  dislikes.remove(userId);
                } else {
                  dislikes.add(userId);
                }

                replies[j]['likes'] = likes;
                replies[j]['dislikes'] = dislikes;
                break;
              }
            }

            comments[i]['replies'] = replies;
            break;
          }
        }

        transaction.update(postRef, {'comments': comments});
      });

      // Stream will automatically update UI
    } catch (e) {
      emit(PostError("Failed to dislike reply: $e"));
    }
  }

  Future<void> _onGetPosts(GetPostsEvent event, Emitter<CommunityFormState> emit) async {
    emit(PostLoading());
    try {
      final QuerySnapshot<Map<String, dynamic>> postsSnapshot =
      await firestore.collection("communityForm").orderBy('createDate', descending: true).get();

      final List<CommunityFormModel> posts = await _processPosts(postsSnapshot.docs);
      emit(PostLoaded(posts));
    } catch (e) {
      emit(PostError("Failed to fetch posts: $e"));
    }
  }

  // CRITICAL: Enhanced stream listening for real-time updates
  Future<void> _onStartListeningPosts(StartListeningPostsEvent event, Emitter<CommunityFormState> emit) async {
    emit(PostLoading());

    // Cancel any existing subscription
    _postsSubscription?.cancel();

    // Start listening to real-time updates
    _postsSubscription = firestore
        .collection("communityForm")
        .orderBy('createDate', descending: true)
        .snapshots(includeMetadataChanges: true) // Include metadata changes for better real-time updates
        .listen(
          (QuerySnapshot<Map<String, dynamic>> snapshot) {
        // CRITICAL: Always trigger PostsUpdatedEvent when stream changes
        add(PostsUpdatedEvent(snapshot.docs));
      },
      onError: (error) {
        add(PostsUpdatedEvent([], error: error.toString()));
      },
    );
  }

  Future<void> _onStopListeningPosts(StopListeningPostsEvent event, Emitter<CommunityFormState> emit) async {
    _postsSubscription?.cancel();
    _postsSubscription = null;
  }

  // CRITICAL: This handles all real-time updates from the stream
  Future<void> _onPostsUpdated(PostsUpdatedEvent event, Emitter<CommunityFormState> emit) async {
    try {
      if (event.error != null) {
        emit(PostError("Stream error: ${event.error}"));
        return;
      }

      final List<CommunityFormModel> posts = await _processPosts(event.docs);

      // CRITICAL: Always emit PostLoaded to trigger UI rebuild
      emit(PostLoaded(posts));
    } catch (e) {
      emit(PostError("Failed to process posts: $e"));
    }
  }

  Future<List<CommunityFormModel>> _processPosts(List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) async {
    final List<CommunityFormModel> posts = [];

    for (var doc in docs) {
      try {
        final postData = doc.data();
        final postModel = CommunityFormModel.fromMap(postData);

        // Fetch user details using userId
        if (postModel.userId.isNotEmpty) {
          try {
            final userSnapshot = await firestore.collection("users").doc(postModel.userId).get();
            if (userSnapshot.exists) {
              final userModel = UserModel.fromJson(userSnapshot.data()!);
              postModel.userName = userModel.fullName ?? 'Unknown User';
              postModel.userProfileImage = userModel.profileImageUrl ?? '';
            }
          } catch (e) {
            // If user fetch fails, use default values
            postModel.userName = 'Unknown User';
            postModel.userProfileImage = '';
          }
        }

        posts.add(postModel);
      } catch (e) {
        // Skip malformed posts and continue processing
        print('Error processing post: $e');
        continue;
      }
    }

    return posts;
  }

  // UPDATED: Add comment with immediate stream update
  Future<void> _onAddComment(AddCommentEvent event, Emitter<CommunityFormState> emit) async {
    try {
      // Get current user details
      final userSnapshot = await firestore.collection("users").doc(auth?.uid).get();
      String userName = "Unknown User";
      String userProfileImage = "";

      if (userSnapshot.exists) {
        final userModel = UserModel.fromJson(userSnapshot.data()!);
        userName = userModel.fullName ?? "Unknown User";
        userProfileImage = userModel.profileImageUrl ?? "";
      }

      // Create comment map with likes/dislikes arrays
      final commentData = {
        'commentId': firestore.collection('temp').doc().id,
        'userId': auth?.uid ?? "",
        'userName': userName,
        'userProfileImage': userProfileImage,
        'content': event.content,
        'createDate': DateTime.now().toIso8601String(),
        'replies': <Map<String, dynamic>>[],
        'likes': <String>[], // Likes array for comment
        'dislikes': <String>[], // Dislikes array for comment
      };

      // Add comment to post - this will trigger the stream to update automatically
      await firestore.collection("communityForm").doc(event.postId).update({
        'comments': FieldValue.arrayUnion([commentData])
      });

      // Stream will handle UI update automatically
    } catch (e) {
      emit(PostError("Failed to add comment: $e"));
    }
  }

  // UPDATED: Add reply with immediate stream update
  Future<void> _onAddReply(AddReplyEvent event, Emitter<CommunityFormState> emit) async {
    try {
      // Get current user details
      final userSnapshot = await firestore.collection("users").doc(auth?.uid).get();
      String userName = "Unknown User";
      String userProfileImage = "";

      if (userSnapshot.exists) {
        final userModel = UserModel.fromJson(userSnapshot.data()!);
        userName = userModel.fullName ?? "Unknown User";
        userProfileImage = userModel.profileImageUrl ?? "";
      }

      // Use transaction for consistent update
      await firestore.runTransaction((transaction) async {
        final postRef = firestore.collection("communityForm").doc(event.postId);
        final postDoc = await transaction.get(postRef);

        if (!postDoc.exists) return;

        final postData = postDoc.data()!;
        List<Map<String, dynamic>> comments = List<Map<String, dynamic>>.from(postData['comments'] ?? []);

        // Find the comment to reply to
        for (int i = 0; i < comments.length; i++) {
          if (comments[i]['commentId'] == event.commentId) {
            // Create reply data with likes/dislikes arrays
            final replyData = {
              'replyId': firestore.collection('temp').doc().id,
              'userId': auth?.uid ?? "",
              'userName': userName,
              'userProfileImage': userProfileImage,
              'content': event.content,
              'createDate': DateTime.now().toIso8601String(),
              'likes': <String>[], // Likes array for reply
              'dislikes': <String>[], // Dislikes array for reply
            };

            // Add reply to the comment's replies array
            List<Map<String, dynamic>> replies = List<Map<String, dynamic>>.from(comments[i]['replies'] ?? []);
            replies.add(replyData);
            comments[i]['replies'] = replies;
            break;
          }
        }

        // Update the post with modified comments
        transaction.update(postRef, {'comments': comments});
      });

      // Stream will handle UI update automatically
    } catch (e) {
      emit(PostError("Failed to add reply: $e"));
    }
  }

  @override
  Future<void> close() {
    _postsSubscription?.cancel();
    return super.close();
  }
}