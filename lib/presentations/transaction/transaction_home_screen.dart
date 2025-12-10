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
import '../../core/constants/fonts.dart';
import '../../data/models/Transactions_Modals/transaction_modal.dart';
import '../../services/receipt_service.dart';
import '../widgets/background_theme.dart';
import '../widgets/home_widgets/transaction_item.dart';
import '../widgets/home_widgets/transaction_items_header.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum TransactionCategory { transaction, payBills, insurance, tickets, donation }

class TransactionHomeScreen extends StatefulWidget {
  const TransactionHomeScreen({super.key});

  @override
  State<TransactionHomeScreen> createState() => _TransactionHomeScreenState();
}

class _TransactionHomeScreenState extends State<TransactionHomeScreen> with TickerProviderStateMixin {
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
  late AnimationController _backgroundAnimationController;

  // Filters
  Map<String, dynamic> activeFilters = <String, dynamic>{
    'period': 'All time',
    'dateRange': null,
    'statuses': <String>{},
  };

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _backgroundAnimationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
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

    _headerAnimationController.forward();
    _contentAnimationController.forward();
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _contentAnimationController.dispose();
    _backgroundAnimationController.dispose();
    searchController.dispose();
    super.dispose();
  }

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
      case TransactionCategory.donation:
        return 'donations';
    }
  }

  TransactionModel _fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final Map<String, dynamic> data = doc.data() ?? <String, dynamic>{};

    switch (selectedCategory) {
      case TransactionCategory.transaction:
        return _mapTransactionData(doc, data);
      case TransactionCategory.payBills:
        return _mapPayBillData(doc, data);
      case TransactionCategory.insurance:
        return _mapInsuranceData(doc, data);
      case TransactionCategory.tickets:
        return _mapTicketData(doc, data);
      case TransactionCategory.donation:
        return _mapDonationData(doc, data);
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

    final String rawStatus = (data['status'] ?? '').toString().toLowerCase();
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

    final String title = (data['recipient_name'] ?? data['title'] ?? 'Payment').toString();
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
      additionalData: data, // Store all data for details view
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

    final String rawStatus = (data['status'] ?? '').toString().toLowerCase();
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

    final companyName = data['companyName'] ?? 'Bill Payment';
    final billType = data['billType'] ?? '';
    final title = billType.isNotEmpty ? '$companyName - $billType' : companyName;
    final amount = (data['amount'] ?? 0).toDouble();

    return TransactionModel(
      id: data['billNumber'] ?? doc.id,
      title: title,
      amount: amount,
      status: uiStatus,
      dateTime: createdAt,
      iconPath: data['companyIcon'] ?? TImageUrl.iconCreditCardTransaction,
      additionalData: data,
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

    final String rawStatus = (data['status'] ?? '').toString().toLowerCase();
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

    final companyName = data['companyName'] ?? 'Insurance Company';
    final insuranceType = data['insuranceType'] ?? 'Insurance';
    final String title = '$companyName - $insuranceType';
    final amount = (data['premiumAmount'] ?? 0).toDouble();

    return TransactionModel(
      id: data['policyNumber'] ?? doc.id,
      title: title,
      amount: amount,
      status: uiStatus,
      dateTime: createdAt,
      iconPath: TImageUrl.iconCreditCardTransaction,
      additionalData: data,
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

    final String rawStatus = (data['paymentStatus'] ?? '').toString().toLowerCase();
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

    final movieTitle = data['movieTitle'] ?? 'Movie Ticket';
    final numberOfTickets = data['numberOfTickets'] ?? 1;
    final seatType = data['seatType'] ?? '';
    final String displayId = 'Tickets: $numberOfTickets${seatType.isNotEmpty ? ' ($seatType)' : ''}';

    return TransactionModel(
      id: displayId,
      title: movieTitle,
      amount: (data['totalAmount'] ?? 0).toDouble(),
      status: uiStatus,
      dateTime: createdAt,
      iconPath: TImageUrl.iconCreditCardTransaction,
      additionalData: data,
    );
  }

  TransactionModel _mapDonationData(DocumentSnapshot doc, Map<String, dynamic> data) {
    DateTime createdAt;
    final ts = data['createdAt'];
    if (ts is Timestamp) {
      createdAt = ts.toDate();
    } else if (ts is String) {
      createdAt = DateTime.tryParse(ts) ?? DateTime.now();
    } else {
      createdAt = DateTime.now();
    }

    final String rawStatus = (data['status'] ?? '').toString().toLowerCase();
    String uiStatus;
    switch (rawStatus) {
      case 'completed':
      case 'success':
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

    final organizationName = data['organizationName'] ?? 'Donation';
    final donationType = data['donationType'] ?? '';
    final title = donationType.isNotEmpty ? '$organizationName - $donationType' : organizationName;

    return TransactionModel(
      id: data['donationId'] ?? doc.id,
      title: title,
      amount: (data['amount'] ?? 0).toDouble(),
      status: uiStatus,
      dateTime: createdAt,
      iconPath: TImageUrl.iconCreditCardTransaction,
      // additionalData: data,
    );
  }

  List<TransactionModel> _getFilteredTransactions(List<TransactionModel> base) {
    List<TransactionModel> filtered = List.from(base);

    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((TransactionModel txn) =>
      txn.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
          txn.id.toLowerCase().contains(searchQuery.toLowerCase())).toList();
    }

    if (activeFilters['statuses'].isNotEmpty) {
      filtered = filtered.where((TransactionModel txn) =>
          activeFilters['statuses'].contains(txn.status)).toList();
    }

    if (activeFilters['dateRange'] != null) {
      final DateTimeRange range = activeFilters['dateRange'];
      filtered = filtered.where((TransactionModel txn) =>
      txn.dateTime.isAfter(range.start) &&
          txn.dateTime.isBefore(range.end.add(const Duration(days: 1)))).toList();
    } else if (activeFilters['period'] != 'All time') {
      final DateTime now = DateTime.now();
      final DateTime today = DateTime(now.year, now.month, now.day);

      switch (activeFilters['period']) {
        case 'Today':
          filtered = filtered.where((TransactionModel txn) =>
          txn.dateTime.isAfter(today.subtract(const Duration(days: 1))) &&
              txn.dateTime.isBefore(today.add(const Duration(days: 1)))).toList();
          break;
        case 'This week':
          final DateTime startOfWeek = today.subtract(Duration(days: today.weekday % 7));
          filtered = filtered.where((TransactionModel txn) =>
          txn.dateTime.isAfter(startOfWeek) &&
              txn.dateTime.isBefore(startOfWeek.add(const Duration(days: 7)))).toList();
          break;
        case 'This month':
          final DateTime startOfMonth = DateTime(today.year, today.month, 1);
          final DateTime nextMonth = (today.month < 12)
              ? DateTime(today.year, today.month + 1, 1)
              : DateTime(today.year + 1, 1, 1);
          filtered = filtered
              .where((TransactionModel txn) =>
          txn.dateTime.isAfter(startOfMonth.subtract(const Duration(days: 1))) &&
              txn.dateTime.isBefore(nextMonth))
              .toList();
          break;
      }
    }

    return filtered;
  }
  Map<String, List<TransactionModel>> _groupTransactionsByDate(List<TransactionModel> txnList) {
    final Map<String, List<TransactionModel>> grouped = <String, List<TransactionModel>>{};
    if (txnList.isEmpty) return grouped;

    for (TransactionModel transaction in txnList) {
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

      grouped.putIfAbsent(dateKey, () => <TransactionModel>[]);
      grouped[dateKey]!.add(transaction);
    }

    return grouped;
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      builder: (BuildContext context) => TransactionFilterSheet(
        initialFilters: activeFilters,
        onApply: (Map<String, dynamic> filters) {
          setState(() {
            activeFilters = filters;
          });
        },
      ),
    );
  }

  void _showTransactionDetail(TransactionModel transaction) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) => TransactionDetailSheet(
        transaction: transaction,
        category: selectedCategory,
      ),
    );
  }

  Widget _buildCategoryButtons() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: <Widget>[
            _buildCategoryButton('Transaction', TransactionCategory.transaction),
            SizedBox(width: 6.w),
            _buildCategoryButton('PayBills', TransactionCategory.payBills),
            SizedBox(width: 6.w),
            _buildCategoryButton('Insurance', TransactionCategory.insurance),
            SizedBox(width: 6.w),
            _buildCategoryButton('Tickets', TransactionCategory.tickets),
            SizedBox(width: 6.w),
            _buildCategoryButton('Donation', TransactionCategory.donation),
          ],
        ),
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
            searchQuery = '';
            searchController.clear();
            isSearchActive = false;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? MyTheme.primaryColor : Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(5.r),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Theme.of(context).brightness == Brightness.light
                    ? Colors.grey.withOpacity(0.3)
                    : Colors.black.withOpacity(0.3),
                blurRadius: 5,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: Font.montserratFont(
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
              color: isSelected
                  ? Colors.white
                  : Theme.of(context).brightness == Brightness.light
                  ? Colors.black
                  : Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerLoading(BuildContext context) {
    return AnimationLimiter(
      child: ListView(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        children: AnimationConfiguration.toStaggeredList(
          duration: const Duration(milliseconds: 375),
          childAnimationBuilder: (Widget widget) => SlideAnimation(
            verticalOffset: 50.0,
            child: FadeInAnimation(child: widget),
          ),
          children: <Widget>[
            _buildShimmerSection(context),
            SizedBox(height: 20.h),
            _buildShimmerSection(context),
            SizedBox(height: 20.h),
            _buildShimmerSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerSection(BuildContext context) {
    return AnimatedContainer(
      duration: AppDurations.quickAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: _buildShimmerBox(context, width: 120.w, height: 20.h),
          ),
          ...List.generate(3, (int index) => _buildTransactionShimmer(context)),
        ],
      ),
    );
  }

  Widget _buildTransactionShimmer(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: AnimatedContainer(
        duration: AppDurations.quickAnimation,
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: <Widget>[
            _buildShimmerBox(context, width: 48.w, height: 48.h, borderRadius: 24.r),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      _buildShimmerBox(context, width: 140.w, height: 18.h),
                      _buildShimmerBox(context, width: 80.w, height: 18.h),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      _buildShimmerBox(context, width: 100.w, height: 14.h),
                      _buildShimmerBox(context, width: 70.w, height: 24.h, borderRadius: 12.r),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  _buildShimmerBox(context, width: 80.w, height: 12.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerBox(
      BuildContext context, {
        required double width,
        required double height,
        double borderRadius = 6.0,
      }) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: isDark
              ? <Color>[
            Colors.grey.shade800,
            Colors.grey.shade700,
            Colors.grey.shade800,
          ]
              : <Color>[
            Colors.grey.shade300,
            Colors.grey.shade100,
            Colors.grey.shade300,
          ],
          stops: const <double>[0.0, 0.5, 1.0],
        ),
      ),
      child: _ShimmerAnimation(
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.grey.shade900 : Colors.white,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String? uid = FirebaseAuth.instance.currentUser?.uid;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Transactions"),
        centerTitle: true,
      ),
      body: Stack(
        children: <Widget>[
          AnimatedBackground(
            animationController: _backgroundAnimationController,
          ),
          Column(
            children: <Widget>[
              SizedBox(height: 20.h),
              SlideTransition(
                position: _headerSlideAnimation,
                child: FadeTransition(
                  opacity: _headerAnimation,
                  child: _buildTransactionHeader(),
                ),
              ),
              _buildCategoryButtons(),
              Expanded(
                child: uid == null
                    ? _buildNoTransactionsView()
                    : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(uid)
                      .collection(_getCollectionName())
                      .orderBy(_getOrderByField(), descending: true)
                      .snapshots(),
                  builder: (BuildContext context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return _buildShimmerLoading(context);
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    final List<QueryDocumentSnapshot<Map<String, dynamic>>> docs =
                        snapshot.data?.docs ?? <QueryDocumentSnapshot<Map<String, dynamic>>>[];
                    final List<TransactionModel> base = docs.map(_fromFirestore).toList();

                    if (base.isEmpty) {
                      return _buildNoTransactionsView();
                    }

                    final List<TransactionModel> filtered = _getFilteredTransactions(base);
                    if (filtered.isEmpty) {
                      return _buildNoTransactionsView();
                    }

                    final Map<String, List<TransactionModel>> grouped =
                    _groupTransactionsByDate(filtered);
                    return _buildTransactionsList(grouped);
                  },
                ),
              ),
            ],
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
      case TransactionCategory.insurance:
      case TransactionCategory.donation:
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
      case TransactionCategory.donation:
        return 'Donations';
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
          children: <Widget>[
            Expanded(
              flex: 5,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 45.h,
                child: AppTextFormField(
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
        child: icon != null
            ? Icon(icon, color: Colors.white)
            : SvgPicture.asset(iconPath),
      ),
    );
  }

  Widget _buildNoTransactionsView() {
    return FadeTransition(
      opacity: _contentAnimationController,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ScaleTransition(
              scale: Tween<double>(begin: 0.5, end: 1.0).animate(
                CurvedAnimation(
                  parent: _contentAnimationController,
                  curve: Curves.elasticOut,
                ),
              ),
              child: const Icon(Icons.wallet, size: 150, color: MyTheme.primaryColor),
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
                children: <Widget>[
                  Text(
                    'No ${_getCategoryTitle()}',
                    style: Font.montserratFont(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    'You haven\'t completed any\n${_getCategoryTitle().toLowerCase()} yet',
                    textAlign: TextAlign.center,
                    style: Font.montserratFont(
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

  Widget _buildTransactionsList(Map<String, List<TransactionModel>> groupedTransactions) {
    return AnimationLimiter(
      child: ListView.builder(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        itemCount: groupedTransactions.length,
        itemBuilder: (BuildContext context, int index) {
          final String dateKey = groupedTransactions.keys.elementAt(index);
          final List<TransactionModel> transactionsForDate = groupedTransactions[dateKey]!;

          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
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
                              child: GestureDetector(
                                onTap: () => _showTransactionDetail(transaction),
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
      builder: (BuildContext context, Widget? child) {
        return ShaderMask(
          shaderCallback: (Rect bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: const <Color>[
                Colors.transparent,
                Colors.white54,
                Colors.transparent,
              ],
              stops: <double>[
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
  final List<String> periodOptions = <String>['All time', 'Today', 'This week', 'This month'];
  final List<String> statusOptions = <String>['Completed', 'Pending', 'Failed'];
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
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Filter Transactions',
                    style: Font.montserratFont(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              const Divider(),
              SizedBox(height: 10.h),

              Text(
                'Period',
                style: Font.montserratFont(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10.h),
              Wrap(
                spacing: 10.w,
                children: periodOptions.map((String option) {
                  final bool isSelected = filters['period'] == option;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    child: ChoiceChip(
                      label: Text(
                        option,
                        style: Font.montserratFont(
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: MyTheme.primaryColor,
                      onSelected: (bool selected) {
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

              Text(
                'Custom Date Range',
                style: Font.montserratFont(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
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
                    builder: (BuildContext context, Widget? child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.light(
                            primary: MyTheme.primaryColor,
                          ),
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
                    color: filters['dateRange'] != null
                        ? MyTheme.primaryColor.withOpacity(0.1)
                        : Colors.transparent,
                  ),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.calendar_today,
                        color: MyTheme.primaryColor,
                        size: 18.sp,
                      ),
                      SizedBox(width: 10.w),
                      filters['dateRange'] != null
                          ? Text(
                        '${DateFormat('MMM d, yyyy').format(filters['dateRange'].start)} - '
                            '${DateFormat('MMM d, yyyy').format(filters['dateRange'].end)}',
                        style: Font.montserratFont(fontSize: 14.sp),
                      )
                          : Text(
                        'Select date range',
                        style: Font.montserratFont(
                          fontSize: 14.sp,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20.h),

              Text(
                'Status',
                style: Font.montserratFont(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10.h),
              Wrap(
                spacing: 10.w,
                children: statusOptions.map((String status) {
                  final isSelected = filters['statuses'].contains(status);
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    child: FilterChip(
                      label: Text(
                        status,
                        style: Font.montserratFont(
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: MyTheme.primaryColor,
                      onSelected: (bool selected) {
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

              Row(
                children: <Widget>[
                  Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            filters = <String, dynamic>{
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
                        child: Text(
                          'Reset',
                          style: Font.montserratFont(
                            fontSize: 16.sp,
                            color: MyTheme.primaryColor,
                          ),
                        ),
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
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        child: Text(
                          'Apply Filters',
                          style: Font.montserratFont(
                            fontSize: 16.sp,
                            color: Colors.white,
                          ),
                        ),
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

class TransactionDetailSheet extends StatefulWidget {
  final TransactionModel transaction;
  final TransactionCategory category;

  const TransactionDetailSheet({
    Key? key,
    required this.transaction,
    required this.category,
  }) : super(key: key);

  @override
  State<TransactionDetailSheet> createState() => _TransactionDetailSheetState();
}

class _TransactionDetailSheetState extends State<TransactionDetailSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Icons.check_circle;
      case 'pending':
        return Icons.access_time;
      case 'failed':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  Widget _buildDetailRow(String label, String value, {bool isHighlighted = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: Font.montserratFont(
                fontSize: 14.sp,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: Font.montserratFont(
                fontSize: 14.sp,
                fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w600,
                color: isHighlighted ? MyTheme.primaryColor : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(top: 16.h, bottom: 8.h),
      child: Text(
        title,
        style: Font.montserratFont(
          fontSize: 16.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  List<Widget> _buildTransactionDetails() {
    final data = widget.transaction.additionalData ?? {};

    return <Widget>[
      _buildDetailRow('Transaction ID', widget.transaction.id),
      _buildDetailRow('Recipient', widget.transaction.title),
      _buildDetailRow(
        'Amount',
        'PKR ${widget.transaction.amount.toStringAsFixed(2)}',
        isHighlighted: true,
      ),
      _buildDetailRow(
        'Date',
        DateFormat('MMMM dd, yyyy').format(widget.transaction.dateTime),
      ),
      _buildDetailRow(
        'Time',
        DateFormat('hh:mm a').format(widget.transaction.dateTime),
      ),
      if (data['recipient_account'] != null)
        _buildDetailRow('Account Number', data['recipient_account'].toString()),
      if (data['bank_name'] != null)
        _buildDetailRow('Bank', data['bank_name'].toString()),
      if (data['transaction_type'] != null)
        _buildDetailRow('Type', data['transaction_type'].toString()),
      if (data['reference_number'] != null)
        _buildDetailRow('Reference', data['reference_number'].toString()),
    ];
  }

  List<Widget> _buildPayBillDetails() {
    final data = widget.transaction.additionalData ?? {};

    return <Widget>[
      _buildDetailRow('Bill Number', widget.transaction.id),
      _buildDetailRow('Company', data['companyName']?.toString() ?? 'N/A'),
      _buildDetailRow('Bill Type', data['billType']?.toString() ?? 'N/A'),
      _buildDetailRow(
        'Amount',
        'PKR ${widget.transaction.amount.toStringAsFixed(2)}',
        isHighlighted: true,
      ),
      _buildDetailRow(
        'Date',
        DateFormat('MMMM dd, yyyy').format(widget.transaction.dateTime),
      ),
      _buildDetailRow(
        'Time',
        DateFormat('hh:mm a').format(widget.transaction.dateTime),
      ),
      if (data['consumerNumber'] != null)
        _buildDetailRow('Consumer Number', data['consumerNumber'].toString()),
      if (data['dueDate'] != null)
        _buildDetailRow('Due Date', data['dueDate'].toString()),
      if (data['billingMonth'] != null)
        _buildDetailRow('Billing Month', data['billingMonth'].toString()),
    ];
  }

  List<Widget> _buildInsuranceDetails() {
    final data = widget.transaction.additionalData ?? {};

    return <Widget>[
      _buildDetailRow('Policy Number', widget.transaction.id),
      _buildDetailRow('Company', data['companyName']?.toString() ?? 'N/A'),
      _buildDetailRow('Insurance Type', data['insuranceType']?.toString() ?? 'N/A'),
      _buildDetailRow(
        'Premium Amount',
        'PKR ${widget.transaction.amount.toStringAsFixed(2)}',
        isHighlighted: true,
      ),
      _buildDetailRow(
        'Date',
        DateFormat('MMMM dd, yyyy').format(widget.transaction.dateTime),
      ),
      if (data['coverageAmount'] != null)
        _buildDetailRow(
          'Coverage',
          'PKR ${(data['coverageAmount'] as num).toStringAsFixed(2)}',
        ),
      if (data['policyStartDate'] != null)
        _buildDetailRow('Policy Start', data['policyStartDate'].toString()),
      if (data['policyEndDate'] != null)
        _buildDetailRow('Policy End', data['policyEndDate'].toString()),
      if (data['beneficiaryName'] != null)
        _buildDetailRow('Beneficiary', data['beneficiaryName'].toString()),
    ];
  }

  List<Widget> _buildTicketDetails() {
    final data = widget.transaction.additionalData ?? {};

    return <Widget>[
      _buildDetailRow('Booking ID', data['bookingId']?.toString() ?? 'N/A'),
      _buildDetailRow('Movie', widget.transaction.title),
      _buildDetailRow('Cinema', data['cinemaChain']?.toString() ?? 'N/A'),
      _buildDetailRow('Location', data['cinemaLocation']?.toString() ?? 'N/A'),
      _buildDetailRow(
        'Total Amount',
        'PKR ${widget.transaction.amount.toStringAsFixed(2)}',
        isHighlighted: true,
      ),
      _buildDetailRow(
        'Booking Date',
        DateFormat('MMMM dd, yyyy').format(widget.transaction.dateTime),
      ),
      if (data['showDate'] != null)
        _buildDetailRow('Show Date', data['showDate'].toString()),
      if (data['showTime'] != null)
        _buildDetailRow('Show Time', data['showTime'].toString()),
      if (data['numberOfTickets'] != null)
        _buildDetailRow('Tickets', data['numberOfTickets'].toString()),
      if (data['seatType'] != null)
        _buildDetailRow('Seat Type', data['seatType'].toString()),
      if (data['seatNumbers'] != null)
        _buildDetailRow('Seats', data['seatNumbers'].toString()),
      if (data['hallNumber'] != null)
        _buildDetailRow('Hall', data['hallNumber'].toString()),
    ];
  }

  List<Widget> _buildDonationDetails() {
    final data = widget.transaction.additionalData ?? {};

    return <Widget>[
      _buildDetailRow('Donation ID', widget.transaction.id),
      _buildDetailRow('Organization', data['organizationName']?.toString() ?? 'N/A'),
      _buildDetailRow('Donation Type', data['donationType']?.toString() ?? 'N/A'),
      _buildDetailRow(
        'Amount',
        'PKR ${widget.transaction.amount.toStringAsFixed(2)}',
        isHighlighted: true,
      ),
      _buildDetailRow(
        'Date',
        DateFormat('MMMM dd, yyyy').format(widget.transaction.dateTime),
      ),
      _buildDetailRow(
        'Time',
        DateFormat('hh:mm a').format(widget.transaction.dateTime),
      ),
      if (data['cause'] != null)
        _buildDetailRow('Cause', data['cause'].toString()),
      if (data['taxDeductible'] != null)
        _buildDetailRow(
          'Tax Deductible',
          data['taxDeductible'] == true ? 'Yes' : 'No',
        ),
      if (data['certificateNumber'] != null)
        _buildDetailRow('Certificate', data['certificateNumber'].toString()),
      if (data['donorName'] != null)
        _buildDetailRow('Donor Name', data['donorName'].toString()),
      if (data['anonymous'] != null)
        _buildDetailRow(
          'Anonymous',
          data['anonymous'] == true ? 'Yes' : 'No',
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return SlideTransition(
      position: _slideAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          margin: EdgeInsets.only(top: 100.h),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30.r),
              topRight: Radius.circular(30.r),
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            children: <Widget>[
              // Handle bar
              Container(
                margin: EdgeInsets.only(top: 12.h),
                width: 50.w,
                height: 5.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),

              // Header
              Padding(
                padding: EdgeInsets.all(20.r),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'Transaction Details',
                      style: Font.montserratFont(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.close,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // Status Card
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: EdgeInsets.all(20.r),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: <Color>[
                              _getStatusColor(widget.transaction.status).withOpacity(0.8),
                              _getStatusColor(widget.transaction.status),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(15.r),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: _getStatusColor(widget.transaction.status).withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          children: <Widget>[
                            Icon(
                              _getStatusIcon(widget.transaction.status),
                              size: 50.sp,
                              color: Colors.white,
                            ),
                            SizedBox(height: 10.h),
                            Text(
                              widget.transaction.status,
                              style: Font.montserratFont(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 5.h),
                            Text(
                              'PKR ${widget.transaction.amount.toStringAsFixed(2)}',
                              style: Font.montserratFont(
                                fontSize: 28.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Details Section
                      _buildSectionTitle('Details'),
                      Container(
                        padding: EdgeInsets.all(16.r),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                          borderRadius: BorderRadius.circular(15.r),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: _getCategorySpecificDetails(),
                        ),
                      ),

                      SizedBox(height: 30.h),

                      // Action Buttons
                      if (widget.transaction.status.toLowerCase() == 'completed')
                        Column(
                          children: <Widget>[
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  await ReceiptService.downloadReceipt(
                                    context: context,
                                    transactionId: widget.transaction.id,
                                    title: widget.transaction.title,
                                    amount: widget.transaction.amount,
                                    status: widget.transaction.status,
                                    dateTime: widget.transaction.dateTime,
                                    category: _getCategoryName(widget.category),
                                    additionalData: widget.transaction.additionalData,
                                  );
                                },
                                icon: const Icon(Icons.download, color: Colors.white),
                                label: Text(
                                  'Download Receipt',
                                  style: Font.montserratFont(
                                    fontSize: 16.sp,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: MyTheme.primaryColor,
                                  padding: EdgeInsets.symmetric(vertical: 14.h),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 10.h),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () async {
                                  await ReceiptService.shareReceipt(
                                    context: context,
                                    transactionId: widget.transaction.id,
                                    title: widget.transaction.title,
                                    amount: widget.transaction.amount,
                                    status: widget.transaction.status,
                                    dateTime: widget.transaction.dateTime,
                                    category: _getCategoryName(widget.category),
                                    additionalData: widget.transaction.additionalData,
                                  );
                                },
                                icon: Icon(
                                  Icons.share,
                                  color: MyTheme.primaryColor,
                                ),
                                label: Text(
                                  'Share Receipt',
                                  style: Font.montserratFont(
                                    fontSize: 16.sp,
                                    color: MyTheme.primaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(vertical: 14.h),
                                  side: const BorderSide(color: MyTheme.primaryColor),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                      SizedBox(height: 30.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getCategoryName(TransactionCategory category) {
    switch (category) {
      case TransactionCategory.transaction:
        return 'Transaction';
      case TransactionCategory.payBills:
        return 'Bill Payment';
      case TransactionCategory.insurance:
        return 'Insurance';
      case TransactionCategory.tickets:
        return 'Ticket Booking';
      case TransactionCategory.donation:
        return 'Donation';
    }
  }

  List<Widget> _getCategorySpecificDetails() {
    switch (widget.category) {
      case TransactionCategory.transaction:
        return _buildTransactionDetails();
      case TransactionCategory.payBills:
        return _buildPayBillDetails();
      case TransactionCategory.insurance:
        return _buildInsuranceDetails();
      case TransactionCategory.tickets:
        return _buildTicketDetails();
      case TransactionCategory.donation:
        return _buildDonationDetails();
    }
  }
}