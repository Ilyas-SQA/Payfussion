import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:payfussion/logic/blocs/theme/theme_event.dart';
import 'package:payfussion/logic/blocs/theme/theme_state.dart';

import '../../../services/local_storage.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final LocalStorage localStorage;

  ThemeBloc({required this.localStorage}) : super(ThemeInitialState()) {
    on<ToggleThemeEvent>(_onToggleTheme);
    on<LoadThemeEvent>(_onLoadTheme);

    // Load theme when BLoC is created
    add(LoadThemeEvent());
  }

  Future<void> _onToggleTheme(
      ToggleThemeEvent event,
      Emitter<ThemeState> emit,
      ) async {
    emit(ThemeLoadingState());
    try {
      final String? themeValue = await localStorage.readValue("theme_mode");
      bool isDarkTheme = themeValue == "dark";
      isDarkTheme = !isDarkTheme;
      await localStorage.setValue("theme_mode", isDarkTheme ? "dark" : "light");
      emit(ThemeUpdatedState(isDarkTheme ? ThemeMode.dark : ThemeMode.light));
    } catch (e) {
      emit(ThemeErrorState("Failed to toggle theme"));
    }
  }

  Future<void> _onLoadTheme(
      LoadThemeEvent event,
      Emitter<ThemeState> emit,
      ) async {
    try {
      final String? themeValue = await localStorage.readValue("theme_mode");
      if (themeValue != null) {
        final bool isDarkTheme = themeValue == "dark";
        emit(ThemeUpdatedState(isDarkTheme ? ThemeMode.dark : ThemeMode.light));
      } else {
        // First time - default to light and save it
        await localStorage.setValue("theme_mode", "light");
        emit(ThemeUpdatedState(ThemeMode.light));
      }
    } catch (e) {
      // If error occurs, default to light mode and try to save it
      try {
        await localStorage.setValue("theme_mode", "light");
      } catch (_) {}
      emit(ThemeUpdatedState(ThemeMode.light));
    }
  }
}