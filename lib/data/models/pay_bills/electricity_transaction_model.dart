class ElectricityTransactionModel {
  final String id;
  final String userId;
  final String type; // 'electricity_bill'
  final String providerName;
  final String accountNumber;
  final String consumerName;
  final String address;
  final String billMonth;
  final double amount;
  final double taxAmount;
  final double totalAmount;
  final String currency;
  final String dueDate;
  final String cardId;
  final String cardHolderName;
  final String cardEnding;
  final String status; // 'pending', 'completed', 'failed'
  final DateTime createdAt;
  final DateTime? completedAt;

  ElectricityTransactionModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.providerName,
    required this.accountNumber,
    required this.consumerName,
    required this.address,
    required this.billMonth,
    required this.amount,
    required this.taxAmount,
    required this.totalAmount,
    required this.currency,
    required this.dueDate,
    required this.cardId,
    required this.cardHolderName,
    required this.cardEnding,
    required this.status,
    required this.createdAt,
    this.completedAt,
  });

  factory ElectricityTransactionModel.fromJson(Map<String, dynamic> json) {
    return ElectricityTransactionModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      type: json['type'] as String,
      providerName: json['providerName'] as String,
      accountNumber: json['accountNumber'] as String,
      consumerName: json['consumerName'] as String,
      address: json['address'] as String,
      billMonth: json['billMonth'] as String,
      amount: (json['amount'] as num).toDouble(),
      taxAmount: (json['taxAmount'] as num).toDouble(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      currency: json['currency'] as String,
      dueDate: json['dueDate'] as String,
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
      'providerName': providerName,
      'accountNumber': accountNumber,
      'consumerName': consumerName,
      'address': address,
      'billMonth': billMonth,
      'amount': amount,
      'taxAmount': taxAmount,
      'totalAmount': totalAmount,
      'currency': currency,
      'dueDate': dueDate,
      'cardId': cardId,
      'cardHolderName': cardHolderName,
      'cardEnding': cardEnding,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }
}