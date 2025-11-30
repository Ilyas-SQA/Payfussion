import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:payfussion/core/theme/theme.dart';
import '../../../../logic/blocs/pay_bill/credit_card_loan/credit_card_loan_bloc.dart';
import '../../../../logic/blocs/pay_bill/credit_card_loan/credit_card_loan_event.dart';
import '../../../../logic/blocs/pay_bill/credit_card_loan/credit_card_loan_state.dart';

class CreditCardLoanSummaryScreen extends StatefulWidget {
  const CreditCardLoanSummaryScreen({super.key});

  @override
  State<CreditCardLoanSummaryScreen> createState() => _CreditCardLoanSummaryScreenState();
}

class _CreditCardLoanSummaryScreenState extends State<CreditCardLoanSummaryScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late AnimationController _pulseController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    // Fade animation
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    // Slide animation
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));

    // Scale animation
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOutBack),
    );

    // Pulse animation for amount card
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Start animations
    _fadeController.forward();
    _slideController.forward();
    _scaleController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _showSuccessDialog(String message, String transactionId) {
    final AnimationController dialogController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    final Animation<double> scaleDialogAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: dialogController, curve: Curves.elasticOut),
    );

    dialogController.forward();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => ScaleTransition(
        scale: scaleDialogAnimation,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 800),
                tween: Tween(begin: 0.0, end: 1.0),
                curve: Curves.elasticOut,
                builder: (BuildContext context, double value, Widget? child) {
                  return Transform.scale(
                    scale: value,
                    child: Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 80.sp,
                    ),
                  );
                },
              ),
              SizedBox(height: 20.h),
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 600),
                tween: Tween(begin: 0.0, end: 1.0),
                curve: Curves.easeOut,
                builder: (BuildContext context, double value, Widget? child) {
                  return Opacity(
                    opacity: value,
                    child: child,
                  );
                },
                child: Text(
                  'Payment Successful!',
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                'Transaction ID: $transactionId',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                context.read<CreditCardLoanBloc>().add(const ResetLoanPayment());
                Navigator.of(context).popUntil((Route route) => route.isFirst);
              },
              child: Text(
                'Done',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: MyTheme.primaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    ).then((_) => dialogController.dispose());
  }

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: const Text('Error'),
        content: Text(error),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Summary'),
        backgroundColor: Colors.transparent,
      ),
      body: BlocConsumer<CreditCardLoanBloc, CreditCardLoanState>(
        listener: (BuildContext context, CreditCardLoanState state) {
          if (state is CreditCardLoanSuccess) {
            _showSuccessDialog(state.message, state.transactionId);
          } else if (state is CreditCardLoanError) {
            _showErrorDialog(state.error);
          }
        },
        builder: (BuildContext context, CreditCardLoanState state) {
          if (state is CreditCardLoanProcessing) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 1000),
                    tween: Tween(begin: 0.0, end: 1.0),
                    builder: (BuildContext context, double value, Widget? child) {
                      return Transform.scale(
                        scale: value,
                        child: const CircularProgressIndicator(
                          color: MyTheme.primaryColor,
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 20.h),
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 800),
                    tween: Tween(begin: 0.0, end: 1.0),
                    curve: Curves.easeOut,
                    builder: (BuildContext context, double value, Widget? child) {
                      return Opacity(
                        opacity: value,
                        child: child,
                      );
                    },
                    child: Text(
                      'Processing your payment...',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          if (state is! CreditCardLoanDataSet) {
            return const Center(child: Text('Invalid state'));
          }

          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _buildAnimatedHeader(),
                    SizedBox(height: 32.h),
                    _buildAnimatedSection(0, _buildInfoCard(
                      context,
                      title: 'Bank Details',
                      icon: Icons.account_balance,
                      children: <Widget>[
                        _buildInfoRow('Bank', state.bankName),
                        _buildInfoRow('Branch', state.branchName),
                      ],
                    )),
                    SizedBox(height: 16.h),
                    _buildAnimatedSection(1, _buildInfoCard(
                      context,
                      title: 'Account Information',
                      icon: Icons.account_balance_wallet,
                      children: <Widget>[
                        _buildInfoRow('Account Number', state.accountNumber),
                        _buildInfoRow('Card Number', '****${state.cardNumber}'),
                      ],
                    )),
                    SizedBox(height: 16.h),
                    _buildAnimatedSection(2, _buildInfoCard(
                      context,
                      title: 'Payment Details',
                      icon: Icons.payment,
                      children: <Widget>[
                        _buildInfoRow('Payment Type', _getPaymentTypeLabel(state.paymentType)),
                        _buildInfoRow('Amount', '\$${state.amount.toStringAsFixed(2)}'),
                      ],
                    )),
                    SizedBox(height: 16.h),
                    if (state.cardId != null)
                      _buildAnimatedSection(3, _buildInfoCard(
                        context,
                        title: 'Payment Method',
                        icon: Icons.credit_card,
                        children: <Widget>[
                          _buildInfoRow('Card Holder', state.cardHolderName!),
                          _buildInfoRow('Card Number', '****${state.cardEnding}'),
                        ],
                      )),
                    SizedBox(height: 16.h),
                    _buildAnimatedSection(4, _buildAmountCard(context, state)),
                    SizedBox(height: 32.h),
                    _buildAnimatedSection(5, _buildConfirmButton(context)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnimatedHeader() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Review Your Payment',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Please review all details before confirming',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedSection(int index, Widget child) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 400 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutCubic,
      builder: (BuildContext context, double value, Widget? child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  Widget _buildInfoCard(
      BuildContext context, {
        required String title,
        required IconData icon,
        required List<Widget> children,
      }) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 600),
                tween: Tween(begin: 0.0, end: 1.0),
                curve: Curves.elasticOut,
                builder: (BuildContext context, double value, Widget? child) {
                  return Transform.scale(
                    scale: value,
                    child: Icon(icon, color: MyTheme.primaryColor, size: 24.sp),
                  );
                },
              ),
              SizedBox(width: 12.w),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountCard(BuildContext context, CreditCardLoanDataSet state) {
    return ScaleTransition(
      scale: _pulseAnimation,
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[MyTheme.primaryColor, MyTheme.primaryColor.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(5.r),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: MyTheme.primaryColor.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: <Widget>[
            _buildAmountRow('Amount', '\$${state.amount.toStringAsFixed(2)}', isWhite: true),
            Divider(color: Colors.white.withOpacity(0.3), height: 24.h),
            _buildAmountRow('Tax', '\$${state.taxAmount.toStringAsFixed(2)}', isWhite: true),
            Divider(color: Colors.white.withOpacity(0.3), height: 24.h),
            _buildAmountRow(
              'Total Amount',
              '\$${state.totalAmount.toStringAsFixed(2)}',
              isWhite: true,
              isBold: true,
              isLarge: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountRow(
      String label,
      String value, {
        bool isWhite = false,
        bool isBold = false,
        bool isLarge = false,
      }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          label,
          style: TextStyle(
            fontSize: isLarge ? 18.sp : 14.sp,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isWhite ? Colors.white : Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isLarge ? 24.sp : 16.sp,
            fontWeight: FontWeight.bold,
            color: isWhite ? Colors.white : Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmButton(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 800),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.elasticOut,
      builder: (BuildContext context, double value, Widget? child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            context.read<CreditCardLoanBloc>().add(const ProcessLoanPayment());
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: MyTheme.primaryColor,
            padding: EdgeInsets.symmetric(vertical: 16.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            elevation: 4,
          ),
          child: Text(
            'Confirm Payment',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  String _getPaymentTypeLabel(String paymentType) {
    switch (paymentType) {
      case 'minimum':
        return 'Minimum Payment';
      case 'full':
        return 'Full Payment';
      case 'custom':
        return 'Custom Amount';
      default:
        return 'Payment';
    }
  }
}