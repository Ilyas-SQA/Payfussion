import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:payfussion/core/circular_indicator.dart';
import 'package:payfussion/core/theme/theme.dart';
import '../../core/constants/fonts.dart';
import '../../logic/blocs/setting/live_chat/live_chat_bloc.dart';
import '../../logic/blocs/setting/live_chat/live_chat_event.dart';
import '../../logic/blocs/setting/live_chat/live_chat_state.dart';
import '../../services/live_chat_services.dart';
import '../widgets/background_theme.dart';

class LiveChatScreen extends StatefulWidget {
  const LiveChatScreen({super.key});

  @override
  State<LiveChatScreen> createState() => _LiveChatScreenState();
}

class _LiveChatScreenState extends State<LiveChatScreen> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late ChatBloc _chatBloc;
  late String userId;
  late AnimationController _logoAnimationController;
  late Animation<double> _logoAnimation;
  bool _isComposing = false;
  late AnimationController _backgroundAnimationController;


  @override
  void initState() {
    super.initState();
    _backgroundAnimationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
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
    final User? user = FirebaseAuth.instance.currentUser;
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
    final String messageText = _messageController.text.trim();
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
    _backgroundAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    return BlocProvider<ChatBloc>.value(
      value: _chatBloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Live Chat"),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: BlocListener<ChatBloc, ChatState>(
          bloc: _chatBloc,
          listener: (BuildContext context, ChatState state) {
            if (state is ChatLoaded) {
              _scrollToBottom();
            }
          },
          child: Stack(
            children: <Widget>[
              AnimatedBackground(
                animationController: _backgroundAnimationController,
              ),
              Column(
                children: <Widget>[
                  /// Chat Messages Area
                  Expanded(
                    child: _buildChatArea(),
                  ),

                  /// Typing Indicator
                  _buildTypingIndicator(),

                  /// Message Input Area
                  _buildMessageInput(theme, isDark),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatArea() {
    return BlocBuilder<ChatBloc, ChatState>(
      bloc: _chatBloc,
      builder: (BuildContext context, ChatState state) {
        if (state is ChatInitial || state is ChatLoading) {
          return Center(
            child: CircularIndicator.circular,
          );
        }

        if (state is ChatError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.error_outline,
                  size: 60.r,
                  color: Colors.red.withOpacity(0.7),
                ),
                SizedBox(height: 16.h),
                Text(
                  'Oops! Something went wrong',
                  style: Font.montserratFont(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.red,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  state.message,
                  style: Font.montserratFont(
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
                    backgroundColor: MyTheme.primaryColor,
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
                children: <Widget>[
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 80.r,
                    color: MyTheme.primaryColor,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Start a conversation',
                    style: Font.montserratFont(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Send a message to begin chatting with support',
                    style: Font.montserratFont(
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
            itemBuilder: (BuildContext context, int index) {
              final Map<String, dynamic> message = state.messages[index];

              final String? sender = message['sender'] as String?;
              final String? text = message['text'] as String?;
              final timestamp = message['timestamp'];

              if (sender == null || text == null) {
                return const SizedBox.shrink();
              }

              final bool isUser = sender == 'user';
              final bool isFirstInGroup = index == 0 || (state.messages[index - 1]['sender'] != sender);
              final bool isLastInGroup = index == state.messages.length - 1 || (index < state.messages.length - 1 && state.messages[index + 1]['sender'] != sender);
              return AnimatedContainer(
                duration: Duration(milliseconds: 300 + (index * 50)),
                curve: Curves.easeOutBack,
                child: Column(
                  crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: <Widget>[
                    if (isFirstInGroup) SizedBox(height: 12.h),

                    Row(
                      mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        if (!isUser && isLastInGroup)
                          Container(
                            margin: EdgeInsets.only(right: 8.w),
                            child: CircleAvatar(
                              radius: 16.r,
                              backgroundColor: MyTheme.primaryColor,
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
                              color: isUser ? MyTheme.secondaryColor : Theme.of(context).brightness == Brightness.dark ? MyTheme.primaryColor : Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(isUser ? 20.r : (isFirstInGroup ? 20.r : 8.r)),
                                topRight: Radius.circular(isUser ? (isFirstInGroup ? 20.r : 8.r) : 20.r),
                                bottomLeft: Radius.circular(isUser ? 20.r : (isLastInGroup ? 8.r : 20.r)),
                                bottomRight: Radius.circular(isUser ? (isLastInGroup ? 8.r : 20.r) : 20.r),
                              ),
                              // boxShadow: [
                              //   BoxShadow(
                              //     color: (isUser ? MyTheme.primaryColor : Colors.grey).withOpacity(0.2),
                              //     blurRadius: 8,
                              //     offset: const Offset(0, 2),
                              //   ),
                              // ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  text,
                                  style: Font.montserratFont(
                                    fontSize: 16.sp,
                                    height: 1.3,
                                    color: isUser ? Colors.white : Colors.black,
                                  ),
                                ),
                                if (isLastInGroup && timestamp != null)
                                  Padding(
                                    padding: EdgeInsets.only(top: 4.h),
                                    child: Text(
                                      _formatTimestamp(timestamp),
                                      style: Font.montserratFont(
                                        fontSize: 11.sp,
                                        color: isUser ? Colors.white : Colors.black,
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
      builder: (BuildContext context, ChatState state) {
        if (state is ChatLoaded && state.isTyping) {
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
            child: Row(
              children: <Widget>[
                CircleAvatar(
                  radius: 16.r,
                  backgroundColor: MyTheme.primaryColor,
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
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      SizedBox(
                        width: 20.w,
                        height: 20.h,
                        child: CircularIndicator.circular,
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        'Support is typing...',
                        style: Font.montserratFont(
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
      padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 25),
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
      child: Row(
        children: <Widget>[
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xff2A2A2A) : const Color(0xffF5F5F5),
                borderRadius: BorderRadius.circular(25.r),
                border: _isComposing ? Border.all(color: const Color(0xff2D9CDB), width: 2) : null,
              ),
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Type your message...',
                  hintStyle: Font.montserratFont(
                    color: Colors.grey[500],
                    fontSize: 12.sp,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 14.h,
                  ),
                  prefixIcon: Icon(
                    Icons.message_outlined,
                    color: MyTheme.primaryColor,
                    size: 20.r,
                  ),
                ),
                style: Font.montserratFont(
                  color: theme.textTheme.bodyLarge?.color,
                  fontSize: 16.sp,
                ),
                cursorColor: MyTheme.primaryColor,
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
            builder: (BuildContext context, ChatState state) {
              final bool isLoading = state is ChatLoaded && state.isTyping;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isLoading ? Colors.grey : MyTheme.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(28.r),
                  onTap: isLoading || !_isComposing ? null : _sendMessage,
                  child: SizedBox(
                    width: 50.w,
                    height: 50.h,
                    child: Icon(
                      isLoading ? Icons.more_horiz : _isComposing ? Icons.send_rounded : Icons.send_rounded,
                      color: Colors.white,
                      size: 24.r,
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

    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDate == today) {
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else {
      return '${dateTime.day}/${dateTime.month} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }
}