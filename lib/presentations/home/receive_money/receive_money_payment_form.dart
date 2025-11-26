import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:payfussion/data/models/card/card_model.dart';
import 'package:payfussion/data/models/recipient/recipient_model.dart';
import 'package:payfussion/logic/blocs/payment_request/payment_request_bloc.dart';
import 'package:payfussion/logic/blocs/payment_request/payment_request_event.dart';
import 'package:payfussion/logic/blocs/payment_request/payment_request_state.dart';
import 'package:payfussion/presentations/home/receive_money/receive_money_payment_screen.dart';
import 'package:payfussion/presentations/home/receive_money/widgets/account_selector_widget.dart';
import 'package:payfussion/presentations/home/receive_money/widgets/expiry_selector_widget.dart';
import 'package:payfussion/presentations/home/receive_money/widgets/note_input_widget.dart';
import 'package:payfussion/presentations/home/receive_money/widgets/success_view_widget.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/fonts.dart';
import '../../../core/theme/theme.dart';
import '../../../data/models/payment_request/payment_request_model.dart';
import '../../../data/repositories/payment_request/payment_request_repository.dart';
import '../../payment_strings.dart';
import 'widgets/amount_input_widget.dart';
import 'widgets/contact_selector_widget.dart';

class ReceiveMoneyPaymentForm extends StatefulWidget {
  const ReceiveMoneyPaymentForm({super.key});

  @override
  State<ReceiveMoneyPaymentForm> createState() => _ReceiveMoneyPaymentFormState();
}

class _ReceiveMoneyPaymentFormState extends State<ReceiveMoneyPaymentForm> with TickerProviderStateMixin {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final FocusNode _amountFocusNode = FocusNode();
  final FocusNode _noteFocusNode = FocusNode();

  RecipientModel? selectedRecipient;
  CardModel? selectedCard;
  int selectedExpiryDays = 7;
  bool _isProcessing = false;

  // Animation controllers
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _bounceController;
  late AnimationController _rotateController;
  late AnimationController _backgroundAnimationController;

  // Animations
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _bounceAnimation;
  late Animation<double> _rotateAnimation;

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

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _rotateController = AnimationController(
      duration: const Duration(milliseconds: 2000),
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

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _bounceAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.easeInOut,
    ));

    _rotateAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rotateController,
      curve: Curves.linear,
    ));

    // Start animations
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fadeController.forward();
      _slideController.forward();
      _scaleController.forward();
      _bounceController.repeat(reverse: true);
    });

    /// Load existing payment requests when the form initializes
    context.read<PaymentRequestBloc>().add(const LoadPaymentRequests());
    _backgroundAnimationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _amountFocusNode.dispose();
    _noteFocusNode.dispose();
    _slideController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    _bounceController.dispose();
    _rotateController.dispose();
    _backgroundAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ReceiveMoneyPaymentProvider>(
      builder: (BuildContext context, ReceiveMoneyPaymentProvider provider, _) {
        return BlocConsumer<PaymentRequestBloc, PaymentRequestState>(
          listener: (BuildContext context, PaymentRequestState state) {
            if (state.status == PaymentRequestStatus.failure) {
              _showErrorSnackBar(state.errorMessage ?? 'Unknown error occurred');
            }
          },
          builder: (BuildContext context, PaymentRequestState blocState) {
            if (provider.isSuccess) {
              return _buildSuccessView(provider);
            }

            /// Update text field if provider state changes
            final String formattedAmount = provider.getFormattedAmount();
            if (_amountController.text != formattedAmount) {
              _amountController.text = formattedAmount;
              _amountController.selection = TextSelection.fromPosition(
                TextPosition(offset: formattedAmount.length),
              );
            }

            return _buildFormContent(provider, blocState);
          },
        );
      },
    );
  }

  Widget _buildSuccessView(ReceiveMoneyPaymentProvider provider) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1000),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (BuildContext context, double value, Widget? child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * value),
          child: Opacity(
            opacity: value,
            child: PaymentSuccessView(provider: provider),
          ),
        );
      },
    );
  }

  Widget _buildFormContent(ReceiveMoneyPaymentProvider provider, PaymentRequestState blocState) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 20.h),

              // Animated request icon
              SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: _buildRequestIcon(),
                ),
              ),

              SizedBox(height: 40.h),

              // Animated amount input
              SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.2),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: _slideController,
                  curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
                )),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: AmountInputWidget(
                    controller: _amountController,
                    focusNode: _amountFocusNode,
                    provider: provider,
                  ),
                ),
              ),

              SizedBox(height: 40.h),

              // Animated contact selector
              SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.15),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: _slideController,
                  curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
                )),
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: ContactSelectorWidget(
                    selectedRecipient: selectedRecipient,
                    onRecipientSelected: (RecipientModel recipient) {
                      setState(() {
                        selectedRecipient = recipient;
                      });
                      print('Selected recipient: ${recipient.name}');
                    },
                  ),
                ),
              ),

              SizedBox(height: 30.h),

              // Animated note input
              SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.1),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: _slideController,
                  curve: const Interval(0.4, 1.0, curve: Curves.easeOutCubic),
                )),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: NoteInputWidget(
                    controller: _noteController,
                    focusNode: _noteFocusNode,
                    provider: provider,
                  ),
                ),
              ),

              SizedBox(height: 30.h),

              // Animated account selector
              SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.1),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: _slideController,
                  curve: const Interval(0.5, 1.0, curve: Curves.easeOutCubic),
                )),
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: AccountSelectorWidget(
                    onCardSelected: (CardModel? card) {
                      setState(() {
                        selectedCard = card;
                      });
                    },
                  ),
                ),
              ),

              SizedBox(height: 30.h),

              // Animated expiry selector
              SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.1),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: _slideController,
                  curve: const Interval(0.6, 1.0, curve: Curves.easeOutCubic),
                )),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: ExpirySelectorWidget(
                    provider: provider,
                    onExpiryChanged: (int days) {
                      setState(() {
                        selectedExpiryDays = days;
                      });
                    },
                  ),
                ),
              ),

              SizedBox(height: 40.h),

              // Animated error messages
              if (blocState.status == PaymentRequestStatus.failure && blocState.errorMessage != null)
                SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, -0.1),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: _slideController,
                    curve: Curves.bounceOut,
                  )),
                  child: _buildErrorMessage(blocState.errorMessage!),
                ),

              if (provider.errorMessage != null)
                SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, -0.1),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: _slideController,
                    curve: Curves.bounceOut,
                  )),
                  child: _buildErrorMessage(provider.errorMessage!),
                ),

              SizedBox(height: (blocState.errorMessage != null || provider.errorMessage != null) ? 20.h : 0),

              // Animated recent requests section
              if (blocState.requests.isNotEmpty) ...<Widget>[
                SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.1),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: _slideController,
                    curve: const Interval(0.7, 1.0, curve: Curves.easeOutCubic),
                  )),
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: _buildRecentRequestsSection(blocState.requests),
                  ),
                ),
                SizedBox(height: 30.h),
              ],

              // Animated request button
              SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.2),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: _slideController,
                  curve: const Interval(0.8, 1.0, curve: Curves.easeOutCubic),
                )),
                child: ScaleTransition(
                  scale: provider.amount > 0 ? _bounceAnimation : _scaleAnimation,
                  child: _buildRequestButton(provider, blocState),
                ),
              ),

              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRequestIcon() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 800),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (BuildContext context, double value, Widget? child) {
        return Transform.scale(
          scale: 0.5 + (0.5 * value),
          child: Container(
            width: 80.r,
            height: 80.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: MyTheme.primaryColor.withOpacity(0.1),
              border: Border.all(
                color: MyTheme.primaryColor.withOpacity(0.3 * value),
                width: 2,
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: MyTheme.primaryColor.withOpacity(0.1 * value),
                  blurRadius: 10 * value,
                  spreadRadius: 2 * value,
                ),
              ],
            ),
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 1000),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (BuildContext context, double iconValue, Widget? child) {
                return Transform.rotate(
                  angle: iconValue * 0.1,
                  child: Icon(
                    Icons.account_balance_wallet,
                    size: 40.r,
                    color: MyTheme.primaryColor.withOpacity(iconValue),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecentRequestsSection(List<PaymentRequestModel> requests) {
    final List<PaymentRequestModel> recentRequests = requests.take(3).toList();

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (BuildContext context, double value, Widget? child) {
        return Transform.scale(
          scale: 0.95 + (0.05 * value),
          child: Opacity(
            opacity: value,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: MyTheme.primaryColor.withOpacity(0.1),
                  width: 1,
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: MyTheme.primaryColor.withOpacity(0.05 * value),
                    blurRadius: 8 * value,
                    offset: Offset(0, 2 * value),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 500),
                    tween: Tween(begin: 0.0, end: 1.0),
                    builder: (BuildContext context, double titleValue, Widget? child) {
                      return Transform.translate(
                        offset: Offset(20 * (1 - titleValue), 0),
                        child: Opacity(
                          opacity: titleValue,
                          child: Text(
                            'Recent Payment Requests',
                            style: Font.montserratFont(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: MyTheme.primaryColor,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 12.h),
                  ...recentRequests.asMap().entries.map((MapEntry<int, PaymentRequestModel> entry) {
                    final int index = entry.key;
                    final PaymentRequestModel request = entry.value;
                    return TweenAnimationBuilder<double>(
                      duration: Duration(milliseconds: 400 + (index * 150)),
                      tween: Tween(begin: 0.0, end: 1.0),
                      builder: (BuildContext context, double itemValue, Widget? child) {
                        return Transform.translate(
                          offset: Offset(30 * (1 - itemValue), 0),
                          child: Opacity(
                            opacity: itemValue,
                            child: _buildRequestItem(request),
                          ),
                        );
                      },
                    );
                  }),
                  if (requests.length > 3)
                    TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 600),
                      tween: Tween(begin: 0.0, end: 1.0),
                      builder: (BuildContext context, double moreValue, Widget? child) {
                        return Opacity(
                          opacity: moreValue,
                          child: Padding(
                            padding: EdgeInsets.only(top: 8.h),
                            child: Text(
                              'and ${requests.length - 3} more...',
                              style: Font.montserratFont(
                                fontSize: 12.sp,
                                color: MyTheme.primaryColor.withOpacity(0.7),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
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

  Widget _buildRequestItem(PaymentRequestModel request) {
    Color statusColor;
    IconData statusIcon;

    switch (request.status.toLowerCase()) {
      case 'completed':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'declined':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      case 'expired':
        statusColor = Colors.orange;
        statusIcon = Icons.schedule;
        break;
      default:
        statusColor = Colors.blue;
        statusIcon = Icons.schedule;
    }

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 400),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (BuildContext context, double value, Widget? child) {
        return Transform.scale(
          scale: 0.95 + (0.05 * value),
          child: Container(
            margin: EdgeInsets.only(bottom: 8.h),
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: statusColor.withOpacity(0.2 * value),
                width: 1,
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: statusColor.withOpacity(0.1 * value),
                  blurRadius: 4 * value,
                  offset: Offset(0, 2 * value),
                ),
              ],
            ),
            child: Row(
              children: <Widget>[
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 500),
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (BuildContext context, double iconValue, Widget? child) {
                    return Transform.scale(
                      scale: iconValue,
                      child: Icon(
                        statusIcon,
                        size: 16.sp,
                        color: statusColor.withOpacity(iconValue),
                      ),
                    );
                  },
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        request.payer.isNotEmpty ? request.payer : 'Unknown',
                        style: Font.montserratFont(
                          fontSize: 14.sp,
                        ),
                      ),
                      Text(
                        request.formattedAmount,
                        style: Font.montserratFont(
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 600),
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (BuildContext context, double chipValue, Widget? child) {
                    return Transform.scale(
                      scale: chipValue,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1 * chipValue),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          request.statusDisplayText,
                          style: Font.montserratFont(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorMessage(String message) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 500),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (BuildContext context, double value, Widget? child) {
        return Transform.scale(
          scale: 0.9 + (0.1 * value),
          child: Opacity(
            opacity: value,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: EdgeInsets.only(bottom: 16.h),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: AppColors.errorRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: AppColors.errorRed.withOpacity(0.3),
                  width: 1,
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: AppColors.errorRed.withOpacity(0.1 * value),
                    blurRadius: 4 * value,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Row(
                children: <Widget>[
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 400),
                    tween: Tween(begin: 0.0, end: 1.0),
                    builder: (BuildContext context, double iconValue, Widget? child) {
                      return Transform.scale(
                        scale: iconValue,
                        child: Icon(
                          Icons.error_outline,
                          color: AppColors.errorRed,
                          size: 24.sp,
                        ),
                      );
                    },
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      message,
                      style: Font.montserratFont(
                        color: AppColors.errorRed,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRequestButton(ReceiveMoneyPaymentProvider provider, PaymentRequestState blocState) {
    final bool isValid =
        provider.amount > 0 &&
            provider.amountError == null &&
            selectedRecipient != null &&
            selectedCard != null;

    final bool isLoading = _isProcessing ||
        provider.isProcessing ||
        blocState.status == PaymentRequestStatus.loading;

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (BuildContext context, double value, Widget? child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: SizedBox(
              width: double.infinity,
              height: 56.h,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: isValid && !isLoading
                      ? <BoxShadow>[
                    BoxShadow(
                      color: MyTheme.primaryColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                      : <BoxShadow>[],
                ),
                child: ElevatedButton(
                  onPressed: (!isValid || isLoading)
                      ? null
                      : () async {
                    await _handleCreatePaymentRequest(provider);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MyTheme.primaryColor,
                    disabledBackgroundColor: MyTheme.primaryColor.withOpacity(0.6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    elevation: 0,
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: isLoading ? Row(
                      key: const ValueKey('loading'),
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        RotationTransition(
                          turns: _rotateAnimation,
                          child: SizedBox(
                            width: 24.w,
                            height: 24.h,
                            child: const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Text(
                          "Processing...",
                          style: Font.montserratFont(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    )
                        : Text(
                      key: const ValueKey('request'),
                      ReceiveMoneyPaymentStrings.requestButton,
                      style: Font.montserratFont(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleCreatePaymentRequest(ReceiveMoneyPaymentProvider provider) async {
    if (selectedRecipient == null || selectedCard == null) {
      _showErrorSnackBar('Please select recipient and account');
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    // Start processing animation
    _rotateController.repeat();

    try {
      HapticFeedback.mediumImpact();
      FocusScope.of(context).unfocus();

      /// Create account snapshot from selected card
      final Map<String, String> accountSnapshot = <String, String>{
        'card_id': selectedCard!.id,
        'card_number': selectedCard!.last4,
        'card_type': selectedCard!.brand,
        'bank_name': selectedCard!.brand,
        'created_at': DateTime.now().toIso8601String(),
      };

      /// Use the repository directly - create a new instance
      final FirestorePaymentRepository repository = FirestorePaymentRepository();

      await repository.createPaymentRequest(
        amount: provider.amount,
        currencyCode: 'USD',
        description: _noteController.text.trim().isEmpty ? 'Payment request' : _noteController.text.trim(),
        expiryDays: selectedExpiryDays,
        recipient: selectedRecipient!,
        accountSnapshot: accountSnapshot,
        paymentLink: null,
        qrCodeData: null,
      );

      /// Reload payment requests to show the new one
      context.read<PaymentRequestBloc>().add(const LoadPaymentRequests());

      /// Call provider's success method to show success view
      await provider.createPaymentRequest();

      _showSuccessSnackBar('Payment request created successfully!');

    } catch (e) {
      _showErrorSnackBar('Failed to create payment request: ${e.toString()}');
    } finally {
      _rotateController.stop();
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.errorRed,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(16.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  void _showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: <Widget>[
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 500),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (BuildContext context, double value, Widget? child) {
                  return Transform.scale(
                    scale: value,
                    child: const Icon(Icons.check_circle, color: Colors.white),
                  );
                },
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(16.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}