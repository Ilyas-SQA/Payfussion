class PaymentAccount {
  final String id;
  final String name;
  final String accountNumber;
  final String cardType;
  final double balance;
  final String imageUrl;
  final bool isDefault;

  const PaymentAccount({
    required this.id,
    required this.name,
    required this.accountNumber,
    required this.cardType,
    required this.balance,
    this.imageUrl = '',
    this.isDefault = false,
  });
}