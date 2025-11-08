import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:password_strength_indicator_plus/password_strength_indicator_plus.dart';
import 'package:payfussion/core/widget/appbutton/app_button.dart';
import '../../../core/constants/fonts.dart';
import '../../../core/constants/image_url.dart';
import '../../../logic/blocs/setting/change-password/change_password_bloc.dart';
import '../../../logic/blocs/setting/change-password/change_pasword_event.dart';
import '../../../logic/blocs/setting/change-password/change_pasword_state.dart';
import '../../widgets/auth_widgets/credential_text_field.dart';
import '../../widgets/helper_widgets/error_dialog.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen>
    with TickerProviderStateMixin {
  final TextEditingController oldPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmNewPasswordController =
  TextEditingController();

  final ScrollController _scrollController = ScrollController();
  final GlobalKey _formKey = GlobalKey();

  late AnimationController _fadeAnimationController;
  late AnimationController _slideAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Focus nodes for text fields
  final FocusNode _oldPasswordFocus = FocusNode();
  final FocusNode _newPasswordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _slideAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeAnimationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideAnimationController,
      curve: Curves.easeOutBack,
    ));

    // Start animations
    _fadeAnimationController.forward();
    _slideAnimationController.forward();

    // REMOVED: Focus listeners that were causing scroll issues
    // Focus listeners ko comment kar diya hai
  }

  @override
  void dispose() {
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmNewPasswordController.dispose();
    _scrollController.dispose();
    _fadeAnimationController.dispose();
    _slideAnimationController.dispose();
    _oldPasswordFocus.dispose();
    _newPasswordFocus.dispose();
    _confirmPasswordFocus.dispose();
    super.dispose();
  }

  PasswordStrength _checkPasswordStrength(String password) {
    final bool hasUppercase = password.contains(RegExp(r'[A-Z]'));
    final bool hasLowercase = password.contains(RegExp(r'[a-z]'));
    final bool hasDigit = password.contains(RegExp(r'\d'));
    final bool hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    final bool hasMinLength = password.length >= 8;

    if (hasUppercase &&
        hasLowercase &&
        hasDigit &&
        hasSpecialChar &&
        hasMinLength) {
      return PasswordStrength.strong;
    } else if ((hasLowercase || hasUppercase) && hasDigit && hasMinLength) {
      return PasswordStrength.medium;
    } else {
      return PasswordStrength.weak;
    }
  }

  Widget _buildAnimatedField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String helpText,
    required bool isPasswordField,
    required int animationDelay,
  }) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 600 + (animationDelay * 200)),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      curve: Curves.elasticOut,
      builder: (BuildContext context, double value, Widget? child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: AppTextFormField(
              controller: controller,
              isPasswordField: isPasswordField,
              helpText: helpText,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChangePasswordBloc, ChangePasswordState>(
      listener: (BuildContext context, ChangePasswordState state) {
        // Handle loading state with animated dialog
        if (state.isLoading) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => WillPopScope(
              onWillPop: () async => false,
              child: Center(
                child: TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 500),
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  builder: (BuildContext context, double value, Widget? child) {
                    return Transform.scale(
                      scale: value,
                      child: Container(
                        padding: EdgeInsets.all(20.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15.r),
                        ),
                        child: const CircularProgressIndicator(),
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        } else {
          // Dismiss loading dialog if it's showing
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }

          // Handle success state with animation
          if (state.isSuccess) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Row(
                    children: <Widget>[
                      TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 500),
                        tween: Tween<double>(begin: 0.0, end: 1.0),
                        builder: (BuildContext context, double value, Widget? child) {
                          return Transform.scale(
                            scale: value,
                            child: const Icon(
                              Icons.check_circle,
                              color: Colors.white,
                            ),
                          );
                        },
                      ),
                      SizedBox(width: 10.w),
                      const Text('Password changed successfully!'),
                    ],
                  ),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 2),
                ),
              );
            Navigator.pop(context); // Return to previous screen
          }
          // Handle error state
          else if (state.errorMessage != null) {
            ErrorDialog.show(context, state.errorMessage!);
          }
        }
      },
      builder: (BuildContext context, ChangePasswordState state) {
        return Scaffold(
          // IMPORTANT: resizeToAvoidBottomInset ko false karna keyboard issue fix karta hai
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            title: Text(
              'Change Password',
              style: Font.montserratFont(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          body: SingleChildScrollView(
            controller: _scrollController,
            // CHANGED: ClampingScrollPhysics use kiya for better keyboard handling
            physics: const ClampingScrollPhysics(),
            // CHANGED: Simplified padding - MediaQuery.viewInsets automatically handle keyboard
            padding: EdgeInsets.only(
              left: 45.w,
              right: 45.w,
              top: 25.h,
              bottom: 20.h,
            ),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    // Animated logo
                    TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 1200),
                      tween: Tween<double>(begin: 0.0, end: 1.0),
                      curve: Curves.bounceOut,
                      builder: (BuildContext context, double value, Widget? child) {
                        return Transform.scale(
                          scale: value,
                          child: Transform.rotate(
                            angle: (1 - value) * 0.5,
                            child: Hero(
                              tag: 'logo',
                              child: Image.asset(TImageUrl.iconLogo, height: 100.h),
                            ),
                          ),
                        );
                      },
                    ),

                    SizedBox(height: 20.h),

                    // Animated app name
                    TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 1000),
                      tween: Tween<double>(begin: 0.0, end: 1.0),
                      curve: Curves.easeInOut,
                      builder: (BuildContext context, double value, Widget? child) {
                        return Opacity(
                          opacity: value,
                          child: Text(
                            'PayFussion',
                            style: Font.montserratFont(
                              fontSize: 22.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      },
                    ),

                    SizedBox(height: 10.h),

                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          // Animated title
                          TweenAnimationBuilder<double>(
                            duration: const Duration(milliseconds: 800),
                            tween: Tween<double>(begin: 0.0, end: 1.0),
                            curve: Curves.easeOutBack,
                            builder: (BuildContext context, double value, Widget? child) {
                              return Transform.translate(
                                offset: Offset(0, 30 * (1 - value)),
                                child: Opacity(
                                  opacity: value,
                                  child: Text(
                                    'Change Password',
                                    style: Font.montserratFont(
                                      fontSize: 22.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),

                          SizedBox(height: 56.h),

                          // Animated text fields
                          _buildAnimatedField(
                            controller: oldPasswordController,
                            focusNode: _oldPasswordFocus,
                            helpText: 'Enter Old Password',
                            isPasswordField: true,
                            animationDelay: 0,
                          ),

                          SizedBox(height: 20.h),

                          _buildAnimatedField(
                            controller: newPasswordController,
                            focusNode: _newPasswordFocus,
                            helpText: 'Enter New Password',
                            isPasswordField: true,
                            animationDelay: 1,
                          ),

                          // Animated password strength indicator
                          TweenAnimationBuilder<double>(
                            duration: const Duration(milliseconds: 1000),
                            tween: Tween<double>(begin: 0.0, end: 1.0),
                            curve: Curves.easeInOut,
                            builder: (BuildContext context, double value, Widget? child) {
                              return Transform.translate(
                                offset: Offset(0, 20 * (1 - value)),
                                child: Opacity(
                                  opacity: value,
                                  child: SizedBox(
                                    width: 280.w,
                                    child: PasswordStrengthIndicatorPlus(
                                      textController: newPasswordController,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),

                          SizedBox(height: 20.h),

                          _buildAnimatedField(
                            controller: confirmNewPasswordController,
                            focusNode: _confirmPasswordFocus,
                            helpText: 'Confirm New Password',
                            isPasswordField: true,
                            animationDelay: 2,
                          ),

                          // Animated error message
                          if (state.passwordsDoNotMatchError)
                            TweenAnimationBuilder<double>(
                              duration: const Duration(milliseconds: 400),
                              tween: Tween<double>(begin: 0.0, end: 1.0),
                              builder: (BuildContext context, double value, Widget? child) {
                                return Transform.translate(
                                  offset: Offset(0, 10 * (1 - value)),
                                  child: Opacity(
                                    opacity: value,
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        'Passwords do not match.',
                                        style: Font.montserratFont(
                                          color: Colors.red,
                                          fontSize: 12.sp,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),

                          SizedBox(height: 40.h),

                          // Animated save button
                          TweenAnimationBuilder<double>(
                            duration: const Duration(milliseconds: 1200),
                            tween: Tween<double>(begin: 0.0, end: 1.0),
                            curve: Curves.elasticOut,
                            builder: (BuildContext context, double value, Widget? child) {
                              return Transform.scale(
                                scale: value,
                                child: AppButton(
                                  onTap: () {
                                    // Hide any existing snackbar
                                    ScaffoldMessenger.of(context).hideCurrentSnackBar();

                                    final String oldPassword = oldPasswordController.text.trim();
                                    final String newPassword = newPasswordController.text.trim();
                                    final String confirmNewPassword =
                                    confirmNewPasswordController.text.trim();

                                    // Validate empty fields
                                    if (oldPassword.isEmpty ||
                                        newPassword.isEmpty ||
                                        confirmNewPassword.isEmpty) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Please fill all fields'),
                                          backgroundColor: Colors.red,
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                      return;
                                    }

                                    // Validate password match
                                    if (newPassword != confirmNewPassword) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Passwords do not match'),
                                          backgroundColor: Colors.red,
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                      return;
                                    }

                                    // Validate password strength
                                    final PasswordStrength passwordStrength = _checkPasswordStrength(newPassword);
                                    if (passwordStrength != PasswordStrength.strong) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Password must be at least 8 characters, include uppercase, lowercase, digit, and special character.',
                                          ),
                                          backgroundColor: Colors.red,
                                          behavior: SnackBarBehavior.floating,
                                          duration: Duration(seconds: 4),
                                        ),
                                      );
                                      return;
                                    }

                                    // Validate if new password is different from old password
                                    if (oldPassword == newPassword) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'New password must be different from old password',
                                          ),
                                          backgroundColor: Colors.red,
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                      return;
                                    }

                                    // All validations passed, submit the change password request
                                    context.read<ChangePasswordBloc>().add(
                                      SubmitChangePasswordEvent(
                                        oldPassword: oldPassword,
                                        newPassword: newPassword,
                                      ),
                                    );
                                  },
                                  text: 'Save',
                                ),
                              );
                            },
                          ),

                          SizedBox(height: 50.h),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}