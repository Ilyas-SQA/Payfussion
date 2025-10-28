import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:payfussion/logic/blocs/auth/auth_bloc.dart';
import 'package:payfussion/logic/blocs/auth/auth_state.dart';
import 'package:payfussion/presentations/auth/sign_in/sign_in_form.dart';
import 'package:payfussion/shared/widgets/error_dialog.dart';
import '../../../core/constants/routes_name.dart';
import '../../../core/theme/theme.dart';
import '../../../services/biometric_service.dart';
import '../../../services/service_locator.dart';
import 'sign_in_header.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> with TickerProviderStateMixin {
  late final BiometricService biometricService;
  late final AuthBloc authBloc;
  late AnimationController _backgroundAnimationController;

  @override
  void initState() {
    super.initState();
    biometricService = getIt<BiometricService>();
    authBloc = BlocProvider.of<AuthBloc>(context, listen: false);
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
      resizeToAvoidBottomInset: false,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (BuildContext context, AuthState state) {
          if (state is AuthLoading) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => const Center(child: CircularProgressIndicator()),
            );
          } else if (state is SignInSuccess || state is BiometricAuthSuccess) {
            Navigator.of(context).pop();
            context.pushReplacement(RouteNames.homeScreen);
          } else if (state is AuthStateFailure || state is BiometricAuthFailure) {
            Navigator.of(context).pop();
            final String message = state is AuthStateFailure ? state.message : (state as BiometricAuthFailure).message;
            ErrorDialog.show(context, message);
          }
        },
        child: Stack(
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
            const Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SignInHeader(),
                SignInForm(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
