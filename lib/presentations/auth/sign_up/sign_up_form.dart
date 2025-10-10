import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:password_strength_indicator_plus/password_strength_indicator_plus.dart';
import 'package:payfussion/core/theme/theme.dart';
import 'package:payfussion/core/widget/appbutton/app_button.dart';

import '../../../core/constants/routes_name.dart';
import '../../../core/widget/text_field/phone_textfield.dart';
import '../../../logic/blocs/auth/auth_bloc.dart';
import '../../../logic/blocs/auth/auth_event.dart';
import '../../widgets/auth_widgets/auth_button.dart';
import '../../widgets/auth_widgets/credential_text_field.dart';
import '../../widgets/helper_widgets/error_dialog.dart';

enum PasswordStrength { weak, medium, strong }

const _emailRegex = r"^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$";
const _phoneRegex = r'^\+?[0-9]{10,15}$';
const _passwordError =
    'Password must be at least 8 characters, include uppercase, lowercase, digit, and special character.';

class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneNumberController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  PasswordStrength _checkPasswordStrength(String password) {
    final hasUppercase = password.contains(RegExp(r'[A-Z]'));
    final hasLowercase = password.contains(RegExp(r'[a-z]'));
    final hasDigit = password.contains(RegExp(r'\d'));
    final hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    final hasMinLength = password.length >= 8;

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
    final firstName = firstNameController.text.trim();
    final lastName = lastNameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneNumberController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if ([
      firstName,
      lastName,
      email,
      phone,
      password,
      confirmPassword,
    ].any((v) => v.isEmpty)) {
      _showError("All fields are required.");
      return;
    }

    if (!RegExp(_emailRegex).hasMatch(email)) {
      _showError("Please enter a valid email address.");
      return;
    }

    if (!RegExp(_phoneRegex).hasMatch(phone)) {
      _showError("Enter a valid phone number with country code if needed.");
      return;
    }

    if (_checkPasswordStrength(password) != PasswordStrength.strong) {
      _showError(_passwordError);
      return;
    }

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


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          CredentialsFields(
            controller: firstNameController,
            isPasswordField: false,
            helpText: "First Name",
          ),
          SizedBox(height: 20.h),
          CredentialsFields(
            controller: lastNameController,
            isPasswordField: false,
            helpText: "Last Name",
          ),
          SizedBox(height: 20.h),
          CredentialsFields(
            controller: emailController,
            isPasswordField: false,
            helpText: "Enter Your Email",
          ),
          SizedBox(height: 20.h),
          PhoneCredentialsField(
            controller: phoneNumberController,
            helpText: "Enter Your Phone No",
          ),
          SizedBox(height: 20.h),
          CredentialsFields(
            controller: passwordController,
            isPasswordField: true,
            helpText: "Enter Password",
          ),
          PasswordStrengthIndicatorPlus(
            textController: passwordController,
          ),
          SizedBox(height: 20.h),
          CredentialsFields(
            controller: confirmPasswordController,
            isPasswordField: true,
            helpText: "Confirm Password",
          ),
          SizedBox(height: 34.h),
          AppButton(
            onTap: _handleSignUp,
            text: 'Sign Up',
          ),
          SizedBox(height: 24.h),
          RichText(
            text: TextSpan(
              text: 'Already have an account? ',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 14.sp,
                color: theme.secondaryHeaderColor,
              ),
              children: [
                TextSpan(
                  text: ' Sign In.',
                  recognizer: TapGestureRecognizer()
                    ..onTap = () => context.go(RouteNames.signIn),
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
          SizedBox(height: 50.h),
        ],
      ),
    );
  }
}
