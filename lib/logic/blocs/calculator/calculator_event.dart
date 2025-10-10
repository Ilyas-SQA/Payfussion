import 'package:flutter/material.dart';

abstract class CalculatorEvent {}

class AddToEquationEvent extends CalculatorEvent {
  final String sign;
  final bool canFirst;
  final BuildContext context;

  AddToEquationEvent(this.sign, this.canFirst, this.context);
}

class EnterAmount extends CalculatorEvent {
  final String amount;
  EnterAmount({required this.amount});
}

class SourceCurrencyChanged extends CalculatorEvent {
  final String currency;
  SourceCurrencyChanged({required this.currency});
}

class TargetCurrencyChanged extends CalculatorEvent {
  final String currency;
  TargetCurrencyChanged({required this.currency});
}

class ClearConversionEvent extends CalculatorEvent {
  ClearConversionEvent();
}
