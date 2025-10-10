import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:payfussion/core/theme/theme.dart';
import 'package:payfussion/presentations/setting/avalible_limit_screen.dart';
import 'package:payfussion/presentations/setting/community_forum/community_forum_screen.dart';
import 'package:payfussion/presentations/setting/profile_screens/cashbacks_and_refund_screen.dart';
import 'package:payfussion/presentations/setting/submit_ticket/show_ticket_screen.dart';
import 'package:payfussion/presentations/setting/tax_and_legal_compliance.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/image_url.dart';
import '../../core/constants/routes_name.dart';
import '../../logic/blocs/add_card/card_bloc.dart';
import '../../logic/blocs/add_card/card_event.dart';
import '../../logic/blocs/add_card/card_state.dart';
import '../../logic/blocs/setting/setting_bloc.dart';
import '../../logic/blocs/setting/setting_event.dart';
import '../../logic/blocs/setting/setting_state.dart';
import '../../logic/blocs/theme/theme_bloc.dart';
import '../../logic/blocs/theme/theme_event.dart';
import '../../logic/blocs/theme/theme_state.dart';
import '../../services/biometric_service.dart';
import '../../services/payment_service.dart';
import '../../services/service_locator.dart';
import '../../services/session_manager_service.dart';
import '../my_reward/my_reward_screen.dart';
import '../widgets/settings_widgets/setting_container.dart';
import '../widgets/settings_widgets/setting_item.dart';
import '../widgets/settings_widgets/setting_item_header.dart';
import '../widgets/settings_widgets/setting_profile.dart';
import 'data_and_permissions.dart';
import 'devices_management_screen.dart';
import 'faqs_screen.dart';
import 'live_chat.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> with TickerProviderStateMixin {
  bool? isBiometricEnabled;
  bool? isBiometricSupported;
  String biometricTypeName = "Fingerprint Login";

  final BiometricService biometricService = getIt<BiometricService>();
  final SessionController sessionController = SessionController();

  // Animation controllers
  late AnimationController _headerController;
  late AnimationController _profileController;
  late AnimationController _contentController;

  // Animation variables - will be initialized in initState
  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;
  late Animation<double> _profileScale;
  late Animation<Offset> _profileSlide;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startAnimations();
  }

  void _initAnimations() {
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _profileController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _contentController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _headerFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _headerController, curve: Curves.easeOut),
    );

    _headerSlide = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _headerController, curve: Curves.easeOut));

    _profileScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _profileController, curve: Curves.easeOutBack),
    );

    _profileSlide = Tween<Offset>(
      begin: const Offset(-0.5, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _profileController, curve: Curves.easeOut));
  }

  void _startAnimations() async {
    // Start animations with proper delays like home screen
    await Future.delayed(const Duration(milliseconds: 100));
    _headerController.forward();

    await Future.delayed(const Duration(milliseconds: 100));
    _profileController.forward();

    await Future.delayed(const Duration(milliseconds: 100));
    _contentController.forward();
  }

  @override
  void dispose() {
    _headerController.dispose();
    _profileController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> updateTransactionStatus(String userID, bool transactionValue) async {
    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(userID)
          .update({
        "transaction": transactionValue,
      });

      SessionController.user.transaction = transactionValue;
      await SessionController().saveUserInPreference(SessionController.user.toJson());

      print("Transaction status updated successfully: $transactionValue");
    } catch (e) {
      print("Error updating transaction status: ${e.toString()}");
      throw e;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isBiometricEnabled = SessionController.isBiometric ??
        context.select((SettingsBloc b) => b.state.security['fingerprint']);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: SlideTransition(
            position: _headerSlide,
            child: FadeTransition(
              opacity: _headerFade,
              child: const Text("Settings"),
            ),
          ),
          centerTitle: true,
          elevation: 0,
          actions: [
            SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.5, 0),
                end: Offset.zero,
              ).animate(_headerController),
              child: FadeTransition(
                opacity: _headerFade,
                child: BlocBuilder<ThemeBloc, ThemeState>(
                  builder: (context, themeState) {
                    bool isDark = themeState.themeMode == ThemeMode.dark;

                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: IconButton(
                        key: ValueKey(isDark),
                        icon: Icon(
                          isDark ? Icons.light_mode : Icons.dark_mode,
                          color: MyTheme.primaryColor,
                          size: 30.sp,
                        ),
                        onPressed: () {
                          context.read<ThemeBloc>().add(ToggleThemeEvent());
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
            SizedBox(width: 10.w),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
            child: AnimationLimiter(
              child: Column(
                children: AnimationConfiguration.toStaggeredList(
                  duration: const Duration(milliseconds: 200),
                  childAnimationBuilder: (widget) => SlideAnimation(
                    verticalOffset: 20.0,
                    child: FadeInAnimation(child: widget),
                  ),
                  children: [
                    // Error message
                    _buildErrorMessage(),
                    SizedBox(height: 18.h),

                    // Profile section
                    SlideTransition(
                      position: _profileSlide,
                      child: ScaleTransition(
                        scale: _profileScale,
                        child: SettingProfile(
                          onTap: () {
                            context.push(RouteNames.profile);
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    LimitSettingContainer(),

                    SizedBox(height: 35.h),
                    SizedBox(height: 35.h),
                    // Linked Accounts
                    _buildLinkedAccountsSection(),
                    SizedBox(height: 35.h),

                    // Security Settings
                    _buildSecuritySection(),
                    SizedBox(height: 35.h),

                    // Privacy Settings
                    _buildPrivacySection(),
                    SizedBox(height: 35.h),

                    // Payment & Transactions
                    _buildPaymentSection(theme),
                    SizedBox(height: 35.h),

                    // Customer Support
                    _buildSupportSection(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Builder(
      builder: (context) {
        final errorMessage = context.select(
              (SettingsBloc b) => b.state.errorMessage,
        );
        if (errorMessage.isEmpty) return const SizedBox.shrink();

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            color: Colors.red.shade100,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Text(
            errorMessage,
            style: TextStyle(
              color: Colors.red.shade800,
              fontSize: 14.sp,
            ),
          ),
        );
      },
    );
  }

  Widget _buildLinkedAccountsSection() {
    return Column(
      children: [
        SettingItemsHeader(
          itemHeaderSideButton: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: TextButton(
              onPressed: () {
                PaymentService().saveCard(context);
              },
              child: Text(
                "Add New",
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 12.sp,
                  color: const Color(0xffffffff),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          itemHeaderText: 'Linked Accounts',
        ),
        SizedBox(height: 20.h),
        BlocProvider(
          create: (context) => CardBloc()..add(LoadCards()),
          child: BlocBuilder<CardBloc, CardState>(
            builder: (context, state) {
              if (state is CardLoading) {
                return _buildShimmerCard();
              } else if (state is CardLoaded) {
                if (state.cards.isEmpty) {
                  return _buildEmptyCard();
                }

                return SettingContainer(
                  child: AnimationLimiter(
                    child: Column(
                      children: AnimationConfiguration.toStaggeredList(
                        duration: const Duration(milliseconds: 150),
                        childAnimationBuilder: (widget) => SlideAnimation(
                          horizontalOffset: 20.0,
                          child: FadeInAnimation(child: widget),
                        ),
                        children: [
                          for (final card in state.cards) ...[
                            SettingTile(
                              icon: TImageUrl.visa,
                              title: card.cardEnding,
                              subtitle: "Exp: ${card.formattedExpiry}",
                              trailingBuilder: (ctx) => _animatedSwitch(
                                value: card.isDefault,
                                onChanged: (v) {
                                  context.read<CardBloc>().add(
                                    SetDefaultCard(
                                      cardId: card.id,
                                      isDefault: v,
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              } else if (state is CardError) {
                return _buildErrorCard(state.message);
              }
              return const SizedBox();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSecuritySection() {
    return Column(
      children: [
        SettingItemsHeader(itemHeaderText: 'Security Settings'),
        SizedBox(height: 20.h),
        SettingContainer(
          child: AnimationLimiter(
            child: Column(
              children: AnimationConfiguration.toStaggeredList(
                duration: const Duration(milliseconds: 150),
                childAnimationBuilder: (widget) => SlideAnimation(
                  horizontalOffset: 20.0,
                  child: FadeInAnimation(child: widget),
                ),
                children: [
                  BlocBuilder<SettingsBloc, SettingsState>(
                    builder: (context, state) {
                      return SettingTile(
                        icon: TImageUrl.fingerPrint,
                        title: "Fingerprint Login",
                        subtitle: "Enable this for a quick access",
                        trailingBuilder: (context) => _animatedSwitch(
                          value: SessionController.isBiometric ?? state.security['fingerprint']!,
                          onChanged: (v) {
                            context.read<SettingsBloc>().add(
                              LinkedAccountToggled(
                                accountId: 'fingerprint',
                                enabled: v,
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 20.h),
                  BlocProvider(
                    create: (context) => SettingsBloc()..add(LoadTwoFactorStatus()),
                    child: BlocBuilder<SettingsBloc, SettingsState>(
                      builder: (context, state) {
                        return SettingTile(
                          icon: TImageUrl.twoFactor,
                          title: "2 Factor Authentication",
                          subtitle: "We will send an OTP to your \nregistered number",
                          trailingBuilder: (ctx) => _animatedSwitch(
                            value: state.isTwoFactorEnabled,
                            onChanged: (v) {
                              context.read<SettingsBloc>().add(UpdateTwoFactorStatus(v));
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 20.h),
                  SettingTile(
                    icon: TImageUrl.lockAccount,
                    title: "Lock Your Account",
                    subtitle: "This will lock all types of\ntransactions from your account",
                    trailingBuilder: (ctx) => _animatedSwitch(
                      value: SessionController.user.transaction ?? true,
                      onChanged: (v) async {
                        try {
                          String? userID = SessionController.user.uid;
                          if (userID != null && userID.isNotEmpty) {
                            await updateTransactionStatus(userID, v);
                            setState(() {});
                            print("Transaction status changed to: $v");
                          } else {
                            print("User ID not found");
                          }
                        } catch (e) {
                          print("Failed to update transaction status: $e");
                          setState(() {});
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrivacySection() {
    return Column(
      children: [
        SettingItemsHeader(itemHeaderText: 'Privacy Settings'),
        SizedBox(height: 20.h),
        SettingContainer(
          child: AnimationLimiter(
            child: Column(
              children: AnimationConfiguration.toStaggeredList(
                duration: const Duration(milliseconds: 150),
                childAnimationBuilder: (widget) => SlideAnimation(
                  horizontalOffset: 20.0,
                  child: FadeInAnimation(child: widget),
                ),
                children: [
                  SettingTile(
                    icon:  TImageUrl.currency,
                    title: 'Currency',
                    subtitle: 'Choose your currency',
                    trailingBuilder: (ctx) => currencyPicker(context: ctx),
                  ),
                  SizedBox(height: 20.h),
                  SettingTile(
                    icon: TImageUrl.refund,
                    title: 'Refund and cashback',
                    subtitle: 'Checkout our policies of refund\nand cash backs',
                    trailingBuilder: (ctx) => _animatedArrow(() {
                      context.push(
                        '/refundAndCashback',
                        extra: const CashbackAndRefundsScreen(),
                      );
                    }),
                  ),
                  SizedBox(height: 20.h),
                  SettingTile(
                    icon: TImageUrl.tax,
                    title: 'Tax and Legal Compliance',
                    subtitle: 'Generate annual reports, view\nguidelines, and know custom tax laws',
                    trailingBuilder: (ctx) => _animatedArrow(() {
                      context.push(
                        '/taxAndLegalCompliance',
                        extra: const TaxComplianceScreen(),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentSection(ThemeData theme) {
    return Column(
      children: [
        SettingItemsHeader(itemHeaderText: 'Payment & Transactions'),
        SizedBox(height: 20.h),
        SettingContainer(
          child: AnimationLimiter(
            child: Column(
              children: AnimationConfiguration.toStaggeredList(
                duration: const Duration(milliseconds: 150),
                childAnimationBuilder: (widget) => SlideAnimation(
                  horizontalOffset: 20.0,
                  child: FadeInAnimation(child: widget),
                ),
                children: [
                  SettingTile(
                    icon: TImageUrl.reward,
                    title: 'My Reward',
                    subtitle: 'View vouchers, games & exciting rewards',
                    trailingBuilder: (ctx) => _animatedArrow(() {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => MyRewardScreen()));
                    }),
                  ),
                  SizedBox(height: 20.h),

                  SettingTile(
                    icon: TImageUrl.transactionPrivacy,
                    title: 'Transaction Privacy',
                    subtitle: 'Choose who can see your\ntransactions history',
                    trailingBuilder: (ctx) => AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 80,
                      child: DropdownButton<String>(
                        value: ctx.select((SettingsBloc b) => b.state.transactionPrivacyMode,
                        ),
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 12.sp,
                          color: theme.secondaryHeaderColor,
                          fontWeight: FontWeight.bold,
                        ),
                        onChanged: (v) => ctx.read<SettingsBloc>().add(
                          TransactionPrivacyModeChanged(v ?? 'Public'),
                        ),
                        underline: const SizedBox(),
                        items: const [
                          DropdownMenuItem(
                            value: 'Public',
                            child: Text(
                              'Public',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 12,
                                color: MyTheme.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'Private',
                            child: Text(
                              'Private',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 12,
                                color: MyTheme.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'Friends',
                            child: Text(
                              'Friends',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 12,
                                color: MyTheme.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  SettingTile(
                    icon: TImageUrl.data,
                    title: 'Data And Permissions',
                    subtitle: 'Choose how you want to manage\nyour data with us',
                    trailingBuilder: (ctx) => _animatedArrow(() {
                      context.push(
                        '/dataAndPermissions',
                        extra: const DataAndPermissionsScreen(),
                      );
                    }),
                  ),
                  SizedBox(height: 20.h),
                  SettingTile(
                    icon: TImageUrl.deviceManagement,
                    title: 'Device Management',
                    subtitle: 'See where accounts are currently\nlogged in and manage them\naccording to your choice',
                    trailingBuilder: (ctx) => _animatedArrow(() {
                      context.push(
                        '/deviceManagement',
                        extra: const DevicesManagementScreen(),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSupportSection() {
    return Column(
      children: [
        SettingItemsHeader(itemHeaderText: 'Customer Support'),
        SizedBox(height: 20.h),
        SettingContainer(
          child: AnimationLimiter(
            child: Column(
              children: AnimationConfiguration.toStaggeredList(
                duration: const Duration(milliseconds: 150),
                childAnimationBuilder: (widget) => SlideAnimation(
                  horizontalOffset: 20.0,
                  child: FadeInAnimation(child: widget),
                ),
                children: [
                  SettingTile(
                    icon: TImageUrl.liveChat,
                    title: 'Live Chat',
                    subtitle: 'Talk with our chat-bot and\nhuman support 24/7',
                    trailingBuilder: (ctx) => _animatedArrow(() {
                      context.push(
                        '/liveChat',
                        extra: const LiveChatScreen(),
                      );
                    }),
                  ),
                  SizedBox(height: 20.h),
                  SettingTile(
                    icon: TImageUrl.submitTTicket,
                    title: 'Submit A Ticket',
                    subtitle: 'Submit a ticket with your complaint\nor suggestion',
                    trailingBuilder: (ctx) => _animatedArrow(() {
                      context.push(
                        '/showTicket',
                        extra: const ShowTicketScreen(),
                      );
                    }),
                  ),
                  SizedBox(height: 20.h),
                  SettingTile(
                    icon: TImageUrl.communityForm,
                    title: 'Community Forum',
                    subtitle: 'Ask and answer common issues with\nthe other members of our app',
                    trailingBuilder: (ctx) => _animatedArrow(() {
                      context.push(
                        '/communityForum',
                        extra: const CommunityForumScreen(),
                      );
                    }),
                  ),
                  SizedBox(height: 20.h),
                  SettingTile(
                    icon: TImageUrl.faq,
                    title: 'FAQs',
                    subtitle: 'Common questions and answers\nabout our app',
                    trailingBuilder: (ctx) => _animatedArrow(() {
                      context.push(
                        RouteNames.faqs,
                        extra: const FaqsScreen(),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Helper widgets
  Widget _animatedSwitch({required bool value, required Function(bool) onChanged}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xff2D9CDB),
      ),
    );
  }

  Widget _animatedArrow(VoidCallback onTap) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15.r),
        child: Padding(
          padding: EdgeInsets.all(8.r),
          child: Icon(
            Icons.arrow_forward_ios,
            size: 24.sp,
            color: MyTheme.primaryColor,
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerCard() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Container(
            width: 40.r,
            height: 40.r,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 16.h,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
                SizedBox(height: 8.h),
                Container(
                  width: 100.w,
                  height: 12.h,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCard() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.all(20.r),
      child: const Center(
        child: Text(
          "No cards added yet",
          style: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildErrorCard(String message) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        message,
        style: TextStyle(color: Colors.red.shade700),
      ),
    );
  }
}