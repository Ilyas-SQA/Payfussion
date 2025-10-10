import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomFadeTransitionPage extends CustomTransitionPage<void> {
  CustomFadeTransitionPage({
    required LocalKey super.key,
    required super.child,
  }) : super(
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: child,
      );
    },
  );
}