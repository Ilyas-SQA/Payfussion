import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:password_strength_indicator_plus/password_strength_indicator_plus.dart';
import 'package:payfussion/core/constants/fonts.dart';
import 'package:payfussion/core/theme/theme.dart';
import 'package:payfussion/core/widget/appbutton/app_button.dart';
import '../../../core/constants/routes_name.dart';
import '../../../core/widget/text_field/phone_textfield.dart';
import '../../../logic/blocs/auth/auth_bloc.dart';
import '../../../logic/blocs/auth/auth_event.dart';
import '../../widgets/auth_widgets/credential_text_field.dart';
import '../../widgets/helper_widgets/error_dialog.dart';

enum PasswordStrength { weak, medium, strong }

const String _emailRegex = r"^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$";
const String _phoneRegex = r'^\+?[0-9]{10,15}$';
const String _passwordError = 'Password must be at least 8 characters, include uppercase, lowercase, digit, and special character.';

class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> with SingleTickerProviderStateMixin {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  late AnimationController _controller;
  late List<Animation<double>> _fadeAnimations;
  late List<Animation<Offset>> _slideAnimations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimations = List.generate(9, (index) {
      final double start = 0.1 + (index * 0.08);
      final double end = start + 0.15;
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(start, end, curve: Curves.easeOut),
        ),
      );
    });

    _slideAnimations = List.generate(9, (index) {
      final double start = 0.1 + (index * 0.08);
      final double end = start + 0.15;
      return Tween<Offset>(
        begin: const Offset(0, 0.3),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(start, end, curve: Curves.easeOut),
        ),
      );
    });

    _controller.forward();
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneNumberController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    _controller.dispose();
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

  void _showError(String message) => ErrorDialog.show(context, message);

  void _handleSignUp() {
    if (!_formKey.currentState!.validate()) {
      return; // Stop if form is invalid
    }

    final String firstName = firstNameController.text.trim();
    final String lastName = lastNameController.text.trim();
    final String email = emailController.text.trim();
    final String phone = phoneNumberController.text.trim();
    final String password = passwordController.text;
    final String confirmPassword = confirmPasswordController.text;

    if (password != confirmPassword) {
      _showError('Passwords do not match.');
      return;
    }

    context.read<AuthBloc>().add(
      SignUpRequested(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phoneNumber: phone,
        password: password,
      ),
    );
  }

  Widget _buildAnimatedField(int index, Widget child) {
    return SlideTransition(
      position: _slideAnimations[index],
      child: FadeTransition(
        opacity: _fadeAnimations[index],
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildAnimatedField(
              0,
              AppTextFormField(
                controller: firstNameController,
                helpText: "First Name",
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'First name is required';
                  }
                  return null;
                },
              ),
            ),
            SizedBox(height: 20.h),
            _buildAnimatedField(
              1,
              AppTextFormField(
                controller: lastNameController,
                helpText: "Last Name",
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Last name is required';
                  }
                  return null;
                },
              ),
            ),
            SizedBox(height: 20.h),
            _buildAnimatedField(
              2,
              AppTextFormField(
                controller: emailController,
                helpText: "Enter Your Email",
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email is required';
                  }
                  final emailRegex = RegExp(_emailRegex);
                  if (!emailRegex.hasMatch(value)) {
                    return 'Enter a valid email';
                  }
                  return null;
                },
              ),
            ),
            SizedBox(height: 20.h),
            _buildAnimatedField(
              3,
              PhoneCredentialsField(
                controller: phoneNumberController,
                helpText: "Enter Your Phone No",
                validator: (PhoneNumber? value) {
                  if (value == null || value.completeNumber.isEmpty) {
                    return 'Phone number is required';
                  }

                  // Validate the phone number format using regex
                  final RegExp phoneRegex = RegExp(_phoneRegex);
                  if (!phoneRegex.hasMatch(value.completeNumber)) {
                    return 'Enter a valid phone number';
                  }

                  return null;  // Return null if validation passes
                },
              ),
            ),


            SizedBox(height: 20.h),
            _buildAnimatedField(
              4,
              AppTextFormField(
                controller: passwordController,
                isPasswordField: true,
                helpText: "Enter Password",
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password is required';
                  }
                  if (value.length < 8) {
                    return 'Password must be at least 8 characters';
                  }
                  return null;
                },
              ),
            ),
            SizedBox(height: 20.h),
            _buildAnimatedField(
              5,
              AppTextFormField(
                controller: confirmPasswordController,
                isPasswordField: true,
                helpText: "Confirm Password",
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Confirm password is required';
                  }
                  if (value != passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
            ),
            SizedBox(height: 34.h),
            _buildAnimatedField(
              6,
              AppButton(
                onTap: _handleSignUp,
                text: 'Sign Up',
              ),
            ),
            SizedBox(height: 24.h),
            _buildAnimatedField(
              7,
              RichText(
                text: TextSpan(
                  text: 'Already have an account? ',
                  style: Font.montserratFont(
                    fontSize: 14.sp,
                    color: Theme.brightnessOf(context) == Brightness.light ? Colors.black : Colors.white,
                  ),
                  children: [
                    TextSpan(
                      text: ' Sign In.',
                      recognizer: TapGestureRecognizer()
                        ..onTap = () => context.go(RouteNames.signIn),
                      style: Font.montserratFont(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: Theme.brightnessOf(context) == Brightness.light ? Colors.black : Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 50.h),
          ],
        ),
      ),
    );
  }
}
