import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../logic/blocs/calculator/calculator_bloc.dart';
import '../../../logic/blocs/calculator/calculator_event.dart';

class CalculatorButton extends StatelessWidget {
  final String label;
  final bool isColored, isEqualSign, canBeFirst;

  const CalculatorButton(
    this.label, {
    this.isColored = false,
    this.isEqualSign = false,
    this.canBeFirst = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final TextStyle? textStyle = Theme.of(context).textTheme.bodyLarge;

    return InkWell(
      onTap: () {
        context.read<CalculatorBloc>().add(
          AddToEquationEvent(label, canBeFirst, context),
        );
      },
      child: Center(
        child: Text(
          label,
          style: textStyle?.copyWith(
            fontSize: isColored ? 25.sp : 20.sp,
            fontWeight: FontWeight.bold,

            color: label == 'C'
                ? Colors.red
                : isColored
                ? const Color(0xff316BFF)
                : Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white,
          ),
        ),
      ),
    );
  }
}
