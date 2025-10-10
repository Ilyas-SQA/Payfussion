import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../logic/blocs/calculator/calculator_bloc.dart';
import '../../../logic/blocs/calculator/calculator_event.dart';

class ConvertButton extends StatelessWidget {
  final String label;
  final bool isColored, canBeFirst;

  const ConvertButton(
      this.label, {
        this.isColored = false,
        this.canBeFirst = true,
        super.key,
      });

  Color _getButtonColor(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    if (label == 'C') {
      return Colors.red;
    } else if (isColored) {
      return const Color(0xff316BFF);
    } else {
      return isDarkMode ? Colors.white : Colors.black87;
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle? textStyle = Theme.of(context).textTheme.bodyLarge;
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Return empty container for empty labels
    if (label.isEmpty) {
      return const SizedBox.shrink();
    }

    return InkWell(
      onTap: () {
        context.read<CalculatorBloc>().add(
          AddToEquationEvent(label, canBeFirst, context),
        );
      },
      borderRadius: BorderRadius.circular(12.r),
      splashColor: (isColored ? const Color(0xff316BFF) : Colors.grey).withOpacity(0.2),
      highlightColor: (isColored ? const Color(0xff316BFF) : Colors.grey).withOpacity(0.1),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          color: isDarkMode
              ? Colors.grey[900]?.withOpacity(0.3)
              : Colors.grey[200]?.withOpacity(0.5),
        ),
        child: Center(
          child: Text(
            label,
            style: textStyle?.copyWith(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: _getButtonColor(context),
            ),
          ),
        ),
      ),
    );
  }
}