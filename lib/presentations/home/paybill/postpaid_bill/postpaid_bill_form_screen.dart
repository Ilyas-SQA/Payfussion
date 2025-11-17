import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:payfussion/core/theme/theme.dart';

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

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  String _selectedBillCycle = 'Current Month';
  bool _isLoading = false;
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
    _mobileNumberController.dispose();
    _billNumberController.dispose();
    _accountHolderController.dispose();
    _amountController.dispose();
    _emailController.dispose();
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
              const Text('Payment Successful!'),
            ],
          ),
          content: Text(
            'Your ${widget.providerName} postpaid bill has been paid successfully.',
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
          'Pay Postpaid Bill',
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

                  SizedBox(height: 24.h),

                  // Features Section
                  _buildFeaturesSection(theme),

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
    // Use proper color based on theme
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
        borderRadius: BorderRadius.circular(16.r),
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
              Icon(
                Icons.phone_android,
                size: 32.sp,
                color: textColor,
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
              Container(
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
        Text(
          'Mobile Number',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.primaryColor != Colors.white
                ? Colors.white
                : const Color(0xff2D3748),
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
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
            filled: true,
            fillColor: theme.brightness == Brightness.dark
                ? Colors.grey[800]
                : Colors.grey[100],
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

        SizedBox(height: 20.h),

        // Bill/Account Number
        Text(
          'Bill/Account Number',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.primaryColor != Colors.white
                ? Colors.white
                : const Color(0xff2D3748),
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: _billNumberController,
          keyboardType: TextInputType.text,
          textCapitalization: TextCapitalization.characters,
          decoration: InputDecoration(
            hintText: 'Enter bill/account number',
            prefixIcon: const Icon(Icons.receipt_long),
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
              return 'Please enter bill/account number';
            }
            if (value.length < 6) {
              return 'Account number must be at least 6 characters';
            }
            return null;
          },
        ),

        SizedBox(height: 20.h),

        // Account Holder Name
        Text(
          'Account Holder Name',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.primaryColor != Colors.white
                ? Colors.white
                : const Color(0xff2D3748),
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: _accountHolderController,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            hintText: 'Enter account holder name',
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
              return 'Please enter account holder name';
            }
            return null;
          },
        ),

        SizedBox(height: 20.h),

        // Bill Cycle
        Text(
          'Bill Cycle',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.primaryColor != Colors.white
                ? Colors.white
                : const Color(0xff2D3748),
          ),
        ),
        SizedBox(height: 8.h),
        DropdownButtonFormField<String>(
          value: _selectedBillCycle,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.calendar_today),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            filled: true,
            fillColor: theme.brightness == Brightness.dark
                ? Colors.grey[800]
                : Colors.grey[100],
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

        SizedBox(height: 20.h),

        // Amount
        Text(
          'Bill Amount',
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
            hintText: 'Enter bill amount',
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
              return 'Please enter bill amount';
            }
            final int? amount = int.tryParse(value);
            if (amount == null || amount < 10) {
              return 'Amount must be at least \$10';
            }
            return null;
          },
        ),

        SizedBox(height: 20.h),

        // Email (Optional)
        Text(
          'Email (Optional)',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.primaryColor != Colors.white
                ? Colors.white
                : const Color(0xff2D3748),
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: 'Enter email for receipt',
            prefixIcon: const Icon(Icons.email),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            filled: true,
            fillColor: theme.brightness == Brightness.dark
                ? Colors.grey[800]
                : Colors.grey[100],
          ),
        ),

        SizedBox(height: 16.h),

        // Save for future checkbox
        CheckboxListTile(
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
      ],
    );
  }

  Widget _buildFeaturesSection(ThemeData theme) {
    return Container(
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
              Icon(
                Icons.featured_play_list,
                color: theme.primaryColor,
                size: 20.sp,
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
          ...widget.features.map((String feature) {
            return Padding(
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
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      height: 56.h,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.primaryColor != Colors.white
              ? theme.primaryColor
              : MyTheme.primaryColor,
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
          'Pay Bill Now',
          style: theme.textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}