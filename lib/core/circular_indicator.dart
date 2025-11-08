import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:payfussion/core/theme/theme.dart';

class CircularIndicator{
  static final SpinKitFadingCircle circular = const SpinKitFadingCircle(
    color:  MyTheme.primaryColor,
    size: 50.0,
  );

  static final SpinKitFadingCircle circularWhite = const SpinKitFadingCircle(
    color:  Colors.white,
    size: 50.0,
  );
}