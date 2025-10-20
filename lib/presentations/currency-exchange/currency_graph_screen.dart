import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:payfussion/data/models/graph_currency/graph_currency_model.dart';
import 'package:payfussion/logic/blocs/graph_currency/graph_currency_bloc.dart';
import '../../core/theme/theme.dart';
import '../../logic/blocs/graph_currency/graph_currency_event.dart';
import '../../logic/blocs/graph_currency/graph_currency_state.dart';

class CurrencyGraphView extends StatelessWidget {
  const CurrencyGraphView({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: _buildAppBar(isDark, context),
      body: BlocBuilder<GraphCurrencyBloc, GraphCurrencyState>(
        builder: (context, state) {
          if (state is CurrencyLoading) {
            return _buildLoadingState(isDark);
          }

          if (state is CurrencyError) {
            return _buildErrorState(state, isDark, context);
          }

          if (state is CurrencyLoaded) {
            return _buildLoadedState(state, isDark, context);
          }

          return const SizedBox();
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDark, BuildContext context) {
    return AppBar(
      title: const Text(
        'Currency Exchange',
      ),
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      iconTheme: const IconThemeData(
        color: MyTheme.primaryColor,
      ),
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2A2A40) : Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withOpacity(0.3)
                      : Colors.grey.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: CircularProgressIndicator(
              color: MyTheme.primaryColor, // Changed here
              strokeWidth: 3.w,
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'Loading currency data...',
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.grey[600],
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(CurrencyError state, bool isDark, BuildContext context) {
    return Center(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 24.w),
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2A2A40) : Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black.withOpacity(0.3) : Colors.grey.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(40.r),
              ),
              child: Icon(
                Icons.error_outline_rounded,
                color: Colors.red,
                size: 40.sp,
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              'Oops! Something went wrong',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              state.message,
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.grey[600],
                fontSize: 14.sp,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: () {
                context.read<GraphCurrencyBloc>().add(LoadCurrencies());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: MyTheme.primaryColor, // Changed here
                foregroundColor: Colors.white,
                elevation: 0,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                'Try Again',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadedState(CurrencyLoaded state, bool isDark, BuildContext context) {
    return Column(
      children: [
        // Enhanced Currency List
        _buildCurrencyList(state, isDark, context),

        // Enhanced Graph Section
        Expanded(
          child: Container(
            margin: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(5.r),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).brightness == Brightness.light ? Colors.grey.withOpacity(0.3) : Colors.black.withOpacity(0.3),
                  blurRadius: 5,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: state.selectedCurrency != null ? _buildGraph(state.selectedCurrency!, isDark) : _buildEmptyState(isDark),
          ),
        ),
      ],
    );
  }

  Widget _buildCurrencyList(CurrencyLoaded state, bool isDark, BuildContext context) {
    return Container(
      height: 170.h,
      padding: EdgeInsets.symmetric(vertical: 20.h),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: state.currencies.length,
        itemBuilder: (context, index) {
          final GraphCurrencyModel currency = state.currencies[index];
          final bool isSelected = state.selectedCurrency?.code == currency.code;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                context.read<GraphCurrencyBloc>().add(SelectCurrency(currency));
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                width: 160.w,
                margin: EdgeInsets.only(right: 16.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.r),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).brightness == Brightness.light ? Colors.grey.withOpacity(0.3) : Colors.black.withOpacity(0.3),
                      blurRadius: 5,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  color: isSelected ? MyTheme.primaryColor : Theme.of(context).scaffoldBackgroundColor,
                  border: Border.all(
                    color: isSelected ? MyTheme.primaryColor : isDark ? Colors.transparent : Colors.grey.withOpacity(0.2),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(4.w),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white.withOpacity(0.2)
                                  : isDark
                                  ? Colors.white.withOpacity(0.1)
                                  : Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Text(
                              currency.symbol,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : isDark
                                    ? Colors.white
                                    : Colors.black,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            currency.code,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white.withOpacity(0.9)
                                  : isDark
                                  ? Colors.white.withOpacity(0.8)
                                  : Colors.grey[600],
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        currency.name,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white.withOpacity(0.7)
                              : isDark
                              ? Colors.white.withOpacity(0.6)
                              : Colors.grey[500],
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      Text(
                        '${currency.symbol}${currency.currentPrice.toStringAsFixed(currency.code == 'JPY' ? 2 : 4)}',
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : isDark
                              ? Colors.white
                              : Colors.black,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGraph(GraphCurrencyModel currency, bool isDark) {
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Enhanced Graph Header
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${currency.symbol} ${currency.name}',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    currency.code,
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.grey[600],
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: MyTheme.primaryColor.withOpacity(0.15), // Changed here
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: MyTheme.primaryColor.withOpacity(0.3), // Changed here
                    width: 1,
                  ),
                ),
                child: Text(
                  'Weekly',
                  style: TextStyle(
                    color: MyTheme.primaryColor, // Changed here
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // Price Display
          Row(
            children: [
              Text(
                '${currency.symbol}${currency.currentPrice.toStringAsFixed(currency.code == 'JPY' ? 2 : 4)}',
                style: TextStyle(
                  color: const Color(0xFF10B981),
                  fontSize: 32.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 12.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: MyTheme.secondaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.trending_up_rounded,
                      color: MyTheme.secondaryColor,
                      size: 14.sp,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      '+2.5%',
                      style: TextStyle(
                        color: MyTheme.secondaryColor,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),

          // Enhanced Graph
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: (currency.weeklyPrices.reduce((a, b) => a > b ? a : b) - currency.weeklyPrices.reduce((a, b) => a < b ? a : b)) / 4,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: isDark ? Colors.white.withOpacity(0.08) : Colors.grey.withOpacity(0.2),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                        if (value.toInt() >= 0 && value.toInt() < days.length) {
                          return SideTitleWidget(
                            // axisSide: meta.axisSide,
                            meta: meta,
                            child: Text(
                              days[value.toInt()],
                              style: TextStyle(
                                color: isDark
                                    ? Colors.white.withOpacity(0.6)
                                    : Colors.grey[600],
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: (currency.weeklyPrices.reduce((a, b) => a > b ? a : b) -
                          currency.weeklyPrices.reduce((a, b) => a < b ? a : b)) / 3,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        return Text(
                          value.toStringAsFixed(currency.code == 'JPY' ? 0 : 3),
                          style: TextStyle(
                            color: isDark
                                ? Colors.white.withOpacity(0.6)
                                : Colors.grey[600],
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      },
                      reservedSize: 50,
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 6,
                minY: currency.weeklyPrices.reduce((a, b) => a < b ? a : b) * 0.995,
                maxY: currency.weeklyPrices.reduce((a, b) => a > b ? a : b) * 1.005,
                lineBarsData: [
                  LineChartBarData(
                    spots: currency.weeklyPrices
                        .asMap()
                        .entries
                        .map((e) => FlSpot(e.key.toDouble(), e.value))
                        .toList(),
                    isCurved: true,
                    gradient: LinearGradient( // Changed here
                      colors: [MyTheme.primaryColor, MyTheme.primaryColor.withOpacity(0.8)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    barWidth: 3.w,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 5.w,
                          color: Colors.white,
                          strokeWidth: 2.w,
                          strokeColor: MyTheme.primaryColor, // Changed here
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          MyTheme.primaryColor.withOpacity(0.3), // Changed here
                          MyTheme.primaryColor.withOpacity(0.05), // Changed here
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100.w,
            height: 100.w,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(50.r),
            ),
            child: Icon(
              Icons.show_chart_rounded,
              size: 50.sp,
              color: isDark
                  ? Colors.white.withOpacity(0.3)
                  : Colors.grey.withOpacity(0.5),
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'Select a currency to view graph',
            style: TextStyle(
              color: isDark
                  ? Colors.white.withOpacity(0.7)
                  : Colors.grey[600],
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Choose from the currency list above',
            style: TextStyle(
              color: isDark
                  ? Colors.white.withOpacity(0.5)
                  : Colors.grey[500],
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}