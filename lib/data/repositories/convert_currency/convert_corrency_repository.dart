import 'dart:convert';

import 'package:http/http.dart' as http;

class CurrencyRepository {
  static const String _baseUrl = 'https://api.exchangerate-api.com/v4';

  Future<Map<String, double>> getExchangeRates({String baseCurrency = 'USD'}) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/latest/$baseCurrency'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Map<String, double>.from(
          data['rates'].map((key, value) => MapEntry(key, value.toDouble())),
        );
      } else {
        throw Exception('Failed to load exchange rates');
      }
    } catch (e) {
      throw Exception('Error fetching exchange rates: $e');
    }
  }

  Future<double> convertCurrency({
    required String from,
    required String to,
    required double amount,
  }) async {
    final rates = await getExchangeRates(baseCurrency: from);
    final rate = rates[to];
    if (rate == null) {
      throw Exception('Exchange rate not found for $from to $to');
    }
    return amount * rate;
  }
}