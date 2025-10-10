import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../logic/blocs/setting/community_forum/community_form_bloc.dart';
import '../../../logic/blocs/setting/community_forum/community_form_event.dart';


class CommentWidget extends StatefulWidget {
  final Map<String, dynamic> comment;
  final String postId;
  final int indent;

  const CommentWidget({
    Key? key,
    required this.comment,
    required this.postId,
    this.indent = 0,
  }) : super(key: key);

  @override
  _CommentWidgetState createState() => _CommentWidgetState();
}

class _CommentWidgetState extends State<CommentWidget> {
  bool _showReplyInput = false;
  final TextEditingController _replyController = TextEditingController();

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  void _toggleReplyInput() {
    setState(() {
      _showReplyInput = !_showReplyInput;
    });
  }

  void _submitReply() {
    if (_replyController.text.trim().isEmpty) return;

    context.read<CommunityFormBloc>().add(
      AddReplyEvent(
        postId: widget.postId,
        commentId: widget.comment['commentId'],
        content: _replyController.text.trim(),
      ),
    );

    _replyController.clear();
    setState(() {
      _showReplyInput = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(left: widget.indent * 20.0, top: 8.0, bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main comment
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: theme.cardColor.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: Colors.grey.shade300, width: 0.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User info row
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16.r,
                      backgroundImage: NetworkImage(
                        widget.comment['userProfileImage']?.isEmpty ?? true
                            ? 'https://i.pinimg.com/736x/3c/ae/07/3cae079ca0b9e55ec6bfc1b358c9b1e2.jpg'
                            : widget.comment['userProfileImage'],
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.comment['userName'] ?? 'Unknown User',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: theme.primaryColor,
                            ),
                          ),
                          Text(
                            _formatDate(widget.comment['createDate']),
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 11.sp,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Reply button
                    IconButton(
                      icon: Icon(
                        Icons.reply,
                        size: 18.sp,
                        color: const Color(0xff2D9CDB),
                      ),
                      onPressed: _toggleReplyInput,
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                // Comment content
                Text(
                  widget.comment['content'] ?? '',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 13.sp,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
              ],
            ),
          ),

          // Reply input field
          if (_showReplyInput)
            Container(
              margin: EdgeInsets.only(top: 8.h, left: 36.w),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _replyController,
                      style: const TextStyle(fontSize: 13, color: Colors.black),
                      decoration: const InputDecoration(
                        hintText: 'Write a reply...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      maxLines: 3,
                      minLines: 1,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _submitReply,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xff2D9CDB),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Reply',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Replies
          if (widget.comment['replies'] != null &&
              (widget.comment['replies'] as List).isNotEmpty)
            Column(
              children: (widget.comment['replies'] as List<dynamic>)
                  .map((reply) => CommentWidget(
                comment: reply as Map<String, dynamic>,
                postId: widget.postId,
                indent: widget.indent + 1,
              ))
                  .toList(),
            ),
        ],
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return '';
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return '';
    }
  }
}