import 'package:equatable/equatable.dart';

abstract class MobileRechargeState extends Equatable {
  const MobileRechargeState();

  @override
  List<Object?> get props => <Object?>[];
}

class MobileRechargeInitial extends MobileRechargeState {}

class MobileRechargeDataSet extends MobileRechargeState {
  final String companyName;
  final String network;
  final String phoneNumber;
  final double amount;
  final double taxAmount;
  final double totalAmount;
  final String? packageName;
  final String? packageData;
  final String? packageValidity;
  final String? cardId;
  final String? cardHolderName;
  final String? cardEnding;

  const MobileRechargeDataSet({
    required this.companyName,
    required this.network,
    required this.phoneNumber,
    required this.amount,
    required this.taxAmount,
    required this.totalAmount,
    this.packageName,
    this.packageData,
    this.packageValidity,
    this.cardId,
    this.cardHolderName,
    this.cardEnding,
  });

  @override
  List<Object?> get props => <Object?>[
    companyName,
    network,
    phoneNumber,
    amount,
    taxAmount,
    totalAmount,
    packageName,
    packageData,
    packageValidity,
    cardId,
    cardHolderName,
    cardEnding,
  ];

  MobileRechargeDataSet copyWith({
    String? companyName,
    String? network,
    String? phoneNumber,
    double? amount,
    double? taxAmount,
    double? totalAmount,
    String? packageName,
    String? packageData,
    String? packageValidity,
    String? cardId,
    String? cardHolderName,
    String? cardEnding,
  }) {
    return MobileRechargeDataSet(
      companyName: companyName ?? this.companyName,
      network: network ?? this.network,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      amount: amount ?? this.amount,
      taxAmount: taxAmount ?? this.taxAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      packageName: packageName ?? this.packageName,
      packageData: packageData ?? this.packageData,
      packageValidity: packageValidity ?? this.packageValidity,
      cardId: cardId ?? this.cardId,
      cardHolderName: cardHolderName ?? this.cardHolderName,
      cardEnding: cardEnding ?? this.cardEnding,
    );
  }
}

class MobileRechargeProcessing extends MobileRechargeState {}

class MobileRechargeSuccess extends MobileRechargeState {
  final String transactionId;
  final String message;

  const MobileRechargeSuccess({
    required this.transactionId,
    required this.message,
  });

  @override
  List<Object> get props => <Object>[transactionId, message];
}

class MobileRechargeError extends MobileRechargeState {
  final String error;

  const MobileRechargeError(this.error);

  @override
  List<Object> get props => <Object>[error];
}