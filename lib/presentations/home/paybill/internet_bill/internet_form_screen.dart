import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:payfussion/core/theme/theme.dart';
import 'package:payfussion/core/widget/card_screen.dart';
import '../../../../logic/blocs/pay_bill/internet_bill/internet_bill_bloc.dart';
import '../../../../logic/blocs/pay_bill/internet_bill/internet_bill_event.dart';


class InternetBillFormScreen extends StatefulWidget {
  final String companyName;
  final String connectionType;
  final String maxSpeed;
  final String coverage;

  const InternetBillFormScreen({
    super.key,
    required this.companyName,
    required this.connectionType,
    required this.maxSpeed,
    required this.coverage,
  });

  @override
  State<InternetBillFormScreen> createState() => _InternetBillFormScreenState();
}

class _InternetBillFormScreenState extends State<InternetBillFormScreen> with TickerProviderStateMixin {
  final TextEditingController _accountController = TextEditingController();
  bool _isLoading = false;

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late AnimationController _pulseController;
  late AnimationController _wifiController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _wifiAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startAnimationSequence();
  }

  void _initAnimations() {
    // Fade animation
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    // Slide animation
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));

    // Scale animation
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOutBack),
    );

    // Pulse animation
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // WiFi animation
    _wifiController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
    _wifiAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _wifiController, curve: Curves.easeInOut),
    );
  }

  void _startAnimationSequence() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _fadeController.forward();

    await Future.delayed(const Duration(milliseconds: 150));
    _slideController.forward();

    await Future.delayed(const Duration(milliseconds: 200));
    _scaleController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    _pulseController.dispose();
    _wifiController.dispose();
    _accountController.dispose();
    super.dispose();
  }

  void _fetchBillDetails() async {
    if (_accountController.text.isEmpty ||
        _accountController.text.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a valid account number'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
    });

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => InternetBillDetailsScreen(
          accountNumber: _accountController.text,
          companyName: widget.companyName,
          connectionType: widget.connectionType,
          maxSpeed: widget.maxSpeed,
          coverage: widget.coverage,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);
          return SlideTransition(position: offsetAnimation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: theme.primaryColor != Colors.white
                ? Colors.white
                : const Color(0xff2D3748),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: FadeTransition(
          opacity: _fadeAnimation,
          child: Text(
            widget.companyName,
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.primaryColor != Colors.white
                  ? Colors.white
                  : const Color(0xff2D3748),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Company Info Card with animation
                _buildAnimatedSection(
                  delay: 0,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: _buildCompanyInfoCard(theme),
                  ),
                ),

                SizedBox(height: 32.h),

                // Account Number Input with animation
                _buildAnimatedSection(
                  delay: 200,
                  child: _buildAccountNumberField(theme),
                ),

                SizedBox(height: 40.h),

                // Next Button with pulse
                _buildAnimatedSection(
                  delay: 400,
                  child: _buildContinueButton(theme),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedSection({required int delay, required Widget child}) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 600 + delay),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
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
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[
            MyTheme.primaryColor.withOpacity(0.1),
            MyTheme.primaryColor.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: MyTheme.primaryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              // Animated WiFi icon
              FadeTransition(
                opacity: _wifiAnimation,
                child: ScaleTransition(
                  scale: _wifiAnimation,
                  child: Icon(
                    Icons.wifi,
                    size: 24.sp,
                    color: MyTheme.primaryColor,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  widget.companyName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor != Colors.white
                        ? Colors.white
                        : const Color(0xff2D3748),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 1000),
            tween: Tween(begin: 0.0, end: 1.0),
            curve: Curves.easeOut,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(20 * (1 - value), 0),
                  child: child,
                ),
              );
            },
            child: Column(
              children: [
                _buildInfoRow(Icons.router, widget.connectionType, theme),
                SizedBox(height: 8.h),
                _buildInfoRow(Icons.speed, widget.maxSpeed, theme),
                SizedBox(height: 8.h),
                _buildInfoRow(Icons.public, widget.coverage, theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountNumberField(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Account Number',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.primaryColor != Colors.white
                ? Colors.white
                : const Color(0xff2D3748),
          ),
        ),
        SizedBox(height: 12.h),
        TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 800),
          tween: Tween(begin: 0.0, end: 1.0),
          curve: Curves.easeOut,
          builder: (context, value, child) {
            return Transform.scale(
              scale: 0.95 + (0.05 * value),
              child: child,
            );
          },
          child: TextField(
            controller: _accountController,
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly
            ],
            style: TextStyle(
              color: theme.primaryColor != Colors.white
                  ? Colors.white
                  : const Color(0xff2D3748),
            ),
            decoration: InputDecoration(
              hintText: 'Enter your account number',
              hintStyle: TextStyle(
                color: theme.primaryColor != Colors.white
                    ? Colors.white.withOpacity(0.3)
                    : Colors.grey[400],
              ),
              prefixIcon: const Icon(Icons.account_balance, color: MyTheme.primaryColor),
            ),
          ),
        ),
        SizedBox(height: 8.h),
        TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 1000),
          tween: Tween(begin: 0.0, end: 1.0),
          curve: Curves.easeOut,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: child,
            );
          },
          child: Text(
            'Tap on information icon for details on finding your account number',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.primaryColor != Colors.white
                  ? Colors.white.withOpacity(0.6)
                  : Colors.grey[600],
              fontSize: 11.sp,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContinueButton(ThemeData theme) {
    return ScaleTransition(
      scale: _pulseAnimation,
      child: SizedBox(
        width: double.infinity,
        height: 56.h,
        child: ElevatedButton(
          onPressed: _isLoading ? null : _fetchBillDetails,
          style: ElevatedButton.styleFrom(
            backgroundColor: MyTheme.primaryColor,
            disabledBackgroundColor: Colors.grey[300],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            elevation: 4,
          ),
          child: _isLoading
              ? SizedBox(
            height: 24.h,
            width: 24.w,
            child: const CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
          )
              : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Continue',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 8.w),
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 1500),
                tween: Tween(begin: 0.0, end: 1.0),
                curve: Curves.easeInOut,
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(5 * value, 0),
                    child: child,
                  );
                },
                child: const Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, ThemeData theme) {
    return Row(
      children: <Widget>[
        Icon(
          icon,
          size: 16.sp,
          color: MyTheme.primaryColor,
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.primaryColor != Colors.white
                  ? Colors.white.withOpacity(0.8)
                  : const Color(0xff718096),
            ),
          ),
        ),
      ],
    );
  }
}


class InternetBillDetailsScreen extends StatefulWidget {
  final String accountNumber;
  final String companyName;
  final String connectionType;
  final String maxSpeed;
  final String coverage;

  const InternetBillDetailsScreen({
    super.key,
    required this.accountNumber,
    required this.companyName,
    required this.connectionType,
    required this.maxSpeed,
    required this.coverage,
  });

  @override
  State<InternetBillDetailsScreen> createState() => _InternetBillDetailsScreenState();
}

class _InternetBillDetailsScreenState extends State<InternetBillDetailsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _proceedToCardSelection(BuildContext context) {
    // Sample data - replace with actual API data
    final double billAmount = 89.99;
    final String dueDate = '25 Nov 2025';
    final String billMonth = 'November 2025';
    final String consumerName = 'Sarah Johnson';
    final String address = '456 Oak Avenue, New York';
    final String planName = 'Premium Unlimited';
    final String dataUsage = '850 GB';
    final String downloadSpeed = '500 Mbps';
    final String uploadSpeed = '100 Mbps';

    // Set internet bill data in bloc
    context.read<InternetBillBloc>().add(SetInternetBillData(
      companyName: widget.companyName,
      connectionType: widget.connectionType,
      maxSpeed: widget.maxSpeed,
      coverage: widget.coverage,
      accountNumber: widget.accountNumber,
      consumerName: consumerName,
      address: address,
      billMonth: billMonth,
      amount: billAmount,
      planName: planName,
      dataUsage: dataUsage,
      downloadSpeed: downloadSpeed,
      uploadSpeed: uploadSpeed,
      dueDate: dueDate,
    ));

    // Navigate to card selection
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => const CardsScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    // Sample data - replace with actual API data
    final String billAmount = '89.99';
    final String dueDate = '25 Nov 2025';
    final String billMonth = 'November 2025';
    final String consumerName = 'Sarah Johnson';
    final String address = '456 Oak Avenue, New York';
    final String planName = 'Premium Unlimited';
    final String dataUsage = '850 GB';
    final String downloadSpeed = '500 Mbps';
    final String uploadSpeed = '100 Mbps';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: theme.primaryColor != Colors.white
                ? Colors.white
                : const Color(0xff2D3748),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Bill Details',
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.primaryColor != Colors.white
                ? Colors.white
                : const Color(0xff2D3748),
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                // Bill Card
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    margin: EdgeInsets.all(16.w),
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      color: theme.scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: theme.primaryColor.withOpacity(0.2),
                        width: 1,
                      ),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: theme.brightness == Brightness.light
                              ? Colors.grey.withOpacity(0.3)
                              : Colors.black.withOpacity(0.3),
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
                            TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.0, end: 1.0),
                              duration: const Duration(milliseconds: 600),
                              builder: (context, value, child) {
                                return Transform.scale(
                                  scale: value,
                                  child: Container(
                                    padding: EdgeInsets.all(12.w),
                                    decoration: BoxDecoration(
                                      color: theme.primaryColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                    child: Icon(
                                      Icons.wifi,
                                      color: MyTheme.primaryColor,
                                      size: 28.sp,
                                    ),
                                  ),
                                );
                              },
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Text(
                                widget.companyName,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.primaryColor != Colors.white
                                      ? Colors.white
                                      : const Color(0xff2D3748),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 24.h),
                        _buildAnimatedInfoRow('Account Number', widget.accountNumber, theme, 0),
                        SizedBox(height: 12.h),
                        _buildAnimatedInfoRow('Consumer Name', consumerName, theme, 1),
                        SizedBox(height: 12.h),
                        _buildAnimatedInfoRow('Address', address, theme, 2),
                        SizedBox(height: 12.h),
                        _buildAnimatedInfoRow('Bill Month', billMonth, theme, 3),
                        SizedBox(height: 12.h),
                        _buildAnimatedInfoRow('Plan', planName, theme, 4),
                        SizedBox(height: 12.h),
                        _buildAnimatedInfoRow('Data Usage', dataUsage, theme, 5),
                        SizedBox(height: 12.h),
                        _buildAnimatedInfoRow('Download Speed', downloadSpeed, theme, 6),
                        SizedBox(height: 12.h),
                        _buildAnimatedInfoRow('Upload Speed', uploadSpeed, theme, 7),
                        SizedBox(height: 20.h),
                        Divider(
                          color: theme.primaryColor != Colors.white
                              ? Colors.white.withOpacity(0.2)
                              : Colors.grey[300],
                        ),
                        SizedBox(height: 20.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.0, end: 1.0),
                              duration: const Duration(milliseconds: 800),
                              curve: Curves.easeOut,
                              builder: (context, value, child) {
                                return Opacity(
                                  opacity: value,
                                  child: Transform.translate(
                                    offset: Offset(-20 * (1 - value), 0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          'Amount Due',
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            color: theme.primaryColor != Colors.white
                                                ? Colors.white.withOpacity(0.7)
                                                : Colors.grey[600],
                                          ),
                                        ),
                                        SizedBox(height: 4.h),
                                        TweenAnimationBuilder<double>(
                                          tween: Tween(begin: 0.0, end: double.parse(billAmount)),
                                          duration: const Duration(milliseconds: 1000),
                                          builder: (context, value, child) {
                                            return Text(
                                              '\$${value.toStringAsFixed(2)}',
                                              style: theme.textTheme.headlineLarge?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: MyTheme.primaryColor,
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                            TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.0, end: 1.0),
                              duration: const Duration(milliseconds: 800),
                              curve: Curves.easeOut,
                              builder: (context, value, child) {
                                return Opacity(
                                  opacity: value,
                                  child: Transform.translate(
                                    offset: Offset(20 * (1 - value), 0),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 16.w,
                                        vertical: 8.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20.r),
                                        border: Border.all(
                                          color: Colors.orange.withOpacity(0.3),
                                          width: 1,
                                        ),
                                      ),
                                      child: Column(
                                        children: <Widget>[
                                          Text(
                                            'Due Date',
                                            style: theme.textTheme.bodySmall?.copyWith(
                                              color: theme.primaryColor != Colors.white
                                                  ? Colors.white.withOpacity(0.7)
                                                  : Colors.grey[700],
                                            ),
                                          ),
                                          SizedBox(height: 2.h),
                                          Text(
                                            dueDate,
                                            style: theme.textTheme.titleSmall?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.orange[800],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Pay Button
                Padding(
                  padding: EdgeInsets.all(16.w),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 1000),
                    curve: Curves.elasticOut,
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: SizedBox(
                          width: double.infinity,
                          height: 56.h,
                          child: ElevatedButton(
                            onPressed: () => _proceedToCardSelection(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: MyTheme.primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              elevation: 4,
                            ),
                            child: Text(
                              'Continue to Card Selection',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedInfoRow(String label, String value, ThemeData theme, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 50)),
      curve: Curves.easeOut,
      builder: (context, animValue, child) {
        return Opacity(
          opacity: animValue,
          child: Transform.translate(
            offset: Offset(0, 10 * (1 - animValue)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  width: 130.w,
                  child: Text(
                    label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.primaryColor != Colors.white
                          ? Colors.white.withOpacity(0.6)
                          : Colors.grey[600],
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    value,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: theme.primaryColor != Colors.white
                          ? Colors.white
                          : const Color(0xff2D3748),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}