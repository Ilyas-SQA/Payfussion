import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:payfussion/core/theme/theme.dart';
import 'package:payfussion/core/widget/card_screen.dart';
import '../../../../logic/blocs/pay_bill/dth_bill/dth_bill_bloc.dart';
import '../../../../logic/blocs/pay_bill/dth_bill/dth_bill_event.dart';

class DthRechargeFormScreen extends StatefulWidget {
  final String providerName;
  final List<String> plans;
  final double rating;

  const DthRechargeFormScreen({
    super.key,
    required this.providerName,
    required this.plans,
    required this.rating,
  });

  @override
  State<DthRechargeFormScreen> createState() => _DthRechargeFormScreenState();
}

class _DthRechargeFormScreenState extends State<DthRechargeFormScreen>
    with TickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _subscriberIdController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _customerNameController = TextEditingController();

  // Enhanced animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late AnimationController _pulseController;
  late AnimationController _starRotationController;
  late AnimationController _fieldFocusController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _starRotationAnimation;
  late Animation<double> _fieldFocusAnimation;

  String? _selectedPlan;

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
      duration: const Duration(milliseconds: 600),
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

    // Star rotation animation
    _starRotationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();
    _starRotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _starRotationController, curve: Curves.linear),
    );

    // Field focus animation
    _fieldFocusController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fieldFocusAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _fieldFocusController, curve: Curves.easeInOut),
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
    _starRotationController.dispose();
    _fieldFocusController.dispose();
    _subscriberIdController.dispose();
    _amountController.dispose();
    _customerNameController.dispose();
    super.dispose();
  }

  void _proceedToCardSelection() {
    if (_formKey.currentState!.validate()) {
      if (_subscriberIdController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter subscriber ID')),
        );
        return;
      }

      if (_customerNameController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter customer name')),
        );
        return;
      }

      if (_selectedPlan == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a plan')),
        );
        return;
      }

      if (_amountController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter amount')),
        );
        return;
      }

      final double amount = double.parse(_amountController.text);

      // Set DTH recharge data in bloc
      context.read<DthRechargeBloc>().add(SetDthRechargeData(
        providerName: widget.providerName,
        subscriberId: _subscriberIdController.text,
        customerName: _customerNameController.text,
        selectedPlan: _selectedPlan!,
        amount: amount,
        rating: widget.rating,
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
        title: FadeTransition(
          opacity: _fadeAnimation,
          child: const Text('DTH Recharge'),
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
                  // Provider Info Card with animations
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
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[
            MyTheme.primaryColor.withOpacity(0.8),
            MyTheme.primaryColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(5.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: MyTheme.primaryColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
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
              // Provider ka icon yahan se milega
              widget.providerName == "DISH Network"
                  ? "assets/images/paybill/dth_recharge/dish_network.png"
                  : widget.providerName == "DIRECTV (AT&T)"
                  ? "assets/images/paybill/dth_recharge/directv.png"
                  : widget.providerName == "Sky Angel"
                  ? "assets/images/paybill/dth_recharge/sky_angell.jpeg"
                  : widget.providerName == "Viasat Satellite TV"
                  ? "assets/images/paybill/dth_recharge/viaset.png"
                  : widget.providerName == "Bell TV"
                  ? "assets/images/paybill/dth_recharge/bell.jpeg"
                  : widget.providerName == "HughesNet TV Bundles"
                  ? "assets/images/paybill/dth_recharge/hughestnet.png"
                  : "assets/images/paybill/dth_recharge/dish_network.png",
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.tv,
                  size: 24.sp,
                  color: MyTheme.primaryColor,
                );
              },
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  widget.providerName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: <Widget>[
                    // Rotating star animation
                    Icon(
                      Icons.star,
                      size: 16.sp,
                      color: Colors.amber,
                    ),
                    SizedBox(width: 4.w),
                    TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 1000),
                      tween: Tween(begin: 0.0, end: widget.rating),
                      curve: Curves.easeOut,
                      builder: (context, value, child) {
                        return Text(
                          value.toStringAsFixed(1),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormFields(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Subscriber ID with animation
        _buildAnimatedFormField(
          delay: 0,
          label: 'Subscriber ID / Bill Number',
          child: TextFormField(
            controller: _subscriberIdController,
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(15),
            ],
            decoration: InputDecoration(
              hintText: 'Enter your subscriber ID',
              prefixIcon: const Icon(Icons.credit_card),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return 'Please enter subscriber ID';
              }
              if (value.length < 8) {
                return 'Subscriber ID must be at least 8 digits';
              }
              return null;
            },
          ),
          theme: theme,
        ),

        SizedBox(height: 20.h),

        // Customer Name with animation
        _buildAnimatedFormField(
          delay: 100,
          label: 'Customer Name',
          child: TextFormField(
            controller: _customerNameController,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              hintText: 'Enter customer name',
              prefixIcon: const Icon(Icons.person),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return 'Please enter customer name';
              }
              return null;
            },
          ),
          theme: theme,
        ),

        SizedBox(height: 20.h),

        // Select Plan with animation
        _buildAnimatedFormField(
          delay: 200,
          label: 'Select Plan',
          child: DropdownButtonFormField<String>(
            value: _selectedPlan,
            decoration: InputDecoration(
              hintText: 'Choose a plan',
              prefixIcon: const Icon(Icons.list_alt),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            items: widget.plans.map((String plan) {
              return DropdownMenuItem<String>(
                value: plan,
                child: Text(plan),
              );
            }).toList(),
            onChanged: (String? value) {
              setState(() {
                _selectedPlan = value;
                // Extract amount from plan string
                final RegExp regex = RegExp(r'\$(\d+)');
                final Match? match = regex.firstMatch(value ?? '');
                if (match != null) {
                  _amountController.text = match.group(1) ?? '';
                }
              });
            },
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return 'Please select a plan';
              }
              return null;
            },
          ),
          theme: theme,
        ),

        SizedBox(height: 20.h),

        // Amount with animation
        _buildAnimatedFormField(
          delay: 300,
          label: 'Amount',
          child: TextFormField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly,
            ],
            decoration: InputDecoration(
              hintText: 'Enter amount',
              prefixIcon: const Icon(Icons.attach_money),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return 'Please enter amount';
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

  Widget _buildSubmitButton(ThemeData theme) {
    return ScaleTransition(
      scale: _pulseAnimation,
      child: SizedBox(
        width: double.infinity,
        height: 56.h,
        child: ElevatedButton(
          onPressed: _proceedToCardSelection,
          style: ElevatedButton.styleFrom(
            backgroundColor: MyTheme.primaryColor,
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