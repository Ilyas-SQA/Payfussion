import 'package:equatable/equatable.dart';

abstract class InternetBillState extends Equatable {
  const InternetBillState();

  @override
  List<Object?> get props => <Object?>[];
}

class InternetBillInitial extends InternetBillState {}

class InternetBillDataSet extends InternetBillState {
  final String companyName;
  final String connectionType;
  final String maxSpeed;
  final String coverage;
  final String accountNumber;
  final String consumerName;
  final String address;
  final String billMonth;
  final double amount;
  final double taxAmount;
  final double totalAmount;
  final String planName;
  final String dataUsage;
  final String downloadSpeed;
  final String uploadSpeed;
  final String dueDate;
  final String? cardId;
  final String? cardHolderName;
  final String? cardEnding;

  const InternetBillDataSet({
    required this.companyName,
    required this.connectionType,
    required this.maxSpeed,
    required this.coverage,
    required this.accountNumber,
    required this.consumerName,
    required this.address,
    required this.billMonth,
    required this.amount,
    required this.taxAmount,
    required this.totalAmount,
    required this.planName,
    required this.dataUsage,
    required this.downloadSpeed,
    required this.uploadSpeed,
    required this.dueDate,
    this.cardId,
    this.cardHolderName,
    this.cardEnding,
  });

  @override
  List<Object?> get props => <Object?>[
    companyName,
    connectionType,
    maxSpeed,
    coverage,
    accountNumber,
    consumerName,
    address,
    billMonth,
    amount,
    taxAmount,
    totalAmount,
    planName,
    dataUsage,
    downloadSpeed,
    uploadSpeed,
    dueDate,
    cardId,
    cardHolderName,
    cardEnding,
  ];

  InternetBillDataSet copyWith({
    String? companyName,
    String? connectionType,
    String? maxSpeed,
    String? coverage,
    String? accountNumber,
    String? consumerName,
    String? address,
    String? billMonth,
    double? amount,
    double? taxAmount,
    double? totalAmount,
    String? planName,
    String? dataUsage,
    String? downloadSpeed,
    String? uploadSpeed,
    String? dueDate,
    String? cardId,
    String? cardHolderName,
    String? cardEnding,
  }) {
    return InternetBillDataSet(
      companyName: companyName ?? this.companyName,
      connectionType: connectionType ?? this.connectionType,
      maxSpeed: maxSpeed ?? this.maxSpeed,
      coverage: coverage ?? this.coverage,
      accountNumber: accountNumber ?? this.accountNumber,
      consumerName: consumerName ?? this.consumerName,
      address: address ?? this.address,
      billMonth: billMonth ?? this.billMonth,
      amount: amount ?? this.amount,
      taxAmount: taxAmount ?? this.taxAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      planName: planName ?? this.planName,
      dataUsage: dataUsage ?? this.dataUsage,
      downloadSpeed: downloadSpeed ?? this.downloadSpeed,
      uploadSpeed: uploadSpeed ?? this.uploadSpeed,
      dueDate: dueDate ?? this.dueDate,
      cardId: cardId ?? this.cardId,
      cardHolderName: cardHolderName ?? this.cardHolderName,
      cardEnding: cardEnding ?? this.cardEnding,
    );
  }
}

class InternetBillProcessing extends InternetBillState {}

class InternetBillSuccess extends InternetBillState {
  final String transactionId;
  final String message;

  const InternetBillSuccess({
    required this.transactionId,
    required this.message,
  });

  @override
  List<Object> get props => <Object>[transactionId, message];
}

class InternetBillError extends InternetBillState {
  final String error;

  const InternetBillError(this.error);

  @override
  List<Object> get props => <Object>[error];
}