import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:payfussion/core/theme/theme.dart';
import '../../../../logic/blocs/pay_bill/dth_bill/dth_bill_bloc.dart';
import '../../../../logic/blocs/pay_bill/dth_bill/dth_bill_event.dart';
import '../../../../logic/blocs/pay_bill/dth_bill/dth_bill_state.dart';

class DthSummaryScreen extends StatefulWidget {
  const DthSummaryScreen({super.key});

  @override
  State<DthSummaryScreen> createState() => _DthSummaryScreenState();
}

class _DthSummaryScreenState extends State<DthSummaryScreen>
    with TickerProviderStateMixin {

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late AnimationController _rotationController;
  late AnimationController _successController;
  late AnimationController _buttonPulseController;
  late AnimationController _tvGlowController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _successScaleAnimation;
  late Animation<double> _buttonPulseAnimation;
  late Animation<double> _tvGlowAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startAnimationSequence();
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
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));

    // Scale animation
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOutBack),
    );

    // Rotation animation for icons
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.easeInOut),
    );

    // Success animation
    _successController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _successScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _successController, curve: Curves.elasticOut),
    );

    // Button pulse animation
    _buttonPulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _buttonPulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _buttonPulseController, curve: Curves.easeInOut),
    );

    // TV glow animation
    _tvGlowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
    _tvGlowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _tvGlowController, curve: Curves.easeInOut),
    );
  }

  void _startAnimationSequence() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _fadeController.forward();

    await Future.delayed(const Duration(milliseconds: 150));
    _slideController.forward();

    await Future.delayed(const Duration(milliseconds: 200));
    _scaleController.forward();

    _rotationController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    _rotationController.dispose();
    _successController.dispose();
    _buttonPulseController.dispose();
    _tvGlowController.dispose();
    super.dispose();
  }

  void _showSuccessDialog(String message, String transactionId) {
    _successController.forward();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => ScaleTransition(
        scale: _successScaleAnimation,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 1000),
                tween: Tween(begin: 0.0, end: 1.0),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Transform.rotate(
                      angle: value * 6.28, // Full rotation
                      child: child,
                    ),
                  );
                },
                child: Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 80.sp,
                ),
              ),
              SizedBox(height: 20.h),
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 800),
                tween: Tween(begin: 0.0, end: 1.0),
                curve: Curves.easeOut,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 20 * (1 - value)),
                      child: child,
                    ),
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
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 1000),
                tween: Tween(begin: 0.0, end: 1.0),
                curve: Curves.easeOut,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: child,
                  );
                },
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              SizedBox(height: 10.h),
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 1200),
                tween: Tween(begin: 0.0, end: 1.0),
                curve: Curves.easeOut,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: child,
                  );
                },
                child: Text(
                  'Transaction ID: $transactionId',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[500],
                  ),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                context.read<DthRechargeBloc>().add(const ResetDthRecharge());
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FadeTransition(
          opacity: _fadeAnimation,
          child: const Text('DTH Recharge Summary'),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: BlocConsumer<DthRechargeBloc, DthRechargeState>(
        listener: (BuildContext context, DthRechargeState state) {
          if (state is DthRechargeSuccess) {
            _showSuccessDialog(state.message, state.transactionId);
          } else if (state is DthRechargeError) {
            showDialog(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.r),
                ),
                title: const Text('Error'),
                content: Text(state.error),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          }
        },
        builder: (BuildContext context, DthRechargeState state) {
          if (state is DthRechargeProcessing) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 1500),
                    tween: Tween(begin: 0.0, end: 1.0),
                    curve: Curves.easeInOut,
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: 0.5 + (value * 0.5),
                        child: Transform.rotate(
                          angle: value * 6.28 * 2, // Two rotations
                          child: child,
                        ),
                      );
                    },
                    child: const CircularProgressIndicator(
                      color: MyTheme.primaryColor,
                      strokeWidth: 4,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 2000),
                    tween: Tween(begin: 0.0, end: 1.0),
                    curve: Curves.easeOut,
                    builder: (context, value, child) {
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

          if (state is! DthRechargeDataSet) {
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
                    // Header with animation
                    _buildAnimatedSection(
                      delay: 0,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Review Your DTH Recharge',
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
                    ),
                    SizedBox(height: 32.h),

                    // Provider Info Card
                    _buildAnimatedSection(
                      delay: 100,
                      child: _buildInfoCard(
                        context,
                        title: 'DTH Provider',
                        icon: Icons.tv,
                        children: <Widget>[
                          _buildInfoRow('Provider', state.providerName),
                          _buildInfoRow('Rating', '⭐ ${state.rating}'),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Subscriber Details Card
                    _buildAnimatedSection(
                      delay: 200,
                      child: _buildInfoCard(
                        context,
                        title: 'Subscriber Details',
                        icon: Icons.person,
                        children: <Widget>[
                          _buildInfoRow('Subscriber ID', state.subscriberId),
                          _buildInfoRow('Customer Name', state.customerName),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Plan Details Card
                    _buildAnimatedSection(
                      delay: 300,
                      child: _buildInfoCard(
                        context,
                        title: 'Plan Details',
                        icon: Icons.card_giftcard,
                        children: <Widget>[
                          _buildInfoRow('Selected Plan', state.selectedPlan),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Payment Card Info
                    if (state.cardId != null)
                      _buildAnimatedSection(
                        delay: 400,
                        child: _buildInfoCard(
                          context,
                          title: 'Payment Method',
                          icon: Icons.credit_card,
                          children: <Widget>[
                            _buildInfoRow('Card Holder', state.cardHolderName!),
                            _buildInfoRow('Card Number', '****${state.cardEnding}'),
                          ],
                        ),
                      ),
                    SizedBox(height: 16.h),

                    // Amount Breakdown Card
                    _buildAnimatedSection(
                      delay: 500,
                      child: _buildAmountCard(context, state),
                    ),
                    SizedBox(height: 32.h),

                    // Confirm Button
                    _buildAnimatedSection(
                      delay: 600,
                      child: _buildConfirmButton(context),
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

  Widget _buildAnimatedSection({required int delay, required Widget child}) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 600 + delay),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOut,
      builder: (context, value, child) {
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
              // Animated icon with glow effect for TV
              AnimatedBuilder(
                animation: icon == Icons.tv ? _tvGlowAnimation : _rotationAnimation,
                builder: (context, child) {
                  return Container(
                    decoration: icon == Icons.tv ? BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: MyTheme.primaryColor.withOpacity(_tvGlowAnimation.value * 0.5),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ) : null,
                    child: RotationTransition(
                      turns: AlwaysStoppedAnimation(icon == Icons.tv ? 0 : _rotationAnimation.value),
                      child: Icon(icon, color: MyTheme.primaryColor, size: 24.sp),
                    ),
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

  Widget _buildAmountCard(BuildContext context, DthRechargeDataSet state) {
    return ScaleTransition(
      scale: _scaleAnimation,
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
    return ScaleTransition(
      scale: _buttonPulseAnimation,
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            context.read<DthRechargeBloc>().add(const ProcessDthPayment());
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: MyTheme.primaryColor,
            padding: EdgeInsets.symmetric(vertical: 16.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            elevation: 4,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Confirm Payment',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 8.w),
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 1500),
                tween: Tween(begin: 0.0, end: 1.0),
                curve: Curves.easeInOut,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: 0.8 + (0.4 * value),
                    child: child,
                  );
                },
                child: const Icon(
                  Icons.check_circle_outline,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}