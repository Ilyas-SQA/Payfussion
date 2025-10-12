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

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController controller = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _titleFadeAnimation;
  late Animation<Offset> _titleSlideAnimation;
  late Animation<double> _subtitleFadeAnimation;
  late Animation<Offset> _subtitleSlideAnimation;
  late Animation<double> _emailFieldAnimation;
  late Animation<Offset> _emailFieldSlideAnimation;
  late Animation<double> _buttonAnimation;
  late Animation<double> _backTextAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1600),
      vsync: this,
    );

    // Logo animations
    _logoScaleAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.4, curve: Curves.elasticOut),
      ),
    );

    _logoFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
      ),
    );

    // Title animations
    _titleFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.5, curve: Curves.easeOut),
      ),
    );

    _titleSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.5, curve: Curves.easeOutCubic),
      ),
    );

    // Subtitle animations
    _subtitleFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 0.6, curve: Curves.easeOut),
      ),
    );

    _subtitleSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 0.6, curve: Curves.easeOutCubic),
      ),
    );

    // Email field animations
    _emailFieldAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.4, 0.7, curve: Curves.easeOut),
      ),
    );

    _emailFieldSlideAnimation = Tween<Offset>(
      begin: const Offset(-0.3, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.4, 0.7, curve: Curves.easeOutCubic),
      ),
    );

    // Button animation
    _buttonAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.6, 0.85, curve: Curves.easeOut),
      ),
    );

    // Back text animation
    _backTextAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.75, 1.0, curve: Curves.easeOut),
      ),
    );

    // Start animation
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    controller.dispose();
    super.dispose();
  }

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

              // Animated Logo
              FadeTransition(
                opacity: _logoFadeAnimation,
                child: ScaleTransition(
                  scale: _logoScaleAnimation,
                  child: Hero(
                    tag: 'logo',
                    child: Image.asset(TImageUrl.iconLogo, height: 100.h),
                  ),
                ),
              ),

              20.verticalSpace,

              // Animated Title
              SlideTransition(
                position: _titleSlideAnimation,
                child: FadeTransition(
                  opacity: _titleFadeAnimation,
                  child: Text(
                    'Forgot Password?',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              10.verticalSpace,

              // Animated Subtitle
              SlideTransition(
                position: _subtitleSlideAnimation,
                child: FadeTransition(
                  opacity: _subtitleFadeAnimation,
                  child: Text(
                    "Don't worry! Enter your registered email\nand we'll send you a reset link.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontFamily: 'Inter',
                      color: Colors.grey.shade600,
                      height: 1.5,
                    ),
                  ),
                ),
              ),

              20.verticalSpace,

              // Animated Email Input Field
              SlideTransition(
                position: _emailFieldSlideAnimation,
                child: FadeTransition(
                  opacity: _emailFieldAnimation,
                  child: AppTextormField(
                    controller: controller,
                    isPasswordField: false,
                    helpText: 'Enter your email address',
                  ),
                ),
              ),

              30.verticalSpace,

              // Animated Send Reset Button
              FadeTransition(
                opacity: _buttonAnimation,
                child: ScaleTransition(
                  scale: _buttonAnimation,
                  child: AppButton(
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
                ),
              ),

              30.verticalSpace,

              // Animated Back to Login
              FadeTransition(
                opacity: _backTextAnimation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.5),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: _animationController,
                      curve: const Interval(0.75, 1.0, curve: Curves.easeOut),
                    ),
                  ),
                  child: GestureDetector(
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}