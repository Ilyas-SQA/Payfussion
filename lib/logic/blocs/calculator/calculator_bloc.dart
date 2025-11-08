import 'package:bloc/bloc.dart';
import 'package:math_expressions/math_expressions.dart';

import '../../../data/models/calculator/historyitem.dart';
import '../../../services/hive_service.dart';
import '../../../services/service_locator.dart';
import 'calculator_event.dart';
import 'calculator_state.dart';

class CalculatorBloc extends Bloc<CalculatorEvent, CalculatorState> {
  final HiveService hiveService = getIt<HiveService>();
  final Map<String, Map<String, double>> conversionRates = <String, Map<String, double>>{
    'USD': <String, double>{
      'INR': 75.0, // Example rate: 1 USD = 75 INR
      'EUR': 0.85, // Example rate: 1 USD = 0.85 EUR
      'GBP': 0.75, // Example rate: 1 USD = 0.75 GBP
    },
    'EUR': <String, double>{'INR': 88.0, 'USD': 1.18, 'GBP': 0.88},
    'INR': <String, double>{'USD': 0.013, 'EUR': 0.012, 'GBP': 0.010},
    'GBP': <String, double>{'USD': 1.33, 'EUR': 1.14, 'INR': 100.0},
  };
  CalculatorBloc()
    : super(
        CalculatorState(
          equation: '',
          result: '',
          sourceCurrency: 'USD',
          targetCurrency: 'INR',
          conversionResult: 0.0,
          amount: 0.0,
          inputDisplay: '0',
        ),
      ) {
    on<AddToEquationEvent>(_onAddToEquation);
    on<SourceCurrencyChanged>(_onSourceCurrencyChanged);
    on<TargetCurrencyChanged>(_onTargetCurrencyChanged);

    on<EnterAmount>(_onInputAmount);

    on<ClearConversionEvent>(_clearConversion);
  }

  void _onAddToEquation(
    AddToEquationEvent event,
    Emitter<CalculatorState> emit,
  ) async {
    String equation = state.equation;
    String result = state.result;
    final String sign = event.sign.trim(); // Remove extra spaces
    final bool canFirst = event.canFirst;

    if (equation == '') {
      // Handle empty equation
      if (sign == '.') {
        equation = '0.'; // Start with decimal if first input is '.'
      } else if (canFirst) {
        equation = sign; // Set first value of the equation
      }
    } else {
      if (sign == "C") {
        // Clear the equation and result when 'C' is pressed
        equation = '';
        result = '';
      } else if (sign == "⌫") {
        // Handle backspace (⌫)
        if (equation.isEmpty) {
          // If equation is empty but result exists, clear result
          if (result.isNotEmpty) {
            result = '';
          }
          return;
        } else if (equation.endsWith(' ')) {
          // Remove operator (3 characters: " + ")
          equation = equation.substring(0, equation.length - 3);
          result = '';
        } else {
          // Remove single character
          equation = equation.substring(0, equation.length - 1);
        }
      } else if (sign == "=") {
        // Calculate result when '=' is pressed
        if (equation.isEmpty) {
          return; // Don't calculate if equation is empty
        }

        try {
          String cleanEquation = equation.trim();

          // Remove trailing operators
          while (cleanEquation.endsWith(' +') ||
              cleanEquation.endsWith(' -') ||
              cleanEquation.endsWith(' ×') ||
              cleanEquation.endsWith(' ÷') ||
              cleanEquation.endsWith('+') ||
              cleanEquation.endsWith('-') ||
              cleanEquation.endsWith('×') ||
              cleanEquation.endsWith('÷')) {
            cleanEquation = cleanEquation
                .substring(0, cleanEquation.length - 2)
                .trim();
          }

          if (cleanEquation.isEmpty) {
            return; // Don't calculate if nothing left
          }

          final String privateResult = cleanEquation
              .replaceAll('÷', '/')
              .replaceAll('×', '*');

          final ShuntingYardParser parser = ShuntingYardParser();
          final Expression exp = parser.parse(privateResult);
          final RealEvaluator evaluator = RealEvaluator();
          final num evalResult = evaluator.evaluate(exp);

          // Check for invalid results
          if (evalResult.isNaN || evalResult.isInfinite) {
            result = 'Error';
          } else {
            // Format the result properly
            if (evalResult == evalResult.roundToDouble()) {
              result = evalResult.round().toString();
            } else {
              result = evalResult.toString();
              // Limit decimal places to avoid very long numbers
              if (result.contains('.') && result.split('.')[1].length > 8) {
                result = evalResult.toStringAsFixed(8);
                // Remove trailing zeros
                result = result
                    .replaceAll(RegExp(r'0*$'), '')
                    .replaceAll(RegExp(r'\.$'), '');
              }
            }

            // Save to history if result is valid (not 'Error')
            if (result != 'Error' && cleanEquation.isNotEmpty) {
              await _saveToHistory(cleanEquation, result);
            }
          }
        } catch (e) {
          result = 'Error'; // Handle errors during evaluation
        }
        // Clear equation after result is calculated
        equation = ''; // Equation is cleared after result
      } else {
        // Handle different input types
        if (_isOperator(sign)) {
          _handleOperator(sign, equation, result, emit);
          return;
        } else if (_isNumber(sign)) {
          _handleNumber(sign, equation, result, emit);
          return;
        } else if (sign == '.') {
          _handleDecimal(equation, result, emit);
          return;
        }
      }
    }

    double conversionResult = state.conversionResult;
    if (state.sourceCurrency.isNotEmpty &&
        state.targetCurrency.isNotEmpty &&
        result.isNotEmpty) {
      conversionResult = _convertCurrency(
        result,
        state.sourceCurrency,
        state.targetCurrency,
      );
    }

    // Emit the updated state with the current equation and result
    emit(
      CalculatorState(
        equation: equation,
        result: result,
        sourceCurrency: state.sourceCurrency,
        targetCurrency: state.targetCurrency,
        conversionResult: conversionResult,
        amount: state.amount,
      ),
    );
  }

  bool _isOperator(String sign) {
    return sign == '+' || sign == '-' || sign == '×' || sign == '÷';
  }

  bool _isNumber(String sign) {
    return RegExp(r'^[0-9]+$').hasMatch(sign);
  }

  void _handleOperator(
    String sign,
    String equation,
    String result,
    Emitter<CalculatorState> emit,
  ) {
    // If we have a result from previous calculation, start with that
    if (result.isNotEmpty && result != 'Error' && equation.isEmpty) {
      equation = '$result $sign ';
      result = ''; // Clear result since we're starting a new calculation
    } else if (equation.isEmpty) {
      // Can't start with operator (except - for negative numbers)
      if (sign == '-') {
        equation = '-';
      }
      // For other operators, do nothing
    } else if (equation.endsWith(' ')) {
      // Replace the last operator with the new one
      equation = '${equation.substring(0, equation.length - 3)} $sign ';
    } else {
      // Add operator after number
      equation = '$equation $sign ';
    }

    emit(
      CalculatorState(
        equation: equation,
        result: result,
        sourceCurrency: state.sourceCurrency,
        targetCurrency: state.targetCurrency,
        conversionResult: state.conversionResult,
        amount: state.amount,
      ),
    );
  }

  void _handleNumber(
    String sign,
    String equation,
    String result,
    Emitter<CalculatorState> emit,
  ) {
    // If we just calculated a result, start fresh with new number
    if (result.isNotEmpty && result != 'Error' && equation.isEmpty) {
      equation = sign;
      result = ''; // Clear result since we're starting new calculation
    } else {
      // Add number to equation
      equation = equation + sign;
    }

    emit(
      CalculatorState(
        equation: equation,
        result: result,
        sourceCurrency: state.sourceCurrency,
        targetCurrency: state.targetCurrency,
        conversionResult: state.conversionResult,
        amount: state.amount,
      ),
    );
  }

  void _handleDecimal(
    String equation,
    String result,
    Emitter<CalculatorState> emit,
  ) {
    // If we just calculated a result, start fresh with decimal
    if (result.isNotEmpty && result != 'Error' && equation.isEmpty) {
      equation = '0.';
      result = ''; // Clear result since we're starting new calculation
    } else {
      // Prevent multiple decimal points in same number
      if (equation.contains('.')) {
        return;
      }
      equation = '$equation.';
    }

    emit(
      CalculatorState(
        equation: equation,
        result: result,
        sourceCurrency: state.sourceCurrency,
        targetCurrency: state.targetCurrency,
        conversionResult: state.conversionResult,
        amount: state.amount,
      ),
    );
  }

  double _convertCurrency(
    String result,
    String sourceCurrency,
    String targetCurrency,
  ) {
    final double value = double.tryParse(result) ?? 0.0;
    if (value == 0.0) return 0.0;

    final double conversionRate =
        conversionRates[sourceCurrency]?[targetCurrency] ?? 1.0;
    return value * conversionRate;
  }

  void _onSourceCurrencyChanged(
    SourceCurrencyChanged event,
    Emitter<CalculatorState> emit,
  ) {
    final double conversionResult = _convertCurrency(
      state.inputDisplay,
      event.currency,
      state.targetCurrency,
    );
    emit(
      state.copyWith(
        sourceCurrency: event.currency,
        conversionResult: conversionResult,
      ),
    );
  }

  // Handle currency target selection
  void _onTargetCurrencyChanged(
    TargetCurrencyChanged event,
    Emitter<CalculatorState> emit,
  ) {
    final double conversionResult = _convertCurrency(
      state.inputDisplay,
      state.sourceCurrency,
      event.currency,
    );
    emit(
      state.copyWith(
        targetCurrency: event.currency,
        conversionResult: conversionResult,
      ),
    );
  }

  void _onInputAmount(EnterAmount event, Emitter<CalculatorState> emit) {
    String newInput = state.inputDisplay;

    // Handle special inputs first
    if (event.amount == 'C') {
      // Clear everything
      emit(
        state.copyWith(inputDisplay: '0', amount: 0.0, conversionResult: 0.0),
      );
      return;
    }

    if (event.amount == '⌫') {
      // Backspace
      if (newInput.length > 1) {
        newInput = newInput.substring(0, newInput.length - 1);
      } else {
        newInput = '0';
      }
    } else if (event.amount == '.') {
      // Handle decimal point
      if (!newInput.contains('.')) {
        if (newInput == '0') {
          newInput = '0.';
        } else {
          newInput = newInput + '.';
        }
      }
    } else {
      // Handle digit input
      if (newInput == '0') {
        // Replace leading zero with the new digit
        newInput = event.amount;
      } else {
        // Append the digit
        newInput = newInput + event.amount;
      }
    }

    // Parse the amount and perform conversion
    final double? amount = double.tryParse(newInput);
    if (amount != null) {
      final double conversionResult = _convertCurrency(
        newInput,
        state.sourceCurrency,
        state.targetCurrency,
      );

      emit(
        state.copyWith(
          inputDisplay: newInput,
          amount: amount,
          conversionResult: conversionResult,
        ),
      );
    } else {
      // If parsing fails, just update the display
      emit(state.copyWith(inputDisplay: newInput));
    }
  }

  void _clearConversion(
    ClearConversionEvent event,
    Emitter<CalculatorState> emit,
  ) {
    emit(
      CalculatorState(
        equation: '',
        result: '',
        sourceCurrency: 'USD',
        targetCurrency: 'INR',
        conversionResult: 0.0,
        amount: 0.0,
        inputDisplay: '0',
      ),
    );
  }

  Future<void> _saveToHistory(String equation, String result) async {
    try {
      final HistoryItem historyItem = HistoryItem(
        title: result,
        subtitle: equation,
        timestamp: DateTime.now(),
      );
      await hiveService.addHistoryItem(historyItem);
      print('Successfully saved to history: $equation = $result'); // Debug log
    } catch (e) {
      // Handle error silently or log it
      print('Error saving to history: $e');
    }
  }

  // Add helper methods for accessing history
  List<HistoryItem> getHistory() {
    return hiveService.getAllHistory();
  }

  Future<void> clearHistory() async {
    await hiveService.clearHistory();
  }

  Future<void> deleteHistoryItem(int index) async {
    await hiveService.deleteHistoryItem(index);
  }

  int getHistoryCount() {
    return hiveService.getAllHistory().length;
  }
}
