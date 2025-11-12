import 'dart:convert';
import 'package:http/http.dart' as http;

class CurrencyApiService {
  // Free API - exchangerate-api.com (aap apni API key use kar sakte hain)
  static const String _baseUrl = 'https://api.exchangerate-api.com/v4/latest';

  // Alternative: Fixer.io (API key required)
  // static const String _apiKey = 'YOUR_API_KEY';
  // static const String _baseUrl = 'https://data.fixer.io/api/latest?access_key=$_apiKey';

  /// Get exchange rates for a specific base currency
  Future<Map<String, dynamic>> getExchangeRates(String baseCurrency) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/$baseCurrency'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load exchange rates');
      }
    } catch (e) {
      throw Exception('Error fetching exchange rates: $e');
    }
  }

  /// Convert amount from source to target currency
  Future<double> convertCurrency({
    required String from,
    required String to,
    required double amount,
  }) async {
    try {
      final data = await getExchangeRates(from);
      final rates = data['rates'] as Map<String, dynamic>;

      if (rates.containsKey(to)) {
        final rate = rates[to] as num;
        return amount * rate.toDouble();
      } else {
        throw Exception('Currency $to not found');
      }
    } catch (e) {
      throw Exception('Conversion error: $e');
    }
  }

  /// Get last update time
  Future<DateTime> getLastUpdateTime(String baseCurrency) async {
    try {
      final data = await getExchangeRates(baseCurrency);
      final timestamp = data['time_last_updated'] as int;
      return DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    } catch (e) {
      return DateTime.now();
    }
  }
}