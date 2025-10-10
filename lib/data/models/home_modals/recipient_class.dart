// class Recipient {
//   final String id;
//   final String name;
//   final String imageUrl;
//   final String maskedIdentifier; // e.g., "••••1234"
//   final String paymentMethodType; // e.g., "Bank Account", "Mobile Wallet"
//   final String institutionName; // e.g., "Chase Bank", "M-Pesa"
//   final String? countryCode;
//   final String? currencyCode;
//   final String? accountNumber; // Added from add_recipient_screen.dart
//
//   const Recipient({
//     required this.id,
//     required this.name,
//     this.imageUrl = '',
//     this.maskedIdentifier = '',
//     this.paymentMethodType = 'Bank Account',
//     required this.institutionName,
//     this.countryCode,
//     this.currencyCode,
//     this.accountNumber,
//   });
//
//   // Helper getter to maintain backward compatibility
//   String? get bankName => institutionName;
//
//   factory Recipient.fromJson(Map<String, dynamic> json) {
//     return Recipient(
//       id: json['id'] as String,
//       name: json['name'] as String,
//       imageUrl: json['imageUrl'] as String? ?? '',
//       maskedIdentifier: json['maskedIdentifier'] as String? ?? '',
//       paymentMethodType: json['paymentMethodType'] as String? ?? 'Bank Account',
//       institutionName: json['institutionName'] as String? ?? json['bankName'] as String? ?? '',
//       countryCode: json['countryCode'] as String?,
//       currencyCode: json['currencyCode'] as String?,
//       accountNumber: json['accountNumber'] as String?,
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'name': name,
//       'imageUrl': imageUrl,
//       'maskedIdentifier': maskedIdentifier,
//       'paymentMethodType': paaymentMethodType,
//       'institutionName': institutionName,
//       'countryCode': countryCode,
//       'currencyCode': currencyCode,
//       'accountNumber': accountNumber,
//     };
//   }
// }