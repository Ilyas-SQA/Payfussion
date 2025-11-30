import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/fonts.dart';
import '../../../../data/models/recipient/recipient_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/theme/theme.dart';
import '../../../../logic/blocs/bank_transaction/bank_transaction_bloc.dart';
import '../../../../logic/blocs/bank_transaction/bank_transaction_event.dart';
import '../../../../logic/blocs/bank_transaction/bank_transaction_state.dart';
import '../../../widgets/background_theme.dart';
import 'credit_card_loan_form_screen.dart';

class CreditCardLoanScreen extends StatefulWidget {
  const CreditCardLoanScreen({Key? key}) : super(key: key);

  @override
  State<CreditCardLoanScreen> createState() => _CreditCardLoanScreenState();
}

class _CreditCardLoanScreenState extends State<CreditCardLoanScreen> with TickerProviderStateMixin{

  late AnimationController _backgroundAnimationController;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    context.read<BankTransactionBloc>().add(const FetchBanks());
    _initAnimations();
  }

  void _initAnimations() {
    _backgroundAnimationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));

    _fadeController.forward();
    _slideController.forward();
  }

  void _navigateToBankDetails(Bank bank) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => CreditCardLoanFormScreen(
          bankName: bank.name,
          branchName: bank.branchName,
          city: bank.city,
          branchCode: bank.branchCode,
          bankLogoUrl: bank.image, // Add this line
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      child: ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: 5,
        itemBuilder: (BuildContext context, int index) {
          return TweenAnimationBuilder<double>(
            duration: Duration(milliseconds: 300 + (index * 100)),
            tween: Tween(begin: 0.0, end: 1.0),
            curve: Curves.easeOut,
            builder: (BuildContext context, double value, Widget? child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: child,
                ),
              );
            },
            child: Container(
              margin: EdgeInsets.only(bottom: 12.h),
              height: 80.h,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[850] : Colors.white,
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBankCard(Bank bank, int index) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 400 + (index * 80)),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutCubic,
      builder: (BuildContext context, double value, Widget? child) {
        return Transform.translate(
          offset: Offset(50 * (1 - value), 0),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 200),
          tween: Tween(begin: 1.0, end: 1.0),
          builder: (BuildContext context, double scale, Widget? child) {
            return Transform.scale(
              scale: scale,
              child: child,
            );
          },
          child: Container(
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
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(5.r),
                onTap: () => _navigateToBankDetails(bank),
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Row(
                    children: <Widget>[
                      Hero(
                        tag: 'bank_${bank.name}',
                        child: TweenAnimationBuilder<double>(
                          duration: const Duration(milliseconds: 600),
                          tween: Tween(begin: 0.0, end: 1.0),
                          curve: Curves.elasticOut,
                          builder: (BuildContext context, double value, Widget? child) {
                            return Transform.scale(
                              scale: value,
                              child: child,
                            );
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: CachedNetworkImage(
                              imageUrl: bank.image,
                              fit: BoxFit.fill,
                              height: 50,
                              width: 50,
                              placeholder: (BuildContext context, String url) => Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).brightness == Brightness.dark
                                      ? Colors.grey[800]
                                      : Colors.grey[200],
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: MyTheme.primaryColor,
                                  ),
                                ),
                              ),
                              errorWidget: (BuildContext context, String url, Object error) {
                                return Container(
                                  height: 50,
                                  width: 50,
                                  decoration: BoxDecoration(
                                    color: MyTheme.primaryColor.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.account_balance,
                                    color: MyTheme.primaryColor,
                                    size: 24.sp,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              bank.name,
                              style: Font.montserratFont(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            if (bank.branchName.isNotEmpty)
                              Text(
                                bank.branchName,
                                style: Font.montserratFont(
                                  fontSize: 12.sp,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            if (bank.city.isNotEmpty)
                              Text(
                                '${bank.city} • ${bank.branchCode}',
                                style: Font.montserratFont(
                                  fontSize: 11.sp,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                          ],
                        ),
                      ),
                      TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 800),
                        tween: Tween(begin: 0.0, end: 1.0),
                        curve: Curves.elasticOut,
                        builder: (BuildContext context, double value, Widget? child) {
                          return Transform.scale(
                            scale: value,
                            child: child,
                          );
                        },
                        child: Icon(
                          Icons.arrow_forward_ios,
                          color: MyTheme.primaryColor,
                          size: 16.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 800),
        tween: Tween(begin: 0.0, end: 1.0),
        curve: Curves.easeOut,
        builder: (BuildContext context, double value, Widget? child) {
          return Transform.scale(
            scale: value,
            child: Opacity(
              opacity: value,
              child: child,
            ),
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 1000),
              tween: Tween(begin: 0.0, end: 1.0),
              curve: Curves.elasticOut,
              builder: (BuildContext context, double value, Widget? child) {
                return Transform.scale(
                  scale: value,
                  child: Icon(
                    Icons.account_balance_outlined,
                    size: 64.sp,
                    color: Colors.grey.shade400,
                  ),
                );
              },
            ),
            SizedBox(height: 16.h),
            Text(
              'No Banks Available',
              style: Font.montserratFont(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: 8.h),
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 600),
              tween: Tween(begin: 0.0, end: 1.0),
              curve: Curves.easeOut,
              builder: (BuildContext context, double value, Widget? child) {
                return Opacity(
                  opacity: value,
                  child: child,
                );
              },
              child: TextButton(
                onPressed: () => context.read<BankTransactionBloc>().add(const FetchBanks()),
                style: TextButton.styleFrom(
                  backgroundColor: MyTheme.primaryColor.withOpacity(0.1),
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  'Retry',
                  style: TextStyle(
                    color: MyTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _backgroundAnimationController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Bank'),
      ),
      body: Stack(
        children: <Widget>[
          AnimatedBackground(
            animationController: _backgroundAnimationController,
          ),
          BlocConsumer<BankTransactionBloc, BankTransactionState>(
            listener: (BuildContext context, BankTransactionState state) {
              if (state.errorMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.errorMessage!),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                );
              }
            },
            builder: (BuildContext context, BankTransactionState state) {
              return Column(
                children: <Widget>[
                  // Header with animations
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 24.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            TweenAnimationBuilder<double>(
                              duration: const Duration(milliseconds: 600),
                              tween: Tween(begin: 0.0, end: 1.0),
                              curve: Curves.easeOut,
                              builder: (BuildContext context, double value, Widget? child) {
                                return Transform.translate(
                                  offset: Offset(-20 * (1 - value), 0),
                                  child: Opacity(
                                    opacity: value,
                                    child: child,
                                  ),
                                );
                              },
                              child: Row(
                                children: <Widget>[
                                  Icon(
                                    Icons.account_balance,
                                    color: MyTheme.primaryColor,
                                    size: 24.sp,
                                  ),
                                  SizedBox(width: 12.w),
                                  Text(
                                    'Choose your bank',
                                    style: Font.montserratFont(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 8.h),
                            TweenAnimationBuilder<double>(
                              duration: const Duration(milliseconds: 800),
                              tween: Tween(begin: 0.0, end: 1.0),
                              curve: Curves.easeOut,
                              builder: (BuildContext context, double value, Widget? child) {
                                return Opacity(
                                  opacity: value,
                                  child: child,
                                );
                              },
                              child: Text(
                                state.isLoadingBanks
                                    ? 'Loading banks...'
                                    : 'Tap on any bank to make credit card/loan payment',
                                style: Font.montserratFont(
                                  fontSize: 12.sp,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Banks List
                  Expanded(
                    child: state.isLoadingBanks
                        ? _buildShimmerLoading()
                        : state.availableBanks.isEmpty
                        ? _buildEmptyState()
                        : RefreshIndicator(
                      onRefresh: () async {
                        context.read<BankTransactionBloc>().add(const FetchBanks());
                      },
                      color: MyTheme.primaryColor,
                      child: ListView.builder(
                        padding: EdgeInsets.only(top: 8.h, bottom: 16.h),
                        physics: const BouncingScrollPhysics(),
                        itemCount: state.availableBanks.length,
                        itemBuilder: (BuildContext context, int index) {
                          final Bank bank = state.availableBanks[index];
                          return _buildBankCard(bank, index);
                        },
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}