class CalculatorState {
  final String equation;
  final String result;
  final String sourceCurrency;
  final String targetCurrency;
  final double conversionResult;
  final double amount;
  final String inputDisplay; // For displaying the current input being built

  CalculatorState({
    required this.sourceCurrency,
    required this.targetCurrency,
    this.conversionResult = 0.0,
    required this.equation,
    required this.result,
    required this.amount,
    this.inputDisplay = '0',
  });

  CalculatorState copyWith({
    String? sourceCurrency,
    String? targetCurrency,
    double? conversionResult,
    String? equation,
    String? result,
    double? amount,
    String? inputDisplay,
  }) {
    return CalculatorState(
      sourceCurrency: sourceCurrency ?? this.sourceCurrency,
      targetCurrency: targetCurrency ?? this.targetCurrency,
      conversionResult: conversionResult ?? this.conversionResult,
      equation: equation ?? this.equation,
      result: result ?? this.result,
      amount: amount ?? this.amount,
      inputDisplay: inputDisplay ?? this.inputDisplay,
    );
  }
}
