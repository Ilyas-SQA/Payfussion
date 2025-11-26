import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:payfussion/core/theme/theme.dart';
import 'package:payfussion/core/widget/card_screen.dart';

import '../../../../logic/blocs/pay_bill/credit_card_loan/credit_card_loan_bloc.dart';
import '../../../../logic/blocs/pay_bill/credit_card_loan/credit_card_loan_event.dart';

class CreditCardLoanFormScreen extends StatefulWidget {
  final String bankName;
  final String branchName;
  final String city;
  final String branchCode;

  const CreditCardLoanFormScreen({
    super.key,
    required this.bankName,
    required this.branchName,
    required this.city,
    required this.branchCode,
  });

  @override
  State<CreditCardLoanFormScreen> createState() => _CreditCardLoanFormScreenState();
}

class _CreditCardLoanFormScreenState extends State<CreditCardLoanFormScreen>
    with TickerProviderStateMixin {
  final TextEditingController _accountController = TextEditingController();
  final TextEditingController _cardController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late AnimationController _backgroundAnimationController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  String _selectedPaymentType = 'custom';
  bool _isProcessing = false;

  final List<Map<String, dynamic>> _paymentTypes = <Map<String, dynamic>>[
    <String, dynamic>{'value': 'minimum', 'label': 'Minimum Payment', 'icon': Icons.money_off},
    <String, dynamic>{'value': 'full', 'label': 'Full Payment', 'icon': Icons.payments},
    <String, dynamic>{'value': 'custom', 'label': 'Custom Amount', 'icon': Icons.edit},
  ];

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _backgroundAnimationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _accountController.dispose();
    _cardController.dispose();
    _amountController.dispose();
    _backgroundAnimationController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _selectPaymentType(String type) {
    setState(() {
      _selectedPaymentType = type;
    });
  }

  void _proceedToCardSelection() {
    if (_formKey.currentState!.validate()) {
      if (_accountController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter account number')),
        );
        return;
      }

      if (_cardController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter card number')),
        );
        return;
      }

      if (_amountController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter payment amount')),
        );
        return;
      }

      final double amount = double.parse(_amountController.text);

      // Set loan payment data in bloc
      context.read<CreditCardLoanBloc>().add(SetLoanPaymentData(
        bankName: widget.bankName,
        branchName: widget.branchName,
        accountNumber: _accountController.text,
        cardNumber: _cardController.text,
        amount: amount,
        paymentType: _selectedPaymentType,
      ));

      // Navigate to card selection
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => const CardsScreen(),
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
        backgroundColor: Colors.transparent,
        title: Text(
          widget.bankName,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.primaryColor != Colors.white ? Colors.white : const Color(0xff2D3748),
          ),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.all(24.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildBankInfoCard(theme),
                SizedBox(height: 32.h),
                _buildAccountNumberInput(theme),
                SizedBox(height: 24.h),
                _buildCardNumberInput(theme),
                SizedBox(height: 24.h),
                _buildPaymentTypeSelection(theme),
                SizedBox(height: 24.h),
                _buildAmountInput(theme),
                SizedBox(height: 32.h),
                _buildPaymentButton(theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBankInfoCard(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(20.w),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.account_balance, color: MyTheme.primaryColor, size: 24.sp),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  widget.bankName,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor != Colors.white ? Colors.white : const Color(0xff2D3748),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          if (widget.branchName.isNotEmpty)
            Row(
              children: <Widget>[
                Icon(Icons.store, size: 16.sp, color: Colors.grey[600]),
                SizedBox(width: 8.w),
                Text(
                  widget.branchName,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: theme.primaryColor != Colors.white ? Colors.white.withOpacity(0.7) : Colors.grey[600],
                  ),
                ),
              ],
            ),
          if (widget.city.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: 4.h),
              child: Row(
                children: <Widget>[
                  Icon(Icons.location_on, size: 16.sp, color: Colors.grey[600]),
                  SizedBox(width: 8.w),
                  Text(
                    '${widget.city} • ${widget.branchCode}',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: theme.primaryColor != Colors.white ? Colors.white.withOpacity(0.7) : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAccountNumberInput(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Account Number',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: theme.primaryColor != Colors.white ? Colors.white : const Color(0xff2D3748),
          ),
        ),
        SizedBox(height: 12.h),
        TextFormField(
          controller: _accountController,
          keyboardType: TextInputType.number,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly,
          ],
          decoration: InputDecoration(
            hintText: 'Enter account number',
            prefixIcon: const Icon(Icons.account_balance_wallet, color: MyTheme.primaryColor),
          ),
          validator: (String? value) {
            if (value == null || value.isEmpty) {
              return 'Please enter account number';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildCardNumberInput(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Credit Card Number (Last 4 Digits)',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: theme.primaryColor != Colors.white ? Colors.white : const Color(0xff2D3748),
          ),
        ),
        SizedBox(height: 12.h),
        TextFormField(
          controller: _cardController,
          keyboardType: TextInputType.number,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(4),
          ],
          decoration: InputDecoration(
            hintText: 'Enter last 4 digits',
            prefixIcon: const Icon(Icons.credit_card, color: MyTheme.primaryColor),
          ),
          validator: (String? value) {
            if (value == null || value.isEmpty) {
              return 'Please enter last 4 digits';
            }
            if (value.length != 4) {
              return 'Please enter exactly 4 digits';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPaymentTypeSelection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Payment Type',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: theme.primaryColor != Colors.white ? Colors.white : const Color(0xff2D3748),
          ),
        ),
        SizedBox(height: 12.h),
        Wrap(
          spacing: 12.w,
          runSpacing: 12.h,
          children: _paymentTypes.map((Map<String, dynamic> type) {
            final bool isSelected = _selectedPaymentType == type['value'];
            return InkWell(
              onTap: () => _selectPaymentType(type['value']),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: isSelected ? MyTheme.primaryColor : theme.scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: isSelected ? MyTheme.primaryColor : Colors.grey.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      type['icon'],
                      color: isSelected ? Colors.white : (theme.primaryColor != Colors.white ? Colors.white : const Color(0xff2D3748)),
                      size: 20.sp,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      type['label'],
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : (theme.primaryColor != Colors.white ? Colors.white : const Color(0xff2D3748)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAmountInput(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Payment Amount',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: theme.primaryColor != Colors.white ? Colors.white : const Color(0xff2D3748),
          ),
        ),
        SizedBox(height: 12.h),
        TextFormField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly,
          ],
          decoration: InputDecoration(
            hintText: 'Enter payment amount',
            prefixIcon: const Icon(Icons.attach_money, color: MyTheme.primaryColor),
          ),
          validator: (String? value) {
            if (value == null || value.isEmpty) {
              return 'Please enter payment amount';
            }
            final int? amount = int.tryParse(value);
            if (amount == null || amount < 10) {
              return 'Minimum payment amount is \$10';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPaymentButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _proceedToCardSelection,
        style: ElevatedButton.styleFrom(
          backgroundColor: MyTheme.primaryColor,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          elevation: 4,
        ),
        child: _isProcessing
            ? SizedBox(
          height: 20.h,
          width: 20.w,
          child: const CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2,
          ),
        )
            : Text(
          'Continue to Card Selection',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}