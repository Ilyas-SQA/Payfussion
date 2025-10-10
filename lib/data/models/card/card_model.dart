// lib/data/models/card_model.dart
class CardModel {
  final String id;
  final String brand;
  final String last4;
  final String expMonth;
  final String expYear;
  final DateTime createDate;
  final String paymentMethodId;
  final String stripeCustomerId;
  final bool isDefault;

  const CardModel({
    required this.id,
    required this.brand,
    required this.last4,
    required this.expMonth,
    required this.expYear,
    required this.createDate,
    required this.paymentMethodId,
    required this.stripeCustomerId,
    this.isDefault = false,
  });

  // Factory constructor to create from Firestore document
  factory CardModel.fromFirestore(Map<String, dynamic> data, String documentId) {
    return CardModel(
      id: documentId,
      brand: data['brand'] ?? '',
      last4: data['last4'] ?? '',
      expMonth: data['exp_month']?.toString() ?? '',
      expYear: data['exp_year']?.toString() ?? '',
      createDate: data['create_date']?.toDate() ?? DateTime.now(),
      paymentMethodId: data['payment_method_id'] ?? '',
      stripeCustomerId: data['stripe_customer_id'] ?? '',
      isDefault: data['is_default'] ?? false,
    );
  }

  // Convert to Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'brand': brand,
      'last4': last4,
      'exp_month': expMonth,
      'exp_year': expYear,
      'create_date': createDate,
      'payment_method_id': paymentMethodId,
      'stripe_customer_id': stripeCustomerId,
      'is_default': isDefault,
    };
  }

  // Get card ending format
  String get cardEnding => '***$last4';

  // Get brand icon path
  String get brandIconPath {
    switch (brand.toLowerCase()) {
      case 'visa':
        return 'assets/icons/visa_logo.png';
      case 'mastercard':
        return 'assets/icons/mastercard.png';
      case 'amex':
        return 'assets/icons/amex.png';
      default:
        return 'assets/icons/card_default.png';
    }
  }

  // Get formatted expiry
  String get formattedExpiry => '$expMonth/$expYear';

  // Copy with method for updates
  CardModel copyWith({
    String? id,
    String? brand,
    String? last4,
    String? expMonth,
    String? expYear,
    DateTime? createDate,
    String? paymentMethodId,
    String? stripeCustomerId,
    bool? isDefault,
  }) {
    return CardModel(
      id: id ?? this.id,
      brand: brand ?? this.brand,
      last4: last4 ?? this.last4,
      expMonth: expMonth ?? this.expMonth,
      expYear: expYear ?? this.expYear,
      createDate: createDate ?? this.createDate,
      paymentMethodId: paymentMethodId ?? this.paymentMethodId,
      stripeCustomerId: stripeCustomerId ?? this.stripeCustomerId,
      isDefault: isDefault ?? this.isDefault,
    );
  }

}