class Currency {
  String code;
  String name;
  String country;
  String countryCode;
  String flag;
  String? symbole;

  Currency({
    required this.code,
    required this.name,
    required this.country,
    required this.countryCode,
    required this.flag,
    this.symbole,
  });

  // Factory method to create a Currency instance from JSON
  factory Currency.fromJson(Map<String, dynamic> json) {
    return Currency(
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      country: json['country'] ?? '',
      countryCode: json['countryCode'] ?? '',
      symbole: _getCountryFlag(json['countryCode'] ?? ''),
      flag: _getCountryFlag(json['countryCode'] ?? ''),
    );
  }

  // Method to convert Currency instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'country': country,
      'countryCode': countryCode,
      'flag': flag,
    };
  }

  // Convert country code to flag emoji
  static String _getCountryFlag(String countryCode) {
    if (countryCode.isEmpty || countryCode.length != 2) {
      return '🏳️'; // Default flag
    }

    // Convert country code to flag emoji
    // Each character is converted to its corresponding regional indicator symbol
    String flag = '';
    for (int i = 0; i < countryCode.length; i++) {
      int codeUnit = countryCode.codeUnitAt(i);
      if (codeUnit >= 65 && codeUnit <= 90) {
        // Convert A-Z to regional indicator symbols
        flag += String.fromCharCode(0x1F1E6 + (codeUnit - 65));
      } else if (codeUnit >= 97 && codeUnit <= 122) {
        // Convert a-z to regional indicator symbols
        flag += String.fromCharCode(0x1F1E6 + (codeUnit - 97));
      }
    }

    return flag.isNotEmpty ? flag : '🏳️';
  }
}
