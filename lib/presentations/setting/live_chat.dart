import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:payfussion/core/theme/theme.dart';

import '../../logic/blocs/setting/live_chat/live_chat_bloc.dart';
import '../../logic/blocs/setting/live_chat/live_chat_event.dart';
import '../../logic/blocs/setting/live_chat/live_chat_state.dart';
import '../../services/live_chat_services.dart';

class LiveChatScreen extends StatefulWidget {
  const LiveChatScreen({super.key});

  @override
  State<LiveChatScreen> createState() => _LiveChatScreenState();
}

class _LiveChatScreenState extends State<LiveChatScreen>
    with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late ChatBloc _chatBloc;
  late String userId;
  late AnimationController _logoAnimationController;
  late Animation<double> _logoAnimation;
  bool _isComposing = false;

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _logoAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _logoAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: Curves.elasticOut,
    ));

    // Get current user ID
    userId = _getCurrentUserId();

    // Create bloc instance with userId
    _chatBloc = ChatBloc(userId: userId);
    _initializeChat();

    // Start logo animation
    _logoAnimationController.forward();

    // Add listener for text changes
    _messageController.addListener(() {
      setState(() {
        _isComposing = _messageController.text.trim().isNotEmpty;
      });
    });
  }

  String _getCurrentUserId() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return user.uid;
    }
    return 'guest_${DateTime.now().millisecondsSinceEpoch}';
  }

  Future<void> _initializeChat() async {
    try {
      await LiveChatServices().initializeDialogflow();
      print('DialogFlow initialized successfully');

      if (mounted) {
        _chatBloc.add(const LoadInitialMessages());
      }
    } catch (e) {
      print('Failed to initialize DialogFlow: $e');
      if (mounted) {
        _chatBloc.add(const LoadInitialMessages());
      }
    }
  }

  void _sendMessage() {
    final messageText = _messageController.text.trim();
    if (messageText.isNotEmpty) {
      _chatBloc.add(SendMessage(messageText));
      _messageController.clear();
      setState(() {
        _isComposing = false;
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _logoAnimationController.dispose();
    _scrollController.dispose();
    _messageController.dispose();
    _chatBloc.close();
    LiveChatServices().dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocProvider<ChatBloc>.value(
      value: _chatBloc,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: BlocListener<ChatBloc, ChatState>(
          bloc: _chatBloc,
          listener: (context, state) {
            if (state is ChatLoaded) {
              _scrollToBottom();
            }
          },
          child: Column(
            children: [
              SizedBox(height: 25.h),
              // Custom AppBar
              _buildCustomAppBar(theme, isDark),

              // Logo and Title Section
              _buildHeaderSection(),

              // Chat Messages Area
              Expanded(
                child: _buildChatArea(),
              ),

              // Typing Indicator
              _buildTypingIndicator(),

              // Message Input Area
              _buildMessageInput(theme, isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomAppBar(ThemeData theme, bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 15.h),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => context.go('/'),
            borderRadius: BorderRadius.circular(25),
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.arrow_back_ios_new,
                    color: const Color(0xff2D9CDB),
                    size: 22.r,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    'Back',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 18.sp,
                      color: const Color(0xff2D9CDB),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: const Color(0xff2D9CDB).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8.w,
                  height: 8.h,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 6.w),
                Text(
                  'Online',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: const Color(0xff2D9CDB),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 5.h),
      child: Column(
        children: [
          // Animated Logo
          AnimatedBuilder(
            animation: _logoAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _logoAnimation.value,
                child: Hero(
                  tag: 'logo',
                  child: Image.asset(
                    "assets/icons/logo.png",
                    height: 100,
                    width: 100,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 100,
                        width: 100,
                        decoration: const BoxDecoration(
                          color: Color(0xff2D9CDB),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.chat,
                          color: Colors.white,
                          size: 60,
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),

          SizedBox(height: 10.h),

          Text(
            'PayFussion',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
            ),
          ),

          SizedBox(height: 8.h),

          Text(
            '24/7 Support',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xff2D9CDB),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatArea() {
    return BlocBuilder<ChatBloc, ChatState>(
      bloc: _chatBloc,
      builder: (context, state) {
        if (state is ChatInitial || state is ChatLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xff2D9CDB),
            ),
          );
        }

        if (state is ChatError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 60.r,
                  color: Colors.red.withOpacity(0.7),
                ),
                SizedBox(height: 16.h),
                Text(
                  'Oops! Something went wrong',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.red,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  state.message,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20.h),
                ElevatedButton.icon(
                  onPressed: () {
                    _chatBloc.add(const LoadInitialMessages());
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Again'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff2D9CDB),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        if (state is ChatLoaded) {
          if (state.messages.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 80.r,
                    color: Colors.grey.withOpacity(0.5),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Start a conversation',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Send a message to begin chatting with support',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[500],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            controller: _scrollController,
            padding: EdgeInsets.all(16.w),
            itemCount: state.messages.length,
            itemBuilder: (context, index) {
              final message = state.messages[index];

              // Add null safety checks
              if (message == null) return const SizedBox.shrink();

              final sender = message['sender'] as String?;
              final text = message['text'] as String?;
              final timestamp = message['timestamp'];

              if (sender == null || text == null) {
                return const SizedBox.shrink();
              }

              final isUser = sender == 'user';
              final isFirstInGroup = index == 0 ||
                  (state.messages[index - 1] != null &&
                      state.messages[index - 1]['sender'] != sender);
              final isLastInGroup = index == state.messages.length - 1 ||
                  (index < state.messages.length - 1 &&
                      state.messages[index + 1] != null &&
                      state.messages[index + 1]['sender'] != sender);

              return AnimatedContainer(
                duration: Duration(milliseconds: 300 + (index * 50)),
                curve: Curves.easeOutBack,
                child: Column(
                  crossAxisAlignment: isUser
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    if (isFirstInGroup) SizedBox(height: 12.h),

                    Row(
                      mainAxisAlignment: isUser
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (!isUser && isLastInGroup)
                          Container(
                            margin: EdgeInsets.only(right: 8.w),
                            child: CircleAvatar(
                              radius: 16.r,
                              backgroundColor: const Color(0xff2D9CDB),
                              child: Icon(
                                Icons.support_agent,
                                color: Colors.white,
                                size: 18.r,
                              ),
                            ),
                          )
                        else if (!isUser)
                          SizedBox(width: 40.w),

                        Flexible(
                          child: Container(
                            margin: EdgeInsets.symmetric(
                              horizontal: 4.w,
                              vertical: 2.h,
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 12.h,
                            ),
                            decoration: BoxDecoration(
                              color: isUser ? MyTheme.primaryColor : Theme.of(context).brightness == Brightness.dark ? const Color(0xff2A2A2A) : Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(isUser ? 20.r : (isFirstInGroup ? 20.r : 8.r)),
                                topRight: Radius.circular(isUser ? (isFirstInGroup ? 20.r : 8.r) : 20.r),
                                bottomLeft: Radius.circular(isUser ? 20.r : (isLastInGroup ? 8.r : 20.r)),
                                bottomRight: Radius.circular(isUser ? (isLastInGroup ? 8.r : 20.r) : 20.r),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: (isUser
                                      ? const Color(0xff2D9CDB)
                                      : Colors.grey).withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  text,
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    color: isUser
                                        ? Colors.white
                                        : Theme.of(context).textTheme.bodyLarge?.color,
                                    height: 1.3,
                                  ),
                                ),
                                if (isLastInGroup && timestamp != null)
                                  Padding(
                                    padding: EdgeInsets.only(top: 4.h),
                                    child: Text(
                                      _formatTimestamp(timestamp),
                                      style: TextStyle(
                                        fontSize: 11.sp,
                                        color: isUser
                                            ? Colors.white.withOpacity(0.8)
                                            : Colors.grey[500],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),

                        if (isUser && isLastInGroup)
                          Container(
                            margin: EdgeInsets.only(left: 8.w),
                            child: CircleAvatar(
                              radius: 16.r,
                              backgroundColor: Colors.grey[300],
                              child: Icon(
                                Icons.person,
                                color: Colors.grey[600],
                                size: 18.r,
                              ),
                            ),
                          )
                        else if (isUser)
                          SizedBox(width: 40.w),
                      ],
                    ),

                    if (isLastInGroup) SizedBox(height: 16.h),
                  ],
                ),
              );
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildTypingIndicator() {
    return BlocBuilder<ChatBloc, ChatState>(
      bloc: _chatBloc,
      builder: (context, state) {
        if (state is ChatLoaded && state.isTyping) {
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16.r,
                  backgroundColor: const Color(0xff2D9CDB),
                  child: Icon(
                    Icons.support_agent,
                    color: Colors.white,
                    size: 18.r,
                  ),
                ),
                SizedBox(width: 12.w),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xff2A2A2A)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 20.w,
                        height: 20.h,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xff2D9CDB),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        'Support is typing...',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildMessageInput(ThemeData theme, bool isDark) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xff2A2A2A) : const Color(0xffF5F5F5),
                borderRadius: BorderRadius.circular(25.r),
                border: _isComposing
                    ? Border.all(color: const Color(0xff2D9CDB), width: 2)
                    : null,
              ),
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Type your message...',
                  hintStyle: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 16.sp,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 14.h,
                  ),
                  prefixIcon: Icon(
                    Icons.message_outlined,
                    color: Colors.grey[500],
                    size: 20.r,
                  ),
                ),
                style: TextStyle(
                  color: theme.textTheme.bodyLarge?.color,
                  fontSize: 16.sp,
                ),
                cursorColor: const Color(0xff2D9CDB),
                onSubmitted: (_) => _sendMessage(),
                textInputAction: TextInputAction.send,
                maxLines: 4,
                minLines: 1,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          BlocBuilder<ChatBloc, ChatState>(
            bloc: _chatBloc,
            builder: (context, state) {
              final isLoading = state is ChatLoaded && state.isTyping;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isLoading ? Colors.grey : MyTheme.primaryColor,
                  shape: BoxShape.circle,
                  boxShadow: !isLoading
                      ? [
                    BoxShadow(
                      color: const Color(0xff2D9CDB).withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                      : null,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(28.r),
                    onTap: isLoading || !_isComposing ? null : _sendMessage,
                    child: SizedBox(
                      width: 56.w,
                      height: 56.h,
                      child: Icon(
                        isLoading
                            ? Icons.more_horiz
                            : _isComposing
                            ? Icons.send_rounded
                            : Icons.send_rounded,
                        color: Colors.white,
                        size: 24.r,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(dynamic timestamp) {
    DateTime? dateTime;

    if (timestamp is DateTime) {
      dateTime = timestamp;
    } else if (timestamp is String) {
      dateTime = DateTime.tryParse(timestamp);
    } else if (timestamp is int) {
      dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    }

    if (dateTime == null) {
      return 'Now';
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDate == today) {
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else {
      return '${dateTime.day}/${dateTime.month} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }
}