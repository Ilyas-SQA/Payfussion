import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:payfussion/presentations/widgets/auth_widgets/credential_text_field.dart';
import '../../../core/constants/fonts.dart';
import '../../../core/theme/theme.dart';
import '../../../data/models/payment_request/payment_request_model.dart';
import '../../../logic/blocs/payment_request/payment_request_bloc.dart';
import '../../../logic/blocs/payment_request/payment_request_event.dart';
import '../../../logic/blocs/payment_request/payment_request_state.dart';
import '../../widgets/background_theme.dart';
import 'receive_money_payment_screen.dart';

class ReceiveMoneyScreen extends StatefulWidget {
  const ReceiveMoneyScreen({super.key});

  @override
  State<ReceiveMoneyScreen> createState() => _ReceiveMoneyScreenState();
}

class _ReceiveMoneyScreenState extends State<ReceiveMoneyScreen> with TickerProviderStateMixin{

  late AnimationController _backgroundAnimationController;

  @override
  void initState() {
    super.initState();
    _backgroundAnimationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _backgroundAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: Text('Receive Money', style: Font.montserratFont(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        )),
        actions: <Widget>[
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 800),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (BuildContext context, double value, Widget? child) {
              return Transform.scale(
                scale: 0.8 + (0.2 * value),
                child: Opacity(
                  opacity: value,
                  child: TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ReceiveMoneyPaymentScreen()),
                      );
                    },
                    icon: const Icon(Icons.add_circle_outline, color: MyTheme.primaryColor),
                    label: Text('New Request', style: Font.montserratFont(fontSize: 12,color: MyTheme.primaryColor)),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            AnimatedBackground(
              animationController: _backgroundAnimationController,
            ),
            const PaymentRequestsList(),
          ],
        ),
      ),
    );
  }
}

class PaymentRequestsList extends StatefulWidget {
  const PaymentRequestsList({super.key});

  @override
  State<PaymentRequestsList> createState() => _PaymentRequestsListState();
}

class _PaymentRequestsListState extends State<PaymentRequestsList>
    with TickerProviderStateMixin {
  final TextEditingController _search = TextEditingController();
  Timer? _debounce;
  String _searchQuery = '';
  String _statusFilter = 'All';

  late AnimationController _slideController;
  late AnimationController _fadeController;
  late AnimationController _filterController;
  late AnimationController _listController;

  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _filterAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _filterController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _listController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Initialize animations
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _filterAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _filterController,
      curve: Curves.elasticOut,
    ));

    // Start animations
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fadeController.forward();
      _slideController.forward();
      _filterController.forward();
      _listController.forward();
    });

    /// Load payment requests when screen initializes
    context.read<PaymentRequestBloc>().add(const LoadPaymentRequests());
  }

  @override
  void dispose() {
    _search.dispose();
    _debounce?.cancel();
    _slideController.dispose();
    _fadeController.dispose();
    _filterController.dispose();
    _listController.dispose();
    super.dispose();
  }

  /// Filter requests based on search query and status filter
  List<PaymentRequestModel> _getFilteredRequests(List<PaymentRequestModel> requests) {
    List<PaymentRequestModel> filtered = requests;

    /// Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((PaymentRequestModel request) {
        return request.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            request.payer.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    /// Apply status filter
    if (_statusFilter != 'All') {
      filtered = filtered.where((PaymentRequestModel request) {
        return request.status.toLowerCase() == _statusFilter.toLowerCase();
      }).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PaymentRequestBloc, PaymentRequestState>(
      builder: (BuildContext context, PaymentRequestState state) {
        return Column(
          children: <Widget>[
            SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: _buildSearch(context),
              ),
            ),
            SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.2),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: _slideController,
                curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
              )),
              child: ScaleTransition(
                scale: _filterAnimation,
                child: _buildFilterChips(context),
              ),
            ),
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
                  child: _buildBody(context, state),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSearch(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (BuildContext context, double value, Widget? child) {
        return Transform.scale(
          scale: 0.95 + (0.05 * value),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: AppTextFormField(
              controller: _search,
              onChanged: (String q) {
                _debounce?.cancel();
                _debounce = Timer(const Duration(milliseconds: 400), () {
                  setState(() {
                    _searchQuery = q;
                  });
                });
              },
              isPasswordField: false,
              helpText: 'Search requests...',
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilterChips(BuildContext context) {
    Widget chip(String label, int index) => TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (BuildContext context, double value, Widget? child) {
        return Transform.translate(
          offset: Offset(20 * (1 - value), 0),
          child: Opacity(
            opacity: value,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                child: FilterChip(
                  selected: _statusFilter == label,
                  label: Text(label,style: Font.montserratFont(color: _statusFilter == label ? Colors.white : Colors.black),),
                  selectedColor: MyTheme.primaryColor,
                  onSelected: (_) {
                    setState(() {
                      _statusFilter = label;
                    });
                  },
                ),
              ),
            ),
          ),
        );
      },
    );

    final List<String> filters = <String>['All', 'Pending', 'Completed', 'Expired', 'Declined'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: filters
            .asMap()
            .entries
            .map((MapEntry<int, String> entry) => chip(entry.value, entry.key))
            .toList(),
      ),
    );
  }

  Widget _buildBody(BuildContext context, PaymentRequestState state) {
    if (state.status == PaymentRequestStatus.loading) {
      return _buildLoadingState();
    }

    if (state.status == PaymentRequestStatus.failure) {
      return _buildErrorState(state);
    }

    if (state.requests.isEmpty) {
      return _empty(context);
    }

    final List<PaymentRequestModel> filteredRequests = _getFilteredRequests(state.requests);

    if (filteredRequests.isEmpty && (_searchQuery.isNotEmpty || _statusFilter != 'All')) {
      return _buildNoResultsState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<PaymentRequestBloc>().add(const LoadPaymentRequests());
        await Future.delayed(const Duration(milliseconds: 350));
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: filteredRequests.length,
        itemBuilder: (_, int i) => TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 300 + (i * 100)),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (BuildContext context, double value, Widget? child) {
            return Transform.translate(
              offset: Offset(0, 50 * (1 - value)),
              child: Opacity(
                opacity: value,
                child: _tile(filteredRequests[i]),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 1000),
        tween: Tween(begin: 0.0, end: 1.0),
        builder: (BuildContext context, double value, Widget? child) {
          return Transform.rotate(
            angle: value * 2 * 3.14159,
            child: const CircularProgressIndicator(
              color: MyTheme.primaryColor,
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(PaymentRequestState state) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (BuildContext context, double value, Widget? child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * value),
          child: Opacity(
            opacity: value,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red.withOpacity(value),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.errorMessage ?? 'An error occurred',
                    textAlign: TextAlign.center,
                    style: Font.montserratFont(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<PaymentRequestBloc>().add(const LoadPaymentRequests());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNoResultsState() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 500),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (BuildContext context, double value, Widget? child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.search_off, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No matching requests'),
                  SizedBox(height: 8),
                  Text('Try adjusting your search or filters'),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _tile(PaymentRequestModel r) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 400),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (BuildContext context, double value, Widget? child) {
        return Transform.scale(
          scale: 0.95 + (0.05 * value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 10),
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
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                _showRequestDetails(context, r);
              },
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: Hero(
                  tag: 'avatar_${r.id}',
                  child: r.payerImageUrl != null
                      ? CircleAvatar(
                    backgroundImage: NetworkImage(r.payerImageUrl!),
                    radius: 24,
                  )
                      : const CircleAvatar(
                    child: Icon(Icons.person),
                    radius: 24,
                  ),
                ),
                title: Text(
                  r.description,
                  style: Font.montserratFont(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const SizedBox(height: 4),
                    Text('From: ${r.payer}'),
                    const SizedBox(height: 2),
                    Text(
                      _formatDate(r.createdAt),
                      style: Font.montserratFont(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 600),
                      tween: Tween(begin: 0.0, end: 1.0),
                      builder: (BuildContext context, double amountValue, Widget? child) {
                        return Transform.scale(
                          scale: 0.8 + (0.2 * amountValue),
                          child: Text(
                            '${r.currencyCode} ${r.amount.toStringAsFixed(2)}',
                            style: Font.montserratFont(
                              fontWeight: FontWeight.w700,
                              color: MyTheme.primaryColor,
                              fontSize: 16,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 4),
                    _statusChip(r.status),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _statusChip(String s) {
    Color c;
    switch (s.toLowerCase()) {
      case 'completed':
        c = Colors.green;
        break;
      case 'pending':
        c = Colors.orange;
        break;
      case 'declined':
        c = Colors.red;
        break;
      case 'expired':
        c = Colors.grey;
        break;
      default:
        c = Colors.blue;
    }

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 500),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (BuildContext context, double value, Widget? child) {
        return Transform.scale(
          scale: value,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: c.withOpacity(.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: c.withOpacity(.3)),
            ),
            child: Text(
              s,
              style: Font.montserratFont(
                color: c,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _empty(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 800),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (BuildContext context, double value, Widget? child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 1000),
                    tween: Tween(begin: 0.0, end: 1.0),
                    builder: (BuildContext context, double iconValue, Widget? child) {
                      return Transform.scale(
                        scale: 0.5 + (0.5 * iconValue),
                        child: Icon(
                          Icons.receipt_long_outlined,
                          size: 64,
                          color: MyTheme.primaryColor.withOpacity(iconValue),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 14),
                   Text(
                    'No payment requests yet',
                    style: Font.montserratFont(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                   Text(
                    'Create a new payment request to get started.',
                    textAlign: TextAlign.center,
                    style: Font.montserratFont(color: Colors.grey),
                  ),
                  const SizedBox(height: 18),
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 600),
                    tween: Tween(begin: 0.0, end: 1.0),
                    builder: (BuildContext context, double buttonValue, Widget? child) {
                      return Transform.scale(
                        scale: 0.8 + (0.2 * buttonValue),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: MyTheme.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ReceiveMoneyPaymentScreen(),
                            ),
                          ),
                          child: const Text('Create Request'),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatDate(String isoDate) {
    try {
      final DateTime date = DateTime.parse(isoDate);
      final DateTime now = DateTime.now();
      final Duration difference = now.difference(date);

      if (difference.inDays == 0) {
        return 'Today';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return 'Unknown';
    }
  }

  void _showRequestDetails(BuildContext context, PaymentRequestModel request) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) => TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 400),
        tween: Tween(begin: 0.0, end: 1.0),
        builder: (BuildContext context, double value, Widget? child) {
          return Transform.translate(
            offset: Offset(0, 200 * (1 - value)),
            child: Opacity(
              opacity: value,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // Handle bar
                    Center(
                      child: TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 300),
                        tween: Tween(begin: 0.0, end: 1.0),
                        builder: (BuildContext context, double handleValue, Widget? child) {
                          return Container(
                            width: 40 * handleValue,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(2),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Title with animation
                    TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 500),
                      tween: Tween(begin: 0.0, end: 1.0),
                      builder: (BuildContext context, double titleValue, Widget? child) {
                        return Transform.translate(
                          offset: Offset(20 * (1 - titleValue), 0),
                          child: Opacity(
                            opacity: titleValue,
                            child: Row(
                              children: <Widget>[
                                Icon(
                                  Icons.receipt_long,
                                  color: MyTheme.primaryColor.withOpacity(titleValue),
                                ),
                                const SizedBox(width: 8),
                                 Text(
                                  'Payment Request Details',
                                  style: Font.montserratFont(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    // Amount (highlighted) with animation
                    TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 700),
                      tween: Tween(begin: 0.0, end: 1.0),
                      builder: (BuildContext context, double amountValue, Widget? child) {
                        return Transform.scale(
                          scale: 0.9 + (0.1 * amountValue),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: MyTheme.primaryColor.withOpacity(0.1 * amountValue),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: MyTheme.primaryColor.withOpacity(0.3 * amountValue),
                              ),
                            ),
                            child: Column(
                              children: <Widget>[
                                Text(
                                  'Amount',
                                  style: Font.montserratFont(
                                    fontSize: 14,
                                    color: Colors.grey.withOpacity(amountValue),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${request.currencyCode} ${request.amount.toStringAsFixed(2)}',
                                  style: Font.montserratFont(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: MyTheme.primaryColor.withOpacity(amountValue),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    // Details with staggered animation
                    ..._buildAnimatedDetails(request),

                    // Bottom padding for safe area
                    SizedBox(height: MediaQuery.of(context).padding.bottom),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildAnimatedDetails(PaymentRequestModel request) {
    final List<(String, String)> details = <(String, String)>[
      ('From', request.payer),
      ('Description', request.description),
      ('Status', request.status),
      ('Created', _formatDate(request.createdAt)),
      ('Expires', _formatDate(request.expiresAt)),
    ];

    if (request.completedAt != null) {
      details.add(('Completed', _formatDate(request.completedAt!)));
    }
    if (request.declinedAt != null) {
      details.add(('Declined', _formatDate(request.declinedAt!)));
    }
    if (request.recipientInstitution != null) {
      details.add(('Institution', request.recipientInstitution!));
    }

    return details.asMap().entries.map((MapEntry<int, (String, String)> entry) {
      final int index = entry.key;
      final (String, String) detail = entry.value;

      return TweenAnimationBuilder<double>(
        duration: Duration(milliseconds: 400 + (index * 100)),
        tween: Tween(begin: 0.0, end: 1.0),
        builder: (BuildContext context, double value, Widget? child) {
          return Transform.translate(
            offset: Offset(30 * (1 - value), 0),
            child: Opacity(
              opacity: value,
              child: _detailRow(detail.$1, detail.$2),
            ),
          );
        },
      );
    }).toList();
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 90,
            child: Text(
              '$label:',
              style: Font.montserratFont(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: Font.montserratFont(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}