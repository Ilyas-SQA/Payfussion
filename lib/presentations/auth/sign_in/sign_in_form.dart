import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:payfussion/core/theme/theme.dart';
import 'package:payfussion/core/widget/appbutton/app_button.dart';
import 'package:payfussion/shared/widgets/error_dialog.dart';
import '../../../../../logic/blocs/auth/auth_bloc.dart';
import '../../../../../logic/blocs/auth/auth_event.dart';
import '../../../logic/blocs/auth/auth_state.dart';
import '../../widgets/auth_widgets/credential_text_field.dart';
import '../otp_verification/otp_verification_screen.dart';

class SignInForm extends StatefulWidget {
  const SignInForm({super.key});

  @override
  State<SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm>
    with SingleTickerProviderStateMixin {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isEnableBiometric = false;

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _emailFieldAnimation;
  late Animation<double> _passwordFieldAnimation;
  late Animation<double> _buttonAnimation;
  late Animation<double> _dividerAnimation;
  late Animation<double> _biometricButtonAnimation;
  late Animation<double> _signupTextAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );

    // Email field animation
    _emailFieldAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );

    // Password field animation
    _passwordFieldAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.15, 0.45, curve: Curves.easeOut),
      ),
    );

    // Sign in button animation
    _buttonAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.6, curve: Curves.easeOut),
      ),
    );

    // Divider animation
    _dividerAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.45, 0.7, curve: Curves.easeOut),
      ),
    );

    // Biometric button animation
    _biometricButtonAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 0.85, curve: Curves.easeOut),
      ),
    );

    // Signup text animation
    _signupTextAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    // Start animation after a short delay
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  void _handleSignIn() {
    final String email = emailController.text.trim();
    final String password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ErrorDialog.show(context, "Please enter both email and password.");
      return;
    }

    context.read<AuthBloc>().add(
      SignInRequested(
        email: email,
        password: password,
        enableBiometric: _isEnableBiometric,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (BuildContext context, AuthState state) {
        if (state is TwoFactorVerificationRequired) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => const OtpVerificationScreen(),
            ),
          );
        } else if (state is SignInSuccess) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      },
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: <Widget>[
              // Email Field with Animation
              FadeTransition(
                opacity: _emailFieldAnimation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(-0.3, 0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: _controller,
                      curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
                    ),
                  ),
                  child: AppTextormField(
                    controller: emailController,
                    isPasswordField: false,
                    helpText: "Enter Email",
                  ),
                ),
              ),

              SizedBox(height: 20.h),

              // Password Field with Animation
              FadeTransition(
                opacity: _passwordFieldAnimation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(-0.3, 0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: _controller,
                      curve: const Interval(0.15, 0.45, curve: Curves.easeOut),
                    ),
                  ),
                  child: AppTextormField(
                    controller: passwordController,
                    isPasswordField: true,
                    helpText: "Enter Password",
                  ),
                ),
              ),

              SizedBox(height: 15.h),

              // Forget Password with Animation
              FadeTransition(
                opacity: _passwordFieldAnimation,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size(50.w, 30.h),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        alignment: Alignment.centerLeft,
                      ),
                      onPressed: () => context.push('/forgetPassword'),
                      child: Text(
                        "Forget Password?",
                        style: TextStyle(
                          color: MyTheme.secondaryColor,
                          fontFamily: 'Roboto',
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 15.h),

              // Sign In Button with Animation
              FadeTransition(
                opacity: _buttonAnimation,
                child: ScaleTransition(
                  scale: _buttonAnimation,
                  child: AppButton(
                    text: 'Sign In',
                    onTap: _handleSignIn,
                  ),
                ),
              ),

              50.verticalSpace,

              // Divider with Animation
              FadeTransition(
                opacity: _dividerAnimation,
                child: ScaleTransition(
                  scale: _dividerAnimation,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    spacing: 10,
                    children: <Widget>[
                      const Flexible(child: Divider(color: Colors.grey)),
                      Text(
                        "OR",
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                        ),
                      ),
                      const Flexible(child: Divider(color: Colors.grey)),
                    ],
                  ),
                ),
              ),

              50.verticalSpace,

              // Biometric Button with Animation
              FadeTransition(
                opacity: _biometricButtonAnimation,
                child: ScaleTransition(
                  scale: _biometricButtonAnimation,
                  child: AppButton(
                    onTap: () {
                      context.read<AuthBloc>().add(LoginWithBiometric());
                    },
                    text: 'Sign in with Biometric',
                    color: MyTheme.secondaryColor,
                  ),
                ),
              ),

              50.verticalSpace,

              // Signup Text with Animation
              FadeTransition(
                opacity: _signupTextAnimation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.3),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: _controller,
                      curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
                    ),
                  ),
                  child: RichText(
                    text: TextSpan(
                      text: 'Don\'t have an account? ',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        color: theme.secondaryHeaderColor,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.normal,
                      ),
                      children: <InlineSpan>[
                        TextSpan(
                          text: ' Create Account.',
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => context.push('/signUp'),
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 14.sp,
                            color: MyTheme.secondaryColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}