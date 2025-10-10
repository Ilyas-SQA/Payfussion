import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:payfussion/core/constants/routes_name.dart';
import 'package:payfussion/presentations/auth/sign_up/sign_up_header.dart';

import '../../../logic/blocs/auth/auth_bloc.dart';
import '../../../logic/blocs/auth/auth_state.dart';
import '../../widgets/helper_widgets/error_dialog.dart';
import 'sign_up_form.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
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
    );
  }
}