import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:payfussion/logic/blocs/auth/auth_bloc.dart';
import 'package:payfussion/logic/blocs/auth/auth_state.dart';
import 'package:payfussion/presentations/auth/sign_in/sign_in_form.dart';
import 'package:payfussion/shared/widgets/error_dialog.dart';
import '../../../core/constants/routes_name.dart';
import '../../../services/biometric_service.dart';
import '../../../services/service_locator.dart';
import 'sign_in_header.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  late final BiometricService biometricService;
  late final AuthBloc authBloc;

  @override
  void initState() {
    super.initState();
    biometricService = getIt<BiometricService>();
    authBloc = BlocProvider.of<AuthBloc>(context, listen: false);
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
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SignInHeader(),
            SignInForm(),
          ],
        ),
      ),
    );
  }
}
