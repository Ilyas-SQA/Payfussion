import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:payfussion/core/theme/theme.dart';
import 'package:payfussion/services/payment_service.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/card/card_model.dart';
import '../../../../data/models/recipient/recipient_model.dart';
import '../../../core/constants/fonts.dart';
import '../../../logic/blocs/add_card/card_bloc.dart';
import '../../../logic/blocs/add_card/card_event.dart';
import '../../../logic/blocs/add_card/card_state.dart';
import '../../../logic/blocs/transaction/transaction_bloc.dart';
import '../../../logic/blocs/transaction/transaction_event.dart';
import '../../../logic/blocs/transaction/transaction_state.dart';
import '../../widgets/background_theme.dart';

class PaymentStrings {
  static const String paymentScreen = 'Payment';
  static const String enterAmount = 'Enter amount';
  static const String selectAccount = 'Select Account';
  static const String send = 'Send';
  static const String transactionFee = 'Transaction Fee';
  static const String totalAmount = 'Total Amount';
}

class Taxes {
  static const double transactionFee = 1.0;
  static const double billTax = 1.0;
  static const double internalTransferFee = 0.5;
}

class PaymentScreen extends StatefulWidget {
  final RecipientModel recipient;
  const PaymentScreen({super.key, required this.recipient});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen>  with TickerProviderStateMixin{

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
        title: const Text(PaymentStrings.paymentScreen),
      ),
      body: Stack(
        children: <Widget>[
          AnimatedBackground(
            animationController: _backgroundAnimationController,
          ),
          PaymentForm(recipient: widget.recipient),
        ],
      ),
    );
  }
}

class PaymentForm extends StatefulWidget {
  final RecipientModel recipient;
  const PaymentForm({Key? key, required this.recipient}) : super(key: key);

  @override
  State<PaymentForm> createState() => _PaymentFormState();
}

class _PaymentFormState extends State<PaymentForm> with TickerProviderStateMixin {
  final TextEditingController _amountController = TextEditingController();
  final FocusNode _amountFocusNode = FocusNode();

  late AnimationController _slideController;
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _pulseController;

  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

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

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
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

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Start animations
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fadeController.forward();
      _slideController.forward();
      _scaleController.forward();
      _pulseController.repeat(reverse: true);

      print('Initializing payment for recipient: ${widget.recipient.name}');
      context.read<TransactionBloc>().add(PaymentStarted(widget.recipient));
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _amountFocusNode.dispose();
    _slideController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  double _calculateTotalAmount(double amount) {
    return amount + Taxes.transactionFee;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TransactionBloc, TransactionState>(
      listenWhen: (TransactionState p, TransactionState c) =>
      p.isSuccess != c.isSuccess || p.errorMessage != c.errorMessage,
      listener: (BuildContext context, TransactionState state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        }
      },
      builder: (BuildContext context, TransactionState state) {
        print('🔍 Current state recipient: ${state.recipient?.name}');

        if (state.isSuccess) {
          return _buildSuccessState(state);
        }
        return _buildFormContent(state);
      },
    );
  }

  Widget _buildFormContent(TransactionState state) {
    final double totalAmount = _calculateTotalAmount(state.amount);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 16.h),

              // Animated recipient info
              SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: _buildRecipientInfo(widget.recipient),
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
                  child: _buildAmountInput(state),
                ),
              ),

              SizedBox(height: 20.h),

              // Animated fee breakdown
              if (state.amount > 0)
                SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.1),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: _slideController,
                    curve: const Interval(0.4, 1.0, curve: Curves.easeOutCubic),
                  )),
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: _buildFeeBreakdown(state.amount, totalAmount),
                  ),
                ),

              SizedBox(height: 30.h),

              // Animated card selector
              SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.15),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: _slideController,
                  curve: const Interval(0.6, 1.0, curve: Curves.easeOutCubic),
                )),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: _buildCardSelector(state),
                ),
              ),

              SizedBox(height: 60.h),

              // Animated error message
              if (state.errorMessage != null)
                SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, -0.1),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: _slideController,
                    curve: Curves.bounceOut,
                  )),
                  child: _buildErrorMessage(state.errorMessage!),
                ),

              SizedBox(height: state.errorMessage != null ? 20.h : 0),

              // Animated send button
              SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.2),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: _slideController,
                  curve: const Interval(0.8, 1.0, curve: Curves.easeOutCubic),
                )),
                child: ScaleTransition(
                  scale: state.amount > 0 ? _pulseAnimation : _scaleAnimation,
                  child: _buildSendButton(state, totalAmount),
                ),
              ),

              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeeBreakdown(double amount, double totalAmount) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 800),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (BuildContext context, double value, Widget? child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * value),
          child: Opacity(
            opacity: value,
            child: Container(
              padding: EdgeInsets.all(16.r),
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
                children: <Widget>[
                  _animatedFeeRow('Amount', '\$${amount.toStringAsFixed(2)}', value, 0),
                  SizedBox(height: 8.h),
                  _animatedFeeRow(PaymentStrings.transactionFee, '\$${Taxes.transactionFee.toStringAsFixed(2)}', value, 0.2),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: (500 * value).round()),
                      child: Divider(color: Colors.grey.withOpacity(0.3 * value)),
                    ),
                  ),
                  _animatedFeeRow(PaymentStrings.totalAmount, '\$${totalAmount.toStringAsFixed(2)}', value, 0.4, isTotal: true),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _animatedFeeRow(String label, String amount, double progress, double delay, {bool isTotal = false}) {
    final double animationValue = ((progress - delay) / (1 - delay)).clamp(0.0, 1.0);

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      tween: Tween(begin: 0.0, end: animationValue),
      builder: (BuildContext context, double value, Widget? child) {
        return Transform.translate(
          offset: Offset(20 * (1 - value), 0),
          child: Opacity(
            opacity: value,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(
                      label,
                      style: Font.montserratFont(
                        fontSize: isTotal ? 16.sp : 14.sp,
                        fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                    if (!isTotal && label == PaymentStrings.transactionFee) ...<Widget>[
                      SizedBox(width: 4.w),
                      Icon(
                        Icons.info_outline,
                        size: 16.sp,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ],
                ),
                Text(
                  amount,
                  style: Font.montserratFont(
                    fontSize: isTotal ? 16.sp : 14.sp,
                    fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSuccessState(TransactionState state) {
    final double totalAmount = _calculateTotalAmount(state.amount);
    final String formattedAmount = '\$${state.amount.toStringAsFixed(2)}';
    final String formattedTotal = '\$${totalAmount.toStringAsFixed(2)}';

    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Animated success icon
              TweenAnimationBuilder(
                duration: const Duration(milliseconds: 1200),
                tween: Tween<double>(begin: 0, end: 1),
                builder: (BuildContext context, double value, Widget? child) {
                  return Transform.scale(
                    scale: value,
                    child: Transform.rotate(
                      angle: (1 - value) * 0.5,
                      child: Container(
                        padding: EdgeInsets.all(20.r),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          shape: BoxShape.circle,
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: Colors.green.withOpacity(0.2 * value),
                              blurRadius: 20 * value,
                              spreadRadius: 5 * value,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 80.sp,
                        ),
                      ),
                    ),
                  );
                },
              ),

              SizedBox(height: 32.h),

              // Animated success text
              TweenAnimationBuilder(
                duration: const Duration(milliseconds: 800),
                tween: Tween<double>(begin: 0, end: 1),
                builder: (BuildContext context, double value, Widget? child) {
                  return Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: Opacity(
                      opacity: value,
                      child: Text(
                        'Payment Successful!',
                        style: Font.montserratFont(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  );
                },
              ),

              SizedBox(height: 16.h),

              // Animated details container
              TweenAnimationBuilder(
                duration: const Duration(milliseconds: 1000),
                tween: Tween<double>(begin: 0, end: 1),
                builder: (BuildContext context, double value, Widget? child) {
                  return Transform.scale(
                    scale: 0.9 + (0.1 * value),
                    child: Opacity(
                      opacity: value,
                      child: Container(
                        padding: EdgeInsets.all(16.r),
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
                          children: <Widget>[
                            _successRow('Amount', formattedAmount, Icons.attach_money),
                            _animatedDivider(24.h),
                            _successRow('Transaction Fee', '\$${Taxes.transactionFee.toStringAsFixed(2)}', Icons.receipt_long),
                            _animatedDivider(24.h),
                            _successRow('Total Paid', formattedTotal, Icons.payment, isHighlight: true),
                            _animatedDivider(24.h),
                            _successRow(
                                'Recipient',
                                state.recipient?.name ?? widget.recipient.name,
                                Icons.person),
                            if (state.selectedCard != null) ...<Widget>[
                              _animatedDivider(24.h),
                              _successRow(
                                'Card',
                                '${state.selectedCard!.brand ?? 'Card'} **** ${state.selectedCard!.last4 ?? '****'}',
                                Icons.credit_card,
                              ),
                            ],
                            _animatedDivider(24.h),
                            _successRow('Date', _getCurrentDate(), Icons.calendar_today),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),

              SizedBox(height: 40.h),

              // Animated buttons
              TweenAnimationBuilder(
                duration: const Duration(milliseconds: 1200),
                tween: Tween<double>(begin: 0, end: 1),
                builder: (BuildContext context, double value, Widget? child) {
                  return Transform.translate(
                    offset: Offset(0, 30 * (1 - value)),
                    child: Opacity(
                      opacity: value,
                      child: Column(
                        children: <Widget>[
                          ElevatedButton.icon(
                            onPressed: () => Navigator.of(context).pop(true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: MyTheme.primaryColor,
                              padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r)),
                            ),
                            icon: const Icon(Icons.home),
                            label: Text('Back to Home',
                                style: Font.montserratFont(fontSize: 16.sp, fontWeight: FontWeight.w600)),
                          ),
                          SizedBox(height: 16.h),
                          TextButton(
                            onPressed: () {
                              context.read<TransactionBloc>().add(const PaymentReset());
                              context.read<TransactionBloc>().add(PaymentStarted(widget.recipient));
                            },
                            child: Text(
                              'Make Another Payment',
                              style: Font.montserratFont(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                                color: MyTheme.primaryColor,
                              ),
                            ),
                          ),
                        ],
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
  }

  Widget _animatedDivider(double height) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (BuildContext context, double value, Widget? child) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: height,
          child: Center(
            child: Container(
              width: 200.w * value,
              height: 1,
              color: Colors.grey.withOpacity(0.3 * value),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecipientInfo(RecipientModel recipient) {
    return Column(
      children: <Widget>[
        TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 800),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (BuildContext context, double value, Widget? child) {
            return Transform.scale(
              scale: 0.5 + (0.5 * value),
              child: Hero(
                tag: 'recipient_image_${recipient.id}',
                child: Container(
                  width: 80.r,
                  height: 80.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: MyTheme.primaryColor.withOpacity(0.1),
                    border: Border.all(
                      color: MyTheme.primaryColor.withOpacity(0.3),
                      width: 2,
                    ),
                    image: recipient.imageUrl.isNotEmpty
                        ? DecorationImage(
                      image: NetworkImage(recipient.imageUrl),
                      fit: BoxFit.cover,
                      onError: (_, __) {},
                    )
                        : null,
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: MyTheme.primaryColor.withOpacity(0.1 * value),
                        blurRadius: 10 * value,
                        spreadRadius: 2 * value,
                      ),
                    ],
                  ),
                  child: recipient.imageUrl.isEmpty ?
                  Center(
                    child: Text(
                      recipient.name.isNotEmpty
                          ? recipient.name[0].toUpperCase()
                          : '?',
                      style: Font.montserratFont(
                        color: MyTheme.primaryColor,
                        fontSize: 32.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                      : null,
                ),
              ),
            );
          },
        ),

        SizedBox(height: 16.h),

        TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 600),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (BuildContext context, double value, Widget? child) {
            return Transform.translate(
              offset: Offset(0, 10 * (1 - value)),
              child: Opacity(
                opacity: value,
                child: Column(
                  children: <Widget>[
                    Text(
                      recipient.name,
                      style: Font.montserratFont(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(Icons.account_balance_outlined, size: 16.sp, color: MyTheme.primaryColor),
                        SizedBox(width: 6.w),
                        Text(
                          recipient.name,
                          style: Font.montserratFont(fontSize: 14.sp),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAmountInput(TransactionState state) {
    return Column(
      children: <Widget>[
        TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 400),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (BuildContext context, double value, Widget? child) {
            return Transform.scale(
              scale: 0.9 + (0.1 * value),
              child: TextField(
                controller: _amountController,
                focusNode: _amountFocusNode,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                textAlign: TextAlign.center,
                style: Font.montserratFont(
                  fontSize: 42.sp,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
                decoration: InputDecoration(
                  hintText: PaymentStrings.enterAmount,
                  hintStyle: Font.montserratFont(
                    fontSize: 30.sp,
                    fontWeight: FontWeight.w400,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  prefixIcon: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      '\$',
                      style: Font.montserratFont(
                        fontSize: 40.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  prefixIconConstraints: BoxConstraints(minWidth: 30.w, minHeight: 0),
                ),
                onChanged: (String value) {
                  final String plain = value.replaceAll(RegExp(r'[^0-9.]'), '');
                  context.read<TransactionBloc>().add(PaymentAmountChanged(plain));
                },
              ),
            );
          },
        ),

        if (state.amountError != null)
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 400),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (BuildContext context, double value, Widget? child) {
              return Transform.translate(
                offset: Offset(0, -10 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: Padding(
                    padding: EdgeInsets.only(top: 8.h),
                    child: Text(
                      state.amountError!,
                      style: Font.montserratFont(color: AppColors.errorRed, fontSize: 14.sp),
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildCardSelector(TransactionState state) {
    return Column(
      children: <Widget>[
        Text(
          PaymentStrings.selectAccount,
          style: Font.montserratFont(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 16.h),
        BlocProvider(
          create: (_) => CardBloc()..add(LoadCards()),
          child: BlocBuilder<CardBloc, CardState>(
            builder: (BuildContext context, CardState cState) {
              if (cState is CardLoading || cState is AddCardLoading) {
                return _loadingCardBox();
              }
              if (cState is CardError) {
                return _errorCardBox(cState.message);
              }
              if (cState is CardLoaded && cState.cards.isNotEmpty) {
                final CardModel? selected = state.selectedCard ?? _pickDefault(cState.cards);
                if (state.selectedCard == null && selected != null) {
                  context.read<TransactionBloc>().add(PaymentSelectCard(selected));
                }
                if (selected == null) {
                  return _errorCardBox('No cards found');
                }
                return TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 600),
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (BuildContext context, double value, Widget? child) {
                    return Transform.translate(
                      offset: Offset(0, 20 * (1 - value)),
                      child: Opacity(
                        opacity: value,
                        child: Column(
                          children: <Widget>[
                            _cardTile(selected, isSelected: true, onTap: null),
                            if (cState.cards.length > 1) ...<Widget>[
                              SizedBox(height: 8.h),
                              GestureDetector(
                                onTap: () => _showCardBottomSheet(context, cState.cards, selected),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      'Change Account',
                                      style: Font.montserratFont(
                                        color: MyTheme.primaryColor,
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(width: 4.w),
                                    Icon(Icons.arrow_drop_down,
                                        color: MyTheme.primaryColor, size: 20.sp),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                );
              }
              return _errorCardBox('No cards found');
            },
          ),
        ),
      ],
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
                    color: AppColors.errorRed.withOpacity(0.1),
                    blurRadius: 4,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Row(
                children: <Widget>[
                  Icon(Icons.error_outline, color: AppColors.errorRed, size: 24.sp),
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

  Widget _buildSendButton(TransactionState state, double totalAmount) {
    print('🔍 Send button validation:');
    print('   Amount: ${state.amount}');
    print('   Amount error: ${state.amountError}');
    print('   Selected card: ${state.selectedCard?.brand}');
    print('   Recipient: ${state.recipient?.name}');

    final bool isValid = state.amount > 0 &&
        state.amountError == null &&
        state.selectedCard != null &&
        state.recipient != null;

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
                  boxShadow: isValid && !state.isProcessing
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
                  onPressed: (!isValid || state.isProcessing)
                      ? null
                      : () {
                    HapticFeedback.mediumImpact();
                    FocusScope.of(context).unfocus();
                    context.read<TransactionBloc>().add(const PaymentSubmit());
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
                    child: state.isProcessing
                        ? Row(
                      key: const ValueKey('processing'),
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(
                          width: 24.w,
                          height: 24.h,
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
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
                        : Column(
                      key: const ValueKey('send'),
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          '${PaymentStrings.send} \$${totalAmount.toStringAsFixed(2)}',
                          style: Font.montserratFont(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        if (state.amount > 0)
                          Text(
                            'Includes \$${Taxes.transactionFee.toStringAsFixed(2)} fee',
                            style: Font.montserratFont(
                              fontSize: 12.sp,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                      ],
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

  // Helper methods
  CardModel? _pickDefault(List<CardModel> cards) {
    try {
      return cards.firstWhere((CardModel e) => e.isDefault == true);
    } catch (_) {}
    return cards.isNotEmpty ? cards.first : null;
  }

  Widget _cardTile(CardModel card,
      {required bool isSelected, VoidCallback? onTap}) {
    final String brand = (card.brand ?? 'Card').toString();
    final String last4 = (card.last4 ?? '****').toString();
    final String holder = '';

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 500),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (BuildContext context, double value, Widget? child) {
        return Transform.scale(
          scale: 0.95 + (0.05 * value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: double.infinity,
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withOpacity(0.05 * value),
                  blurRadius: 8 * value,
                  spreadRadius: -2,
                ),
              ],
              border: Border.all(
                color: isSelected
                    ? MyTheme.primaryColor.withOpacity(0.3)
                    : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: InkWell(
              onTap: onTap,
              child: Row(
                children: <Widget>[
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 48.r,
                    height: 48.r,
                    decoration: BoxDecoration(
                      color: MyTheme.primaryColor.withOpacity(isSelected ? 0.15 : 0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Center(
                      child: Icon(Icons.credit_card,
                          color: MyTheme.primaryColor, size: 24.sp),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          holder.isEmpty ? brand : holder,
                          style: Font.montserratFont(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          '$brand **** $last4',
                          style: Font.montserratFont(
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 400),
                      tween: Tween(begin: 0.0, end: 1.0),
                      builder: (BuildContext context, double checkValue, Widget? child) {
                        return Transform.scale(
                          scale: checkValue,
                          child: Icon(Icons.check_circle,
                              color: MyTheme.primaryColor, size: 20.sp),
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

  void _showCardBottomSheet(BuildContext context, List<CardModel> cards, CardModel selected) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      builder: (BuildContext context) {
        return TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 400),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (BuildContext context, double value, Widget? child) {
            return Transform.translate(
              offset: Offset(0, 100 * (1 - value)),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1 * value),
                      blurRadius: 10 * value,
                      spreadRadius: -5,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                padding: EdgeInsets.symmetric(vertical: 20.h),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      width: 50.w,
                      height: 5.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Text(
                      'Select Account',
                      style: Font.montserratFont(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    ...cards.asMap().entries.map((MapEntry<int, CardModel> entry) {
                      final int index = entry.key;
                      final CardModel card = entry.value;
                      final bool isSel = selected.id == card.id;

                      return TweenAnimationBuilder<double>(
                        duration: Duration(milliseconds: 300 + (index * 100)),
                        tween: Tween(begin: 0.0, end: 1.0),
                        builder: (BuildContext context, double cardValue, Widget? child) {
                          return Transform.translate(
                            offset: Offset(50 * (1 - cardValue), 0),
                            child: Opacity(
                              opacity: cardValue,
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 16.w),
                                child: _cardTile(
                                  card,
                                  isSelected: isSel,
                                  onTap: () {
                                    context
                                        .read<TransactionBloc>()
                                        .add(PaymentSelectCard(card));
                                    HapticFeedback.selectionClick();
                                    Navigator.pop(context);
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }),
                    SizedBox(height: 16.h),
                    // Add New Card Button
                    TweenAnimationBuilder<double>(
                      duration: Duration(milliseconds: 300 + (cards.length * 100)),
                      tween: Tween(begin: 0.0, end: 1.0),
                      builder: (BuildContext context, double buttonValue, Widget? child) {
                        return Transform.translate(
                          offset: Offset(50 * (1 - buttonValue), 0),
                          child: Opacity(
                            opacity: buttonValue,
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.w),
                              child: GestureDetector(
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  PaymentService().saveCard(context);
                                },
                                child: Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 20.w),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12.r),
                                    border: Border.all(
                                      color: Colors.grey[300]!,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Row(
                                    children: <Widget>[
                                      Container(
                                        width: 40.w,
                                        height: 40.h,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(8.r),
                                        ),
                                        child: Icon(
                                          Icons.add,
                                          size: 20.sp,
                                        ),
                                      ),
                                      SizedBox(width: 16.w),
                                      Text(
                                        'Add New Card',
                                        style: Font.montserratFont(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const Spacer(),
                                      Icon(
                                        Icons.arrow_forward_ios,
                                        size: 16.sp,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 16.h),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _loadingCardBox() {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: _cardBoxDecoration(),
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 1000),
        tween: Tween(begin: 0.0, end: 1.0),
        builder: (BuildContext context, double value, Widget? child) {
          return Transform.rotate(
            angle: value * 2 * 3.14159,
            child: const CircularProgressIndicator(
              strokeWidth: 3,
              color: MyTheme.primaryColor,
            ),
          );
        },
      ),
    );
  }

  Widget _errorCardBox(String msg) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 400),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (BuildContext context, double value, Widget? child) {
        return Transform.scale(
          scale: 0.9 + (0.1 * value),
          child: Opacity(
            opacity: value,
            child: Container(
              padding: EdgeInsets.all(16.r),
              decoration: _cardBoxDecoration(),
              child: Center(
                child: Text(
                  msg,
                  style: Font.montserratFont(color: AppColors.errorRed, fontSize: 14.sp),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  BoxDecoration _cardBoxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12.r),
      boxShadow: <BoxShadow>[
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 8,
          spreadRadius: -2,
        ),
      ],
    );
  }

  Widget _successRow(String label, String value, IconData icon, {bool isHighlight = false}) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (BuildContext context, double animValue, Widget? child) {
        return Transform.translate(
          offset: Offset(20 * (1 - animValue), 0),
          child: Opacity(
            opacity: animValue,
            child: Row(
              children: <Widget>[
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: isHighlight
                        ? MyTheme.primaryColor.withOpacity(0.1)
                        : Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: isHighlight ? <BoxShadow>[
                      BoxShadow(
                        color: MyTheme.primaryColor.withOpacity(0.2),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ] : <BoxShadow>[],
                  ),
                  child: Icon(
                    icon,
                    size: 18.sp,
                    color: MyTheme.primaryColor,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        label,
                        style: Font.montserratFont(
                          fontSize: 12.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        value,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600,
                          color: isHighlight ? MyTheme.primaryColor : AppColors.textPrimary,
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
    );
  }

  String _getCurrentDate() {
    final DateTime now = DateTime.now();
    const List<String> months = <String>[
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    return '${months[now.month - 1]} ${now.day}, ${now.year}';
  }
}

class AppStyles {
  static final TextStyle title = Font.montserratFont(
    fontSize: 18.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
  static final TextStyle subtitle = Font.montserratFont(
    fontSize: 16.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
  static final TextStyle caption = Font.montserratFont(
    fontSize: 14.sp,
    color: AppColors.textSecondary,
  );
}