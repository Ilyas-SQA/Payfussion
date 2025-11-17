import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RentPaymentForm extends StatefulWidget {
  final String? companyName;
  final String? category;

  const RentPaymentForm({
    super.key,
    this.companyName,
    this.category,
  });

  @override
  State<RentPaymentForm> createState() => _RentPaymentFormState();
}

class _RentPaymentFormState extends State<RentPaymentForm> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Form Controllers
  final TextEditingController _propertyAddressController = TextEditingController();
  final TextEditingController _landlordNameController = TextEditingController();
  final TextEditingController _landlordEmailController = TextEditingController();
  final TextEditingController _landlordPhoneController = TextEditingController();
  final TextEditingController _rentAmountController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  String _selectedPaymentMethod = 'Credit Card';
  bool _saveForFuture = false;
  bool _isLoading = false;

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

  void _processPayment() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      // Simulate payment processing
      await Future.delayed(const Duration(seconds: 2));

      setState(() => _isLoading = false);

      if (mounted) {
        _showSuccessDialog();
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 60.sp),
            SizedBox(height: 16.h),
            const Text('Payment Successful!'),
          ],
        ),
        content: Text(
          'Your rent payment of PKR ${_rentAmountController.text} has been sent to ${_landlordNameController.text}',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Pay Rent',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.all(20.w),
            children: [
              // Company Info Card
              if (widget.companyName != null)
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.primaryColor.withOpacity(0.8),
                        theme.primaryColor,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(15.r),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.business, color: Colors.white, size: 30.sp),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.companyName!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (widget.category != null)
                              Text(
                                widget.category!,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

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
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
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
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),

              SizedBox(height: 16.h),

              _buildTextField(
                controller: _landlordEmailController,
                label: 'Landlord Email',
                hint: 'landlord@example.com',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Required';
                  if (!value!.contains('@')) return 'Invalid email';
                  return null;
                },
              ),

              SizedBox(height: 16.h),

              _buildTextField(
                controller: _landlordPhoneController,
                label: 'Landlord Phone',
                hint: '+92 XXX XXXXXXX',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),

              SizedBox(height: 24.h),

              // Payment Details
              _buildSectionTitle('Payment Details', Icons.payment),
              SizedBox(height: 12.h),

              _buildTextField(
                controller: _rentAmountController,
                label: 'Rent Amount (PKR)',
                hint: '0.00',
                icon: Icons.currency_rupee,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Required';
                  if (double.tryParse(value!) == null) return 'Invalid amount';
                  return null;
                },
              ),

              SizedBox(height: 16.h),

              // Payment Method Selector
              _buildPaymentMethodSelector(theme),

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
                  title: const Text('Save landlord details for future payments'),
                  subtitle: const Text('Quick payment next time', style: TextStyle(fontSize: 12)),
                  value: _saveForFuture,
                  onChanged: (value) => setState(() => _saveForFuture = value!),
                  activeColor: theme.primaryColor,
                ),
              ),

              SizedBox(height: 32.h),

              // Payment Button
              _buildPaymentButton(theme),

              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 22.sp,),
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
        // labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        filled: true,
      ),
    );
  }

  Widget _buildPaymentMethodSelector(ThemeData theme) {
    final methods = [
      {'name': 'Credit Card', 'icon': Icons.credit_card},
      {'name': 'Debit Card', 'icon': Icons.payment},
      {'name': 'Bank Transfer', 'icon': Icons.account_balance},
      {'name': 'Mobile Wallet', 'icon': Icons.wallet},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Method',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 12.h),
        Wrap(
          spacing: 12.w,
          runSpacing: 12.h,
          children: methods.map((method) {
            final isSelected = _selectedPaymentMethod == method['name'];
            return InkWell(
              onTap: () => setState(() => _selectedPaymentMethod = method['name'] as String),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: isSelected ? theme.primaryColor : theme.cardColor,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: isSelected ? theme.primaryColor : Colors.grey.withOpacity(0.3),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      method['icon'] as IconData,
                      color: isSelected ? Colors.white : Colors.grey[700],
                      size: 20.sp,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      method['name'] as String,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey[700],
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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

  Widget _buildPaymentButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      height: 56.h,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _processPayment,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          elevation: 4,
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, color: Colors.white),
            SizedBox(width: 8.w),
            Text(
              'Pay Securely',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}