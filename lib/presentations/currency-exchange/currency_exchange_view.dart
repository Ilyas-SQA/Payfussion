import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/constants/image_url.dart';
import '../../core/constants/routes_name.dart';
import '../../core/theme/theme.dart';
import '../../data/models/currency_model.dart';
import '../../logic/blocs/currency_convert/currency_convert_bloc.dart';
import '../../logic/blocs/currency_convert/currency_convert_event.dart';
import '../../logic/blocs/currency_convert/currency_convert_state.dart';
import '../widgets/custom_button.dart';
import '../widgets/payment_selector_widget.dart';
import '../widgets/profile_app_bar.dart';
import 'currency_graph_screen.dart';
import 'currency_viewmodel.dart';
import 'widget/graph_widget.dart';

class CurrencyExchangeView extends StatefulWidget {
  const CurrencyExchangeView({super.key});

  @override
  State<CurrencyExchangeView> createState() => _CurrencyExchangeViewState();
}

class _CurrencyExchangeViewState extends State<CurrencyExchangeView> {
  Currency? selectedCurrencyFrom;
  Currency? selectedCurrencyTo;
  List<Currency> availableCurrencies = [];

  final CurrencyViewmodel currencyViewmodel = CurrencyViewmodel();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _convertedAmountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeCurrencies();
    // Load exchange rates when the widget initializes
    context.read<CurrencyConversionBloc>().add(const LoadExchangeRates());
  }

  @override
  void dispose() {
    _amountController.dispose();
    _convertedAmountController.dispose();
    super.dispose();
  }

  void _initializeCurrencies() {
    availableCurrencies = currencyViewmodel.currencies;

    if (availableCurrencies.isNotEmpty) {
      selectedCurrencyFrom =
          currencyViewmodel.getCurrencyByCode('USD') ??
              availableCurrencies.first;
      selectedCurrencyTo =
          currencyViewmodel.getCurrencyByCode('EUR') ??
              availableCurrencies.first;
    }
  }

  void _onAmountChanged(String value) {
    if (value.isEmpty) {
      _convertedAmountController.clear();
      return;
    }

    try {
      final amount = double.parse(value);
      context.read<CurrencyConversionBloc>().add(
        ConvertCurrency(
          fromCurrency: selectedCurrencyFrom?.code ?? 'USD',
          toCurrency: selectedCurrencyTo?.code ?? 'EUR',
          amount: amount,
        ),
      );
    } catch (e) {
      // Handle invalid number input
    }
  }

  void _altertDialogBox() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text(
            'Graph',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: 250.h,
            child: const SingleChildScrollView(
              child: GraphWidget(
                dataPoints: [
                  FlSpot(0, 3.65),
                  FlSpot(2, 3.71),
                  FlSpot(2.5, 3.75),
                  FlSpot(3, 3.85),
                  FlSpot(5, 3.80),
                  FlSpot(6, 3.85),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Close',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final isLoading = selectedCurrencyFrom == null || availableCurrencies.isEmpty;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: isLoading ?
      _buildLoadingView() :
      _buildMainView(isDark),
    );
  }

  Widget _buildLoadingView() {
    return SingleChildScrollView(
      child: Column(
        children: [
          50.verticalSpace,
          ProfileAppBar(),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: Center(
              child: BlocBuilder<CurrencyConversionBloc, CurrencyConversionState>(
                builder: (context, state) {
                  if (state.isLoading) {
                    return const CircularProgressIndicator();
                  }
                  if (state.error != null) {
                    return Text(
                      state.error!,
                      style: TextStyle(fontSize: 16.sp),
                    );
                  }
                  return Text(
                    'Loading currencies...',
                    style: TextStyle(fontSize: 16.sp),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainView(bool isDark) {
    return SafeArea(
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height -
                MediaQuery.of(context).padding.top -
                MediaQuery.of(context).padding.bottom,
          ),
          child: IntrinsicHeight(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                ProfileAppBar(),
                const SizedBox(height: 15),
                PaymentCardSelector(
                  userId: FirebaseAuth.instance.currentUser?.uid ?? '',
                  onCardSelect: (PaymentCard card) {
                    print('Selected: ${card.last4}');
                    print('Selected: ${card.expYear}');
                    print('Selected: ${card.expMonth}');
                    print('Selected: ${card.last4}');
                  },
                ),
                const SizedBox(height: 15),
                _buildCurrencyInput(
                  selectedCurrencyFrom!,
                  context: context,
                  controller: _amountController,
                  onCurrencyChanged: (val) {
                    setState(() => selectedCurrencyFrom = val);
                    context.read<CurrencyConversionBloc>().add(
                      UpdateFromCurrency(val?.code ?? 'USD'),
                    );
                  },
                  onAmountChanged: _onAmountChanged,
                ),
                const SizedBox(height: 15),
                _buildRateInfo(),
                const SizedBox(height: 15),
                _buildCurrencyInput(
                  context: context,
                  selectedCurrencyTo!,
                  controller: _convertedAmountController,
                  onCurrencyChanged: (val) {
                    setState(() => selectedCurrencyTo = val);
                    context.read<CurrencyConversionBloc>().add(
                      UpdateToCurrency(val?.code ?? 'EUR'),
                    );
                  },
                  isReadOnly: true,
                ),
                const SizedBox(height: 15),
                // KEY FIX 4: Use Flexible instead of Expanded
                Flexible(
                  child: _buildForesight(isDark),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRateInfo() {
    return BlocBuilder<CurrencyConversionBloc, CurrencyConversionState>(
      builder: (context, state) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            children: [
              Image.asset(TImageUrl.iconUpDown, width: 35.w, height: 35.h),
              10.horizontalSpace,
              if (state.currentRate != null) ...[
                Text(
                  '1 ${state.currentRate!.from} = ${state.currentRate!.rate.toStringAsFixed(4)} ${state.currentRate!.to}',
                  style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500),
                ),
                10.horizontalSpace,
                Icon(
                  state.currentRate!.changePercent >= 0 ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: state.currentRate!.changePercent >= 0 ? Colors.green : Colors.red,
                  size: 20.sp,
                ),
                2.horizontalSpace,
                Text(
                  '${state.currentRate!.changePercent >= 0 ? '+' : ''}${state.currentRate!.changePercent.toStringAsFixed(2)}% 1hr ago',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: state.currentRate!.changePercent >= 0 ? Colors.green : Colors.red,
                  ),
                ),
              ] else ...[
                Text(
                  '₪1 ILS = \$0.27 USD',
                  style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500),
                ),
                10.horizontalSpace,
                Image.asset(TImageUrl.iconDown, width: 35.w, height: 35.h),
                2.horizontalSpace,
                Text(
                  'Down -0.2% 1hr ago',
                  style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildCurrencyInput(
      Currency selectedCurrency, {
        required ValueChanged<Currency?>? onCurrencyChanged,
        required TextEditingController controller,
        ValueChanged<String>? onAmountChanged,
        bool isReadOnly = false,
        required BuildContext context,
      }) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    return BlocListener<CurrencyConversionBloc, CurrencyConversionState>(
      listener: (context, state) {
        if (isReadOnly && state.convertedAmount > 0) {
          controller.text = state.convertedAmount.toStringAsFixed(2);
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        margin: EdgeInsets.symmetric(horizontal: 16.w),
        height: 65.h,
        decoration: BoxDecoration(
          color: isDark ? Colors.black12 : Colors.white12,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: isDark ? Colors.white : Colors.black,
            width: 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              getCurrencySymbol(selectedCurrency.code),
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black38,
                height: 1.2.h,
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            3.horizontalSpace,
            Expanded(
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                cursorHeight: 24.h,
                readOnly: isReadOnly,
                onChanged: onAmountChanged,
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black38,
                ),
                decoration: InputDecoration(
                  isDense: true,
                  isCollapsed: false,
                  contentPadding: EdgeInsets.zero,
                  border: InputBorder.none,
                  hintText: '0.00',
                  hintStyle: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    height: 1.5.h,
                    color: isDark ? Colors.white : Colors.black38,
                  ),
                ),
              ),
            ),
            3.horizontalSpace,
            DropdownButton<Currency>(
              value: selectedCurrency,
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: isDark ? Colors.white : Colors.black,
              ),
              underline: const SizedBox.shrink(),
              onChanged: onCurrencyChanged,
              items: availableCurrencies.map((currency) {
                return DropdownMenuItem(
                  value: currency,
                  child: Row(
                    children: [
                      Text(currency.flag, style: TextStyle(fontSize: 20.sp)),
                      8.horizontalSpace,
                      Text(
                        currency.code,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForesight(bool isDark) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 22.h),
      decoration: BoxDecoration(
        color: isDark ? Colors.black26 : Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // KEY FIX 5: Add mainAxisSize.min
        children: [
          _buildForesightHeader(isDark),
          10.verticalSpace,
          InkWell(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => const CurrencyGraphView())),
            child: _buildListTile(CupertinoIcons.graph_square_fill, 'Graph'),
          ),
          InkWell(
            child: _buildListTile(Icons.calculate_rounded, 'Calculator'),
            onTap: () {
              context.push(RouteNames.calculatorView);
            },
          ),
          const SizedBox(height: 20),
          InkWell(
            child: _buildListTile(Icons.history, 'Exchange History',),
            onTap: () {
              context.push(RouteNames.currencyExchangeHistoryView);
            },
          ),
          const SizedBox(height: 20), // Add bottom padding
        ],
      ),
    );
  }

  Widget _buildForesightHeader(bool isDark) {
    return ExpansionTile(
      leading: _circleIcon(Icons.lightbulb_outline, isDark),
      title: _whiteText('Foresight', 16.sp, FontWeight.w600, isDark),
      children: [
        ...[
          'Rates usually drop between 1AM to 6PM on Monday',
          'Rates usually are up during holidays',
          'Rates usually are up during holidays',
        ].map(
                (e) =>
                Padding(
                  padding: EdgeInsets.only(bottom: 10.h),
                  child: _buildForesightItem(e, isDark),
                ))
            .toList(),
      ],
    );
  }

  Widget _buildListTile(IconData icon, String title) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    return ListTile(
      leading: _circleIcon(icon, isDark),
      title: _whiteText(title, 16.sp, FontWeight.w600, isDark),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16.sp,
        color: isDark ? Colors.white : Colors.black,
      ),
    );
  }

  Widget _buildForesightItem(String text, bool isDark) {
    return Row(
      children: [
        Container(
          margin: EdgeInsets.only(top: 6.h, right: 8.w),
          width: 4.w,
          height: 4.w,
          decoration: BoxDecoration(
            color: isDark ? Colors.white : Colors.black,
            shape: BoxShape.circle,
          ),
        ),
        Expanded(child: _whiteText(text, 14.sp, FontWeight.w400, isDark)),
      ],
    );
  }

  Widget _circleIcon(IconData icon, bool isDark) {
    return Container(
      width: 35.w,
      height: 35.h,
      decoration: BoxDecoration(
        color: MyTheme.secondaryColor,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: 20.sp,
        color: Colors.white,
      ),
    );
  }

  Text _whiteText(String text, double size, FontWeight weight, bool isDark) {
    return Text(
      text,
      style: TextStyle(
        fontSize: size,
        fontWeight: weight,
        color: isDark ? Colors.white : Colors.black,
      ),
    );
  }

  String getCurrencySymbol(String code) {
    try {
      return NumberFormat.simpleCurrency(name: code).currencySymbol;
    } catch (_) {
      return 'Invalid';
    }
  }
}