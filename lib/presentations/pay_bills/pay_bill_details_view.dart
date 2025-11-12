import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nested/nested.dart';
import 'package:payfussion/core/constants/image_url.dart';
import 'package:payfussion/core/constants/routes_name.dart';
import 'package:payfussion/presentations/widgets/custom_button.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/theme.dart';
import '../../data/models/card/card_model.dart';
import '../../data/models/pay_bills/bill_item.dart';
import '../../logic/blocs/add_card/card_bloc.dart';
import '../../logic/blocs/add_card/card_event.dart';
import '../../logic/blocs/add_card/card_state.dart';
import '../../logic/blocs/pay_bill/pay_bill_bloc.dart';
import '../../logic/blocs/pay_bill/pay_bill_event.dart';
import '../../logic/blocs/pay_bill/pay_bill_state.dart';
import '../../services/payment_service.dart';

class PayBillDetailsView extends StatefulWidget {
  final String? billType;
  final String? companyName;

  const PayBillDetailsView({super.key, this.billType, this.companyName});

  @override
  _PayBillDetailsViewState createState() => _PayBillDetailsViewState();
}

class _PayBillDetailsViewState extends State<PayBillDetailsView> with TickerProviderStateMixin {
  bool _isFingerprintVisible = false;
  CardModel? _selectedCard;
  String _currentBillId = '';

  final TextEditingController _accountNumberController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Animation Controllers
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _fingerprintController;
  late AnimationController _pulseController;

  // Animations
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fingerprintFadeAnimation;
  late Animation<double> _pulseAnimation;

  // Company information - properly stored and used throughout
  late String _companyName;
  late String _billType;

  @override
  void initState() {
    super.initState();
    // Store company information from widget parameters
    _companyName = widget.companyName ?? 'XYZ Company';
    _billType = widget.billType ?? 'electricity';

    // Debug print to verify company name
    print('🏢 Initializing PayBillDetailsView for company: $_companyName');
    print('📋 Bill type: $_billType');

    _initAnimations();
    context.read<CardBloc>().add(LoadCards());
  }

  void _initAnimations() {
    _slideController = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    _fadeController = AnimationController(duration: const Duration(milliseconds: 600), vsync: this);
    _scaleController = AnimationController(duration: const Duration(milliseconds: 400), vsync: this);
    _fingerprintController = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
    _pulseController = AnimationController(duration: const Duration(milliseconds: 1500), vsync: this);

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
        CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut));
    _fingerprintFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _fingerprintController, curve: Curves.easeInOut));
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
        CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));

    _startInitialAnimations();
  }

  void _startInitialAnimations() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _slideController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _fadeController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _scaleController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    _fingerprintController.dispose();
    _pulseController.dispose();
    _accountNumberController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  // Dynamic input configuration based on bill type
  Map<String, dynamic> _getInputConfig(String billType) {
    switch (billType.toLowerCase()) {
      case "mobile":
        return <String, dynamic>{
          'label': 'Mobile Number',
          'hint': 'Enter mobile number',
          'keyboardType': TextInputType.phone,
          'icon': Icons.phone_android,
          'validator': (String? value) {
            if (value == null || value.isEmpty) return 'Please enter mobile number';
            if (value.length != 11 || !value.startsWith('0')) return 'Please enter valid 11-digit mobile number';
            return null;
          }
        };
      case "electricity":
        return <String, dynamic>{
          'label': 'Consumer Number',
          'hint': 'Enter consumer number',
          'keyboardType': TextInputType.text,
          'icon': Icons.electrical_services,
          'validator': (String? value) {
            if (value == null || value.isEmpty) return 'Please enter consumer number';
            if (value.length < 8) return 'Consumer number must be at least 8 characters';
            return null;
          }
        };
      case "gas":
        return <String, dynamic>{
          'label': 'Consumer Number',
          'hint': 'Enter gas consumer number',
          'keyboardType': TextInputType.text,
          'icon': Icons.local_gas_station,
          'validator': (String? value) {
            if (value == null || value.isEmpty) return 'Please enter consumer number';
            if (value.length < 6) return 'Consumer number must be at least 6 characters';
            return null;
          }
        };
      case "movies":
        return <String, dynamic>{
          'label': 'Email Address',
          'hint': 'Enter email address',
          'keyboardType': TextInputType.emailAddress,
          'icon': Icons.email,
          'validator': (String? value) {
            if (value == null || value.isEmpty) return 'Please enter email address';
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) return 'Please enter valid email address';
            return null;
          }
        };
      case "dth":
        return <String, dynamic>{
          'label': 'Customer ID',
          'hint': 'Enter DTH customer ID',
          'keyboardType': TextInputType.number,
          'icon': Icons.satellite_alt,
          'validator': (String? value) {
            if (value == null || value.isEmpty) return 'Please enter DTH customer ID';
            if (value.length < 6) return 'Customer ID must be at least 6 digits';
            return null;
          }
        };
      case "postpaid":
        return <String, dynamic>{
          'label': 'Mobile Number',
          'hint': 'Enter postpaid mobile number',
          'keyboardType': TextInputType.phone,
          'icon': Icons.sim_card,
          'validator': (String? value) {
            if (value == null || value.isEmpty) return 'Please enter mobile number';
            if (value.length != 11 || !value.startsWith('0')) return 'Please enter valid 11-digit mobile number';
            return null;
          }
        };
      default:
        return <String, dynamic>{
          'label': 'Account Number',
          'hint': 'Enter account number',
          'keyboardType': TextInputType.text,
          'icon': Icons.account_circle,
          'validator': (String? value) {
            if (value == null || value.isEmpty) return 'Please enter account number';
            if (value.length < 4) return 'Account number must be at least 4 characters';
            return null;
          }
        };
    }
  }

  bool _validateInputs() {
    if (!_formKey.currentState!.validate()) return false;
    if (_selectedCard == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a card first'), backgroundColor: Colors.red));
      return false;
    }
    return true;
  }

  void _triggerFingerprintAnimation() {
    if (_validateInputs()) {
      setState(() {
        _isFingerprintVisible = !_isFingerprintVisible;
      });
      if (_isFingerprintVisible) {
        _fingerprintController.forward();
        _pulseController.repeat(reverse: true);
      } else {
        _fingerprintController.reverse();
        _pulseController.stop();
        _pulseController.reset();
      }
    }
  }

  // Enhanced payment processing with complete company information
  void _processPayment() {
    if (_validateInputs()) {
      final double amount = double.tryParse(_amountController.text) ?? 0.0;

      // Generate unique bill ID
      final String billId = const Uuid().v4();

      print('Processing payment for $_companyName');
      print('Amount: \$${amount.toStringAsFixed(2)}');
      print('Bill ID: $billId');

      // Create PayBillModel with complete company information
      final PayBillModel payBill = PayBillModel(
        id: billId,
        companyName: _companyName, // Company name explicitly set from widget parameter
        companyIcon: _getCompanyIcon(),
        billNumber: _accountNumberController.text,
        amount: amount,
        cardId: _selectedCard!.id,
        cardEnding: _selectedCard!.cardEnding,
        createdAt: DateTime.now(),
        paidAt: DateTime.now(),
        paymentMethod: 'fingerprint',
        status: 'completed',
        hasFee: amount > 1000,
        feeAmount: amount > 1000 ? (amount * 0.01).clamp(5.0, 50.0) : 0.0,
        billType: _billType,
        currency: 'USD', // Default currency
      );

      // Store current bill ID for processing
      _currentBillId = payBill.id;

      // Add bill to repository first
      context.read<PayBillBloc>().add(AddPayBill(payBill));

      print('PayBillModel created with company: ${payBill.companyName}');
    }
  }

  String _getCompanyIcon() {
    switch (_billType.toLowerCase()) {
      case 'electricity': return TImageUrl.iconElectricity;
      case 'mobile': return TImageUrl.iconIphone;
      case 'gas': return TImageUrl.iconGas;
      case 'internet': return TImageUrl.iconInternet;
      case 'movies': return TImageUrl.iconNetlix;
      default: return TImageUrl.iconPayBil;
    }
  }

  Color _getBrandColor() {
    switch (_billType.toLowerCase()) {
      case 'electricity': return MyTheme.primaryColor;
      case 'mobile': return MyTheme.primaryColor;
      case 'gas': return MyTheme.primaryColor;
      case 'internet': return MyTheme.primaryColor;
      case 'movies': return MyTheme.primaryColor;
      case 'dth': return MyTheme.primaryColor;
      case 'postpaid': return MyTheme.primaryColor;
      default: return MyTheme.primaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? MyTheme.darkBackgroundColor : MyTheme.backgroundColor,
      body: MultiBlocListener(
        listeners: <SingleChildWidget>[
          BlocListener<PayBillBloc, PayBillState>(
              listener: (BuildContext context, PayBillState state) {
                if (state is PayBillSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.message), backgroundColor: Colors.green));

                  // Process payment with complete information after bill is added
                  if (_currentBillId.isNotEmpty) {
                    print('Processing payment for bill ID: $_currentBillId');
                    context.read<PayBillBloc>().add(ProcessPayment(
                        _currentBillId,
                        'fingerprint',
                        _selectedCard!.id
                    ));
                  }
                } else if (state is PayBillPaymentSuccess) {
                  print('Payment successful for company: ${state.payBill.companyName}');
                  context.push(RouteNames.receiptView, extra: state.payBill);
                } else if (state is PayBillPaymentFailed) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Payment failed: ${state.error}'), backgroundColor: Colors.red));
                  setState(() {
                    _isFingerprintVisible = false;
                    _fingerprintController.reverse();
                    _pulseController.stop();
                    _pulseController.reset();
                  });
                } else if (state is PayBillError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: ${state.error}'), backgroundColor: Colors.red));
                  setState(() {
                    _isFingerprintVisible = false;
                    _fingerprintController.reverse();
                    _pulseController.stop();
                    _pulseController.reset();
                  });
                }
              }
          ),
        ],
        child: CustomScrollView(
          slivers: <Widget>[
            // Enhanced App Bar with company branding
            SliverAppBar(
              expandedHeight: 200.h,
              pinned: true,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  _companyName, // Display actual company name
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                  ),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: <Color>[
                        _getBrandColor(),
                        _getBrandColor().withOpacity(0.8),
                      ],
                    ),
                  ),
                  child: Center(
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: Container(
                          padding: EdgeInsets.all(20.w),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Image.asset(
                            _getCompanyIcon(),
                            height: 60.h,
                            width: 60.w,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Content
            SliverToBoxAdapter(
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? MyTheme.darkBackgroundColor : Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
                ),
                child: Padding(
                  padding: EdgeInsets.all(24.w),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        // Header Info Card with company details
                        _buildInfoCard(isDark),

                        32.verticalSpace,

                        // Account Input Section
                        _buildSectionHeader('Account Details', Icons.account_balance, isDark, false),
                        16.verticalSpace,
                        _buildAccountInput(isDark),

                        24.verticalSpace,

                        // Amount Section
                        _buildSectionHeader('Amount', Icons.payments, isDark, false),
                        16.verticalSpace,
                        _buildAmountInput(isDark),

                        32.verticalSpace,

                        // Payment Method Section
                        _buildSectionHeader(
                            'Payment Method',
                            Icons.credit_card,
                            isDark,
                            true
                        ),
                        16.verticalSpace,
                        _buildCardsSection(),

                        32.verticalSpace,

                        // Fingerprint Section
                        if (_isFingerprintVisible) _buildFingerPrint(isDark: isDark),

                        100.verticalSpace, // Space for bottom button
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(isDark: isDark),
    );
  }

  Widget _buildInfoCard(bool isDark) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
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

        child: Row(
          children: <Widget>[
            Icon(
              Icons.info_outline,
              color: _getBrandColor(),
              size: 24.sp,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Bill Payment for $_companyName', // Show actual company name
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Secure ${_billType} payment processing',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, bool isDark, bool isCard) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Row(
          children: <Widget>[
            Icon(
              icon,
              color: _getBrandColor(),
              size: 20.sp,
            ),
            SizedBox(width: 8.w),
            Text(
              title,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
        isCard ? TextButton.icon(
          label: Text("Add New Card", style: TextStyle(color: MyTheme.primaryColor, fontSize: 12.sp)),
          icon: const Icon(Icons.add, color: MyTheme.primaryColor),
          onPressed: () {
            PaymentService().saveCard(context);
          },
        ) : const SizedBox()
      ],
    );
  }

  Widget _buildAccountInput(bool isDark) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(-0.3, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _slideController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
      )),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Builder(
          builder: (BuildContext context) {
            final Map<String, dynamic> config = _getInputConfig(_billType);
            return _buildInputField(
              controller: _accountNumberController,
              label: config['label'],
              hint: config['hint'],
              icon: config['icon'],
              isDark: isDark,
              keyboardType: config['keyboardType'],
              validator: config['validator'],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAmountInput(bool isDark) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.3, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _slideController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      )),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          padding: EdgeInsets.all(24.w),
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
            children: <Widget>[
              Text(
                'Enter Amount for $_companyName',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8.h),
              TextFormField(
                controller: _amountController,
                validator: (String? value) {
                  if (value == null || value.isEmpty) return 'Please enter Amount';
                  final double? amount = double.tryParse(value);
                  if (amount == null || amount <= 0) return 'Please enter a valid amount';
                  return null;
                },
                style: TextStyle(
                  fontSize: 36.sp,
                  fontWeight: FontWeight.bold,
                  color: _getBrandColor(),
                ),
                cursorColor: _getBrandColor(),
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.zero,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  hintStyle: TextStyle(
                    fontSize: 36.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[400],
                  ),
                  hintText: '\$ 0.00',
                  prefixStyle: TextStyle(
                    fontSize: 36.sp,
                    fontWeight: FontWeight.bold,
                    color: _getBrandColor(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool isDark,
    required TextInputType keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      cursorColor: _getBrandColor(),
      style: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w500,
        color: isDark ? Colors.white : Colors.black,
      ),
      validator: validator,
      inputFormatters: keyboardType == TextInputType.phone
          ? <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(11)]
          : keyboardType == TextInputType.number
          ? <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(12)]
          : <TextInputFormatter>[],
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(
          fontSize: 14.sp,
          color: _getBrandColor(),
          fontWeight: FontWeight.w500,
        ),
        hintStyle: TextStyle(
          fontSize: 14.sp,
          color: Colors.grey[500],
        ),
        prefixIcon: Icon(
          icon,
          color: _getBrandColor(),
          size: 20.sp,
        ),
        suffixIcon: ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (BuildContext context, TextEditingValue value, Widget? child) {
            if (value.text.isEmpty) return const SizedBox();
            if (keyboardType == TextInputType.emailAddress) {
              final bool isValid = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}'
              ).hasMatch(value.text);
              return Icon(
                isValid ? Icons.check_circle : Icons.error_outline,
                color: isValid ? Colors.green : Colors.red,
                size: 20.sp,
              );
            }
            return IconButton(
              icon: Icon(Icons.clear, size: 18.sp, color: Colors.grey[600]),
              onPressed: () => controller.clear(),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCardsSection() {
    return BlocBuilder<CardBloc, CardState>(
      builder: (BuildContext context, CardState state) {
        if (state is CardLoading) {
          return Container(
            height: 80.h,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: const Center(child: CircularProgressIndicator()),
          );
        } else if (state is CardLoaded) {
          if (state.cards.isEmpty) {
            return Container(
              height: 80.h,
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
              child: Center(
                child: Text(
                  'No cards available. Please add a card first.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 14.sp),
                ),
              ),
            );
          }
          if (_selectedCard == null) {
            _selectedCard = state.cards.firstWhere((CardModel card) => card.isDefault,
              orElse: () => state.cards.first,
            );
          }
          return Column(
            children: <Widget>[
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _buildAccountItem(
                  context: context,
                  card: _selectedCard!,
                  isSelected: true,
                  onTap: () => _showCardSelectionBottomSheet(context, state.cards),
                ),
              ),
              if (_selectedCard != null) ...<Widget>[
                8.verticalSpace,
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    'Tap to change card',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ]
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  void _showCardSelectionBottomSheet(BuildContext context, List<CardModel> cards) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        final ThemeData theme = Theme.of(context);
        final bool isDark = theme.brightness == Brightness.dark;
        return Container(
          decoration: BoxDecoration(
            color: isDark ? MyTheme.darkBackgroundColor : Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Handle
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
                16.verticalSpace,
                Text(
                  'Select Payment Card for $_companyName',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                20.verticalSpace,
                ...cards.asMap().entries.map((MapEntry<int, CardModel> entry) {
                  final CardModel card = entry.value;
                  return Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: _buildAccountItem(
                      context: context,
                      card: card,
                      isSelected: _selectedCard?.id == card.id,
                      onTap: () {
                        setState(() {
                          _selectedCard = card;
                        });
                        Navigator.pop(context);
                      },
                    ),
                  );
                }),
                20.verticalSpace,
                CustomButton(
                  text: 'Cancel',
                  height: 48.h,
                  backgroundColor: Colors.grey[300]!,
                  textColor: Colors.black,
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomNav({required bool isDark}) {
    return BlocBuilder<PayBillBloc, PayBillState>(
      builder: (BuildContext context, PayBillState state) {
        if (state is PayBillProcessing) {
          return Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: isDark ? MyTheme.darkBackgroundColor : Colors.white,
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Container(
              height: 54.h,
              decoration: BoxDecoration(
                color: _getBrandColor(),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                    SizedBox(width: 16.w),
                    Text(
                      'Processing $_companyName payment...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: _isFingerprintVisible
              ? _buildFingerPrintBottom(isDark: isDark)
              : Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: isDark ? MyTheme.darkBackgroundColor : Colors.white,
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: CustomButton(
              text: 'Pay $_companyName Now', // Include company name in button
              height: 54.h,
              backgroundColor: _getBrandColor(),
              textColor: Colors.white,
              onPressed: _triggerFingerprintAnimation,
            ),
          ),
        );
      },
    );
  }

  Widget _buildFingerPrintBottom({required bool isDark}) {
    return FadeTransition(
      opacity: _fingerprintFadeAnimation,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: isDark ? MyTheme.darkBackgroundColor : Colors.white,
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            TextButton(
              onPressed: () {
                setState(() {
                  _isFingerprintVisible = false;
                });
                _fingerprintController.reverse();
                _pulseController.stop();
                _pulseController.reset();
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              ),
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
            ),
            TextButton(
              onPressed: _processPayment,
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              ),
              child: Text(
                'Enter PIN Instead?',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: _getBrandColor(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFingerPrint({required bool isDark}) {
    return AnimatedBuilder(
      animation: _fingerprintFadeAnimation,
      builder: (BuildContext context, Widget? child) {
        return Opacity(
          opacity: _fingerprintFadeAnimation.value,
          child: Transform.translate(
            offset: Offset(0, (1 - _fingerprintFadeAnimation.value) * 50),
            child: Container(
              padding: EdgeInsets.all(32.w),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[900] : Colors.grey[50],
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: _getBrandColor().withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                children: <Widget>[
                  Icon(
                    Icons.fingerprint,
                    size: 40.sp,
                    color: _getBrandColor(),
                  ),
                  16.verticalSpace,
                  Text(
                    'Fingerprint Authentication',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  12.verticalSpace,
                  Text(
                    'Place your finger on the sensor to complete the $_companyName payment',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                  24.verticalSpace,
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (BuildContext context, Widget? child) {
                      return Transform.scale(
                        scale: _pulseAnimation.value,
                        child: GestureDetector(
                          onTap: _processPayment,
                          child: Container(
                            padding: EdgeInsets.all(20.w),
                            decoration: BoxDecoration(
                              color: _getBrandColor().withOpacity(0.1),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _getBrandColor(),
                                width: 2,
                              ),
                            ),
                            child: Image.asset(
                              TImageUrl.iconFingerScanner,
                              height: 60.h,
                              width: 60.w,
                              color: _getBrandColor(),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAccountItem({
    required BuildContext context,
    required CardModel card,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: EdgeInsets.all(16.w),
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

        child: Row(
          children: <Widget>[
            Image.asset(
              card.brandIconPath,
              height: 30.h,
              width: 40.w,
              color: Theme.of(context).brightness == ThemeMode.light ? Colors.black : Colors.white,
            ),
            16.horizontalSpace,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    card.cardholderName,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  Text(
                    card.cardEnding,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  4.verticalSpace,
                  Text(
                    'Exp: ${card.formattedExpiry}${card.isDefault ? ' • Default' : ''}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: _getBrandColor(),
                size: 20.sp,
              ),
            8.horizontalSpace,
            Icon(
              CupertinoIcons.chevron_down,
              size: 16.sp,
              color: Colors.grey[600],
            ),
          ],
        ),
      ),
    );
  }
}