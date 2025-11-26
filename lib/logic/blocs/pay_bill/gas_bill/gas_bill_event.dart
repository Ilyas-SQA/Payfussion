import 'package:equatable/equatable.dart';

abstract class GasBillState extends Equatable {
  const GasBillState();

  @override
  List<Object?> get props => <Object?>[];
}

class GasBillInitial extends GasBillState {}

class GasBillDataSet extends GasBillState {
  final String companyName;
  final String region;
  final String averageRate;
  final String accountNumber;
  final String consumerName;
  final String address;
  final String billMonth;
  final double amount;
  final double taxAmount;
  final double totalAmount;
  final String gasUsage;
  final String previousReading;
  final String currentReading;
  final String dueDate;
  final String? cardId;
  final String? cardHolderName;
  final String? cardEnding;

  const GasBillDataSet({
    required this.companyName,
    required this.region,
    required this.averageRate,
    required this.accountNumber,
    required this.consumerName,
    required this.address,
    required this.billMonth,
    required this.amount,
    required this.taxAmount,
    required this.totalAmount,
    required this.gasUsage,
    required this.previousReading,
    required this.currentReading,
    required this.dueDate,
    this.cardId,
    this.cardHolderName,
    this.cardEnding,
  });

  @override
  List<Object?> get props => <Object?>[
    companyName,
    region,
    averageRate,
    accountNumber,
    consumerName,
    address,
    billMonth,
    amount,
    taxAmount,
    totalAmount,
    gasUsage,
    previousReading,
    currentReading,
    dueDate,
    cardId,
    cardHolderName,
    cardEnding,
  ];

  GasBillDataSet copyWith({
    String? companyName,
    String? region,
    String? averageRate,
    String? accountNumber,
    String? consumerName,
    String? address,
    String? billMonth,
    double? amount,
    double? taxAmount,
    double? totalAmount,
    String? gasUsage,
    String? previousReading,
    String? currentReading,
    String? dueDate,
    String? cardId,
    String? cardHolderName,
    String? cardEnding,
  }) {
    return GasBillDataSet(
      companyName: companyName ?? this.companyName,
      region: region ?? this.region,
      averageRate: averageRate ?? this.averageRate,
      accountNumber: accountNumber ?? this.accountNumber,
      consumerName: consumerName ?? this.consumerName,
      address: address ?? this.address,
      billMonth: billMonth ?? this.billMonth,
      amount: amount ?? this.amount,
      taxAmount: taxAmount ?? this.taxAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      gasUsage: gasUsage ?? this.gasUsage,
      previousReading: previousReading ?? this.previousReading,
      currentReading: currentReading ?? this.currentReading,
      dueDate: dueDate ?? this.dueDate,
      cardId: cardId ?? this.cardId,
      cardHolderName: cardHolderName ?? this.cardHolderName,
      cardEnding: cardEnding ?? this.cardEnding,
    );
  }
}

class GasBillProcessing extends GasBillState {}

class GasBillSuccess extends GasBillState {
  final String transactionId;
  final String message;

  const GasBillSuccess({
    required this.transactionId,
    required this.message,
  });

  @override
  List<Object> get props => <Object>[transactionId, message];
}

class GasBillError extends GasBillState {
  final String error;

  const GasBillError(this.error);

  @override
  List<Object> get props => <Object>[error];
}