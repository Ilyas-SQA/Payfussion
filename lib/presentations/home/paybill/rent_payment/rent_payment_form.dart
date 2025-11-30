import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:payfussion/core/theme/theme.dart';
import 'package:payfussion/core/widget/card_screen.dart';
import '../../../../logic/blocs/pay_bill/rent_payment/rent_payment_bloc.dart';
import '../../../../logic/blocs/pay_bill/rent_payment/rent_payment_event.dart';

class RentPaymentForm extends StatefulWidget {
  final String? companyName;
  final String? category;
  final String? feeRange;
  final String? properties;
  final String? companyIcon; // ADD THIS PARAMETER

  const RentPaymentForm({
    super.key,
    this.companyName,
    this.category,
    this.feeRange,
    this.properties,
    this.companyIcon, // ADD THIS
  });

  @override
  State<RentPaymentForm> createState() => _RentPaymentFormState();
}

class _RentPaymentFormState extends State<RentPaymentForm>
    with TickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  final TextEditingController _propertyAddressController = TextEditingController();
  final TextEditingController _landlordNameController = TextEditingController();
  final TextEditingController _landlordEmailController = TextEditingController();
  final TextEditingController _landlordPhoneController = TextEditingController();
  final TextEditingController _rentAmountController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  bool _saveForFuture = false;

  @override
  void initState() {
    super.initState();
    _initAnimations();
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
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOutBack),
    );

    _fadeController.forward();
    _slideController.forward();
    _scaleController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    _propertyAddressController.dispose();
    _landlordNameController.dispose();
    _landlordEmailController.dispose();
    _landlordPhoneController.dispose();
    _rentAmountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _proceedToCardSelection() {
    if (_formKey.currentState!.validate()) {
      final double amount = double.parse(_rentAmountController.text);

      context.read<RentPaymentBloc>().add(SetRentPaymentData(
        companyName: widget.companyName ?? 'Rent Payment',
        category: widget.category ?? 'Rental',
        propertyAddress: _propertyAddressController.text,
        landlordName: _landlordNameController.text,
        landlordEmail: _landlordEmailController.text,
        landlordPhone: _landlordPhoneController.text,
        amount: amount,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      ));

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
        title: Row(
          children: <Widget>[
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 600),
              tween: Tween(begin: 0.0, end: 1.0),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Icon(
                    Icons.home_work,
                    color: MyTheme.primaryColor,
                    size: 24.sp,
                  ),
                );
              },
            ),
            SizedBox(width: 12.w),
            const Text('Pay Rent'),
          ],
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Form(
            key: _formKey,
            child: ListView(
              padding: EdgeInsets.all(20.w),
              children: <Widget>[
                if (widget.companyName != null)
                  _buildAnimatedSection(0, _buildCompanyInfoCard(theme)),
                SizedBox(height: 24.h),
                _buildAnimatedSection(1, _buildSectionTitle('Property Details', Icons.home_work)),
                SizedBox(height: 12.h),
                _buildAnimatedSection(2, _buildTextField(
                  controller: _propertyAddressController,
                  label: 'Property Address',
                  hint: 'Enter full property address',
                  icon: Icons.location_on,
                  validator: (String? value) => value?.isEmpty ?? true ? 'Required' : null,
                )),
                SizedBox(height: 24.h),
                _buildAnimatedSection(3, _buildSectionTitle('Landlord Details', Icons.person)),
                SizedBox(height: 12.h),
                _buildAnimatedSection(4, _buildTextField(
                  controller: _landlordNameController,
                  label: 'Landlord Name',
                  hint: 'Enter landlord full name',
                  icon: Icons.person_outline,
                  validator: (String? value) => value?.isEmpty ?? true ? 'Required' : null,
                )),
                SizedBox(height: 16.h),
                _buildAnimatedSection(5, _buildTextField(
                  controller: _landlordEmailController,
                  label: 'Landlord Email',
                  hint: 'landlord@example.com',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (String? value) {
                    if (value?.isEmpty ?? true) return 'Required';
                    if (!value!.contains('@')) return 'Invalid email';
                    return null;
                  },
                )),
                SizedBox(height: 16.h),
                _buildAnimatedSection(6, _buildTextField(
                  controller: _landlordPhoneController,
                  label: 'Landlord Phone',
                  hint: '+1 XXX XXX XXXX',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (String? value) => value?.isEmpty ?? true ? 'Required' : null,
                )),
                SizedBox(height: 24.h),
                _buildAnimatedSection(7, _buildSectionTitle('Payment Details', Icons.payment)),
                SizedBox(height: 12.h),
                _buildAnimatedSection(8, _buildTextField(
                  controller: _rentAmountController,
                  label: 'Rent Amount (\$)',
                  hint: '0.00',
                  icon: Icons.attach_money,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))
                  ],
                  validator: (String? value) {
                    if (value?.isEmpty ?? true) return 'Required';
                    if (double.tryParse(value!) == null) return 'Invalid amount';
                    if (double.parse(value) < 100) return 'Minimum amount is \$100';
                    return null;
                  },
                )),
                SizedBox(height: 16.h),
                _buildAnimatedSection(9, _buildTextField(
                  controller: _notesController,
                  label: 'Additional Notes (Optional)',
                  hint: 'Add any notes or references',
                  icon: Icons.note_outlined,
                  maxLines: 3,
                )),
                SizedBox(height: 16.h),
                _buildAnimatedSection(10, _buildSaveCheckbox(theme)),
                SizedBox(height: 32.h),
                _buildAnimatedSection(11, _buildContinueButton(theme)),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedSection(int index, Widget child) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 400 + (index * 80)),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutCubic,
      builder: (BuildContext context, double value, Widget? child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  Widget _buildCompanyInfoCard(ThemeData theme) {
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
                // Company Logo with Hero Animation
                if (widget.companyIcon != null)
                  Hero(
                    tag: 'rent_icon_${widget.companyName}',
                    child: TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 800),
                      tween: Tween(begin: 0.0, end: 1.0),
                      curve: Curves.elasticOut,
                      builder: (BuildContext context, double value, Widget? child) {
                        return Transform.scale(
                          scale: value,
                          child: Container(
                            height: 56.h,
                            width: 56.w,
                            decoration: BoxDecoration(
                              color: MyTheme.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: MyTheme.primaryColor.withOpacity(0.2),
                                width: 2,
                              ),
                            ),
                            padding: EdgeInsets.all(8.w),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.r),
                              child: Image.asset(
                                widget.companyIcon!,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    Icons.business,
                                    color: MyTheme.primaryColor,
                                    size: 28.sp,
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  )
                else
                // Fallback icon if no logo
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 600),
                    tween: Tween(begin: 0.0, end: 1.0),
                    curve: Curves.elasticOut,
                    builder: (BuildContext context, double value, Widget? child) {
                      return Transform.scale(
                        scale: value,
                        child: Container(
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: MyTheme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Icon(
                            Icons.business,
                            color: MyTheme.primaryColor,
                            size: 28.sp,
                          ),
                        ),
                      );
                    },
                  ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        widget.companyName!,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: theme.primaryColor != Colors.white
                              ? Colors.white
                              : const Color(0xff2D3748),
                        ),
                      ),
                      if (widget.category != null) ...[
                        SizedBox(height: 4.h),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: MyTheme.primaryColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: MyTheme.primaryColor.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            widget.category!,
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              color: MyTheme.primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            if (widget.properties != null || widget.feeRange != null) ...<Widget>[
              SizedBox(height: 16.h),
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: theme.brightness == Brightness.light
                      ? Colors.grey[100]
                      : Colors.grey[850],
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    if (widget.properties != null)
                      Row(
                        children: <Widget>[
                          Icon(
                            Icons.home,
                            size: 16.sp,
                            color: MyTheme.primaryColor,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            widget.properties!,
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                              color: theme.primaryColor != Colors.white
                                  ? Colors.white.withOpacity(0.8)
                                  : Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    if (widget.feeRange != null)
                      Row(
                        children: <Widget>[
                          Icon(
                            Icons.credit_card,
                            size: 16.sp,
                            color: MyTheme.primaryColor,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            widget.feeRange!,
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                              color: theme.primaryColor != Colors.white
                                  ? Colors.white.withOpacity(0.8)
                                  : Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
      child: Row(
        children: <Widget>[
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 500),
            tween: Tween(begin: 0.0, end: 1.0),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: MyTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(icon, size: 20.sp, color: MyTheme.primaryColor),
                ),
              );
            },
          ),
          SizedBox(width: 12.w),
          Text(
            title,
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.light
                ? Colors.grey.withOpacity(0.1)
                : Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: MyTheme.primaryColor),
          filled: true,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
        ),
      ),
    );
  }

  Widget _buildSaveCheckbox(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: CheckboxListTile(
        title: const Text('Save landlord details for future payments'),
        subtitle: const Text('Quick payment next time', style: TextStyle(fontSize: 12)),
        value: _saveForFuture,
        onChanged: (bool? value) => setState(() => _saveForFuture = value!),
        activeColor: MyTheme.primaryColor,
      ),
    );
  }

  Widget _buildContinueButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _proceedToCardSelection,
        style: ElevatedButton.styleFrom(
          backgroundColor: MyTheme.primaryColor,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
          elevation: 4,
        ),
        child: Text(
          'Continue to Card Selection',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }
}