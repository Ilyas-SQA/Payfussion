import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:payfussion/core/theme/theme.dart';
import 'package:payfussion/core/widget/card_screen.dart';
import '../../../../logic/blocs/pay_bill/postpaid_bill/postpaid_bill_bloc.dart';
import '../../../../logic/blocs/pay_bill/postpaid_bill/postpaid_bill_event.dart';

class PostpaidBillFormScreen extends StatefulWidget {
  final String providerName;
  final String planType;
  final String startingPrice;
  final List<String> features;

  const PostpaidBillFormScreen({
    super.key,
    required this.providerName,
    required this.planType,
    required this.startingPrice,
    required this.features,
  });

  @override
  State<PostpaidBillFormScreen> createState() => _PostpaidBillFormScreenState();
}

class _PostpaidBillFormScreenState extends State<PostpaidBillFormScreen>
    with TickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _mobileNumberController = TextEditingController();
  final TextEditingController _billNumberController = TextEditingController();
  final TextEditingController _accountHolderController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  // Enhanced animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late AnimationController _pulseController;
  late AnimationController _rotateController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotateAnimation;

  String _selectedBillCycle = 'Current Month';
  bool _saveForFuture = false;

  final List<String> _billCycles = <String>[
    'Current Month',
    'Previous Month',
    'Custom Period',
  ];

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
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));

    // Scale animation
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOutBack),
    );

    // Pulse animation for button
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Rotate animation for icon
    _rotateController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _rotateAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rotateController, curve: Curves.elasticOut),
    );
  }

  void _startAnimationSequence() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _fadeController.forward();

    await Future.delayed(const Duration(milliseconds: 150));
    _slideController.forward();

    await Future.delayed(const Duration(milliseconds: 200));
    _scaleController.forward();
    _rotateController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    _pulseController.dispose();
    _rotateController.dispose();
    _mobileNumberController.dispose();
    _billNumberController.dispose();
    _accountHolderController.dispose();
    _amountController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _proceedToCardSelection() {
    if (_formKey.currentState!.validate()) {
      final double amount = double.parse(_amountController.text);

      // Set postpaid bill data in bloc
      context.read<PostpaidBillBloc>().add(SetPostpaidBillData(
        providerName: widget.providerName,
        planType: widget.planType,
        startingPrice: widget.startingPrice,
        features: widget.features,
        mobileNumber: _mobileNumberController.text,
        billNumber: _billNumberController.text,
        accountHolderName: _accountHolderController.text,
        billCycle: _selectedBillCycle,
        amount: amount,
        email: _emailController.text.isEmpty ? null : _emailController.text,
        saveForFuture: _saveForFuture,
      ));

      // Navigate to card selection with animation
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const CardsScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOutCubic;
            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);
            return SlideTransition(position: offsetAnimation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: FadeTransition(
          opacity: _fadeAnimation,
          child: Text(
            'Pay Postpaid Bill',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.primaryColor != Colors.white
                  ? Colors.white
                  : const Color(0xff2D3748),
            ),
          ),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.all(24.w),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Provider Info Card with animation
                  _buildAnimatedSection(
                    delay: 0,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: _buildProviderInfoCard(theme),
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // Form Fields with staggered animation
                  _buildAnimatedSection(
                    delay: 200,
                    child: _buildFormFields(theme),
                  ),

                  SizedBox(height: 24.h),

                  // Features Section with animation
                  _buildAnimatedSection(
                    delay: 400,
                    child: _buildFeaturesSection(theme),
                  ),

                  SizedBox(height: 32.h),

                  // Submit Button with pulse
                  _buildAnimatedSection(
                    delay: 600,
                    child: _buildSubmitButton(theme),
                  ),
                ],
              ),
            ),
          ),
        ),
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

  Widget _buildProviderInfoCard(ThemeData theme) {
    final Color cardColor = theme.primaryColor != Colors.white
        ? theme.primaryColor
        : MyTheme.primaryColor;

    final Color textColor = Colors.white;

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[
            cardColor.withOpacity(0.8),
            cardColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(5.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: cardColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              // Animated phone icon
              Container(
                width: 50.w,
                height: 50.w,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: EdgeInsets.all(8.w),
                child: Image.asset(
                  // Provider name se match karke sahi icon dikhao
                  widget.providerName == "Verizon Wireless"
                      ? "assets/images/paybill/postpaid_bill/verizon.png"
                      : widget.providerName == "AT&T Mobility"
                      ? "assets/images/paybill/postpaid_bill/at_t_mobility.png"
                      : widget.providerName == "T-Mobile US"
                      ? "assets/images/paybill/postpaid_bill/t_mobile.png"
                      : widget.providerName == "US Cellular"
                      ? "assets/images/paybill/postpaid_bill/us_cellular.png"
                      : widget.providerName == "Google Fi Wireless"
                      ? "assets/images/paybill/postpaid_bill/google_fi_wireless.png"
                      : widget.providerName == "Visible"
                      ? "assets/images/paybill/postpaid_bill/visible.png"
                      : widget.providerName == "Cricket Wireless"
                      ? "assets/images/paybill/postpaid_bill/cricket_wireless.png"
                      : widget.providerName == "Boost Mobile"
                      ? "assets/images/paybill/postpaid_bill/boost_mobile.png"
                      : "assets/images/paybill/postpaid_bill/verizon.png", // Default
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.phone_android,
                      size: 24.sp,
                      color: MyTheme.primaryColor,
                    );
                  },
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      widget.providerName,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      widget.planType,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: textColor.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 1000),
                tween: Tween(begin: 0.0, end: 1.0),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: child,
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    widget.startingPrice,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFormFields(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Mobile Number
        _buildAnimatedFormField(
          delay: 0,
          label: 'Mobile Number',
          child: TextFormField(
            controller: _mobileNumberController,
            keyboardType: TextInputType.phone,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
            decoration: InputDecoration(
              hintText: 'Enter your mobile number',
              prefixIcon: const Icon(Icons.phone),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return 'Please enter mobile number';
              }
              if (value.length != 10) {
                return 'Mobile number must be 10 digits';
              }
              return null;
            },
          ),
          theme: theme,
        ),

        SizedBox(height: 20.h),

        // Bill/Account Number
        _buildAnimatedFormField(
          delay: 100,
          label: 'Bill/Account Number',
          child: TextFormField(
            controller: _billNumberController,
            keyboardType: TextInputType.text,
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              hintText: 'Enter bill/account number',
              prefixIcon: const Icon(Icons.receipt_long),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return 'Please enter bill/account number';
              }
              if (value.length < 6) {
                return 'Account number must be at least 6 characters';
              }
              return null;
            },
          ),
          theme: theme,
        ),

        SizedBox(height: 20.h),

        // Account Holder Name
        _buildAnimatedFormField(
          delay: 200,
          label: 'Account Holder Name',
          child: TextFormField(
            controller: _accountHolderController,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              hintText: 'Enter account holder name',
              prefixIcon: const Icon(Icons.person),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return 'Please enter account holder name';
              }
              return null;
            },
          ),
          theme: theme,
        ),

        SizedBox(height: 20.h),

        // Bill Cycle
        _buildAnimatedFormField(
          delay: 300,
          label: 'Bill Cycle',
          child: DropdownButtonFormField<String>(
            value: _selectedBillCycle,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.calendar_today),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            items: _billCycles.map((String cycle) {
              return DropdownMenuItem<String>(
                value: cycle,
                child: Text(cycle),
              );
            }).toList(),
            onChanged: (String? value) {
              setState(() {
                _selectedBillCycle = value!;
              });
            },
          ),
          theme: theme,
        ),

        SizedBox(height: 20.h),

        // Amount
        _buildAnimatedFormField(
          delay: 400,
          label: 'Bill Amount',
          child: TextFormField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly,
            ],
            decoration: InputDecoration(
              hintText: 'Enter bill amount',
              prefixIcon: const Icon(Icons.attach_money),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return 'Please enter bill amount';
              }
              final int? amount = int.tryParse(value);
              if (amount == null || amount < 10) {
                return 'Amount must be at least \$10';
              }
              return null;
            },
          ),
          theme: theme,
        ),

        SizedBox(height: 20.h),

        // Email (Optional)
        _buildAnimatedFormField(
          delay: 500,
          label: 'Email (Optional)',
          child: TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: 'Enter email for receipt',
              prefixIcon: const Icon(Icons.email),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
          theme: theme,
        ),

        SizedBox(height: 16.h),

        // Save for future checkbox with animation
        TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 1200),
          tween: Tween(begin: 0.0, end: 1.0),
          curve: Curves.easeOut,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(20 * (1 - value), 0),
                child: child,
              ),
            );
          },
          child: CheckboxListTile(
            value: _saveForFuture,
            onChanged: (bool? value) {
              setState(() {
                _saveForFuture = value ?? false;
              });
            },
            title: Text(
              'Save this bill for future payments',
              style: theme.textTheme.bodyMedium,
            ),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedFormField({
    required int delay,
    required String label,
    required Widget child,
    required ThemeData theme,
  }) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 800 + delay),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOut,
      builder: (context, value, widget) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(20 * (1 - value), 0),
            child: widget,
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.primaryColor != Colors.white
                  ? Colors.white
                  : const Color(0xff2D3748),
            ),
          ),
          SizedBox(height: 8.h),
          child,
        ],
      ),
    );
  }

  Widget _buildFeaturesSection(ThemeData theme) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1000),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: theme.brightness == Brightness.dark
              ? Colors.grey[850]
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: theme.primaryColor.withOpacity(0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 1200),
                  tween: Tween(begin: 0.0, end: 1.0),
                  curve: Curves.elasticOut,
                  builder: (context, value, child) {
                    return Transform.rotate(
                      angle: value * 6.28, // Full rotation
                      child: child,
                    );
                  },
                  child: Icon(
                    Icons.featured_play_list,
                    color: theme.primaryColor,
                    size: 20.sp,
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  'Plan Features',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor != Colors.white
                        ? Colors.white
                        : const Color(0xff2D3748),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            ...widget.features.asMap().entries.map((entry) {
              int index = entry.key;
              String feature = entry.value;
              return TweenAnimationBuilder<double>(
                duration: Duration(milliseconds: 800 + (index * 100)),
                tween: Tween(begin: 0.0, end: 1.0),
                curve: Curves.easeOut,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(30 * (1 - value), 0),
                      child: child,
                    ),
                  );
                },
                child: Padding(
                  padding: EdgeInsets.only(bottom: 8.h),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 16.sp,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          feature,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.primaryColor != Colors.white
                                ? Colors.white.withOpacity(0.9)
                                : const Color(0xff4A5568),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton(ThemeData theme) {
    return ScaleTransition(
      scale: _pulseAnimation,
      child: SizedBox(
        width: double.infinity,
        height: 56.h,
        child: ElevatedButton(
          onPressed: _proceedToCardSelection,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.primaryColor != Colors.white
                ? theme.primaryColor
                : MyTheme.primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            elevation: 4,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Continue to Card Selection',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
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
                  Icons.arrow_forward,
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