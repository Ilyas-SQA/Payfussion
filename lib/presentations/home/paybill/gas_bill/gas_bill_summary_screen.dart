import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:payfussion/core/theme/theme.dart';
import '../../../../logic/blocs/pay_bill/gas_bill/gas_bill_bloc.dart';
import '../../../../logic/blocs/pay_bill/gas_bill/gas_bill_event.dart';
import '../../../../logic/blocs/pay_bill/gas_bill/gas_bill_state.dart';

class GasBillSummaryScreen extends StatefulWidget {
  const GasBillSummaryScreen({super.key});

  @override
  State<GasBillSummaryScreen> createState() => _GasBillSummaryScreenState();
}

class _GasBillSummaryScreenState extends State<GasBillSummaryScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late AnimationController _pulseController;
  late AnimationController _successController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _successScale;
  late Animation<double> _successRotation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startAnimationSequence();
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOutBack),
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _successController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _successScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _successController, curve: Curves.elasticOut),
    );
    _successRotation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _successController, curve: Curves.easeOut),
    );
  }

  void _startAnimationSequence() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _fadeController.forward();

    await Future.delayed(const Duration(milliseconds: 150));
    _slideController.forward();

    await Future.delayed(const Duration(milliseconds: 200));
    _scaleController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    _pulseController.dispose();
    _successController.dispose();
    super.dispose();
  }

  void _showSuccessDialog(GasBillSuccess state) {
    _successController.forward();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => ScaleTransition(
        scale: _successScale,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              RotationTransition(
                turns: _successRotation,
                child: ScaleTransition(
                  scale: _successScale,
                  child: Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 80.sp,
                  ),
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
                  state.message,
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
                  'Transaction ID: ${state.transactionId}',
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
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 1400),
              tween: Tween(begin: 0.0, end: 1.0),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: child,
                );
              },
              child: TextButton(
                onPressed: () {
                  context.read<GasBillBloc>().add(const ResetGasBill());
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
          child: const Text('Payment Summary'),
        ),
      ),
      body: BlocConsumer<GasBillBloc, GasBillState>(
        listener: (BuildContext context, GasBillState state) {
          if (state is GasBillSuccess) {
            _showSuccessDialog(state);
          } else if (state is GasBillError) {
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
        builder: (BuildContext context, GasBillState state) {
          if (state is GasBillProcessing) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 1500),
                    tween: Tween(begin: 0.0, end: 1.0),
                    curve: Curves.easeInOut,
                    builder: (context, value, child) {
                      return Transform.rotate(
                        angle: value * 6.28 * 2,
                        child: child,
                      );
                    },
                    child: const CircularProgressIndicator(
                      color: MyTheme.primaryColor,
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

          if (state is! GasBillDataSet) {
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
                    // Header
                    _buildAnimatedSection(
                      delay: 0,
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
                    ),
                    SizedBox(height: 32.h),

                    // Cards with staggered animation
                    _buildAnimatedSection(
                      delay: 100,
                      child: _buildInfoCard(
                        context,
                        title: 'Gas Provider',
                        icon: Icons.local_fire_department,
                        children: <Widget>[
                          _buildInfoRow('Company', state.companyName),
                          _buildInfoRow('Region', state.region),
                          _buildInfoRow('Rate', state.averageRate),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),

                    _buildAnimatedSection(
                      delay: 200,
                      child: _buildInfoCard(
                        context,
                        title: 'Account Details',
                        icon: Icons.account_balance,
                        children: <Widget>[
                          _buildInfoRow('Account Number', state.accountNumber),
                          _buildInfoRow('Consumer Name', state.consumerName),
                          _buildInfoRow('Bill Month', state.billMonth),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),

                    _buildAnimatedSection(
                      delay: 300,
                      child: _buildInfoCard(
                        context,
                        title: 'Usage Details',
                        icon: Icons.analytics,
                        children: <Widget>[
                          _buildInfoRow('Gas Usage', state.gasUsage),
                          _buildInfoRow('Previous Reading', state.previousReading),
                          _buildInfoRow('Current Reading', state.currentReading),
                          _buildInfoRow('Due Date', state.dueDate),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),

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

                    _buildAnimatedSection(
                      delay: 500,
                      child: _buildAmountCard(context, state),
                    ),
                    SizedBox(height: 32.h),

                    _buildAnimatedSection(
                      delay: 600,
                      child: ScaleTransition(
                        scale: _pulseAnimation,
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              context.read<GasBillBloc>().add(const ProcessGasBillPayment());
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
                                    return Transform.translate(
                                      offset: Offset(5 * value, 0),
                                      child: child,
                                    );
                                  },
                                  child: const Icon(
                                    Icons.check_circle,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
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

  Widget _buildAnimatedSection({required int delay, required Widget child}) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 600 + delay),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOut,
      builder: (context, value, widget) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: widget,
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
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
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
                  duration: const Duration(milliseconds: 1000),
                  tween: Tween(begin: 0.0, end: 1.0),
                  curve: Curves.elasticOut,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Transform.rotate(
                        angle: value * 6.28,
                        child: child,
                      ),
                    );
                  },
                  child: Icon(icon, color: MyTheme.primaryColor, size: 24.sp),
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

  Widget _buildAmountCard(BuildContext context, GasBillDataSet state) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[
              MyTheme.primaryColor,
              MyTheme.primaryColor.withOpacity(0.8)
            ],
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
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 1000),
              tween: Tween(begin: 0.0, end: state.amount),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return _buildAmountRow(
                  'Amount',
                  '\$${value.toStringAsFixed(2)}',
                  isWhite: true,
                );
              },
            ),
            Divider(color: Colors.white.withOpacity(0.3), height: 24.h),
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 1200),
              tween: Tween(begin: 0.0, end: state.taxAmount),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return _buildAmountRow(
                  'Tax',
                  '\$${value.toStringAsFixed(2)}',
                  isWhite: true,
                );
              },
            ),
            Divider(color: Colors.white.withOpacity(0.3), height: 24.h),
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 1400),
              tween: Tween(begin: 0.0, end: state.totalAmount),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return _buildAmountRow(
                  'Total Amount',
                  '\$${value.toStringAsFixed(2)}',
                  isWhite: true,
                  isBold: true,
                  isLarge: true,
                );
              },
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
}