import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:payfussion/core/theme/theme.dart';
import 'package:payfussion/core/widget/appbutton/app_button.dart';
import '../../../core/constants/image_url.dart';
import '../../../core/constants/routes_name.dart';
import '../../../logic/blocs/auth/auth_bloc.dart';
import '../../../logic/blocs/auth/auth_event.dart';
import '../../../logic/blocs/auth/auth_state.dart';
import '../../widgets/auth_widgets/credential_text_field.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (BuildContext context, AuthState state) {
        Navigator.of(context, rootNavigator: true).popUntil((route) => route.isFirst);

        if (state is ForgotFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        } else if (state is ForgotLoading) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const Center(child: CircularProgressIndicator()),
          );
        } else if (state is ForgotSuccess) {
          context.go(RouteNames.signIn);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Check your email for the password reset link"),
            ),
          );
        }
      },
      child: Scaffold(
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 30.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 60.h),
              Hero(
                tag: 'logo',
                child: Image.asset(TImageUrl.iconLogo, height: 100.h),
              ),

              20.verticalSpace,

              Text(
                'Forgot Password?',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),

              10.verticalSpace,

              Text(
                "Don’t worry! Enter your registered email\nand we’ll send you a reset link.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontFamily: 'Inter',
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ),

              20.verticalSpace,

              /// Email Input Field
              CredentialsFields(
                controller: controller,
                isPasswordField: false,
                helpText: 'Enter your email address',
              ),

              30.verticalSpace,

              /// Send Reset Button
              AppButton(
                onTap: () {
                  final String input = controller.text.trim();
                  if (input.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Email cannot be empty"),
                      ),
                    );
                    return;
                  }

                  context.read<AuthBloc>().add(
                    ForgotPasswordWithEmail(email: input),
                  );
                },
                text: 'Send Reset Link',
              ),

              30.verticalSpace,

              /// 🔁 Back to Login
              GestureDetector(
                onTap: () => context.go(RouteNames.signIn),
                child: RichText(
                  text: TextSpan(
                    text: "Remember your password? ",
                    style: TextStyle(
                      fontFamily: 'Inter',
                      color: Colors.grey.shade600,
                      fontSize: 14.sp,
                    ),
                    children: [
                      TextSpan(
                        text: "Sign in",
                        style: TextStyle(
                          color: MyTheme.secondaryColor,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
