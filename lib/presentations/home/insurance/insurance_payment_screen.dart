import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:payfussion/presentations/widgets/auth_widgets/credential_text_field.dart';
import 'package:payfussion/presentations/widgets/custom_button.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/theme.dart';
import '../../../data/models/card/card_model.dart';
import '../../../data/models/insurance/insurance_model.dart';
import '../../../logic/blocs/add_card/card_bloc.dart';
import '../../../logic/blocs/add_card/card_event.dart';
import '../../../logic/blocs/add_card/card_state.dart';
import '../../../logic/blocs/insurance/insurance_bloc.dart';
import '../../../logic/blocs/insurance/insurance_event.dart';
import '../../../logic/blocs/insurance/insurance_state.dart';
import '../../../services/biometric_service.dart';
import '../../../services/payment_service.dart';
import '../../../services/service_locator.dart';

class InsurancePaymentScreen extends StatefulWidget {
  final String companyName;
  final String insuranceType;
  final Color color;
  final IconData icon;

  const InsurancePaymentScreen({
    super.key,
    required this.companyName,
    required this.insuranceType,
    required this.color,
    required this.icon,
  });

  @override
  _InsurancePaymentScreenState createState() => _InsurancePaymentScreenState();
}

class _InsurancePaymentScreenState extends State<InsurancePaymentScreen> with TickerProviderStateMixin {
  bool _isFingerprintVisible = false;
  CardModel? _selectedCard;
  String _currentPaymentId = '';

  final TextEditingController _policyNumberController = TextEditingController();
  final TextEditingController _premiumAmountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Biometric Service
  final BiometricService _biometricService = getIt<BiometricService>();
  bool _isBiometricAvailable = false;
  bool _isBiometricEnabled = false;
  String _biometricTypeName = 'Biometric';

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

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _initBiometric();
    context.read<CardBloc>().add(LoadCards());
  }

  void _initAnimations() {
    _slideController = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    _fadeController = AnimationController(duration: const Duration(milliseconds: 600), vsync: this);
    _scaleController = AnimationController(duration: const Duration(milliseconds: 400), vsync: this);
    _fingerprintController = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
    _pulseController = AnimationController(duration: const Duration(milliseconds: 1500), vsync: this);

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
        CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack));
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

  Future<void> _initBiometric() async {
    try {
      _isBiometricAvailable = await _biometricService.isBiometricAvailable();
      _isBiometricEnabled = await _biometricService.isBiometricEnabled();
      _biometricTypeName = await _biometricService.getBiometricTypeName();

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('Error initializing biometric: $e');
    }
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
    _policyNumberController.dispose();
    _premiumAmountController.dispose();
    super.dispose();
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

  void _processPayment() async {
    if (_validateInputs()) {
      // Try biometric authentication first if available
      if (_isBiometricAvailable && _isBiometricEnabled) {
        await _authenticateWithBiometric();
      } else {
        _completePayment();
      }
    }
  }

  Future<void> _authenticateWithBiometric() async {
    try {
      final result = await _biometricService.authenticate(
        reason: 'Authenticate to complete insurance premium payment',
        biometricOnly: true,
      );

      if (result['success']) {
        _completePayment();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['error'] ?? 'Authentication failed'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() { _isFingerprintVisible = false; });
        _fingerprintController.reverse();
        _pulseController.stop();
        _pulseController.reset();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Authentication error: $e'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() { _isFingerprintVisible = false; });
    }
  }

  void _completePayment() {
    final double amount = double.tryParse(_premiumAmountController.text) ?? 0.0;
    final insurancePayment = InsurancePaymentModel(
      id: const Uuid().v4(),
      companyName: widget.companyName,
      insuranceType: widget.insuranceType,
      policyNumber: _policyNumberController.text,
      premiumAmount: amount,
      cardId: _selectedCard!.id,
      cardEnding: _selectedCard!.cardEnding,
      createdAt: DateTime.now(),
      paidAt: DateTime.now(),
      paymentMethod: _isBiometricAvailable && _isBiometricEnabled ? _biometricTypeName.toLowerCase() : 'pin',
      status: 'completed',
      hasFee: amount > 1000,
      feeAmount: amount > 1000 ? (amount * 0.015).clamp(10.0, 100.0) : 0.0,
      dueDate: DateTime.now().add(const Duration(days: 30)),
      policyStartDate: DateTime.now(),
      policyEndDate: DateTime.now().add(const Duration(days: 365)),
    );
    context.read<InsurancePaymentBloc>().add(AddInsurancePayment(insurancePayment));
    _currentPaymentId = insurancePayment.id;
  }


  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? MyTheme.darkBackgroundColor : MyTheme.backgroundColor,
      body: MultiBlocListener(
        listeners: [
          BlocListener<InsurancePaymentBloc, InsurancePaymentState>(
              listener: (context, state) {
                if (state is InsurancePaymentSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.message), backgroundColor: Colors.green));
                  if (_currentPaymentId.isNotEmpty) {
                    context.read<InsurancePaymentBloc>().add(
                        ProcessInsurancePayment(_currentPaymentId, 'fingerprint', _selectedCard!.id));
                  }
                } else if (state is InsurancePaymentProcessSuccess) {
                  // Show success message
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Payment completed successfully!'),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 2),
                      ));

                  // Navigate back after short delay
                  Future.delayed(Duration(seconds: 2), () {
                    if (mounted) {
                      Navigator.of(context).pop();
                    }
                  });
                } else if (state is InsurancePaymentProcessFailed) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Payment failed: ${state.error}'), backgroundColor: Colors.red));
                  setState(() { _isFingerprintVisible = false; });
                }
              }
          ),
        ],
        child: CustomScrollView(
          slivers: [
            // Enhanced App Bar
            SliverAppBar(
              expandedHeight: 200.h,
              pinned: true,
              backgroundColor: widget.color,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white, size: 20.sp),
                onPressed: () => context.pop(),
              ),
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  widget.companyName,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                  ),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        widget.color,
                        widget.color.withOpacity(0.8),
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
                          child: Icon(
                            widget.icon,
                            size: 60.sp,
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
                      children: [
                        // Header Info Card
                        _buildInfoCard(isDark),

                        32.verticalSpace,

                        // Policy Details Section
                        _buildSectionHeader('Policy Details', Icons.policy, isDark,false),
                        16.verticalSpace,
                        _buildPolicyInput(isDark),

                        24.verticalSpace,

                        // Premium Amount Section
                        _buildSectionHeader('Premium Amount', Icons.payments, isDark,false),
                        16.verticalSpace,
                        _buildPremiumInput(isDark),

                        32.verticalSpace,

                        // Payment Method Section
                        _buildSectionHeader('Payment Method', Icons.credit_card, isDark,true),
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
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).brightness == Brightness.light ? Colors.grey.withOpacity(0.3) : Colors.black.withOpacity(0.3),
              blurRadius: 5,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: widget.color,
              size: 24.sp,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Insurance Premium Payment',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Secure payment for ${widget.insuranceType}',
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

  Widget _buildSectionHeader(String title, IconData icon, bool isDark,bool isCard) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: widget.color,
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
          label: Text("Add  New Card",style: TextStyle(color: MyTheme.secondaryColor,fontSize: 12.sp),),
          icon: Icon(Icons.add,color: MyTheme.secondaryColor),
          onPressed: (){
            PaymentService().saveCard(context);
          },
        ) : SizedBox()
      ],
    );
  }

  Widget _buildPolicyInput(bool isDark) {
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
        child: AppTextFormField(
          isPasswordField: false,
          helpText: 'Policy Number',
          controller: _policyNumberController,
          useGreenColor: true,
          validator: (value) {
            if (value == null || value.isEmpty) return 'Please enter policy number';
            if (value.length < 6) return 'Policy number must be at least 6 characters';
            return null;
          },
        )
      ),
    );
  }

  Widget _buildPremiumInput(bool isDark) {
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
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).brightness == Brightness.light ? Colors.grey.withOpacity(0.3) : Colors.black.withOpacity(0.3),
                blurRadius: 5,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                'Premium Amount',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8.h),
              TextFormField(
                controller: _premiumAmountController,
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Please enter premium amount';
                  final double? amount = double.tryParse(value);
                  if (amount == null || amount <= 0)
                    return 'Please enter a valid amount';
                  return null;
                },
                style: TextStyle(
                  fontSize: 36.sp,
                  fontWeight: FontWeight.bold,
                  color: widget.color,
                ),
                cursorColor: widget.color,
                cursorHeight: 30,
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
                  prefixText: '\$ ',
                  prefixStyle: TextStyle(
                    fontSize: 36.sp,
                    fontWeight: FontWeight.bold,
                    color: widget.color,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardsSection() {
    return BlocBuilder<CardBloc, CardState>(
      builder: (context, state) {
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
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Center(
                child: Text(
                  'No cards available. Please add a card first.',
                  style: TextStyle(color: Colors.grey, fontSize: 14.sp),
                ),
              ),
            );
          }
          if (_selectedCard == null) {
            _selectedCard = state.cards.firstWhere(
                  (card) => card.isDefault,
              orElse: () => state.cards.first,
            );
          }
          return Column(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _buildAccountItem(
                  context: context,
                  card: _selectedCard!,
                  isSelected: true,
                  onTap: () => _showCardSelectionBottomSheet(context, state.cards),
                ),
              ),
              if (_selectedCard != null) ...[
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
      builder: (context) {
        final ThemeData theme = Theme.of(context);
        final bool isDark = theme.brightness == Brightness.dark;
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(5.r),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).brightness == Brightness.light ? Colors.grey.withOpacity(0.3) : Colors.black.withOpacity(0.3),
                blurRadius: 5,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                  'Select Payment Card',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 18,
                  ),
                ),
                20.verticalSpace,
                ...cards.asMap().entries.map((entry) {
                  CardModel card = entry.value;
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
    return BlocBuilder<InsurancePaymentBloc, InsurancePaymentState>(
      builder: (context, state) {
        if (state is InsurancePaymentProcessing) {
          return Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: isDark ? MyTheme.darkBackgroundColor : Colors.white,
              boxShadow: [
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
                color: widget.color,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: CustomButton(
              text: _isBiometricAvailable && _isBiometricEnabled
                  ? 'Pay with $_biometricTypeName'
                  : 'Pay Premium',
              height: 54.h,
              backgroundColor: widget.color,
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
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
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
              onPressed: () {
                // Fallback to PIN payment when biometric fails or user chooses PIN
                _completePayment();
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              ),
              child: Text(
                _isBiometricAvailable && _isBiometricEnabled
                    ? 'Enter PIN Instead?'
                    : 'Complete Payment',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: widget.color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFingerPrint({required bool isDark}) {
    IconData biometricIcon = Icons.fingerprint;
    String authTitle = '$_biometricTypeName Authentication';
    String authDescription = 'Use $_biometricTypeName to complete the payment';

    // Set icon based on biometric type
    if (_biometricTypeName.toLowerCase().contains('face')) {
      biometricIcon = Icons.face;
    } else if (_biometricTypeName.toLowerCase().contains('fingerprint')) {
      biometricIcon = Icons.fingerprint;
    } else {
      biometricIcon = Icons.security;
    }

    return AnimatedBuilder(
      animation: _fingerprintFadeAnimation,
      builder: (context, child) {
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
                  color: widget.color.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    biometricIcon,
                    size: 40.sp,
                    color: widget.color,
                  ),
                  16.verticalSpace,
                  Text(
                    authTitle,
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  12.verticalSpace,
                  Text(
                    authDescription,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                  24.verticalSpace,
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _pulseAnimation.value,
                        child: GestureDetector(
                          onTap: _processPayment,
                          child: Container(
                            padding: EdgeInsets.all(20.w),
                            decoration: BoxDecoration(
                              color: widget.color.withOpacity(0.1),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: widget.color,
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              biometricIcon,
                              size: 60.sp,
                              color: widget.color,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  if (!_isBiometricAvailable || !_isBiometricEnabled) ...[
                    16.verticalSpace,
                    Text(
                      'Biometric not available. Use PIN instead.',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.orange,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
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
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).brightness == Brightness.light ? Colors.grey.withOpacity(0.3) : Colors.black.withOpacity(0.3),
              blurRadius: 5,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Image.asset(
              card.brandIconPath,
              height: 24.h,
              width: 32.w,
              color: isDark ? Colors.white : Colors.black,
            ),
            16.horizontalSpace,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                color: widget.color,
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