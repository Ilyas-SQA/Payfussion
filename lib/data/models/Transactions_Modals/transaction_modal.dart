class TransactionModel {
  final String id;
  final String title;
  final double amount;
  final String status;
  final DateTime dateTime;
  final String iconPath;
  final Map<String, dynamic>? additionalData; // NEW: Store all extra data

  TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.status,
    required this.dateTime,
    required this.iconPath,
    this.additionalData, // NEW
  });

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      status: map['status'] ?? 'Pending',
      dateTime: map['dateTime']?.toDate() ?? DateTime.now(),
      iconPath: map['iconPath'] ?? 'assets/icons/transaction_screen_icons/default_icon.png',
      additionalData: map, // NEW: Store complete data
    );
  }
}