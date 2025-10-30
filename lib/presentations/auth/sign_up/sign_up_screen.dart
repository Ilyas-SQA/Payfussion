import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:payfussion/core/constants/routes_name.dart';
import 'package:payfussion/presentations/auth/sign_up/sign_up_header.dart';
import '../../../core/theme/theme.dart';
import '../../../logic/blocs/auth/auth_bloc.dart';
import '../../../logic/blocs/auth/auth_state.dart';
import '../../widgets/background_theme.dart';
import '../../widgets/helper_widgets/error_dialog.dart';
import 'sign_up_form.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> with TickerProviderStateMixin{
  late AnimationController _backgroundAnimationController;

  @override
  void initState() {
    super.initState();
    _backgroundAnimationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _backgroundAnimationController.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: Stack(
        children: [
          AnimatedBackground(
            animationController: _backgroundAnimationController,
          ),

          SingleChildScrollView(
            child: BlocListener<AuthBloc, AuthState>(
              listener: (BuildContext context, AuthState state) {
                // Always dismiss any existing dialog first
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }

                if (state is AuthLoading) {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => const Center(child: CircularProgressIndicator())
                  );
                } else if (state is SignUpSuccess) {
                  context.go(RouteNames.signIn);
                } else if (state is AuthStateFailure) {
                  ErrorDialog.show(context, state.message);
                }
              },
              child: const Center(
                child: Column(
                  children: <Widget>[
                    SignUpHeader(),
                    SignUpForm(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}