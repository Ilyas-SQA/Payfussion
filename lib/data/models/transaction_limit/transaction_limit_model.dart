import 'package:cloud_firestore/cloud_firestore.dart';

class LimitOption {
  final int amount;
  final int utilityBills;
  final String period;

  LimitOption({
    required this.amount,
    required this.utilityBills,
    this.period = 'Daily',
  });

  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'utilityBills': utilityBills,
      'period': period,
    };
  }

  factory LimitOption.fromMap(Map<String, dynamic> map) {
    return LimitOption(
      amount: map['amount'] ?? 0,
      utilityBills: map['utilityBills'] ?? 0,
      period: map['period'] ?? 'Daily',
    );
  }
}

class TransactionLimitData {
  final int totalLimit;
  final int usedAmount;
  final int remainingAmount;
  final int utilityBills;
  final String period;
  final DateTime? resetDate;
  final bool hasCustomLimit; // User ne limit select ki hai ya nahi

  TransactionLimitData({
    required this.totalLimit,
    required this.usedAmount,
    required this.utilityBills,
    required this.period,
    this.resetDate,
    this.hasCustomLimit = false,
  }) : remainingAmount = totalLimit - usedAmount;

  double get usagePercentage {
    if (totalLimit == 0) return 0.0;
    return (usedAmount / totalLimit).clamp(0.0, 1.0);
  }

  Map<String, dynamic> toMap() {
    return {
      'totalLimit': totalLimit,
      'usedAmount': usedAmount,
      'utilityBills': utilityBills,
      'period': period,
      'resetDate': resetDate?.toIso8601String(),
      'hasCustomLimit': hasCustomLimit,
      'lastUpdated': FieldValue.serverTimestamp(),
    };
  }

  factory TransactionLimitData.fromMap(Map<String, dynamic> map) {
    return TransactionLimitData(
      totalLimit: map['totalLimit'] ?? 250000,
      usedAmount: map['usedAmount'] ?? 0,
      utilityBills: map['utilityBills'] ?? 5,
      period: map['period'] ?? 'Daily',
      resetDate: map['resetDate'] != null
          ? DateTime.parse(map['resetDate'])
          : null,
      hasCustomLimit: map['hasCustomLimit'] ?? false,
    );
  }
}