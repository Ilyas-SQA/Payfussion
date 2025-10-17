import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:payfussion/core/constants/image_url.dart';
import 'package:payfussion/core/theme/theme.dart';
import 'package:payfussion/presentations/widgets/auth_widgets/credential_text_field.dart';

import '../../core/constants/app_colors.dart';
import '../../data/models/Transactions_Modals/transaction_modal.dart';
import '../widgets/home_widgets/transaction_item.dart';
import '../widgets/home_widgets/transaction_items_header.dart';
import '../widgets/payment_selector_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum TransactionCategory { transaction, payBills, insurance, tickets }

class TransactionHomeScreen extends StatefulWidget {
  const TransactionHomeScreen({super.key});

  @override
  State<TransactionHomeScreen> createState() => _TransactionHomeScreenState();
}

class _TransactionHomeScreenState extends State<TransactionHomeScreen>
    with TickerProviderStateMixin {
  // Search / Filters local UI state
  bool isSearchActive = false;
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  // Selected category
  TransactionCategory selectedCategory = TransactionCategory.transaction;

  // Animation controllers
  late AnimationController _headerAnimationController;
  late AnimationController _contentAnimationController;
  late Animation<double> _headerAnimation;
  late Animation<Offset> _headerSlideAnimation;

  // Filters
  Map<String, dynamic> activeFilters = {
    'period': 'All time',
    'dateRange': null,
    'statuses': <String>{},
  };

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _contentAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _headerAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.easeOutCubic,
    ));

    _headerSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.elasticOut,
    ));

    // Start animations
    _headerAnimationController.forward();
    _contentAnimationController.forward();
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _contentAnimationController.dispose();
    super.dispose();
  }

  /// Get collection name based on selected category
  String _getCollectionName() {
    switch (selectedCategory) {
      case TransactionCategory.transaction:
        return 'transactions';
      case TransactionCategory.payBills:
        return 'payBills';
      case TransactionCategory.insurance:
        return 'insurance';
      case TransactionCategory.tickets:
        return 'movie_bookings';
    }
  }

  /// Map Firestore doc -> your UI TransactionModel based on category
  TransactionModel _fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc,
      ) {
    final data = doc.data() ?? {};

    switch (selectedCategory) {
      case TransactionCategory.transaction:
        return _mapTransactionData(doc, data);
      case TransactionCategory.payBills:
        return _mapPayBillData(doc, data);
      case TransactionCategory.insurance:
        return _mapInsuranceData(doc, data);
      case TransactionCategory.tickets:
        return _mapTicketData(doc, data);
    }
  }

  TransactionModel _mapTransactionData(DocumentSnapshot doc, Map<String, dynamic> data) {
    final ts = data['created_at'];
    DateTime createdAt;
    if (ts is Timestamp) {
      createdAt = ts.toDate();
    } else if (ts is DateTime) {
      createdAt = ts;
    } else {
      createdAt = DateTime.now();
    }

    final rawStatus = (data['status'] ?? '').toString().toLowerCase();
    String uiStatus;
    switch (rawStatus) {
      case 'success':
      case 'completed':
        uiStatus = 'Completed';
        break;
      case 'pending':
        uiStatus = 'Pending';
        break;
      case 'failed':
      case 'failure':
        uiStatus = 'Failed';
        break;
      default:
        uiStatus = 'Completed';
    }

    final title = (data['recipient_name'] ?? data['title'] ?? 'Payment').toString();
    final String iconPath = uiStatus == 'Failed'
        ? TImageUrl.iconConversionTransaction
        : TImageUrl.iconCreditCardTransaction;

    return TransactionModel(
      id: doc.id,
      title: title,
      amount: (data['amount'] ?? 0).toDouble(),
      status: uiStatus,
      dateTime: createdAt,
      iconPath: iconPath,
    );
  }

  TransactionModel _mapPayBillData(DocumentSnapshot doc, Map<String, dynamic> data) {
    DateTime createdAt;
    final ts = data['createdAt'];
    if (ts is String) {
      createdAt = DateTime.tryParse(ts) ?? DateTime.now();
    } else if (ts is Timestamp) {
      createdAt = ts.toDate();
    } else {
      createdAt = DateTime.now();
    }

    final rawStatus = (data['status'] ?? '').toString().toLowerCase();
    String uiStatus;
    switch (rawStatus) {
      case 'completed':
        uiStatus = 'Completed';
        break;
      case 'pending':
        uiStatus = 'Pending';
        break;
      case 'failed':
        uiStatus = 'Failed';
        break;
      default:
        uiStatus = 'Completed';
    }

    // Show company name and bill type
    final companyName = data['companyName'] ?? 'Bill Payment';
    final billType = data['billType'] ?? '';
    final title = billType.isNotEmpty
        ? '$companyName - $billType'
        : companyName;
    final amount = (data['amount'] ?? 0).toDouble();

    return TransactionModel(
      id: data['billNumber'] ?? doc.id, // Use bill number as ID for display
      title: title,
      amount: amount,
      status: uiStatus,
      dateTime: createdAt,
      iconPath: data['companyIcon'] ?? TImageUrl.iconCreditCardTransaction,
    );
  }

  TransactionModel _mapInsuranceData(DocumentSnapshot doc, Map<String, dynamic> data) {
    DateTime createdAt;
    final ts = data['createdAt'];
    if (ts is Timestamp) {
      createdAt = ts.toDate();
    } else {
      createdAt = DateTime.now();
    }

    final rawStatus = (data['status'] ?? '').toString().toLowerCase();
    String uiStatus;
    switch (rawStatus) {
      case 'completed':
        uiStatus = 'Completed';
        break;
      case 'pending':
        uiStatus = 'Pending';
        break;
      case 'failed':
        uiStatus = 'Failed';
        break;
      default:
        uiStatus = 'Completed';
    }

    // Show company name and insurance type in title
    final companyName = data['companyName'] ?? 'Insurance Company';
    final insuranceType = data['insuranceType'] ?? 'Insurance';
    final title = '$companyName - $insuranceType';
    final amount = (data['premiumAmount'] ?? 0).toDouble();

    return TransactionModel(
      id: data['policyNumber'] ?? doc.id, // Use policy number as ID for display
      title: title,
      amount: amount,
      status: uiStatus,
      dateTime: createdAt,
      iconPath: TImageUrl.iconCreditCardTransaction,
    );
  }

  TransactionModel _mapTicketData(DocumentSnapshot doc, Map<String, dynamic> data) {
    DateTime createdAt;
    final ts = data['bookingDate'];
    if (ts is Timestamp) {
      createdAt = ts.toDate();
    } else {
      createdAt = DateTime.now();
    }

    final rawStatus = (data['paymentStatus'] ?? '').toString().toLowerCase();
    String uiStatus;
    switch (rawStatus) {
      case 'completed':
        uiStatus = 'Completed';
        break;
      case 'pending':
        uiStatus = 'Pending';
        break;
      case 'failed':
        uiStatus = 'Failed';
        break;
      default:
        uiStatus = 'Completed';
    }

    // Show movie title only for cleaner display
    final movieTitle = data['movieTitle'] ?? 'Movie Ticket';
    final cinemaChain = data['cinemaChain'] ?? 'Cinema';
    final numberOfTickets = data['numberOfTickets'] ?? 1;
    final seatType = data['seatType'] ?? '';

    // Create a more user-friendly ID display
    final displayId = 'Tickets: $numberOfTickets${seatType.isNotEmpty ? ' ($seatType)' : ''}';

    return TransactionModel(
      id: displayId, // Show ticket count and seat type instead of UUID
      title: movieTitle, // Just movie title for cleaner look
      amount: (data['totalAmount'] ?? 0).toDouble(),
      status: uiStatus,
      dateTime: createdAt,
      iconPath: TImageUrl.iconCreditCardTransaction,
    );
  }

  /// Apply search + filters to a base list
  List<TransactionModel> _getFilteredTransactions(List<TransactionModel> base) {
    List<TransactionModel> filtered = List.from(base);

    // search
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((txn) =>
      txn.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
          txn.id.toLowerCase().contains(searchQuery.toLowerCase())).toList();
    }

    // status
    if (activeFilters['statuses'].isNotEmpty) {
      filtered = filtered.where((txn) => activeFilters['statuses'].contains(txn.status)).toList();
    }

    // date range
    if (activeFilters['dateRange'] != null) {
      final DateTimeRange range = activeFilters['dateRange'];
      filtered = filtered.where((txn) =>
      txn.dateTime.isAfter(range.start) &&
          txn.dateTime.isBefore(range.end.add(const Duration(days: 1)))).toList();
    } else if (activeFilters['period'] != 'All time') {
      final DateTime now = DateTime.now();
      final DateTime today = DateTime(now.year, now.month, now.day);

      switch (activeFilters['period']) {
        case 'Today':
          filtered = filtered.where((txn) =>
          txn.dateTime.isAfter(today.subtract(const Duration(days: 1))) &&
              txn.dateTime.isBefore(today.add(const Duration(days: 1)))).toList();
          break;
        case 'This week':
          final DateTime startOfWeek = today.subtract(Duration(days: today.weekday % 7));
          filtered = filtered.where((txn) =>
          txn.dateTime.isAfter(startOfWeek) &&
              txn.dateTime.isBefore(startOfWeek.add(const Duration(days: 7)))).toList();
          break;
        case 'This month':
          final DateTime startOfMonth = DateTime(today.year, today.month, 1);
          final DateTime nextMonth = (today.month < 12)
              ? DateTime(today.year, today.month + 1, 1)
              : DateTime(today.year + 1, 1, 1);
          filtered = filtered
              .where((txn) =>
          txn.dateTime.isAfter(startOfMonth.subtract(const Duration(days: 1))) &&
              txn.dateTime.isBefore(nextMonth))
              .toList();
          break;
      }
    }

    return filtered;
  }

  /// Group by date buckets (Today / Yesterday / This Week / This Month / MMMM yyyy)
  Map<String, List<TransactionModel>> _groupTransactionsByDate(List<TransactionModel> txnList) {
    final Map<String, List<TransactionModel>> grouped = {};
    if (txnList.isEmpty) return grouped;

    for (var transaction in txnList) {
      String dateKey;
      final DateTime now = DateTime.now();
      final DateTime today = DateTime(now.year, now.month, now.day);
      final DateTime yesterday = today.subtract(const Duration(days: 1));
      final DateTime txnDate = DateTime(
        transaction.dateTime.year,
        transaction.dateTime.month,
        transaction.dateTime.day,
      );

      final DateTime startOfWeek = today.subtract(Duration(days: today.weekday % 7));
      final DateTime startOfMonth = DateTime(today.year, today.month, 1);

      if (txnDate == today) {
        dateKey = "Today";
      } else if (txnDate == yesterday) {
        dateKey = "Yesterday";
      } else if (txnDate.isAfter(startOfWeek) && txnDate.isBefore(today)) {
        dateKey = "This Week";
      } else if (txnDate.isAfter(startOfMonth) && txnDate.isBefore(startOfWeek)) {
        dateKey = "This Month";
      } else {
        dateKey = DateFormat('MMMM yyyy').format(transaction.dateTime);
      }

      grouped.putIfAbsent(dateKey, () => []);
      grouped[dateKey]!.add(transaction);
    }

    return grouped;
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      builder: (context) => TransactionFilterSheet(
        initialFilters: activeFilters,
        onApply: (filters) {
          setState(() {
            activeFilters = filters;
          });
        },
      ),
    );
  }

  // Category buttons widget
  Widget _buildCategoryButtons() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
      child: Row(
        children: [
          Expanded(child: _buildCategoryButton('Transaction', TransactionCategory.transaction)),
          SizedBox(width: 6.w),
          Expanded(child: _buildCategoryButton('PayBills', TransactionCategory.payBills)),
          SizedBox(width: 6.w),
          Expanded(child: _buildCategoryButton('Insurance', TransactionCategory.insurance)),
          SizedBox(width: 6.w),
          Expanded(child: _buildCategoryButton('Tickets', TransactionCategory.tickets)),
        ],
      ),
    );
  }

  Widget _buildCategoryButton(String title, TransactionCategory category) {
    final bool isSelected = selectedCategory == category;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: InkWell(
        onTap: () {
          setState(() {
            selectedCategory = category;
            // Reset search when changing category
            searchQuery = '';
            searchController.clear();
            isSearchActive = false;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? MyTheme.primaryColor : Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(5.r),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).brightness == Brightness.light ? Colors.grey.withOpacity(0.3) : Colors.black.withOpacity(0.3),
                blurRadius: 5,
                offset: const Offset(0, 4),
              ),
            ],
          ),

          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  // ENHANCED SHIMMER LOADING WIDGETS WITH ANIMATIONS
  Widget _buildShimmerLoading() {
    return AnimationLimiter(
      child: ListView(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        children: AnimationConfiguration.toStaggeredList(
          duration: const Duration(milliseconds: 375),
          childAnimationBuilder: (widget) => SlideAnimation(
            verticalOffset: 50.0,
            child: FadeInAnimation(child: widget),
          ),
          children: [
            _buildShimmerSection(),
            SizedBox(height: 20.h),
            _buildShimmerSection(),
            SizedBox(height: 20.h),
            _buildShimmerSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerSection() {
    return AnimatedContainer(
      duration: AppDurations.quickAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header shimmer
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: _buildShimmerBox(width: 120.w, height: 20.h),
          ),
          // Transaction items shimmer
          ...List.generate(3, (index) => _buildTransactionShimmer()),
        ],
      ),
    );
  }

  Widget _buildTransactionShimmer() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: AnimatedContainer(
        duration: AppDurations.quickAnimation,
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            // Icon shimmer
            _buildShimmerBox(width: 48.w, height: 48.h, borderRadius: 24.r),
            SizedBox(width: 12.w),
            // Content shimmer
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildShimmerBox(width: 140.w, height: 18.h),
                      _buildShimmerBox(width: 80.w, height: 18.h),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildShimmerBox(width: 100.w, height: 14.h),
                      _buildShimmerBox(width: 70.w, height: 24.h, borderRadius: 12.r),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  _buildShimmerBox(width: 80.w, height: 12.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerBox({
    required double width,
    required double height,
    double borderRadius = 6.0,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.grey.shade100,
            Colors.grey.shade50,
            Colors.grey.shade100,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: _ShimmerAnimation(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Transactions"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          SizedBox(height: 20.h),
          // Animated header
          SlideTransition(
            position: _headerSlideAnimation,
            child: FadeTransition(
              opacity: _headerAnimation,
              child: _buildTransactionHeader(),
            ),
          ),
          // Category buttons
          _buildCategoryButtons(),
          Expanded(
            child: uid == null ? _buildNoTransactionsView() : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance.collection('users').doc(uid).collection(_getCollectionName()).orderBy(_getOrderByField(), descending: true).snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                // SHIMMER LOADING STATE
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildShimmerLoading();
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final docs = snapshot.data?.docs ?? [];
                final base = docs.map(_fromFirestore).toList();

                if (base.isEmpty) {
                  return _buildNoTransactionsView();
                }

                final filtered = _getFilteredTransactions(base);
                if (filtered.isEmpty) {
                  return _buildNoTransactionsView();
                }

                final grouped = _groupTransactionsByDate(filtered);
                return _buildTransactionsList(grouped);
              },
            ),
          ),
        ],
      ),
    );
  }

  String _getOrderByField() {
    switch (selectedCategory) {
      case TransactionCategory.transaction:
        return 'created_at';
      case TransactionCategory.payBills:
        return 'createdAt';
      case TransactionCategory.insurance:
        return 'createdAt';
      case TransactionCategory.tickets:
        return 'bookingDate';
    }
  }

  String _getCategoryTitle() {
    switch (selectedCategory) {
      case TransactionCategory.transaction:
        return 'Transactions';
      case TransactionCategory.payBills:
        return 'Bill Payments';
      case TransactionCategory.insurance:
        return 'Insurance';
      case TransactionCategory.tickets:
        return 'Movie Tickets';
    }
  }

  Widget _buildTransactionHeader() {


    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Row(
          spacing: 5,
          children: [
            Expanded(
              flex: 5,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 45.h,
                child: AppTextormField(
                  controller: searchController,
                  helpText: 'Search ${_getCategoryTitle().toLowerCase()}...',
                  isPasswordField: false,
                  prefixIcon: Icon(
                    Icons.search,
                    color: MyTheme.primaryColor,
                    size: 20.sp,
                  ),
                  onChanged: (String value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: _buildIconButton(
                TImageUrl.filter,
                onTap: _showFilterBottomSheet,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton(
      String iconPath, {
        Function()? onTap,
        IconData? icon,
      }) {
    return InkWell(
      onTap: onTap ?? () {},
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 50.h,
        width: 45.w,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: MyTheme.primaryColor,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: icon != null ? Icon(icon, color: MyTheme.primaryColor) : SvgPicture.asset(iconPath),
      ),
    );
  }

  Widget _buildNoTransactionsView() {
    return FadeTransition(
      opacity: _contentAnimationController,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: Tween<double>(begin: 0.5, end: 1.0).animate(
                CurvedAnimation(
                  parent: _contentAnimationController,
                  curve: Curves.elasticOut,
                ),
              ),
              child: const Icon(Icons.wallet,size: 150,color: MyTheme.primaryColor,),
            ),
            SizedBox(height: 20.h),
            SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.5),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: _contentAnimationController,
                curve: Curves.easeOutCubic,
              )),
              child: Column(
                children: [
                  Text(
                    'No ${_getCategoryTitle()}',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    'You haven\'t completed any\n${_getCategoryTitle().toLowerCase()} yet',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 16.sp,
                      color: const Color(0xff757575),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsList(Map<String, List<TransactionModel>> groupedTransactions,) {
    return AnimationLimiter(
      child: ListView.builder(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        itemCount: groupedTransactions.length,
        itemBuilder: (BuildContext context, int index) {
          final dateKey = groupedTransactions.keys.elementAt(index);
          final transactionsForDate = groupedTransactions[dateKey]!;

          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TransactionItemHeader(
                      heading: dateKey,
                      showTrailingButton: false,
                    ),
                    AnimationLimiter(
                      child: Column(
                        children: AnimationConfiguration.toStaggeredList(
                          duration: const Duration(milliseconds: 375),
                          childAnimationBuilder: (Widget widget) => SlideAnimation(
                            horizontalOffset: 30.0,
                            child: FadeInAnimation(child: widget),
                          ),
                          children: transactionsForDate.map((TransactionModel transaction) {
                            return Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 8.h,
                              ),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                child: TransactionItem(
                                  iconPath: transaction.iconPath,
                                  heading: transaction.title,
                                  transactionId: transaction.id,
                                  moneyValue: transaction.amount.toStringAsFixed(2),
                                  status: transaction.status,
                                  date: DateFormat('MM/dd/yyyy').format(transaction.dateTime),
                                  time: DateFormat('hh:mm a').format(transaction.dateTime),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ShimmerAnimation extends StatefulWidget {
  final Widget child;

  const _ShimmerAnimation({required this.child});

  @override
  _ShimmerAnimationState createState() => _ShimmerAnimationState();
}

class _ShimmerAnimationState extends State<_ShimmerAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: const [
                Colors.transparent,
                Colors.white54,
                Colors.transparent,
              ],
              stops: [
                _animation.value - 0.3,
                _animation.value,
                _animation.value + 0.3,
              ],
              transform: const GradientRotation(0),
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

class TransactionFilterSheet extends StatefulWidget {
  final Map<String, dynamic> initialFilters;
  final Function(Map<String, dynamic>) onApply;

  const TransactionFilterSheet({
    Key? key,
    required this.initialFilters,
    required this.onApply,
  }) : super(key: key);

  @override
  State<TransactionFilterSheet> createState() => _TransactionFilterSheetState();
}

class _TransactionFilterSheetState extends State<TransactionFilterSheet> with SingleTickerProviderStateMixin {
  late Map<String, dynamic> filters;
  final List<String> periodOptions = ['All time', 'Today', 'This week', 'This month'];
  final List<String> statusOptions = ['Completed', 'Pending', 'Failed'];
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    filters = Map.from(widget.initialFilters);
    filters['statuses'] ??= <String>{};

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: MediaQuery.of(context).size.height * 0.7,
      padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 20.w),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
      ),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.1),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _animationController,
          curve: Curves.easeOutCubic,
        )),
        child: FadeTransition(
          opacity: _animationController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Filter Transactions', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                ],
              ),
              SizedBox(height: 10.h),
              const Divider(),
              SizedBox(height: 10.h),

              // Period
              Text('Period', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
              SizedBox(height: 10.h),
              Wrap(
                spacing: 10.w,
                children: periodOptions.map((option) {
                  final isSelected = filters['period'] == option;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    child: ChoiceChip(
                      label: Text(
                        option, style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                      ),
                      ),
                      selected: isSelected,
                      selectedColor: MyTheme.primaryColor,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            filters['period'] = option;
                            if (option != 'Custom') filters['dateRange'] = null;
                          }
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 20.h),

              // Custom Range
              Text('Custom Date Range', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
              SizedBox(height: 10.h),
              GestureDetector(
                onTap: () async {
                  final DateTimeRange? picked = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                    initialDateRange: filters['dateRange'] ??
                        DateTimeRange(
                          start: DateTime.now().subtract(const Duration(days: 7)),
                          end: DateTime.now(),
                        ),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme:  const ColorScheme.light(primary: MyTheme.primaryColor),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (picked != null) {
                    setState(() {
                      filters['dateRange'] = picked;
                      filters['period'] = 'Custom';
                    });
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(8.r),
                    color: filters['dateRange'] != null ? MyTheme.primaryColor : Colors.transparent,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color:  MyTheme.primaryColor, size: 18.sp),
                      SizedBox(width: 10.w),
                      filters['dateRange'] != null
                          ? Text(
                        '${DateFormat('MMM d, yyyy').format(filters['dateRange'].start)} - '
                            '${DateFormat('MMM d, yyyy').format(filters['dateRange'].end)}',
                        style: TextStyle(fontSize: 14.sp),
                      )
                          : Text('Select date range', style: TextStyle(fontSize: 14.sp, color: Colors.grey)),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20.h),

              // Status
              Text('Status', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
              SizedBox(height: 10.h),
              Wrap(
                spacing: 10.w,
                children: statusOptions.map((status) {
                  final isSelected = filters['statuses'].contains(status);
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    child: FilterChip(
                      label: Text(status, style: TextStyle(color: isSelected ? Colors.white : Colors.black)),
                      selected: isSelected,
                      selectedColor:  MyTheme.primaryColor,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            filters['statuses'].add(status);
                          } else {
                            filters['statuses'].remove(status);
                          }
                        });
                      },
                    ),
                  );
                }).toList(),
              ),

              const Spacer(),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            filters = {
                              'period': 'All time',
                              'dateRange': null,
                              'statuses': <String>{},
                            };
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          side: const BorderSide(color: MyTheme.primaryColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        child: Text('Reset', style: TextStyle(fontSize: 16.sp, color: MyTheme.primaryColor)),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      child: ElevatedButton(
                        onPressed: () {
                          widget.onApply(filters);
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          backgroundColor: MyTheme.primaryColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                        ),
                        child: Text('Apply Filters', style: TextStyle(fontSize: 16.sp, color: Colors.white)),
                      ),
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
}