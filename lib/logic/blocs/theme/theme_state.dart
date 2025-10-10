import 'package:flutter/material.dart';

abstract class ThemeState {
  ThemeMode get themeMode;
}

class ThemeInitialState extends ThemeState {
  @override
  ThemeMode get themeMode => ThemeMode.light;
}

class ThemeLoadingState extends ThemeState {
  @override
  ThemeMode get themeMode => ThemeMode.light;
}

class ThemeUpdatedState extends ThemeState {
  final ThemeMode mode;
  ThemeUpdatedState(this.mode);

  @override
  ThemeMode get themeMode => mode;
}

class ThemeErrorState extends ThemeState {
  final String message;
  ThemeErrorState(this.message);

  @override
  ThemeMode get themeMode => ThemeMode.light;
}
