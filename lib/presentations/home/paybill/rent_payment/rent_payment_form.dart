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

  const RentPaymentForm({
    super.key,
    this.companyName,
    this.category,
    this.feeRange,
    this.properties,
  });

  @override
  State<RentPaymentForm> createState() => _RentPaymentFormState();
}

class _RentPaymentFormState extends State<RentPaymentForm>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Form Controllers
  final TextEditingController _propertyAddressController =
  TextEditingController();
  final TextEditingController _landlordNameController =
  TextEditingController();
  final TextEditingController _landlordEmailController =
  TextEditingController();
  final TextEditingController _landlordPhoneController =
  TextEditingController();
  final TextEditingController _rentAmountController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  bool _saveForFuture = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
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

      // Set rent payment data in bloc
      context.read<RentPaymentBloc>().add(SetRentPaymentData(
        companyName: widget.companyName ?? 'Rent Payment',
        category: widget.category ?? 'Rental',
        propertyAddress: _propertyAddressController.text,
        landlordName: _landlordNameController.text,
        landlordEmail: _landlordEmailController.text,
        landlordPhone: _landlordPhoneController.text,
        amount: amount,
        notes: _notesController.text.isNotEmpty
            ? _notesController.text
            : null,
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
        title: Text(
          'Pay Rent',
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.all(20.w),
            children: <Widget>[
              // Company Info Card
              if (widget.companyName != null) _buildCompanyInfoCard(theme),

              SizedBox(height: 24.h),

              // Section Title
              _buildSectionTitle('Property Details', Icons.home_work),
              SizedBox(height: 12.h),

              // Property Address
              _buildTextField(
                controller: _propertyAddressController,
                label: 'Property Address',
                hint: 'Enter full property address',
                icon: Icons.location_on,
                validator: (String? value) =>
                value?.isEmpty ?? true ? 'Required' : null,
              ),

              SizedBox(height: 24.h),

              // Landlord Details Section
              _buildSectionTitle('Landlord Details', Icons.person),
              SizedBox(height: 12.h),

              _buildTextField(
                controller: _landlordNameController,
                label: 'Landlord Name',
                hint: 'Enter landlord full name',
                icon: Icons.person_outline,
                validator: (String? value) =>
                value?.isEmpty ?? true ? 'Required' : null,
              ),

              SizedBox(height: 16.h),

              _buildTextField(
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
              ),

              SizedBox(height: 16.h),

              _buildTextField(
                controller: _landlordPhoneController,
                label: 'Landlord Phone',
                hint: '+1 XXX XXX XXXX',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (String? value) =>
                value?.isEmpty ?? true ? 'Required' : null,
              ),

              SizedBox(height: 24.h),

              // Payment Details
              _buildSectionTitle('Payment Details', Icons.payment),
              SizedBox(height: 12.h),

              _buildTextField(
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
                  if (double.tryParse(value!) == null) {
                    return 'Invalid amount';
                  }
                  if (double.parse(value) < 100) {
                    return 'Minimum amount is \$100';
                  }
                  return null;
                },
              ),

              SizedBox(height: 16.h),

              // Notes
              _buildTextField(
                controller: _notesController,
                label: 'Additional Notes (Optional)',
                hint: 'Add any notes or references',
                icon: Icons.note_outlined,
                maxLines: 3,
              ),

              SizedBox(height: 16.h),

              // Save for Future Checkbox
              Container(
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.grey.withOpacity(0.2)),
                ),
                child: CheckboxListTile(
                  title: const Text(
                      'Save landlord details for future payments'),
                  subtitle: const Text('Quick payment next time',
                      style: TextStyle(fontSize: 12)),
                  value: _saveForFuture,
                  onChanged: (bool? value) =>
                      setState(() => _saveForFuture = value!),
                  activeColor: MyTheme.primaryColor,
                ),
              ),

              SizedBox(height: 32.h),

              // Continue Button
              _buildContinueButton(theme),

              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompanyInfoCard(ThemeData theme) {
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
              Icon(Icons.business,
                  color: MyTheme.primaryColor, size: 30.sp),
              SizedBox(width: 12.w),
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
                    if (widget.category != null)
                      Text(
                        widget.category!,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: theme.primaryColor != Colors.white
                              ? Colors.white.withOpacity(0.7)
                              : Colors.grey[600],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (widget.properties != null || widget.feeRange != null) ...<Widget>[
            SizedBox(height: 12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                if (widget.properties != null)
                  Row(
                    children: <Widget>[
                      Icon(Icons.home,
                          size: 16.sp, color: Colors.grey[600]),
                      SizedBox(width: 4.w),
                      Text(
                        widget.properties!,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                if (widget.feeRange != null)
                  Text(
                    widget.feeRange!,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: <Widget>[
        Icon(icon, size: 22.sp),
        SizedBox(width: 8.w),
        Text(
          title,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
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
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: MyTheme.primaryColor),
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          elevation: 4,
        ),
        child: Text(
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