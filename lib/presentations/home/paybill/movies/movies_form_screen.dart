import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/widget/card_screen.dart';
import '../../../../logic/blocs/pay_bill/movies/movies_bloc.dart';
import '../../../../logic/blocs/pay_bill/movies/movies_event.dart';

class MoviesFormScreen extends StatefulWidget {
  final String? serviceName;
  final String? category;
  final String? monthlyPrice;
  final String? content;
  final String? icon;

  const MoviesFormScreen({
    super.key,
    this.serviceName,
    this.category,
    this.monthlyPrice,
    this.content,
    this.icon,
  });

  @override
  State<MoviesFormScreen> createState() => _MoviesFormScreenState();
}

class _MoviesFormScreenState extends State<MoviesFormScreen> with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Form Controllers
  final TextEditingController _emailController = TextEditingController();

  String _selectedPlan = 'Monthly';
  bool _autoRenew = true;

  // Platform-specific subscription plans
  Map<String, Map<String, dynamic>> get subscriptionPlans {
    final String serviceName = widget.serviceName?.toLowerCase() ?? '';

    if (serviceName.contains('netflix')) {
      return <String, Map<String, dynamic>>{
        'Basic': <String, dynamic>{
          'duration': '1 Month',
          'price': 9.99,
          'discount': 0,
          'description': 'SD quality, 1 screen',
        },
        'Standard': <String, dynamic>{
          'duration': '1 Month',
          'price': 15.49,
          'discount': 0,
          'description': 'HD quality, 2 screens',
        },
        'Premium': <String, dynamic>{
          'duration': '1 Month',
          'price': 19.99,
          'discount': 0,
          'description': '4K quality, 4 screens',
        },
      };
    } else if (serviceName.contains('youtube')) {
      return <String, Map<String, dynamic>>{
        'Individual': <String, dynamic>{
          'duration': '1 Month',
          'price': 11.99,
          'discount': 0,
          'description': 'Ad-free, background play',
        },
        'Family': <String, dynamic>{
          'duration': '1 Month',
          'price': 22.99,
          'discount': 0,
          'description': 'Up to 6 family members',
        },
        'Student': <String, dynamic>{
          'duration': '1 Month',
          'price': 6.99,
          'discount': 40,
          'description': 'Verify student status',
        },
      };
    } else if (serviceName.contains('disney')) {
      return <String, Map<String, dynamic>>{
        'Monthly': <String, dynamic>{
          'duration': '1 Month',
          'price': 7.99,
          'discount': 0,
          'description': 'Billed monthly',
        },
        'Yearly': <String, dynamic>{
          'duration': '12 Months',
          'price': 79.99,
          'discount': 16,
          'description': 'Save 16% annually',
        },
      };
    } else if (serviceName.contains('hbo') || serviceName.contains('max')) {
      return <String, Map<String, dynamic>>{
        'With Ads': <String, dynamic>{
          'duration': '1 Month',
          'price': 9.99,
          'discount': 0,
          'description': 'Limited ads',
        },
        'Ad-Free': <String, dynamic>{
          'duration': '1 Month',
          'price': 15.99,
          'discount': 0,
          'description': 'No ads, download',
        },
        'Ultimate': <String, dynamic>{
          'duration': '1 Month',
          'price': 19.99,
          'discount': 0,
          'description': '4K, 4 streams',
        },
      };
    } else if (serviceName.contains('prime')) {
      return <String, Map<String, dynamic>>{
        'Monthly': <String, dynamic>{
          'duration': '1 Month',
          'price': 14.99,
          'discount': 0,
          'description': 'Prime Video only',
        },
        'Annual': <String, dynamic>{
          'duration': '12 Months',
          'price': 139.00,
          'discount': 22,
          'description': 'Full Prime benefits',
        },
      };
    } else if (serviceName.contains('apple')) {
      return <String, Map<String, dynamic>>{
        'Monthly': <String, dynamic>{
          'duration': '1 Month',
          'price': 6.99,
          'discount': 0,
          'description': 'Apple TV+ only',
        },
        'Apple One': <String, dynamic>{
          'duration': '1 Month',
          'price': 16.95,
          'discount': 0,
          'description': 'TV+, Music, Arcade, iCloud',
        },
      };
    } else {
      // Default plans for other services
      return <String, Map<String, dynamic>>{
        'Monthly': <String, dynamic>{
          'duration': '1 Month',
          'price': 9.99,
          'discount': 0,
          'description': 'Billed monthly',
        },
        'Quarterly': <String, dynamic>{
          'duration': '3 Months',
          'price': 26.97,
          'discount': 10,
          'description': 'Save 10% quarterly',
        },
        'Yearly': <String, dynamic>{
          'duration': '12 Months',
          'price': 95.88,
          'discount': 20,
          'description': 'Save 20% annually',
        },
      };
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedPlan = subscriptionPlans.keys.first;
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
    _emailController.dispose();
    super.dispose();
  }

  void _proceedToCardSelection() {
    if (_formKey.currentState!.validate()) {
      final Map<String, dynamic> selectedPlanData = subscriptionPlans[_selectedPlan]!;

      // Set subscription data in bloc
      context.read<MoviesBloc>().add(SetSubscriptionData(
        serviceName: widget.serviceName ?? 'Streaming Service',
        category: widget.category ?? 'Entertainment',
        email: _emailController.text,
        planName: _selectedPlan,
        planPrice: selectedPlanData['price'],
        planDuration: selectedPlanData['duration'],
        planDescription: selectedPlanData['description'],
        autoRenew: _autoRenew,
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
      appBar: AppBar(
        title: const Text('Subscribe Now'),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.all(20.w),
            children: <Widget>[
              // Service Info Card
              _buildServiceInfoCard(),

              SizedBox(height: 24.h),

              // Subscription Plans
              _buildSectionTitle('Choose Your Plan', Icons.card_membership),
              SizedBox(height: 12.h),
              _buildSubscriptionPlans(),

              SizedBox(height: 24.h),

              // Email Only
              _buildSectionTitle('Account Email', Icons.email),
              SizedBox(height: 12.h),

              _buildTextField(
                controller: _emailController,
                label: 'Email Address',
                hint: 'your@email.com',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (String? value) {
                  if (value?.isEmpty ?? true) return 'Email is required';
                  if (!value!.contains('@')) return 'Invalid email format';
                  return null;
                },
              ),

              SizedBox(height: 16.h),

              // Auto-Renew Toggle
              _buildAutoRenewCard(),

              SizedBox(height: 8.h),

              // Terms Notice
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: <Widget>[
                    Icon(Icons.info_outline, color: Colors.blue[700], size: 20.sp),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        'By subscribing, you agree to the Terms of Service and Privacy Policy',
                        style: TextStyle(fontSize: 11.sp, color: Colors.blue[700]),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 32.h),

              // Subscribe Button
              _buildSubscribeButton(),

              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceInfoCard() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[
            MyTheme.primaryColor,
            MyTheme.primaryColor,
          ],
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: MyTheme.primaryColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50.r),
                ),
                child: Image.asset(widget.icon.toString(), height: 40, width: 40),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      widget.serviceName ?? 'Streaming Service',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (widget.category != null)
                      Text(
                        widget.category!,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14.sp,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (widget.content != null) ...<Widget>[
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                widget.content!,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13.sp,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: <Widget>[
        Icon(icon, size: 22.sp, color: MyTheme.primaryColor),
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

  Widget _buildSubscriptionPlans() {
    return Column(
      children: subscriptionPlans.entries.map((MapEntry<String, Map<String, dynamic>> entry) {
        final bool isSelected = _selectedPlan == entry.key;
        final Map<String, dynamic> planData = entry.value;

        return GestureDetector(
          onTap: () => setState(() => _selectedPlan = entry.key),
          child: Container(
            margin: EdgeInsets.only(bottom: 12.h),
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: isSelected ? MyTheme.primaryColor : Colors.grey.withOpacity(0.3),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: isSelected ? MyTheme.primaryColor : null,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isSelected ? Icons.check : Icons.circle_outlined,
                    color: Colors.white,
                    size: 20.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Text(
                            entry.key,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (planData['discount'] > 0) ...<Widget>[
                            SizedBox(width: 8.w),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Text(
                                'Save ${planData['discount']}%',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        planData['description'],
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '\$${planData['price'].toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: MyTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
      ),
    );
  }

  Widget _buildAutoRenewCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: SwitchListTile(
        title: const Text(
          'Auto-Renew Subscription',
        ),
        subtitle: Text(
          'Automatically renew at the end of billing period',
          style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
        ),
        value: _autoRenew,
        onChanged: (bool value) => setState(() => _autoRenew = value),
        activeThumbColor: MyTheme.primaryColor,
        secondary: const Icon(Icons.autorenew, color: MyTheme.primaryColor),
      ),
    );
  }

  Widget _buildSubscribeButton() {
    final Map<String, dynamic> selectedPlanData = subscriptionPlans[_selectedPlan]!;

    return SizedBox(
      width: double.infinity,
      height: 56.h,
      child: ElevatedButton(
        onPressed: _proceedToCardSelection,
        style: ElevatedButton.styleFrom(
          backgroundColor: MyTheme.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          elevation: 4,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(Icons.arrow_forward, color: Colors.white),
            SizedBox(width: 8.w),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Continue to Payment',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '\$${selectedPlanData['price'].toStringAsFixed(2)} / ${selectedPlanData['duration']}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}