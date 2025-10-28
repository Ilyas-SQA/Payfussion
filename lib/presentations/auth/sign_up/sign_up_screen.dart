import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:payfussion/core/constants/routes_name.dart';
import 'package:payfussion/presentations/auth/sign_up/sign_up_header.dart';
import '../../../core/theme/theme.dart';
import '../../../logic/blocs/auth/auth_bloc.dart';
import '../../../logic/blocs/auth/auth_state.dart';
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
    return Scaffold(
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _backgroundAnimationController,
            builder: (BuildContext context, Widget? child) {
              return Stack(
                children: List.generate(8, (int index) {
                  /// Calculate movement path for each circle
                  final double angle = (_backgroundAnimationController.value * 2 * pi) + (index * pi / 4);
                  final double radiusX = 150 + (index * 20);
                  final double radiusY = 200 + (index * 30);

                  final double left = MediaQuery.of(context).size.width / 2 + cos(angle) * radiusX - 125;
                  final double top = MediaQuery.of(context).size.height / 2 + sin(angle) * radiusY - 125;

                  /// Different sizes and colors
                  final double size = 150 + (index * 30) + sin(_backgroundAnimationController.value * 2 * pi) * 20;
                  final Color circleColor = index % 3 == 0 ? MyTheme.primaryColor.withOpacity(0.15) : index % 3 == 1 ? MyTheme.secondaryColor.withOpacity(0.15) : MyTheme.secondaryColor.withOpacity(0.15);

                  return Positioned(
                    left: left,
                    top: top,
                    child: Container(
                      width: size,
                      height: size,
                      decoration: BoxDecoration(
                        color: circleColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: circleColor.withOpacity(0.3),
                            blurRadius: 40,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              );
            },
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