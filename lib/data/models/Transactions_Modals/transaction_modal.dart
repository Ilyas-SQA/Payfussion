class TransactionModel {
  final String id;
  final String title;
  final double amount;
  final String status; // e.g., "Pending", "Completed"
  final DateTime dateTime;
  final String iconPath;

  TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.status,
    required this.dateTime,
    required this.iconPath,
  });

  // This will be useful when fetching from Firebase
  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      status: map['status'] ?? 'Pending',
      dateTime: map['dateTime']?.toDate() ?? DateTime.now(),
      iconPath: map['iconPath'] ?? 'assets/icons/transaction_screen_icons/default_icon.png',
    );
  }
}