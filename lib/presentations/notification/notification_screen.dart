import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:shimmer/shimmer.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../data/models/notification/notification_model.dart';
import '../../../logic/blocs/notification/notification_bloc.dart';
import '../../../logic/blocs/notification/notification_event.dart';
import '../../../logic/blocs/notification/notification_state.dart';
import '../../core/constants/fonts.dart';
import '../../core/theme/theme.dart';
import '../widgets/background_theme.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> with TickerProviderStateMixin {
  String _selectedFilter = 'all';

  late AnimationController _headerController;
  late AnimationController _contentController;
  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;
  late AnimationController _backgroundAnimationController;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startAnimations();
    context.read<NotificationBloc>().add(OpenNotificationScreen());
    _backgroundAnimationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
  }

  void _initAnimations() {
    _headerController = AnimationController(duration: const Duration(milliseconds: 400), vsync: this);
    _contentController = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
    _headerFade = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _headerController, curve: Curves.easeOut));
    _headerSlide = Tween<Offset>(begin: const Offset(0, -0.3), end: Offset.zero).animate(
        CurvedAnimation(parent: _headerController, curve: Curves.easeOut));
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _headerController.forward();
    await Future.delayed(const Duration(milliseconds: 100));
    _contentController.forward();
  }

  @override
  void dispose() {
    _headerController.dispose();
    _contentController.dispose();
    _backgroundAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: SlideTransition(
          position: _headerSlide,
          child: FadeTransition(
            opacity: _headerFade,
            child: Text('Notifications', style: Font.montserratFont(fontWeight: FontWeight.w600,),),),),
        actions: <Widget>[
          SlideTransition(
              position: Tween<Offset>(begin: const Offset(0.5, 0), end: Offset.zero).animate(_headerController),
              child: FadeTransition(
                  opacity: _headerFade,
                  child: PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert),
                      onSelected: (String value) {
                        switch (value) {
                          case 'mark_all_read': context.read<NotificationBloc>().add(MarkAllNotificationsAsRead()); break;
                          case 'clear_all': _showClearAllDialog(); break;
                        }
                      },
                      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                        const PopupMenuItem(value: 'mark_all_read',
                            child: Row(children: <Widget>[Icon(Icons.mark_email_read, size: 20), SizedBox(width: 12), Text('Mark All Read')])),
                        const PopupMenuItem(value: 'clear_all',
                            child: Row(children: <Widget>[Icon(Icons.clear_all, size: 20), SizedBox(width: 12), Text('Clear All')]))
                      ]))),
        ],
      ),
      body: Stack(
        children: <Widget>[
          AnimatedBackground(
            animationController: _backgroundAnimationController,
          ),
          Column(
              children: <Widget>[
                SlideTransition(
                  position: Tween<Offset>(begin: const Offset(0, -0.2), end: Offset.zero).animate(_headerController),
                  child: FadeTransition(opacity: _headerFade, child: _buildFilterTabs(),
                  ),
                ),
                Expanded(
                  child: FadeTransition(
                    opacity: _contentController,
                    child: BlocConsumer<NotificationBloc, NotificationState>(
                            listener: (BuildContext context, NotificationState state) {
                              if (state is NotificationError) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(state.message), backgroundColor: Colors.red));
                              } else if (state is NotificationSuccess) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(state.message), backgroundColor: Colors.green));
                              }
                            },
                            builder: (BuildContext context, NotificationState state) {
                              if (state is NotificationLoading) {
                                return _buildShimmerLoading();
                              }

                              if (state is NotificationsLoaded) {
                                final List<NotificationModel> filteredNotifications =
                                _filterNotifications(state.notifications);

                                if (filteredNotifications.isEmpty) {
                                  return _buildEmptyState();
                                }

                                return RefreshIndicator(
                                    onRefresh: () async {
                                      context.read<NotificationBloc>().add(LoadNotifications());
                                    },
                                    child: AnimationLimiter(
                                        child: ListView.builder(
                                            padding: const EdgeInsets.all(16),
                                            itemCount: filteredNotifications.length,
                                            itemBuilder: (BuildContext context, int index) {
                                              final NotificationModel notification =
                                              filteredNotifications[index];
                                              return AnimationConfiguration.staggeredList(
                                                  position: index,
                                                  duration: const Duration(milliseconds: 200),
                                                  child: SlideAnimation(
                                                      verticalOffset: 30.0,
                                                      child: FadeInAnimation(
                                                          child: _buildNotificationCard(notification)
                                                      )
                                                  )
                                              );
                                            }
                                        )
                                    )
                                );
                              }

                              return _buildEmptyState();
                            }
                            ),
                  ),
                ),
              ],
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return AnimationLimiter(
        child: ListView.builder(
            padding: const EdgeInsets.all(16), itemCount: 8,
            itemBuilder: (BuildContext context, int index) {
              return AnimationConfiguration.staggeredList(
                  position: index, duration: const Duration(milliseconds: 150),
                  child: SlideAnimation(
                      verticalOffset: 20.0,
                      child: FadeInAnimation(child: _buildShimmerCard(context))));
            }));
  }

  Widget _buildShimmerCard(BuildContext context) {
    // Dark mode check
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    // Colors based on theme
    final Color cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color shadowColor = isDark
        ? Colors.black.withOpacity(0.3)
        : Colors.grey.withOpacity(0.1);
    final Color baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final Color highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    return Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: <BoxShadow>[
              BoxShadow(
                  color: shadowColor,
                  blurRadius: 4,
                  offset: const Offset(0, 2))
            ]),
        child: Shimmer.fromColors(
            baseColor: baseColor,
            highlightColor: highlightColor,
            child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                              color: isDark ? Colors.grey[700] : Colors.white,
                              borderRadius: BorderRadius.circular(10))),
                      const SizedBox(width: 12),
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                    width: double.infinity,
                                    height: 16,
                                    decoration: BoxDecoration(
                                        color: isDark ? Colors.grey[700] : Colors.white,
                                        borderRadius: BorderRadius.circular(4))),
                                const SizedBox(height: 8),
                                Container(
                                    width: double.infinity,
                                    height: 14,
                                    decoration: BoxDecoration(
                                        color: isDark ? Colors.grey[700] : Colors.white,
                                        borderRadius: BorderRadius.circular(4))),
                                const SizedBox(height: 4),
                                Container(
                                    width: 200,
                                    height: 14,
                                    decoration: BoxDecoration(
                                        color: isDark ? Colors.grey[700] : Colors.white,
                                        borderRadius: BorderRadius.circular(4))),
                                const SizedBox(height: 12),
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Container(
                                          width: 80,
                                          height: 12,
                                          decoration: BoxDecoration(
                                              color: isDark ? Colors.grey[700] : Colors.white,
                                              borderRadius: BorderRadius.circular(4))),
                                      Container(
                                          width: 60,
                                          height: 20,
                                          decoration: BoxDecoration(
                                              color: isDark ? Colors.grey[700] : Colors.white,
                                              borderRadius: BorderRadius.circular(6)))
                                    ])
                              ])),
                      Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                              color: isDark ? Colors.grey[700] : Colors.white,
                              borderRadius: BorderRadius.circular(4)))
                    ]))));}

  Widget _buildFilterTabs() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: <Widget>[
            _buildFilterChip('all', 'All', Icons.notifications),
            const SizedBox(width: 8),
            _buildFilterChip('bill_payment', 'Bills', Icons.receipt),
            const SizedBox(width: 8),
            _buildFilterChip('movie_booking', 'Movies', Icons.movie),
            const SizedBox(width: 8),
            _buildFilterChip('train_booking', 'Trains', Icons.train),
            const SizedBox(width: 8),
            _buildFilterChip('flight_booking', 'Flights', Icons.flight),
            const SizedBox(width: 8),
            _buildFilterChip('ride_booking', 'Rides', Icons.directions_car),
            const SizedBox(width: 8),
            _buildFilterChip('bus_booking', 'Bus', Icons.directions_bus),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String value, String label, IconData icon) {
    final bool isSelected = _selectedFilter == value;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(25),
          onTap: () {
            setState(() {
              _selectedFilter = value;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? MyTheme.primaryColor // Changed here
                  : Colors.grey[50],
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: isSelected
                    ? MyTheme.primaryColor // Changed here
                    : Colors.grey[200]!,
                width: 1,
              ),
              boxShadow: isSelected ? <BoxShadow>[
                BoxShadow(
                  color: MyTheme.primaryColor.withOpacity(0.3), // Changed here
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ] : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  icon,
                  size: 16,
                  color: isSelected ? Colors.white : Colors.grey[600],
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: Font.montserratFont(
                    color: isSelected ? Colors.white : Colors.grey[600],
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard(NotificationModel notification) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: <BoxShadow>[
          const BoxShadow(
            color: Colors.black26,
            blurRadius: 5,
            offset: Offset(1, 1),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          if (!notification.isRead && notification.id != null) {
            context.read<NotificationBloc>().add(MarkNotificationAsRead(notification.id!));
          }
          _showNotificationDetails(notification);
        },
        child: Padding(
          padding: const EdgeInsets.all(20), // Increased padding
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Icon with better styling
              Container(
                width: 48, // Increased size
                height: 48,
                decoration: BoxDecoration(
                  color: _getNotificationColor(notification.type).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _getNotificationColor(notification.type).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Icon(
                  _getNotificationIcon(notification.type),
                  color: _getNotificationColor(notification.type),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),

              // Content section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // Title row with read indicator
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            notification.title,
                            style: Font.montserratFont(
                              fontSize: 16,
                              fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.w600,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!notification.isRead) ...<Widget>[
                          const SizedBox(width: 8),
                          Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: MyTheme.primaryColor, // Changed here
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Message
                    Text(
                      notification.message,
                      style: Font.montserratFont(
                        fontSize: 14,
                        color: Colors.grey[600],
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),

                    // Bottom row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Flexible(
                          child: Text(
                            timeago.format(notification.createdAt),
                            style: Font.montserratFont(
                              fontSize: 12,
                              color: Colors.grey[500],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        if (notification.data != null && notification.data!['amount'] != null) ...<Widget>[
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: _getNotificationColor(notification.type).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _getNotificationColor(notification.type).withOpacity(0.3),
                                width: 0.5,
                              ),
                            ),
                            child: Text(
                              '${notification.data!['currency'] ?? 'USD'} ${(notification.data!['amount'] ?? 0.0).toStringAsFixed(2)}',
                              style: Font.montserratFont(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _getNotificationColor(notification.type),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Menu button
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert,
                  size: 20,
                  color: Colors.grey[400],
                ),
                offset: const Offset(-10, 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onSelected: (String value) {
                  switch (value) {
                    case 'mark_read':
                      if (notification.id != null) {
                        context.read<NotificationBloc>().add(MarkNotificationAsRead(notification.id!));
                      }
                      break;
                    case 'delete':
                      if (notification.id != null) {
                        _showDeleteDialog(notification);
                      }
                      break;
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  if (!notification.isRead)
                    const PopupMenuItem(
                      value: 'mark_read',
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.mark_email_read, size: 18),
                          SizedBox(width: 8),
                          Text('Mark as Read'),
                        ],
                      ),
                    ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: <Widget>[
                        const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                        const SizedBox(width: 8),
                        Text('Delete', style: Font.montserratFont(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey[50],
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey[200]!, width: 2),
              ),
              child: Icon(
                Icons.notifications_none_outlined,
                size: 48,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _selectedFilter == 'all'
                  ? 'No notifications yet'
                  : 'No ${_getFilterLabel()} found',
              style: Font.montserratFont(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'When you have notifications, they\'ll appear here',
              style: Font.montserratFont(
                fontSize: 16,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  List<NotificationModel> _filterNotifications(List<NotificationModel> notifications) {
    if (_selectedFilter == 'all') {
      return notifications; // Show ALL notifications
    }

    // Filter by matching notification type prefix (e.g., 'bill_payment' matches both 'bill_payment_success' and 'bill_payment_failed')
    return notifications.where((NotificationModel notification) {
      return notification.type.startsWith(_selectedFilter);
    }).toList();
  }
  // Fixed notification details modal
  void _showNotificationDetails(NotificationModel notification) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: <Widget>[
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 20),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: _getNotificationColor(notification.type).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _getNotificationColor(notification.type).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      _getNotificationIcon(notification.type),
                      color: _getNotificationColor(notification.type),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          notification.title,
                          style: Font.montserratFont(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          timeago.format(notification.createdAt),
                          style: Font.montserratFont(
                            fontSize: 12,
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.grey),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // Message content
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey[200]!, width: 1),
                      ),
                      child: Text(
                        notification.message,
                        style: Font.montserratFont(
                          fontSize: 16,
                          height: 1.5,
                          color: Colors.black87,
                        ),
                      ),
                    ),

                    // Transaction details
                    if (notification.data != null && notification.data!.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 24),
                      Text(
                        'Transaction Details',
                        style: Font.montserratFont(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey[200]!, width: 1),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: notification.data!.entries
                              .where((MapEntry<String, dynamic> entry) => entry.key != 'paidAt' && entry.value != null)
                              .map((MapEntry<String, dynamic> entry) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors.grey[100]!,
                                  width: 1,
                                ),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    _formatKey(entry.key),
                                    style: Font.montserratFont(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    _formatValue(entry.key, entry.value),
                                    style: Font.montserratFont(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                    textAlign: TextAlign.end,
                                  ),
                                ),
                              ],
                            ),
                          ))
                              .toList(),
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Action button
            if (!notification.isRead && notification.id != null)
              Container(
                padding: const EdgeInsets.all(24),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      context.read<NotificationBloc>().add(MarkNotificationAsRead(notification.id!));
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MyTheme.primaryColor, // Changed here
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 2,
                    ),
                    child: Text(
                      'Mark as Read',
                      style: Font.montserratFont(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Helper methods for icons, colors, and formatting
  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'bill_payment_success': return Icons.receipt_long;
      case 'bill_payment_failed': return Icons.error_outline;
      case 'movie_booking_success': return Icons.movie;
      case 'movie_booking_failed': return Icons.movie_outlined;
      case 'train_booking_success': return Icons.train;
      case 'train_booking_failed': return Icons.train_outlined;
      case 'flight_booking_success': return Icons.flight;
      case 'flight_booking_failed': return Icons.flight_outlined;
      case 'ride_booking_success': return Icons.directions_car;
      case 'ride_booking_failed': return Icons.directions_car_outlined;
      case 'bus_booking_success': return Icons.directions_bus;
      case 'bus_booking_failed': return Icons.directions_bus_outlined;
      case 'transaction': return Icons.account_balance_wallet;
      case 'transfer': return Icons.send;
      case 'deposit': return Icons.arrow_downward;
      case 'withdrawal': return Icons.arrow_upward;
      default: return Icons.notifications;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'bill_payment_success': return const Color(0xFF10B981);
      case 'bill_payment_failed': return const Color(0xFFEF4444);
      case 'movie_booking_success': return const Color(0xFFF59E0B);
      case 'movie_booking_failed': return const Color(0xFFEF4444);
      case 'train_booking_success': return const Color(0xFF8B5CF6);
      case 'train_booking_failed': return const Color(0xFFEF4444);
      case 'flight_booking_success': return MyTheme.primaryColor; // Changed here
      case 'flight_booking_failed': return const Color(0xFFEF4444);
      case 'ride_booking_success': return const Color(0xFF059669);
      case 'ride_booking_failed': return const Color(0xFFEF4444);
      case 'bus_booking_success': return const Color(0xFFDC2626);
      case 'bus_booking_failed': return const Color(0xFFEF4444);
      case 'transaction': return MyTheme.primaryColor; // Changed here
      case 'transfer': return const Color(0xFF8B5CF6);
      case 'deposit': return const Color(0xFF059669);
      case 'withdrawal': return const Color(0xFFDC2626);
      default: return const Color(0xFF6B7280);
    }
  }

  String _getFilterLabel() {
    switch (_selectedFilter) {
      case 'bill_payment': return 'bill payments';
      case 'movie_booking': return 'movie bookings';
      case 'train_booking': return 'train bookings';
      case 'flight_booking': return 'flight bookings';
      case 'ride_booking': return 'ride bookings';
      case 'bus_booking': return 'bus bookings';
      case 'transaction': return 'transactions';
      case 'transfer': return 'transfers';
      case 'general': return 'general notifications';
      default: return 'notifications';
    }
  }

  String _formatKey(String key) {
    switch (key) {
      case 'bookingId': return 'Booking ID';
      case 'totalAmount': return 'Total Amount';
      case 'taxAmount': return 'Tax Amount';
      case 'paymentStatus': return 'Payment Status';
      case 'billId': return 'Bill ID';
      case 'companyName': return 'Company';
      case 'accountNumber': return 'Account Number';
      case 'billType': return 'Bill Type';
      case 'originalAmount': return 'Original Amount';
      case 'paymentMethod': return 'Payment Method';
      case 'cardId': return 'Card ID';
      case 'movieTitle': return 'Movie';
      case 'cinemaChain': return 'Cinema';
      case 'showDate': return 'Show Date';
      case 'showtime': return 'Show Time';
      case 'numberOfTickets': return 'Tickets';
      case 'seatType': return 'Seat Type';
      case 'customerName': return 'Customer';
      case 'trainName': return 'Train';
      case 'passengerName': return 'Passenger';
      case 'travelDate': return 'Travel Date';
      case 'numberOfPassengers': return 'Passengers';
      case 'travelClass': return 'Class';
      case 'baseFare': return 'Base Fare';
      default: return key.split('_').map((String word) => word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1)).join(' ');
    }
  }

  String _formatValue(String key, dynamic value) {
    if (key.toLowerCase().contains('amount') || key.toLowerCase().contains('fare') || key.toLowerCase().contains('fee') || key.toLowerCase().contains('price')) {
      if (value is num) return 'USD ${value.toStringAsFixed(2)}';
    }
    if (key.toLowerCase().contains('date') || key.toLowerCase().contains('time')) {
      if (value is String && value.contains('T')) {
        try {
          final DateTime date = DateTime.parse(value);
          return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
        } catch (e) { return value.toString(); }
      }
    }
    if (key.toLowerCase().contains('distance')) {
      if (value is num) return '${value.toStringAsFixed(1)} miles';
    }
    return value.toString();
  }

  void _showDeleteDialog(NotificationModel notification) {
    showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
            title: const Text('Delete Notification'),
            content: const Text('Are you sure you want to delete this notification?'),
            actions: <Widget>[
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              TextButton(
                  onPressed: () {
                    context.read<NotificationBloc>().add(DeleteNotification(notification.id!));
                    Navigator.pop(context);
                  },
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('Delete'))
            ]));
  }

  void _showClearAllDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
            title: const Text('Clear All Notifications'),
            content: const Text('Are you sure you want to clear all notifications? This action cannot be undone.'),
            actions: <Widget>[
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              TextButton(
                  onPressed: () {
                    context.read<NotificationBloc>().add(ClearAllNotifications());
                    Navigator.pop(context);
                  },
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('Clear All'))
            ]));
  }
}