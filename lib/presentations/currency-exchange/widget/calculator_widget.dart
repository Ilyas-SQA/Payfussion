import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:payfussion/presentations/currency-exchange/widget/calculator_button.dart';

import '../../../core/constants/routes_name.dart';
import '../../../logic/blocs/calculator/calculator_bloc.dart';
import '../../../logic/blocs/calculator/calculator_state.dart';

List<CalculatorButton> calculateButton = const <CalculatorButton>[
  CalculatorButton('C', canBeFirst: false, isColored: true),
  CalculatorButton('⌫', canBeFirst: false, isColored: true),
  CalculatorButton('.', canBeFirst: false, isColored: true),
  CalculatorButton('÷', isColored: true, canBeFirst: false),
  CalculatorButton('7',isEqualSign: true),
  CalculatorButton('8'),
  CalculatorButton('9'),
  CalculatorButton('×', isColored: true, canBeFirst: false),
  CalculatorButton('4'),
  CalculatorButton('5'),
  CalculatorButton('6'),
  CalculatorButton('-', isColored: true, canBeFirst: true),
  CalculatorButton('1'),
  CalculatorButton('2'),
  CalculatorButton('3'),
  CalculatorButton('+', isColored: true, canBeFirst: false),
  CalculatorButton('00'),
  CalculatorButton('0'),
  CalculatorButton('000'),
  CalculatorButton('=', isEqualSign: true, isColored: true, canBeFirst: false),
];

class CalculatorWidget extends StatelessWidget {
  const CalculatorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final Size mediaQuery = MediaQuery.of(context).size;
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        // Display equation and result
        Container(
          width: mediaQuery.width,
          height: mediaQuery.height * .4,
          padding: EdgeInsets.symmetric(
            vertical: mediaQuery.width * 0.08,
            horizontal: mediaQuery.width * 0.06,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              SizedBox(
                height: 20.0,
                child: BlocBuilder<CalculatorBloc, CalculatorState>(
                  builder: (BuildContext context, CalculatorState state) =>
                      Text(
                        state.equation,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                ),
              ),
              const SizedBox(height: 10.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.history,
                      color: Theme.of(context).iconTheme.color,
                      size: 20.sp,
                    ),
                    onPressed: () {
                      context.push(RouteNames.calculatorHistoryView);
                    },
                  ),
                  Expanded(
                    child: BlocBuilder<CalculatorBloc, CalculatorState>(
                      builder: (BuildContext context, CalculatorState state) =>
                          Text(
                            state.result,
                            textAlign: TextAlign.right,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontSize: 25.sp,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Calculator Buttons Grid
        Expanded(
          flex: 1,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.black : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.r),
                topRight: Radius.circular(15.r),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            alignment: Alignment.bottomCenter,
            child: GridView.count(
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(15.0),
              crossAxisSpacing: 5.0,
              childAspectRatio: 1.3,
              mainAxisSpacing: 5.0,
              crossAxisCount: 4,
              children: calculateButton,
            ),
          ),
        ),
      ],
    );
  }
}