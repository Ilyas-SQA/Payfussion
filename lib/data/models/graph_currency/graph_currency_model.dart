class GraphCurrencyModel {
  final String code;
  final String name;
  final double currentPrice;
  final List<double> weeklyPrices;
  final String symbol;
  final DateTime lastUpdated;
  final double? changePercent;
  final bool isIncreasing;

  GraphCurrencyModel({
    required this.code,
    required this.name,
    required this.currentPrice,
    required this.weeklyPrices,
    required this.symbol,
    DateTime? lastUpdated,
    this.changePercent,
  }) :
        lastUpdated = lastUpdated ?? DateTime.now(),
        isIncreasing = weeklyPrices.length >= 2
            ? weeklyPrices.last > weeklyPrices[weeklyPrices.length - 2]
            : true;

  /// Calculate the percentage change from first to last price in weekly data
  double get weeklyChangePercent {
    if (weeklyPrices.isEmpty || weeklyPrices.length < 2) return 0.0;

    final double firstPrice = weeklyPrices.first;
    final double lastPrice = weeklyPrices.last;

    if (firstPrice == 0) return 0.0;

    return ((lastPrice - firstPrice) / firstPrice) * 100;
  }

  /// Get the highest price from weekly data
  double get weeklyHigh {
    if (weeklyPrices.isEmpty) return currentPrice;
    return weeklyPrices.reduce((double a, double b) => a > b ? a : b);
  }

  /// Get the lowest price from weekly data
  double get weeklyLow {
    if (weeklyPrices.isEmpty) return currentPrice;
    return weeklyPrices.reduce((double a, double b) => a < b ? a : b);
  }

  /// Check if the data is fresh (less than 1 hour old)
  bool get isFresh {
    final DateTime now = DateTime.now();
    final Duration difference = now.difference(lastUpdated);
    return difference.inHours < 1;
  }

  /// Get formatted last updated time
  String get lastUpdatedFormatted {
    final DateTime now = DateTime.now();
    final Duration difference = now.difference(lastUpdated);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hr ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }

  /// Create a copy of this model with updated fields
  GraphCurrencyModel copyWith({
    String? code,
    String? name,
    double? currentPrice,
    List<double>? weeklyPrices,
    String? symbol,
    DateTime? lastUpdated,
    double? changePercent,
  }) {
    return GraphCurrencyModel(
      code: code ?? this.code,
      name: name ?? this.name,
      currentPrice: currentPrice ?? this.currentPrice,
      weeklyPrices: weeklyPrices ?? this.weeklyPrices,
      symbol: symbol ?? this.symbol,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      changePercent: changePercent ?? this.changePercent,
    );
  }

  @override
  String toString() {
    return 'GraphCurrencyModel(code: $code, name: $name, currentPrice: $currentPrice, symbol: $symbol)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GraphCurrencyModel && other.code == code;
  }

  @override
  int get hashCode => code.hashCode;
}