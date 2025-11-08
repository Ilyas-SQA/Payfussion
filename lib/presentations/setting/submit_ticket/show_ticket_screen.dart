import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:payfussion/core/theme/theme.dart';
import '../../../core/constants/fonts.dart';
import '../../../core/constants/routes_name.dart';
import '../../../services/submit_ticket_service.dart';
import '../../widgets/background_theme.dart';

class ShowTicketScreen extends StatefulWidget {
  const ShowTicketScreen({super.key});

  @override
  State<ShowTicketScreen> createState() => _ShowTicketScreenState();
}

class _ShowTicketScreenState extends State<ShowTicketScreen>
    with TickerProviderStateMixin {

  // Animation controllers
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _backgroundAnimationController;

  // Animations
  late Animation<double> _fadeAnimation;

  // Initialize the repository - THIS WAS THE MISSING PART
  late TicketRepository _ticketRepository;

  @override
  void initState() {
    super.initState();
    _backgroundAnimationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
    // Initialize the repository - ADD THIS LINE
    _ticketRepository = TicketRepository();

    // Initialize animation controllers
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );


    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    // Start entry animations
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fadeController.forward();
      _slideController.forward();
      _scaleController.forward();
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    _backgroundAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Tickets"),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: <Widget>[
          AnimatedBackground(
            animationController: _backgroundAnimationController,
          ),
          Column(
            children: <Widget>[

              SizedBox(height: 20.h),

              // Animated Tickets List
              Expanded(
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.1),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: _slideController,
                    curve: const Interval(0.4, 1.0, curve: Curves.easeOutCubic),
                  )),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildTicketsList(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: MyTheme.primaryColor,
        onPressed: (){
          context.push(RouteNames.submitATicket);
        },
        label: const Text("Add Ticket"),
      ),
    );
  }

  Widget _buildTicketsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _ticketRepository.getCurrentUserTicketsStream(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot<Object?>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        }

        if (snapshot.hasError) {
          return _buildErrorState(snapshot.error.toString());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState();
        }

        return _buildTicketsListView(snapshot.data!.docs);
      },
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 1000),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (BuildContext context, double value, Widget? child) {
              return Transform.rotate(
                angle: value * 2 * 3.14159,
                child: SizedBox(
                  height: 50.h,
                  width: 50.w,
                  child: const CircularProgressIndicator(
                    color: MyTheme.primaryColor,
                    strokeWidth: 3,
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 20.h),
          Text(
            'Loading tickets...',
            style: Font.montserratFont(
              fontSize: 16.sp,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.error_outline,
            size: 60.r,
            color: Colors.red,
          ),
          SizedBox(height: 20.h),
          Text(
            'Error loading tickets',
            style: Font.montserratFont(
              fontSize: 18.sp,
              color: Colors.red,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            error,
            textAlign: TextAlign.center,
            style: Font.montserratFont(
              fontSize: 14.sp,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 800),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (BuildContext context, double value, Widget? child) {
              return Transform.scale(
                scale: 0.8 + (0.2 * value),
                child: Icon(
                  Icons.confirmation_number_outlined,
                  size: 80.r,
                  color: MyTheme.primaryColor,
                ),
              );
            },
          ),
          SizedBox(height: 20.h),
          Text(
            'No tickets found',
            style: Font.montserratFont(
              fontSize: 18.sp,
              color: Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            'You haven\'t created any tickets yet',
            style: Font.montserratFont(
              fontSize: 14.sp,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketsListView(List<QueryDocumentSnapshot> tickets) {
    // Sort tickets by date in Flutter instead of Firestore
    tickets.sort((QueryDocumentSnapshot<Object?> a, QueryDocumentSnapshot<Object?> b) {
      final Map<String, dynamic> aData = a.data() as Map<String, dynamic>;
      final Map<String, dynamic> bData = b.data() as Map<String, dynamic>;

      final Timestamp? aDate = aData['date'] as Timestamp?;
      final Timestamp? bDate = bData['date'] as Timestamp?;

      // Handle null dates
      if (aDate == null && bDate == null) return 0;
      if (aDate == null) return 1;
      if (bDate == null) return -1;

      // Sort by date descending (newest first)
      return bDate.compareTo(aDate);
    });

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      itemCount: tickets.length,
      itemBuilder: (BuildContext context, int index) {
        final QueryDocumentSnapshot<Object?> ticket = tickets[index];
        final Map<String, dynamic> data = ticket.data() as Map<String, dynamic>;

        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 600 + (index * 100)),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (BuildContext context, double value, Widget? child) {
            return Transform.translate(
              offset: Offset(50 * (1 - value), 0),
              child: Opacity(
                opacity: value,
                child: _buildTicketCard(data, ticket.id),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTicketCard(Map<String, dynamic> data, String documentId) {
    final title = data['title'] ?? 'No Title';
    final description = data['description'] ?? 'No Description';
    final status = data['status'] ?? 'pending';
    final userId = data['userId'] ?? '';
    final Timestamp? date = data['date'] as Timestamp?;

    String formattedDate = 'Unknown Date';
    if (date != null) {
      final DateTime dateTime = date.toDate();
      formattedDate =
      '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    }

    final Color statusColor = _getStatusColor(status);
    final IconData statusIcon = _getStatusIcon(status);

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      child: Container(
        padding: EdgeInsets.all(20.w),
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
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Text(
                    title,
                    style: Font.montserratFont(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: MyTheme.primaryColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: statusColor.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(
                        statusIcon,
                        size: 14.r,
                        color: statusColor,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        status.toUpperCase(),
                        style: Font.montserratFont(
                          fontSize: 12.sp,
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 12.h),

            // Description
            Text(
              description,
              style: Font.montserratFont(
                fontSize: 14.sp,
                color: Colors.grey.shade700,
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),

            SizedBox(height: 16.h),

            // Footer Row
            Row(
              children: <Widget>[
                Icon(
                  Icons.access_time,
                  size: 16.r,
                  color: Colors.grey,
                ),
                SizedBox(width: 6.w),
                Text(
                  formattedDate,
                  style: Font.montserratFont(
                    fontSize: 12.sp,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Text(
                  'ID: ${documentId.substring(0, 8)}...',
                  style: Font.montserratFont(
                    fontSize: 12.sp,
                    color: const Color(0xff2D9CDB),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'in_progress':
      case 'in progress':
        return Colors.blue;
      case 'resolved':
      case 'completed':
        return Colors.green;
      case 'closed':
        return Colors.grey;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.pending;
      case 'in_progress':
      case 'in progress':
        return Icons.loop;
      case 'resolved':
      case 'completed':
        return Icons.check_circle;
      case 'closed':
        return Icons.lock;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.pending;
    }
  }
}