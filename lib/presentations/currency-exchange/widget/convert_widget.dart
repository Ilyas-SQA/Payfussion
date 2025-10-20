import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:payfussion/presentations/currency-exchange/widget/convert_button.dart';

import '../../../logic/blocs/calculator/calculator_bloc.dart';
import '../../../logic/blocs/calculator/calculator_event.dart';
import '../../../logic/blocs/calculator/calculator_state.dart';

List<ConvertButton> convertButton = const <ConvertButton>[
  ConvertButton('7', canBeFirst: false, isColored: false),
  ConvertButton('8', canBeFirst: false, isColored: false),
  ConvertButton('9', canBeFirst: false, isColored: false),
  ConvertButton('C', canBeFirst: false, isColored: false),
  ConvertButton('4', canBeFirst: false, isColored: false),
  ConvertButton('5', canBeFirst: false, isColored: false),
  ConvertButton('6', canBeFirst: false, isColored: false),
  ConvertButton('', canBeFirst: false, isColored: false),
  ConvertButton('1', canBeFirst: false, isColored: false),
  ConvertButton('2', canBeFirst: false, isColored: false),
  ConvertButton('3', canBeFirst: false, isColored: false),
  ConvertButton('', canBeFirst: false, isColored: false),
  ConvertButton('00', canBeFirst: false, isColored: false),
  ConvertButton('0', canBeFirst: false, isColored: false),
  ConvertButton('.', canBeFirst: false, isColored: false),
  ConvertButton('⌫', canBeFirst: false, isColored: true),
];

class ConvertWidget extends StatelessWidget {
  const ConvertWidget({super.key});

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
          height: mediaQuery.height * .48,
          padding: EdgeInsets.symmetric(
            vertical: mediaQuery.width * 0.08,
            horizontal: mediaQuery.width * 0.06,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              BlocBuilder<CalculatorBloc, CalculatorState>(
                builder: (BuildContext context, CalculatorState state) =>
                    Column(
                      children: <Widget>[
                        // Currency Selector Dropdowns
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            // Source Currency Dropdown
                            DropdownButton<String>(
                              value: state.sourceCurrency,
                              iconSize: 20.sp,
                              menuWidth: 80.w,
                              underline: Container(height: 0),
                              icon: Icon(
                                Icons.arrow_forward_ios,
                                color: isDarkMode ? Colors.white70 : Colors.black87,
                              ),
                              dropdownColor: isDarkMode
                                  ? Colors.grey[850]
                                  : Colors.white,
                              onChanged: (String? value) {
                                BlocProvider.of<CalculatorBloc>(
                                  context,
                                ).add(SourceCurrencyChanged(currency: value!));
                              },
                              items: <String>['USD', 'EUR', 'INR', 'GBP'].map((
                                  String currency,
                                  ) {
                                return DropdownMenuItem<String>(
                                  value: currency,
                                  child: Text(
                                    currency,
                                    style: Theme.of(context).textTheme.bodyLarge
                                        ?.copyWith(
                                      fontSize: 20.sp,
                                      color: isDarkMode
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),

                            Text(
                              state.amount.toStringAsFixed(0),
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(
                                fontSize: 25.sp,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ),

                        12.verticalSpace,
                        // Target Currency Dropdown
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            // target Currency Dropdown
                            DropdownButton<String>(
                              value: state.targetCurrency,
                              iconSize: 20.sp,
                              menuWidth: 80.w,
                              underline: Container(height: 0),
                              icon: Icon(
                                Icons.arrow_forward_ios,
                                color: isDarkMode ? Colors.white70 : Colors.black87,
                              ),
                              dropdownColor: isDarkMode
                                  ? Colors.grey[850]
                                  : Colors.white,
                              onChanged: (String? value) {
                                BlocProvider.of<CalculatorBloc>(
                                  context,
                                ).add(TargetCurrencyChanged(currency: value!));
                              },
                              items: <String>['USD', 'EUR', 'INR', 'GBP'].map((
                                  String currency,
                                  ) {
                                return DropdownMenuItem<String>(
                                  value: currency,
                                  child: Text(
                                    currency,
                                    style: Theme.of(context).textTheme.bodyLarge
                                        ?.copyWith(
                                      fontSize: 20.sp,
                                      color: isDarkMode
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),

                            Text(
                              state.conversionResult.toStringAsFixed(0),
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(
                                fontSize: 25.sp,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode
                                    ? Colors.white
                                    : Colors.black87,
                              ),
                            ),
                          ],
                        ),

                        100.verticalSpace,
                        // last update
                        Text(
                          'Last Updated 2 min ago',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                            fontSize: 12.sp,
                            color: isDarkMode
                                ? Colors.white70
                                : Colors.black54,
                          ),
                        ),
                      ],
                    ),
              ),

              BlocBuilder<CalculatorBloc, CalculatorState>(
                builder: (BuildContext context, CalculatorState state) => Text(
                  state.result,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: 25.sp,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
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
              children: convertButton,
            ),
          ),
        ),
      ],
    );
  }
}