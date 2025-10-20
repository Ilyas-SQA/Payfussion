import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:payfussion/core/constants/routes_name.dart';
import 'package:payfussion/core/theme/theme.dart';
import 'package:payfussion/data/models/community_form/community_form_model.dart';
import 'package:payfussion/data/models/user/user_model.dart';
import '../../../core/utils/dates_utils.dart';
import 'create_forum_post.dart';

class CommunityForumScreen extends StatefulWidget {
  const CommunityForumScreen({super.key});

  @override
  State<CommunityForumScreen> createState() => _CommunityForumScreenState();
}

class _CommunityForumScreenState extends State<CommunityForumScreen>
    with TickerProviderStateMixin {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final Map<String, TextEditingController> _commentControllers = {};
  final Map<String, AnimationController> _likeAnimations = {};
  final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    for (var controller in _commentControllers.values) {
      controller.dispose();
    }
    for (var controller in _likeAnimations.values) {
      controller.dispose();
    }
    super.dispose();
  }

  TextEditingController _getCommentController(String postId) {
    if (!_commentControllers.containsKey(postId)) {
      _commentControllers[postId] = TextEditingController();
    }
    return _commentControllers[postId]!;
  }

  AnimationController _getOrCreateAnimationController(String postId, String type) {
    final key = '${postId}_$type';
    if (!_likeAnimations.containsKey(key)) {
      _likeAnimations[key] = AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
      );
    }
    return _likeAnimations[key]!;
  }

  // Stream for real-time posts data
  Stream<List<CommunityFormModel>> get postsStream {
    return firestore.collection("communityForm").orderBy('createDate', descending: true).snapshots().asyncMap((snapshot) async {
      final List<CommunityFormModel> posts = [];

      for (var doc in snapshot.docs) {
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
              postModel.userName = 'Unknown User';
              postModel.userProfileImage = '';
            }
          }

          posts.add(postModel);
        } catch (e) {
          print('Error processing post: $e');
          continue;
        }
      }

      return posts;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Community Forum",),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
            child: Container(
              decoration: BoxDecoration(
                color: MyTheme.primaryColor,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: IconButton(
                icon: Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 22.sp,
                ),
                onPressed: () {
                  context.push(
                    RouteNames.createPost,
                    extra: CreatePostScreen(),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      body: StreamBuilder<List<CommunityFormModel>>(
        stream: postsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingState();
          }

          if (snapshot.hasError) {
            return _buildErrorState('Error: ${snapshot.error}');
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState();
          }

          final posts = snapshot.data!;
          return _buildPostsList(posts);
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        color: MyTheme.primaryColor,
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 60.sp, color: Colors.red),
          SizedBox(height: 20.h),
          Text(
            'Failed to load posts',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 10.h),
          Text(
            error,
            style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.forum_outlined,
              size: 80.sp,
              color: Colors.grey,
            ),
            SizedBox(height: 20.h),
            Text(
              'No posts yet',
              style: TextStyle(
                fontSize: 20.sp,
                color: Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              'Be the first to share something!',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostsList(List<CommunityFormModel> posts) {
    return RefreshIndicator(
      onRefresh: () async {
        // Force refresh by rebuilding stream
        setState(() {});
      },
      color: MyTheme.primaryColor,
      backgroundColor: Colors.white,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          return _buildPostCard(post);
        },
      ),
    );
  }

  Widget _buildPostCard(CommunityFormModel post) {
    final bool isLiked = (post.likes as List?)?.contains(currentUserId) ?? false;
    final int likesCount = (post.likes as List?)?.length ?? 0;
    final int commentsCount = (post.comments as List?)?.length ?? 0;

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(5.r),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.light ? Colors.grey.withOpacity(0.3) : Colors.black.withOpacity(0.3),
            blurRadius: 5,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post Header
          _buildPostHeader(post),

          // Post Content
          _buildPostContent(post),

          // Interaction counts (likes, comments)
          if (likesCount > 0 || commentsCount > 0)
            _buildInteractionCounts(likesCount, commentsCount),

          // Action Buttons (Like, Comment, Share)
          _buildActionButtons(post, isLiked, likesCount, commentsCount),
        ],
      ),
    );
  }

  Widget _buildPostHeader(CommunityFormModel post) {
    return Padding(
      padding: EdgeInsets.all(12.w),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20.r,
            backgroundColor: Colors.grey.shade300,
            backgroundImage: NetworkImage(
              post.userProfileImage?.isNotEmpty == true
                  ? post.userProfileImage!
                  : 'https://i.pinimg.com/736x/3c/ae/07/3cae079ca0b9e55ec6bfc1b358c9b1e2.jpg',
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.userName ?? 'Unknown User',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15.sp,
                  ),
                ),
                Text(
                  DatesUtils.formatDate(post.createDate),
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostContent(CommunityFormModel post) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (post.question.isNotEmpty)
            Container(
              width: double.infinity,
              height: 300.h,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: MyTheme.primaryColor,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    post.question,
                    style: TextStyle(
                      fontSize: 18.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20.h,),
                  if (post.content.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: Text(
                        post.content,
                        style: TextStyle(
                          fontSize: 15.sp,
                          height: 1.3,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInteractionCounts(int likesCount, int commentsCount) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      child: Row(
        children: [
          if (likesCount > 0) ...[
            Row(
              children: [
                Container(
                  width: 20.w,
                  height: 20.h,
                  decoration: const BoxDecoration(
                    color: MyTheme.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.thumb_up,
                    color: Colors.white,
                    size: 12.sp,
                  ),
                ),
                SizedBox(width: 6.w),
                Text(
                  '$likesCount',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13.sp,
                  ),
                ),
              ],
            ),
          ],
          const Spacer(),
          if (commentsCount > 0)
            Text(
              '$commentsCount ${commentsCount == 1 ? 'comment' : 'comments'}',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13.sp,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(CommunityFormModel post, bool isLiked, int likesCount, int commentsCount) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey.shade300, width: 0.5),
          bottom: BorderSide(color: Colors.grey.shade300, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildActionButton(
              icon: isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
              label: 'Like',
              color: isLiked ? MyTheme.primaryColor : Colors.grey.shade600,
              onTap: () => _handleLike(post.postId, isLiked),
            ),
          ),
          Expanded(
            child: _buildActionButton(
              icon: Icons.mode_comment_outlined,
              label: 'Comment',
              color: Colors.grey.shade600,
              onTap: () => _showCommentsBottomSheet(context, post),
            ),
          ),
          Expanded(
            child: _buildActionButton(
              icon: Icons.share_outlined,
              label: 'Share',
              color: Colors.grey.shade600,
              onTap: () => _handleShare(post),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20.sp),
            SizedBox(width: 8.w),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Comments bottom sheet with StreamBuilder for real-time updates
  void _showCommentsBottomSheet(BuildContext context, CommunityFormModel post) {
    final controller = _getCommentController(post.postId);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (modalContext) => StreamBuilder<DocumentSnapshot>(
        stream: firestore.collection("communityForm").doc(post.postId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.r),
                  topRight: Radius.circular(20.r),
                ),
              ),
              child: const Center(child: CircularProgressIndicator()),
            );
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.r),
                  topRight: Radius.circular(20.r),
                ),
              ),
              child: const Center(child: Text('Post not found')),
            );
          }

          final postData = snapshot.data!.data() as Map<String, dynamic>;
          final comments = List<Map<String, dynamic>>.from(postData['comments'] ?? []);

          return DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.5,
            maxChildSize: 0.9,
            builder: (context, scrollController) => Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.r),
                  topRight: Radius.circular(20.r),
                ),
              ),
              child: Column(
                children: [
                  // Handle bar
                  Container(
                    margin: EdgeInsets.only(top: 8.h),
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),

                  // Header
                  Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Comments (${comments.length})',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(modalContext),
                          icon: Icon(Icons.close, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),

                  // Comments List
                  Expanded(
                    child: comments.isEmpty
                        ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.comment_outlined,
                            size: 50.sp,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'No comments yet',
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            'Be the first to comment!',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    )
                        : ListView.builder(
                      controller: scrollController,
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      itemCount: comments.length,
                      itemBuilder: (context, index) {
                        final comment = comments[index];
                        return _buildCommentItem(comment, post.postId);
                      },
                    ),
                  ),

                  // Add Comment Section
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Colors.grey.shade200),
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20.r,
                          backgroundColor: Colors.grey.shade300,
                          backgroundImage: NetworkImage(
                            FirebaseAuth.instance.currentUser?.photoURL?.isNotEmpty == true
                                ? FirebaseAuth.instance.currentUser!.photoURL!
                                : 'https://i.pinimg.com/736x/3c/ae/07/3cae079ca0b9e55ec6bfc1b358c9b1e2.jpg',
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(20.r),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: TextField(
                              controller: controller,
                              style: TextStyle(fontSize: 14.sp),
                              maxLines: null,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 12.h,
                                ),
                                hintText: 'Write a comment...',
                                hintStyle: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 14.sp,
                                ),
                                border: InputBorder.none,
                                suffixIcon: IconButton(
                                  onPressed: () => _addComment(post.postId, controller),
                                  icon: Icon(
                                    Icons.send,
                                    color: MyTheme.primaryColor,
                                    size: 20.sp,
                                  ),
                                ),
                              ),
                              onSubmitted: (_) => _addComment(post.postId, controller),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCommentItem(Map<String, dynamic> comment, String postId) {
    final bool isCommentLiked = (comment['likes'] as List?)?.contains(currentUserId) ?? false;
    final int commentLikesCount = (comment['likes'] as List?)?.length ?? 0;
    final String commentId = comment['commentId'] ?? '';

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18.r,
            backgroundColor: Colors.grey.shade300,
            backgroundImage: NetworkImage(
              comment['userProfileImage']?.isNotEmpty == true
                  ? comment['userProfileImage']
                  : 'https://i.pinimg.com/736x/3c/ae/07/3cae079ca0b9e55ec6bfc1b358c9b1e2.jpg',
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    comment['userName'] ?? 'Unknown User',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    comment['content'] ?? '',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.black87,
                      height: 1.3,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Text(
                        _formatCommentDate(comment['createDate']),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      SizedBox(width: 16.w),
                      // Like button for comment
                      InkWell(
                        onTap: () => _handleCommentLike(postId, commentId, isCommentLiked),
                        child: Row(
                          children: [
                            Icon(
                              isCommentLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                              size: 16.sp,
                              color: isCommentLiked ? MyTheme.primaryColor : Colors.grey.shade600,
                            ),
                            if (commentLikesCount > 0) ...[
                              SizedBox(width: 4.w),
                              Text(
                                '$commentLikesCount',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      SizedBox(width: 16.w),
                      // Reply button
                      InkWell(
                        onTap: () => _showReplyDialog(context, postId, commentId),
                        child: Text(
                          'Reply',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Show replies if any
                  if (comment['replies'] != null && (comment['replies'] as List).isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: 12.h, left: 16.w),
                      child: Column(
                        children: [
                          for (var reply in (comment['replies'] as List))
                            _buildReplyItem(reply, postId, commentId),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReplyItem(Map<String, dynamic> reply, String postId, String commentId) {
    final bool isReplyLiked = (reply['likes'] as List?)?.contains(currentUserId) ?? false;
    final int replyLikesCount = (reply['likes'] as List?)?.length ?? 0;
    final String replyId = reply['replyId'] ?? '';

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 14.r,
            backgroundColor: Colors.grey.shade300,
            backgroundImage: NetworkImage(
              reply['userProfileImage']?.isNotEmpty == true
                  ? reply['userProfileImage']
                  : 'https://i.pinimg.com/736x/3c/ae/07/3cae079ca0b9e55ec6bfc1b358c9b1e2.jpg',
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reply['userName'] ?? 'Unknown User',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13.sp,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    reply['content'] ?? '',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.black87,
                      height: 1.3,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      Text(
                        _formatCommentDate(reply['createDate']),
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      // Like button for reply
                      InkWell(
                        onTap: () => _handleReplyLike(postId, commentId, replyId, isReplyLiked),
                        child: Row(
                          children: [
                            Icon(
                              isReplyLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                              size: 14.sp,
                              color: isReplyLiked ? MyTheme.primaryColor : Colors.grey.shade600,
                            ),
                            if (replyLikesCount > 0) ...[
                              SizedBox(width: 3.w),
                              Text(
                                '$replyLikesCount',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatCommentDate(String? dateString) {
    if (dateString == null) return 'Now';
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inMinutes < 1) return 'Now';
      if (difference.inMinutes < 60) return '${difference.inMinutes}m';
      if (difference.inHours < 24) return '${difference.inHours}h';
      if (difference.inDays < 7) return '${difference.inDays}d';

      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Now';
    }
  }

  // Like handler for posts
  Future<void> _handleLike(String postId, bool isCurrentlyLiked) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      final postRef = firestore.collection("communityForm").doc(postId);

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

      // Show feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isCurrentlyLiked ? 'Post unliked' : 'Post liked!'),
            duration: const Duration(milliseconds: 800),
            backgroundColor: isCurrentlyLiked ? Colors.grey : MyTheme.primaryColor,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(bottom: 100.h),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to like post: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // Comment like handler
  Future<void> _handleCommentLike(String postId, String commentId, bool isCurrentlyLiked) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      final postRef = firestore.collection("communityForm").doc(postId);

      await firestore.runTransaction((transaction) async {
        final postSnapshot = await transaction.get(postRef);
        if (!postSnapshot.exists) return;

        final postData = postSnapshot.data()!;
        List<Map<String, dynamic>> comments = List<Map<String, dynamic>>.from(postData['comments'] ?? []);

        // Find and update the specific comment
        for (int i = 0; i < comments.length; i++) {
          if (comments[i]['commentId'] == commentId) {
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

      // Show feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isCurrentlyLiked ? 'Comment unliked' : 'Comment liked!'),
            duration: const Duration(milliseconds: 600),
            backgroundColor: isCurrentlyLiked ? Colors.grey : MyTheme.primaryColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to like comment: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // Reply like handler
  Future<void> _handleReplyLike(String postId, String commentId, String replyId, bool isCurrentlyLiked) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      final postRef = firestore.collection("communityForm").doc(postId);

      await firestore.runTransaction((transaction) async {
        final postSnapshot = await transaction.get(postRef);
        if (!postSnapshot.exists) return;

        final postData = postSnapshot.data()!;
        List<Map<String, dynamic>> comments = List<Map<String, dynamic>>.from(postData['comments'] ?? []);

        // Find the comment and then the reply
        for (int i = 0; i < comments.length; i++) {
          if (comments[i]['commentId'] == commentId) {
            List<Map<String, dynamic>> replies = List<Map<String, dynamic>>.from(comments[i]['replies'] ?? []);

            for (int j = 0; j < replies.length; j++) {
              if (replies[j]['replyId'] == replyId) {
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

      // Show feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isCurrentlyLiked ? 'Reply unliked' : 'Reply liked!'),
            duration: const Duration(milliseconds: 600),
            backgroundColor: isCurrentlyLiked ? Colors.grey : MyTheme.primaryColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to like reply: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _handleShare(CommunityFormModel post) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share functionality coming soon!')),
    );
  }

  // Add comment
  Future<void> _addComment(String postId, TextEditingController controller) async {
    if (controller.text.trim().isEmpty) return;

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      // Get current user details
      final userSnapshot = await firestore.collection("users").doc(userId).get();
      String userName = "Unknown User";
      String userProfileImage = "";

      if (userSnapshot.exists) {
        final userModel = UserModel.fromJson(userSnapshot.data()!);
        userName = userModel.fullName ?? "Unknown User";
        userProfileImage = userModel.profileImageUrl ?? "";
      }

      // Create comment data
      final commentData = {
        'commentId': firestore.collection('temp').doc().id,
        'userId': userId,
        'userName': userName,
        'userProfileImage': userProfileImage,
        'content': controller.text.trim(),
        'createDate': DateTime.now().toIso8601String(),
        'replies': <Map<String, dynamic>>[],
        'likes': <String>[],
        'dislikes': <String>[],
      };

      // Add comment to post
      await firestore.collection("communityForm").doc(postId).update({
        'comments': FieldValue.arrayUnion([commentData])
      });

      controller.clear();

      // Show success feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Comment added successfully!'),
            duration: const Duration(seconds: 1),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add comment: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // Reply dialog
  void _showReplyDialog(BuildContext context, String postId, String commentId) {
    final TextEditingController replyController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reply to Comment'),
        content: TextField(
          controller: replyController,
          decoration: const InputDecoration(
            hintText: 'Write your reply...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (replyController.text.trim().isNotEmpty) {
                await _addReply(postId, commentId, replyController.text.trim());
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('Reply'),
          ),
        ],
      ),
    );
  }

  // Add reply
  Future<void> _addReply(String postId, String commentId, String content) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      // Get current user details
      final userSnapshot = await firestore.collection("users").doc(userId).get();
      String userName = "Unknown User";
      String userProfileImage = "";

      if (userSnapshot.exists) {
        final userModel = UserModel.fromJson(userSnapshot.data()!);
        userName = userModel.fullName ?? "Unknown User";
        userProfileImage = userModel.profileImageUrl ?? "";
      }

      await firestore.runTransaction((transaction) async {
        final postRef = firestore.collection("communityForm").doc(postId);
        final postDoc = await transaction.get(postRef);

        if (!postDoc.exists) return;

        final postData = postDoc.data()!;
        List<Map<String, dynamic>> comments = List<Map<String, dynamic>>.from(postData['comments'] ?? []);

        // Find the comment to reply to
        for (int i = 0; i < comments.length; i++) {
          if (comments[i]['commentId'] == commentId) {
            // Create reply data
            final replyData = {
              'replyId': firestore.collection('temp').doc().id,
              'userId': userId,
              'userName': userName,
              'userProfileImage': userProfileImage,
              'content': content,
              'createDate': DateTime.now().toIso8601String(),
              'likes': <String>[],
              'dislikes': <String>[],
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

      // Show success feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Reply added successfully!'),
            duration: const Duration(seconds: 1),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add reply: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

}