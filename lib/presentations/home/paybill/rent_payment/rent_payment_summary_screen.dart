import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:payfussion/core/theme/theme.dart';
import '../../../../logic/blocs/pay_bill/rent_payment/rent_payment_bloc.dart';
import '../../../../logic/blocs/pay_bill/rent_payment/rent_payment_event.dart';
import '../../../../logic/blocs/pay_bill/rent_payment/rent_payment_state.dart';

class RentPaymentSummaryScreen extends StatefulWidget {
  const RentPaymentSummaryScreen({super.key});

  @override
  State<RentPaymentSummaryScreen> createState() => _RentPaymentSummaryScreenState();
}

class _RentPaymentSummaryScreenState extends State<RentPaymentSummaryScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Summary'),
        backgroundColor: Colors.transparent,
      ),
      body: BlocConsumer<RentPaymentBloc, RentPaymentState>(
        listener: (BuildContext context, RentPaymentState state) {
          if (state is RentPaymentSuccess) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) => ScaleTransition(
                scale: CurvedAnimation(
                  parent: AnimationController(
                    duration: const Duration(milliseconds: 400),
                    vsync: Navigator.of(context),
                  )..forward(),
                  curve: Curves.elasticOut,
                ),
                child: AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.elasticOut,
                        builder: (context, value, child) {
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
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 400),
                        builder: (context, value, child) {
                          return Opacity(
                            opacity: value,
                            child: Text(
                              'Payment Successful!',
                              style: TextStyle(
                                fontSize: 22.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        'Transaction ID: ${state.transactionId}',
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
                        context.read<RentPaymentBloc>().add(const ResetRentPayment());
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
          } else if (state is RentPaymentError) {
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
        builder: (BuildContext context, RentPaymentState state) {
          if (state is RentPaymentProcessing) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 1000),
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: 0.5 + (value * 0.5),
                        child: const CircularProgressIndicator(
                          color: MyTheme.primaryColor,
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 20.h),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 600),
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Text(
                          'Processing your payment...',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          }

          if (state is! RentPaymentDataSet) {
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
                    _buildAnimatedHeader(),
                    SizedBox(height: 32.h),

                    // Company Info Card
                    _buildAnimatedInfoCard(
                      context,
                      title: 'Rental Platform',
                      icon: Icons.business,
                      delay: 0,
                      children: <Widget>[
                        _buildInfoRow('Platform', state.companyName, Icons.apartment),
                        _buildInfoRow('Category', state.category, Icons.category),
                      ],
                    ),
                    SizedBox(height: 16.h),

                    // Property Details Card
                    _buildAnimatedInfoCard(
                      context,
                      title: 'Property Details',
                      icon: Icons.home_work,
                      delay: 100,
                      children: <Widget>[
                        _buildInfoRow('Address', state.propertyAddress, Icons.location_on),
                      ],
                    ),
                    SizedBox(height: 16.h),

                    // Landlord Details Card
                    _buildAnimatedInfoCard(
                      context,
                      title: 'Landlord Information',
                      icon: Icons.person,
                      delay: 200,
                      children: <Widget>[
                        _buildInfoRow('Name', state.landlordName, Icons.person_outline),
                        _buildInfoRow('Email', state.landlordEmail, Icons.email_outlined),
                        _buildInfoRow('Phone', state.landlordPhone, Icons.phone_outlined),
                      ],
                    ),
                    SizedBox(height: 16.h),

                    // Payment Card Info
                    if (state.cardId != null)
                      _buildAnimatedInfoCard(
                        context,
                        title: 'Payment Method',
                        icon: Icons.credit_card,
                        delay: 300,
                        children: <Widget>[
                          _buildInfoRow('Card Holder', state.cardHolderName!, Icons.account_circle),
                          _buildInfoRow('Card Number', '****${state.cardEnding}', Icons.credit_card),
                        ],
                      ),

                    if (state.cardId != null)
                      SizedBox(height: 16.h),

                    // Notes (if any)
                    if (state.notes != null && state.notes!.isNotEmpty)
                      _buildAnimatedInfoCard(
                        context,
                        title: 'Additional Notes',
                        icon: Icons.note,
                        delay: 400,
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.all(12.w),
                            decoration: BoxDecoration(
                              color: MyTheme.primaryColor.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(
                                color: MyTheme.primaryColor.withOpacity(0.2),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Icon(
                                  Icons.sticky_note_2,
                                  size: 18.sp,
                                  color: MyTheme.primaryColor,
                                ),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: Text(
                                    state.notes!,
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                    if (state.notes != null && state.notes!.isNotEmpty)
                      SizedBox(height: 16.h),

                    // Amount Breakdown Card
                    _buildAnimatedAmountCard(context, state),
                    SizedBox(height: 32.h),

                    // Confirm Button
                    _buildAnimatedButton(context),
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
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, -20 * (1 - value)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Icon(
                      Icons.receipt_long,
                      color: MyTheme.primaryColor,
                      size: 28.sp,
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      'Review Your Payment',
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Padding(
                  padding: EdgeInsets.only(left: 40.w),
                  child: Text(
                    'Please review all details before confirming',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedInfoCard(
      BuildContext context, {
        required String title,
        required IconData icon,
        required List<Widget> children,
        required int delay,
      }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + delay),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(30 * (1 - value), 0),
            child: Transform.scale(
              scale: 0.9 + (0.1 * value),
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
                        Container(
                          padding: EdgeInsets.all(10.w),
                          decoration: BoxDecoration(
                            color: MyTheme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Icon(icon, color: MyTheme.primaryColor, size: 22.sp),
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
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: 16.sp, color: MyTheme.primaryColor.withOpacity(0.7)),
          SizedBox(width: 8.w),
          SizedBox(
            width: 110.w,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
            ),
          ),
          SizedBox(width: 8.w),
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

  Widget _buildAnimatedAmountCard(BuildContext context, RentPaymentDataSet state) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * value),
          child: Opacity(
            opacity: value,
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
                  Row(
                    children: <Widget>[
                      Icon(Icons.payments, color: Colors.white, size: 20.sp),
                      SizedBox(width: 8.w),
                      Text(
                        'Payment Breakdown',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  _buildAnimatedAmountRow(
                    'Rent Amount',
                    state.amount,
                    isWhite: true,
                    delay: 0,
                  ),
                  Divider(color: Colors.white.withOpacity(0.3), height: 24.h),
                  _buildAnimatedAmountRow(
                    'Tax',
                    state.taxAmount,
                    isWhite: true,
                    delay: 200,
                  ),
                  Divider(color: Colors.white.withOpacity(0.3), height: 24.h),
                  _buildAnimatedAmountRow(
                    'Total Amount',
                    state.totalAmount,
                    isWhite: true,
                    isBold: true,
                    isLarge: true,
                    delay: 400,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedAmountRow(
      String label,
      double amount, {
        bool isWhite = false,
        bool isBold = false,
        bool isLarge = false,
        int delay = 0,
      }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: amount),
      duration: Duration(milliseconds: 1000 + delay),
      curve: Curves.easeOut,
      builder: (context, value, child) {
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
              '\$${value.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: isLarge ? 24.sp : 16.sp,
                fontWeight: FontWeight.bold,
                color: isWhite ? Colors.white : Colors.black,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAnimatedButton(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            decoration: BoxDecoration(
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: MyTheme.primaryColor.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  context.read<RentPaymentBloc>().add(const ProcessRentPayment());
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
                    Icon(Icons.verified, color: Colors.white, size: 22.sp),
                    SizedBox(width: 12.w),
                    Text(
                      'Confirm Payment',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}