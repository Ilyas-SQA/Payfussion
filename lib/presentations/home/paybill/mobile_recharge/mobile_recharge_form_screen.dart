import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:payfussion/core/theme/theme.dart';
import 'package:payfussion/core/widget/card_screen.dart';

import '../../../../logic/blocs/pay_bill/mobile_recharge/mobile_recharge_bloc.dart';
import '../../../../logic/blocs/pay_bill/mobile_recharge/mobile_recharge_event.dart';


class MobileRechargeFormScreen extends StatefulWidget {
  final String companyName;
  final String network;
  final String customers;
  final String coverage;

  const MobileRechargeFormScreen({
    super.key,
    required this.companyName,
    required this.network,
    required this.customers,
    required this.coverage,
  });

  @override
  State<MobileRechargeFormScreen> createState() => _MobileRechargeFormScreenState();
}

class _MobileRechargeFormScreenState extends State<MobileRechargeFormScreen>
    with TickerProviderStateMixin {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  // ✅ FIXED: Separate form keys for each tab
  final GlobalKey<FormState> _packagesFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _rechargeFormKey = GlobalKey<FormState>();

  late AnimationController _backgroundAnimationController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  String? _selectedAmount;
  Map<String, dynamic>? _selectedPackage;
  bool _isProcessing = false;

  final List<String> _quickAmounts = <String>[
    '\$10',
    '\$20',
    '\$30',
    '\$50',
    '\$75',
    '\$100',
  ];

  Map<String, List<Map<String, dynamic>>> _getPackagesForCompany() {
    switch (widget.companyName.toLowerCase()) {
      case 'verizon wireless':
        return <String, List<Map<String, dynamic>>>{
          'packages': <Map<String, dynamic>>[
            <String, dynamic>{'name': 'Unlimited Welcome', 'price': '\$65', 'data': 'Unlimited', 'validity': '30 days'},
            <String, dynamic>{'name': 'Unlimited Plus', 'price': '\$80', 'data': 'Unlimited Premium', 'validity': '30 days'},
            <String, dynamic>{'name': '5GB Plan', 'price': '\$35', 'data': '5GB', 'validity': '30 days'},
            <String, dynamic>{'name': '15GB Plan', 'price': '\$50', 'data': '15GB', 'validity': '30 days'},
          ]
        };
      case 'at&t mobility':
        return <String, List<Map<String, dynamic>>>{
          'packages': <Map<String, dynamic>>[
            <String, dynamic>{'name': 'Unlimited Starter', 'price': '\$65', 'data': 'Unlimited', 'validity': '30 days'},
            <String, dynamic>{'name': 'Unlimited Extra', 'price': '\$75', 'data': 'Unlimited + 50GB Hotspot', 'validity': '30 days'},
            <String, dynamic>{'name': '4GB Plan', 'price': '\$40', 'data': '4GB', 'validity': '30 days'},
            <String, dynamic>{'name': '10GB Plan', 'price': '\$55', 'data': '10GB', 'validity': '30 days'},
          ]
        };
      default:
        return <String, List<Map<String, dynamic>>>{
          'packages': <Map<String, dynamic>>[
            <String, dynamic>{'name': 'Basic Plan', 'price': '\$30', 'data': '5GB', 'validity': '30 days'},
            <String, dynamic>{'name': 'Standard Plan', 'price': '\$50', 'data': '15GB', 'validity': '30 days'},
            <String, dynamic>{'name': 'Unlimited Plan', 'price': '\$60', 'data': 'Unlimited', 'validity': '30 days'},
          ]
        };
    }
  }

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
    _phoneController.dispose();
    _amountController.dispose();
    _backgroundAnimationController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _selectQuickAmount(String amount) {
    setState(() {
      _selectedAmount = amount;
      _selectedPackage = null;
      _amountController.text = amount.replaceAll('\$', '');
    });
  }

  void _selectPackage(Map<String, dynamic> package) {
    setState(() {
      _selectedPackage = package;
      _selectedAmount = null;
      _amountController.text = package['price'].replaceAll('\$', '').split(' ').first;
    });
  }

  // ✅ FIXED: Accept form key as parameter
  void _proceedToCardSelection(GlobalKey<FormState> formKey) {
    if (formKey.currentState!.validate()) {
      if (_phoneController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter phone number')),
        );
        return;
      }

      if (_amountController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter amount or select package')),
        );
        return;
      }

      final double amount = double.parse(_amountController.text);

      /// Set recharge data in bloc
      context.read<MobileRechargeBloc>().add(SetRechargeData(
        companyName: widget.companyName,
        network: widget.network,
        phoneNumber: _phoneController.text,
        amount: amount,
        packageName: _selectedPackage?['name'],
        packageData: _selectedPackage?['data'],
        packageValidity: _selectedPackage?['validity'],
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

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(
            widget.companyName,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.primaryColor != Colors.white ? Colors.white : const Color(0xff2D3748),
            ),
          ),
          bottom: TabBar(
            labelColor: MyTheme.primaryColor,
            unselectedLabelColor: theme.primaryColor != Colors.white ? Colors.white.withOpacity(0.6) : Colors.grey,
            indicatorColor: MyTheme.primaryColor,
            indicatorWeight: 3,
            labelStyle: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
            unselectedLabelStyle: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.normal,
            ),
            tabs: const <Widget>[
              Tab(text: 'Packages'),
              Tab(text: 'Recharge'),
            ],
          ),
        ),
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: TabBarView(
            children: <Widget>[
              _buildPackagesTab(theme),
              _buildRechargeTab(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPackagesTab(ThemeData theme) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.all(24.w),
      child: Form(
        key: _packagesFormKey, // ✅ Using separate key
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildCarrierInfoCard(theme),
            SizedBox(height: 32.h),
            _buildPhoneNumberInput(theme),
            SizedBox(height: 24.h),
            _buildPackagesSection(theme),
            SizedBox(height: 32.h),
            _buildRechargeButton(theme, _packagesFormKey), // ✅ Passing form key
          ],
        ),
      ),
    );
  }

  Widget _buildRechargeTab(ThemeData theme) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.all(24.w),
      child: Form(
        key: _rechargeFormKey, // ✅ Using separate key
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildCarrierInfoCard(theme),
            SizedBox(height: 32.h),
            _buildPhoneNumberInput(theme),
            SizedBox(height: 24.h),
            _buildQuickAmountSelection(theme),
            SizedBox(height: 24.h),
            _buildAmountInput(theme),
            SizedBox(height: 32.h),
            _buildRechargeButton(theme, _rechargeFormKey), // ✅ Passing form key
          ],
        ),
      ),
    );
  }

  Widget _buildCarrierInfoCard(ThemeData theme) {
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
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: MyTheme.primaryColor,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  widget.network,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Icon(
                    Icons.people,
                    size: 16.sp,
                    color: theme.primaryColor != Colors.white ? Colors.white.withOpacity(0.7) : Colors.grey[600],
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    '${widget.customers} customers',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: theme.primaryColor != Colors.white ? Colors.white.withOpacity(0.7) : Colors.grey[600],
                    ),
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Icon(
                    Icons.signal_cellular_alt,
                    size: 16.sp,
                    color: theme.primaryColor != Colors.white ? Colors.white.withOpacity(0.7) : Colors.grey[600],
                  ),
                  Text(
                    widget.coverage,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: theme.primaryColor != Colors.white ? Colors.white.withOpacity(0.7) : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneNumberInput(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Phone Number',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: theme.primaryColor != Colors.white ? Colors.white : const Color(0xff2D3748),
          ),
        ),
        SizedBox(height: 12.h),
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
          decoration: const InputDecoration(
            hintText: 'Enter 10-digit mobile number',
            prefixIcon: Icon(Icons.phone_android, color: MyTheme.primaryColor),
          ),
          validator: (String? value) {
            if (value == null || value.isEmpty) {
              return 'Please enter phone number';
            }
            if (value.length != 10) {
              return 'Phone number must be 10 digits';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPackagesSection(ThemeData theme) {
    final List<Map<String, dynamic>> packages = _getPackagesForCompany()['packages']!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Available Packages',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: theme.primaryColor != Colors.white ? Colors.white : const Color(0xff2D3748),
          ),
        ),
        SizedBox(height: 12.h),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: packages.length,
          itemBuilder: (BuildContext context, int index) {
            final Map<String, dynamic> package = packages[index];
            final bool isSelected = _selectedPackage?['name'] == package['name'];

            return Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: InkWell(
                onTap: () => _selectPackage(package),
                borderRadius: BorderRadius.circular(12.r),
                child: Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: isSelected ? MyTheme.primaryColor : Colors.grey.withOpacity(0.3),
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected ? <BoxShadow>[
                      BoxShadow(
                        color: MyTheme.primaryColor.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ] : null,
                  ),
                  child: Row(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: MyTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Icon(
                          Icons.card_giftcard,
                          color: MyTheme.primaryColor,
                          size: 24.sp,
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              package['name'],
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: theme.primaryColor != Colors.white ? Colors.white : const Color(0xff2D3748),
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Row(
                              children: <Widget>[
                                Icon(Icons.data_usage, size: 14.sp, color: Colors.grey[600]),
                                SizedBox(width: 4.w),
                                Flexible(
                                  child: Text(
                                    package['data'],
                                    style: TextStyle(fontSize: 13.sp, color: Colors.grey[600]),
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Icon(Icons.calendar_today, size: 14.sp, color: Colors.grey[600]),
                                SizedBox(width: 4.w),
                                Text(
                                  package['validity'],
                                  style: TextStyle(fontSize: 13.sp, color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Text(
                        package['price'],
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: MyTheme.primaryColor,
                        ),
                      ),
                      if (isSelected) ...<Widget>[
                        SizedBox(width: 8.w),
                        Icon(Icons.check_circle, color: MyTheme.primaryColor, size: 24.sp),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildQuickAmountSelection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Quick Select Amount',
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
          children: _quickAmounts.map((String amount) {
            final bool isSelected = _selectedAmount == amount;
            return InkWell(
              onTap: () => _selectQuickAmount(amount),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: isSelected ? MyTheme.primaryColor : theme.scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: isSelected ? MyTheme.primaryColor : Colors.grey.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Text(
                  amount,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? Colors.white
                        : (theme.primaryColor != Colors.white ? Colors.white : const Color(0xff2D3748)),
                  ),
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
          'Or Enter Custom Amount',
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
            hintText: 'Enter amount',
            prefixIcon: const Icon(Icons.attach_money, color: MyTheme.primaryColor),
            filled: true,
            fillColor: theme.scaffoldBackgroundColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: MyTheme.primaryColor, width: 2),
            ),
          ),
          validator: (String? value) {
            if (value == null || value.isEmpty) {
              return 'Please enter recharge amount';
            }
            final int? amount = int.tryParse(value);
            if (amount == null || amount < 10) {
              return 'Minimum recharge amount is \$10';
            }
            if (amount > 500) {
              return 'Maximum recharge amount is \$500';
            }
            return null;
          },
        ),
      ],
    );
  }

  // ✅ FIXED: Accept form key as parameter
  Widget _buildRechargeButton(ThemeData theme, GlobalKey<FormState> formKey) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _proceedToCardSelection(formKey),
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