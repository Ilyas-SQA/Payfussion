import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GraphWidget extends StatefulWidget {
  final List<FlSpot> dataPoints;

  const GraphWidget({super.key, required this.dataPoints});

  @override
  State<GraphWidget> createState() => _StockChartState();
}

class _StockChartState extends State<GraphWidget> {
  String selectedPeriod = '1M';
  int? touchedIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12), // Reduced padding
      width: 250.w,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time period selector with flexible layout
          Wrap(
            spacing: 5,
            runSpacing: 1,
            alignment: WrapAlignment.center,
            children: [
              '1D',
              '5D',
              '1M',
              '1Y',
              '5Y',
              'Max',
            ].map((period) => _buildPeriodButton(period)).toList(),
          ),
          16.verticalSpace,
          // Chart with flexible height
          Flexible(
            child: SizedBox(
              height: 180.h, // Reduced chart height
              width: 220.w,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 0.05,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.withOpacity(0.3),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 25, // Reduced reserved size
                        interval: 5,
                        getTitlesWidget: (value, meta) {
                          return _buildBottomTitle(value);
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 0.05,
                        reservedSize: 35, // Reduced reserved size
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toStringAsFixed(2),
                            style: const TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                              fontSize: 10, // Reduced font size
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: widget.dataPoints.length.toDouble() - 1,
                  minY: 3.65,
                  maxY: 3.85,
                  lineBarsData: [
                    LineChartBarData(
                      spots: widget.dataPoints,
                      isCurved: false,
                      color: Colors.green,
                      barWidth: 2,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          if (index == touchedIndex) {
                            return FlDotCirclePainter(
                              radius: 6,
                              color: Colors.green,
                              strokeWidth: 2,
                              strokeColor: Colors.white,
                            );
                          }
                          return FlDotCirclePainter(
                            radius: 0,
                            color: Colors.transparent,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.green.withOpacity(0.3),
                            Colors.green.withOpacity(0.1),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    enabled: true,
                    touchCallback:
                        (FlTouchEvent event, LineTouchResponse? response) {
                          if (response != null &&
                              response.lineBarSpots != null) {
                            setState(() {
                              touchedIndex =
                                  response.lineBarSpots!.first.spotIndex;
                            });
                          }
                        },
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (touchedSpot) => Colors.white,
                      tooltipBorderRadius: BorderRadius.circular(8),
                      tooltipPadding: const EdgeInsets.all(8),
                      getTooltipItems: (List<LineBarSpot> touchedSpots) {
                        return touchedSpots.map((LineBarSpot touchedSpot) {
                          return LineTooltipItem(
                            '${touchedSpot.y.toStringAsFixed(2)} Thu, 4 Apr',
                            const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          );
                        }).toList();
                      },
                    ),
                    getTouchedSpotIndicator:
                        (LineChartBarData barData, List<int> spotIndexes) {
                          return spotIndexes.map((spotIndex) {
                            return TouchedSpotIndicatorData(
                              FlLine(
                                color: Colors.grey.withOpacity(0.8),
                                strokeWidth: 1,
                                dashArray: [3, 3],
                              ),
                              FlDotData(
                                getDotPainter: (spot, percent, barData, index) {
                                  return FlDotCirclePainter(
                                    radius: 6,
                                    color: Colors.green,
                                    strokeWidth: 2,
                                    strokeColor: Colors.white,
                                  );
                                },
                              ),
                            );
                          }).toList();
                        },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(String period) {
    final bool isSelected = period == selectedPeriod;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPeriod = period;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 4,
        ), // Reduced padding
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          period,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 12, // Reduced font size
          ),
        ),
      ),
    );
  }

  Widget _buildBottomTitle(double value) {
    if (value.toInt() == 5) {
      return const Text(
        '7 Apr',
        style: TextStyle(
          color: Colors.grey,
          fontWeight: FontWeight.bold,
          fontSize: 10, // Reduced font size
        ),
      );
    } else if (value.toInt() == 15) {
      return const Text(
        '18 Apr',
        style: TextStyle(
          color: Colors.grey,
          fontWeight: FontWeight.bold,
          fontSize: 10, // Reduced font size
        ),
      );
    }
    return const Text('');
  }
}
