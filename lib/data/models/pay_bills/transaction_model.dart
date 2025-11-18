class TransactionModel {
  final String id;
  final String userId;
  final String type; // 'mobile_recharge' or 'package'
  final String companyName;
  final String network;
  final String phoneNumber;
  final double amount;
  final double taxAmount;
  final double totalAmount;
  final String currency;
  final String? packageName;
  final String? packageData;
  final String? packageValidity;
  final String cardId;
  final String cardHolderName;
  final String cardEnding;
  final String status; // 'pending', 'completed', 'failed'
  final DateTime createdAt;
  final DateTime? completedAt;

  TransactionModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.companyName,
    required this.network,
    required this.phoneNumber,
    required this.amount,
    required this.taxAmount,
    required this.totalAmount,
    required this.currency,
    this.packageName,
    this.packageData,
    this.packageValidity,
    required this.cardId,
    required this.cardHolderName,
    required this.cardEnding,
    required this.status,
    required this.createdAt,
    this.completedAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      type: json['type'] as String,
      companyName: json['companyName'] as String,
      network: json['network'] as String,
      phoneNumber: json['phoneNumber'] as String,
      amount: (json['amount'] as num).toDouble(),
      taxAmount: (json['taxAmount'] as num).toDouble(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      currency: json['currency'] as String,
      packageName: json['packageName'] as String?,
      packageData: json['packageData'] as String?,
      packageValidity: json['packageValidity'] as String?,
      cardId: json['cardId'] as String,
      cardHolderName: json['cardHolderName'] as String,
      cardEnding: json['cardEnding'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'userId': userId,
      'type': type,
      'companyName': companyName,
      'network': network,
      'phoneNumber': phoneNumber,
      'amount': amount,
      'taxAmount': taxAmount,
      'totalAmount': totalAmount,
      'currency': currency,
      'packageName': packageName,
      'packageData': packageData,
      'packageValidity': packageValidity,
      'cardId': cardId,
      'cardHolderName': cardHolderName,
      'cardEnding': cardEnding,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  TransactionModel copyWith({
    String? id,
    String? userId,
    String? type,
    String? companyName,
    String? network,
    String? phoneNumber,
    double? amount,
    double? taxAmount,
    double? totalAmount,
    String? currency,
    String? packageName,
    String? packageData,
    String? packageValidity,
    String? cardId,
    String? cardHolderName,
    String? cardEnding,
    String? status,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      companyName: companyName ?? this.companyName,
      network: network ?? this.network,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      amount: amount ?? this.amount,
      taxAmount: taxAmount ?? this.taxAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      currency: currency ?? this.currency,
      packageName: packageName ?? this.packageName,
      packageData: packageData ?? this.packageData,
      packageValidity: packageValidity ?? this.packageValidity,
      cardId: cardId ?? this.cardId,
      cardHolderName: cardHolderName ?? this.cardHolderName,
      cardEnding: cardEnding ?? this.cardEnding,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}