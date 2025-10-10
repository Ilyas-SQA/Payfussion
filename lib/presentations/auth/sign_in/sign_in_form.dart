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
import '../../widgets/auth_widgets/auth_button.dart';
import '../../widgets/auth_widgets/credential_text_field.dart';
import '../otp_verification/otp_verification_screen.dart';

class SignInForm extends StatefulWidget {
  const SignInForm({super.key});

  @override
  State<SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isEnableBiometric = false;

  void _handleSignIn() {
    final String email = emailController.text.trim();
    final String password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ErrorDialog.show(context, "Please enter both email and password.");
      return; // Show error or handle accordingly
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
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is TwoFactorVerificationRequired) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => OtpVerificationScreen(),
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
              CredentialsFields(
                controller: emailController,
                isPasswordField: false,
                helpText: "Enter Email",
              ),
              SizedBox(height: 20.h),
              CredentialsFields(
                controller: passwordController,
                isPasswordField: true,
                helpText: "Enter Password",
              ),
              SizedBox(height: 15.h),
              Row(
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
              SizedBox(height: 15.h),
              AppButton(
                text: 'Sign In',
                onTap: _handleSignIn,
              ),
              50.verticalSpace,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                spacing: 10,
                children: <Widget>[
                  const Flexible(child: Divider(color: Colors.grey,)),
                  Text(
                    "OR",
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                  const Flexible(child: Divider(color: Colors.grey,)),
                ],
              ),
              50.verticalSpace,
              AppButton(
                onTap: () {
                  context.read<AuthBloc>().add(LoginWithBiometric());
                },
                text: 'Sign in with Biometric',
                color: MyTheme.secondaryColor,
              ),
              50.verticalSpace,
              RichText(
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
            ],
          ),
        );
      },
    );
  }
}
