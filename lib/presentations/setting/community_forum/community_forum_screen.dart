import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:payfussion/core/constants/routes_name.dart';
import 'package:payfussion/core/theme/theme.dart';
import 'package:payfussion/data/models/community_form/community_form_model.dart';
import 'package:payfussion/data/models/user/user_model.dart';
import '../../../core/circular_indicator.dart';
import '../../../core/constants/fonts.dart';
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
  final Map<String, TextEditingController> _commentControllers = <String, TextEditingController>{};
  final Map<String, AnimationController> _likeAnimations = <String, AnimationController>{};
  final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    for (TextEditingController controller in _commentControllers.values) {
      controller.dispose();
    }
    for (AnimationController controller in _likeAnimations.values) {
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
    final String key = '${postId}_$type';
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
    return firestore.collection("communityForm").orderBy('createDate', descending: true).snapshots().asyncMap((QuerySnapshot<Map<String, dynamic>> snapshot) async {
      final List<CommunityFormModel> posts = <CommunityFormModel>[];

      for (QueryDocumentSnapshot<Map<String, dynamic>> doc in snapshot.docs) {
        try {
          final Map<String, dynamic> postData = doc.data();
          final CommunityFormModel postModel = CommunityFormModel.fromMap(postData);

          // Fetch user details using userId
          if (postModel.userId.isNotEmpty) {
            try {
              final DocumentSnapshot<Map<String, dynamic>> userSnapshot = await firestore.collection("users").doc(postModel.userId).get();
              if (userSnapshot.exists) {
                final UserModel userModel = UserModel.fromJson(userSnapshot.data()!);
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
        actions: <Widget>[
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
        builder: (BuildContext context, AsyncSnapshot<List<CommunityFormModel>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingState();
          }

          if (snapshot.hasError) {
            return _buildErrorState('Error: ${snapshot.error}');
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState();
          }

          final List<CommunityFormModel> posts = snapshot.data!;
          return _buildPostsList(posts);
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: CircularIndicator.circular,
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.error_outline, size: 60.sp, color: Colors.red),
          SizedBox(height: 20.h),
          Text(
            'Failed to load posts',
            style: Font.montserratFont(fontSize: 16.sp, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 10.h),
          Text(
            error,
            style: Font.montserratFont(fontSize: 14.sp, color: Colors.grey.shade600),
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
          children: <Widget>[
            Icon(
              Icons.forum_outlined,
              size: 80.sp,
              color: Colors.grey,
            ),
            SizedBox(height: 20.h),
            Text(
              'No posts yet',
              style: Font.montserratFont(
                fontSize: 20.sp,
                color: Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              'Be the first to share something!',
              style: Font.montserratFont(
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
        itemBuilder: (BuildContext context, int index) {
          final CommunityFormModel post = posts[index];
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
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.light ? Colors.grey.withOpacity(0.3) : Colors.black.withOpacity(0.3),
            blurRadius: 5,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
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
        children: <Widget>[
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
              children: <Widget>[
                Text(
                  post.userName ?? 'Unknown User',
                  style: Font.montserratFont(
                    fontWeight: FontWeight.w600,
                    fontSize: 15.sp,
                  ),
                ),
                Text(
                  DatesUtils.formatDate(post.createDate),
                  style: Font.montserratFont(
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
        children: <Widget>[
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
                children: <Widget>[
                  Text(
                    post.question,
                    style: Font.montserratFont(
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
                        style: Font.montserratFont(
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
        children: <Widget>[
          if (likesCount > 0) ...<Widget>[
            Row(
              children: <Widget>[
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
                  style: Font.montserratFont(
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
              style: Font.montserratFont(
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
        children: <Widget>[
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
          children: <Widget>[
            Icon(icon, color: color, size: 20.sp),
            SizedBox(width: 8.w),
            Text(
              label,
              style: Font.montserratFont(
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
    final TextEditingController controller = _getCommentController(post.postId);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext modalContext) => StreamBuilder<DocumentSnapshot>(
        stream: firestore.collection("communityForm").doc(post.postId).snapshots(),
        builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot<Object?>> snapshot) {
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

          final Map<String, dynamic> postData = snapshot.data!.data() as Map<String, dynamic>;
          final List<Map<String, dynamic>> comments = List<Map<String, dynamic>>.from(postData['comments'] ?? <dynamic>[]);

          return DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.5,
            maxChildSize: 0.9,
            builder: (BuildContext context, ScrollController scrollController) => Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.r),
                  topRight: Radius.circular(20.r),
                ),
              ),
              child: Column(
                children: <Widget>[
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
                      children: <Widget>[
                        Text(
                          'Comments (${comments.length})',
                          style: Font.montserratFont(
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
                        children: <Widget>[
                          Icon(
                            Icons.comment_outlined,
                            size: 50.sp,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'No comments yet',
                            style: Font.montserratFont(
                              fontSize: 16.sp,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            'Be the first to comment!',
                            style: Font.montserratFont(
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
                      itemBuilder: (BuildContext context, int index) {
                        final Map<String, dynamic> comment = comments[index];
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
                      children: <Widget>[
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
                              style: Font.montserratFont(fontSize: 14.sp),
                              maxLines: null,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 12.h,
                                ),
                                hintText: 'Write a comment...',
                                hintStyle: Font.montserratFont(
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
        children: <Widget>[
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
                children: <Widget>[
                  Text(
                    comment['userName'] ?? 'Unknown User',
                    style: Font.montserratFont(
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    comment['content'] ?? '',
                    style: Font.montserratFont(
                      fontSize: 14.sp,
                      color: Colors.black87,
                      height: 1.3,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: <Widget>[
                      Text(
                        _formatCommentDate(comment['createDate']),
                        style: Font.montserratFont(
                          fontSize: 12.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      SizedBox(width: 16.w),
                      // Like button for comment
                      InkWell(
                        onTap: () => _handleCommentLike(postId, commentId, isCommentLiked),
                        child: Row(
                          children: <Widget>[
                            Icon(
                              isCommentLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                              size: 16.sp,
                              color: isCommentLiked ? MyTheme.primaryColor : Colors.grey.shade600,
                            ),
                            if (commentLikesCount > 0) ...<Widget>[
                              SizedBox(width: 4.w),
                              Text(
                                '$commentLikesCount',
                                style: Font.montserratFont(
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
                          style: Font.montserratFont(
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
                        children: <Widget>[
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
        children: <Widget>[
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
                children: <Widget>[
                  Text(
                    reply['userName'] ?? 'Unknown User',
                    style: Font.montserratFont(
                      fontWeight: FontWeight.w600,
                      fontSize: 13.sp,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    reply['content'] ?? '',
                    style: Font.montserratFont(
                      fontSize: 13.sp,
                      color: Colors.black87,
                      height: 1.3,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    children: <Widget>[
                      Text(
                        _formatCommentDate(reply['createDate']),
                        style: Font.montserratFont(
                          fontSize: 11.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      // Like button for reply
                      InkWell(
                        onTap: () => _handleReplyLike(postId, commentId, replyId, isReplyLiked),
                        child: Row(
                          children: <Widget>[
                            Icon(
                              isReplyLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                              size: 14.sp,
                              color: isReplyLiked ? MyTheme.primaryColor : Colors.grey.shade600,
                            ),
                            if (replyLikesCount > 0) ...<Widget>[
                              SizedBox(width: 3.w),
                              Text(
                                '$replyLikesCount',
                                style: Font.montserratFont(
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
      final DateTime date = DateTime.parse(dateString);
      final DateTime now = DateTime.now();
      final Duration difference = now.difference(date);

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
      final String? userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      final DocumentReference<Map<String, dynamic>> postRef = firestore.collection("communityForm").doc(postId);

      await firestore.runTransaction((Transaction transaction) async {
        final DocumentSnapshot<Map<String, dynamic>> postSnapshot = await transaction.get(postRef);
        if (!postSnapshot.exists) return;

        final Map<String, dynamic> postData = postSnapshot.data()!;
        final List<String> likes = List<String>.from(postData['likes'] ?? <dynamic>[]);
        final List<String> dislikes = List<String>.from(postData['dislikes'] ?? <dynamic>[]);

        // Remove from dislikes if present
        dislikes.remove(userId);

        // Toggle like
        if (likes.contains(userId)) {
          likes.remove(userId);
        } else {
          likes.add(userId);
        }

        transaction.update(postRef, <String, dynamic>{
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
      final String? userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      final DocumentReference<Map<String, dynamic>> postRef = firestore.collection("communityForm").doc(postId);

      await firestore.runTransaction((Transaction transaction) async {
        final DocumentSnapshot<Map<String, dynamic>> postSnapshot = await transaction.get(postRef);
        if (!postSnapshot.exists) return;

        final Map<String, dynamic> postData = postSnapshot.data()!;
        final List<Map<String, dynamic>> comments = List<Map<String, dynamic>>.from(postData['comments'] ?? <dynamic>[]);

        // Find and update the specific comment
        for (int i = 0; i < comments.length; i++) {
          if (comments[i]['commentId'] == commentId) {
            final List<String> likes = List<String>.from(comments[i]['likes'] ?? <dynamic>[]);
            final List<String> dislikes = List<String>.from(comments[i]['dislikes'] ?? <dynamic>[]);

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

        transaction.update(postRef, <String, dynamic>{'comments': comments});
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
      final String? userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      final DocumentReference<Map<String, dynamic>> postRef = firestore.collection("communityForm").doc(postId);

      await firestore.runTransaction((Transaction transaction) async {
        final DocumentSnapshot<Map<String, dynamic>> postSnapshot = await transaction.get(postRef);
        if (!postSnapshot.exists) return;

        final Map<String, dynamic> postData = postSnapshot.data()!;
        final List<Map<String, dynamic>> comments = List<Map<String, dynamic>>.from(postData['comments'] ?? <dynamic>[]);

        // Find the comment and then the reply
        for (int i = 0; i < comments.length; i++) {
          if (comments[i]['commentId'] == commentId) {
            final List<Map<String, dynamic>> replies = List<Map<String, dynamic>>.from(comments[i]['replies'] ?? <dynamic>[]);

            for (int j = 0; j < replies.length; j++) {
              if (replies[j]['replyId'] == replyId) {
                final List<String> likes = List<String>.from(replies[j]['likes'] ?? <dynamic>[]);
                final List<String> dislikes = List<String>.from(replies[j]['dislikes'] ?? <dynamic>[]);

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

        transaction.update(postRef, <String, dynamic>{'comments': comments});
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
      final String? userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      // Get current user details
      final DocumentSnapshot<Map<String, dynamic>> userSnapshot = await firestore.collection("users").doc(userId).get();
      String userName = "Unknown User";
      String userProfileImage = "";

      if (userSnapshot.exists) {
        final UserModel userModel = UserModel.fromJson(userSnapshot.data()!);
        userName = userModel.fullName ?? "Unknown User";
        userProfileImage = userModel.profileImageUrl ?? "";
      }

      // Create comment data
      final Map<String, Object> commentData = <String, Object>{
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
      await firestore.collection("communityForm").doc(postId).update(<Object, Object?>{
        'comments': FieldValue.arrayUnion(<dynamic>[commentData])
      });

      controller.clear();

      // Show success feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Comment added successfully!'),
            duration: Duration(seconds: 1),
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
      builder: (BuildContext dialogContext) => AlertDialog(
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
        actions: <Widget>[
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
      final String? userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      // Get current user details
      final DocumentSnapshot<Map<String, dynamic>> userSnapshot = await firestore.collection("users").doc(userId).get();
      String userName = "Unknown User";
      String userProfileImage = "";

      if (userSnapshot.exists) {
        final UserModel userModel = UserModel.fromJson(userSnapshot.data()!);
        userName = userModel.fullName ?? "Unknown User";
        userProfileImage = userModel.profileImageUrl ?? "";
      }

      await firestore.runTransaction((Transaction transaction) async {
        final DocumentReference<Map<String, dynamic>> postRef = firestore.collection("communityForm").doc(postId);
        final DocumentSnapshot<Map<String, dynamic>> postDoc = await transaction.get(postRef);

        if (!postDoc.exists) return;

        final Map<String, dynamic> postData = postDoc.data()!;
        final List<Map<String, dynamic>> comments = List<Map<String, dynamic>>.from(postData['comments'] ?? <dynamic>[]);

        // Find the comment to reply to
        for (int i = 0; i < comments.length; i++) {
          if (comments[i]['commentId'] == commentId) {
            // Create reply data
            final Map<String, Object> replyData = <String, Object>{
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
            final List<Map<String, dynamic>> replies = List<Map<String, dynamic>>.from(comments[i]['replies'] ?? <dynamic>[]);
            replies.add(replyData);
            comments[i]['replies'] = replies;
            break;
          }
        }

        // Update the post with modified comments
        transaction.update(postRef, <String, dynamic>{'comments': comments});
      });

      // Show success feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reply added successfully!'),
            duration: Duration(seconds: 1),
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