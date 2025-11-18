// lib/data/models/card_model.dart

class CardModel {
  final String id;
  final String brand;
  final String last4;
  final String expMonth;
  final String expYear;
  final String funding;
  final String paymentMethodId;
  final String customerId;
  final String createdBy;
  final DateTime createDate;
  final DateTime updatedAt;
  final bool isDefault;

  // Cardholder info
  final String cardholderName;
  final String cardholderEmail;
  final String cardholderPhone;

  // Billing address (nested map)
  final BillingAddress? billingAddress;

  const CardModel({
    required this.id,
    required this.brand,
    required this.last4,
    required this.expMonth,
    required this.expYear,
    required this.funding,
    required this.paymentMethodId,
    required this.customerId,
    required this.createdBy,
    required this.createDate,
    required this.updatedAt,
    required this.isDefault,
    required this.cardholderName,
    required this.cardholderEmail,
    required this.cardholderPhone,
    this.billingAddress,
  });

  // ✅ Factory constructor to create from Firestore
  factory CardModel.fromFirestore(Map<String, dynamic> data, String documentId) {
    return CardModel(
      id: documentId,
      brand: data['brand'] ?? '',
      last4: data['last4'] ?? '',
      expMonth: data['exp_month']?.toString() ?? '',
      expYear: data['exp_year']?.toString() ?? '',
      funding: data['funding'] ?? '',
      paymentMethodId: data['payment_method_id'] ?? '',
      customerId: data['customer_id'] ?? '',
      createdBy: data['created_by'] ?? '',
      createDate: data['create_date']?.toDate() ?? DateTime.now(),
      updatedAt: data['updated_at']?.toDate() ?? DateTime.now(),
      isDefault: data['is_default'] ?? false,
      cardholderName: data['cardholder_name'] ?? '',
      cardholderEmail: data['cardholder_email'] ?? '',
      cardholderPhone: data['cardholder_phone'] ?? '',
      billingAddress: data['billing_address'] != null
          ? BillingAddress.fromMap(data['billing_address'])
          : null,
    );
  }

  // ✅ Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'brand': brand,
      'last4': last4,
      'exp_month': expMonth,
      'exp_year': expYear,
      'funding': funding,
      'payment_method_id': paymentMethodId,
      'customer_id': customerId,
      'created_by': createdBy,
      'create_date': createDate,
      'updated_at': updatedAt,
      'is_default': isDefault,
      'cardholder_name': cardholderName,
      'cardholder_email': cardholderEmail,
      'cardholder_phone': cardholderPhone,
      if (billingAddress != null) 'billing_address': billingAddress!.toMap(),
    };
  }

  // ✅ Helper methods
  String get cardEnding => '**** **** **** $last4';
  String get formattedExpiry => '$expMonth/$expYear';

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

  // ✅ Copy with method
  CardModel copyWith({
    String? id,
    String? brand,
    String? last4,
    String? expMonth,
    String? expYear,
    String? funding,
    String? paymentMethodId,
    String? customerId,
    String? createdBy,
    DateTime? createDate,
    DateTime? updatedAt,
    bool? isDefault,
    String? cardholderName,
    String? cardholderEmail,
    String? cardholderPhone,
    BillingAddress? billingAddress,
  }) {
    return CardModel(
      id: id ?? this.id,
      brand: brand ?? this.brand,
      last4: last4 ?? this.last4,
      expMonth: expMonth ?? this.expMonth,
      expYear: expYear ?? this.expYear,
      funding: funding ?? this.funding,
      paymentMethodId: paymentMethodId ?? this.paymentMethodId,
      customerId: customerId ?? this.customerId,
      createdBy: createdBy ?? this.createdBy,
      createDate: createDate ?? this.createDate,
      updatedAt: updatedAt ?? this.updatedAt,
      isDefault: isDefault ?? this.isDefault,
      cardholderName: cardholderName ?? this.cardholderName,
      cardholderEmail: cardholderEmail ?? this.cardholderEmail,
      cardholderPhone: cardholderPhone ?? this.cardholderPhone,
      billingAddress: billingAddress ?? this.billingAddress,
    );
  }
}

// ✅ Nested model for Billing Address
class BillingAddress {
  final String city;
  final String country;
  final String line1;
  final String line2;
  final String postalCode;
  final String state;

  const BillingAddress({
    required this.city,
    required this.country,
    required this.line1,
    required this.line2,
    required this.postalCode,
    required this.state,
  });

  factory BillingAddress.fromMap(Map<String, dynamic> map) {
    return BillingAddress(
      city: map['city'] ?? '',
      country: map['country'] ?? '',
      line1: map['line1'] ?? '',
      line2: map['line2'] ?? '',
      postalCode: map['postal_code'] ?? '',
      state: map['state'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'city': city,
      'country': country,
      'line1': line1,
      'line2': line2,
      'postal_code': postalCode,
      'state': state,
    };
  }
}
