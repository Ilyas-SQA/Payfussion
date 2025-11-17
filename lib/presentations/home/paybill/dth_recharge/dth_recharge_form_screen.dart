import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:payfussion/core/theme/theme.dart';

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

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  String? _selectedPlan;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _subscriberIdController.dispose();
    _amountController.dispose();
    _customerNameController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Simulate API call
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          _isLoading = false;
        });

        // Show success dialog
        _showSuccessDialog();
      });
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          title: Column(
            children: <Widget>[
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 60.sp,
              ),
              SizedBox(height: 16.h),
              const Text('Recharge Successful!'),
            ],
          ),
          content: Text(
            'Your DTH recharge for ${widget.providerName} has been processed successfully.',
            textAlign: TextAlign.center,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          'DTH Recharge',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.primaryColor != Colors.white
                ? Colors.white
                : const Color(0xff2D3748),
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
                  // Provider Info Card
                  _buildProviderInfoCard(theme),

                  SizedBox(height: 24.h),

                  // Form Fields
                  _buildFormFields(theme),

                  SizedBox(height: 32.h),

                  // Submit Button
                  _buildSubmitButton(theme),
                ],
              ),
            ),
          ),
        ),
      ),
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
        borderRadius: BorderRadius.circular(16.r),
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
          Icon(
            Icons.tv,
            size: 40.sp,
            color: Colors.white,
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
                    Icon(
                      Icons.star,
                      size: 16.sp,
                      color: Colors.amber,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      widget.rating.toString(),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
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
        // Subscriber ID / Bill Number
        Text(
          'Subscriber ID / Bill Number',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.primaryColor != Colors.white
                ? Colors.white
                : const Color(0xff2D3748),
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
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
            filled: true,
            fillColor: theme.brightness == Brightness.dark
                ? Colors.grey[800]
                : Colors.grey[100],
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

        SizedBox(height: 20.h),

        // Customer Name
        Text(
          'Customer Name',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.primaryColor != Colors.white
                ? Colors.white
                : const Color(0xff2D3748),
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: _customerNameController,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            hintText: 'Enter customer name',
            prefixIcon: const Icon(Icons.person),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            filled: true,
            fillColor: theme.brightness == Brightness.dark
                ? Colors.grey[800]
                : Colors.grey[100],
          ),
          validator: (String? value) {
            if (value == null || value.isEmpty) {
              return 'Please enter customer name';
            }
            return null;
          },
        ),

        SizedBox(height: 20.h),

        // Select Plan
        Text(
          'Select Plan',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.primaryColor != Colors.white
                ? Colors.white
                : const Color(0xff2D3748),
          ),
        ),
        SizedBox(height: 8.h),
        DropdownButtonFormField<String>(
          value: _selectedPlan,
          decoration: InputDecoration(
            hintText: 'Choose a plan',
            prefixIcon: const Icon(Icons.list_alt),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            filled: true,
            fillColor: theme.brightness == Brightness.dark
                ? Colors.grey[800]
                : Colors.grey[100],
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

        SizedBox(height: 20.h),

        // Amount
        Text(
          'Amount',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.primaryColor != Colors.white
                ? Colors.white
                : const Color(0xff2D3748),
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
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
            filled: true,
            fillColor: theme.brightness == Brightness.dark
                ? Colors.grey[800]
                : Colors.grey[100],
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
      ],
    );
  }

  Widget _buildSubmitButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      height: 56.h,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitForm,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          elevation: 4,
        ),
        child: _isLoading
            ? const CircularProgressIndicator(
          color: Colors.white,
        )
            : Text(
          'Proceed to Recharge',
          style: theme.textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}