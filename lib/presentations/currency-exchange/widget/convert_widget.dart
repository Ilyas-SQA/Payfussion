// lib/presentations/currency-exchange/widget/convert_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:payfussion/presentations/currency-exchange/widget/convert_button.dart';
import '../../../logic/blocs/exchange_currency/exchange_currency_bloc.dart';
import '../../../logic/blocs/exchange_currency/exchange_currency_event.dart';
import '../../../logic/blocs/exchange_currency/exchange_currency_state.dart';

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
              BlocBuilder<ExchangeCurrencyBloc, ExchangeCurrencyState>(
                builder: (BuildContext context, ExchangeCurrencyState state) {
                  // Show loading indicator
                  if (state.status == ExchangeStatus.loading && state.exchangeRates == null) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  // Show error message
                  if (state.status == ExchangeStatus.error) {
                    return Column(
                      children: <Widget>[
                        Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 40.sp,
                        ),
                        8.verticalSpace,
                        Text(
                          'Failed to load exchange rates',
                          style: TextStyle(color: Colors.red, fontSize: 14.sp),
                        ),
                        8.verticalSpace,
                        ElevatedButton(
                          onPressed: () {
                            context.read<ExchangeCurrencyBloc>().add(
                              const FetchExchangeRates(),
                            );
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    );
                  }

                  return Column(
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
                              context.read<ExchangeCurrencyBloc>().add(
                                SourceCurrencyChanged(currency: value!),
                              );
                            },
                            items: <String>['USD', 'EUR', 'INR', 'GBP', 'PKR', 'AUD', 'CAD', 'JPY'].map((
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
                            state.amount.toStringAsFixed(2),
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

                      // Swap Currencies Button
                      IconButton(
                        icon: Icon(
                          Icons.swap_vert,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        onPressed: () {
                          context.read<ExchangeCurrencyBloc>().add(
                            const SwapCurrencies(),
                          );
                        },
                      ),

                      12.verticalSpace,

                      // Target Currency Dropdown
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          // Target Currency Dropdown
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
                              context.read<ExchangeCurrencyBloc>().add(
                                TargetCurrencyChanged(currency: value!),
                              );
                            },
                            items: <String>['USD', 'EUR', 'INR', 'GBP', 'PKR', 'AUD', 'CAD', 'JPY'].map((
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

                          Row(
                            children: <Widget>[
                              if (state.status == ExchangeStatus.loading)
                                Padding(
                                  padding: EdgeInsets.only(right: 8.w),
                                  child: SizedBox(
                                    width: 16.w,
                                    height: 16.h,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Theme.of(context).colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                ),
                              Text(
                                state.conversionResult.toStringAsFixed(2),
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
                        ],
                      ),

                      20.verticalSpace,

                      // Exchange Rate Info
                      if (state.exchangeRates != null &&
                          state.exchangeRates![state.targetCurrency] != null)
                        Text(
                          '1 ${state.sourceCurrency} = ${state.exchangeRates![state.targetCurrency]!.toStringAsFixed(4)} ${state.targetCurrency}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 11.sp,
                            color: isDarkMode ? Colors.white60 : Colors.black45,
                          ),
                        ),

                      8.verticalSpace,

                      // Last Update with Refresh Button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            state.getLastUpdatedText(),
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                              fontSize: 12.sp,
                              color: isDarkMode
                                  ? Colors.white70
                                  : Colors.black54,
                            ),
                          ),
                          4.horizontalSpace,
                          IconButton(
                            icon: Icon(
                              Icons.refresh,
                              size: 18.sp,
                              color: isDarkMode
                                  ? Colors.white70
                                  : Colors.black54,
                            ),
                            onPressed: () {
                              context.read<ExchangeCurrencyBloc>().add(
                                const RefreshExchangeRates(),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  );
                },
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
              boxShadow: <BoxShadow>[
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