import 'dart:convert';
import '../../data/models/currency_model.dart';
import '../../core/constants/currency_data_json.dart';

class CurrencyViewmodel {
  List<Currency> currencies = [];
  bool isLoading = false;
  String? errorMessage;

  CurrencyViewmodel() {
    loadCurrencies();
  }

  void loadCurrencies() {
    try {
      isLoading = true;
      errorMessage = null;

      // Parse the JSON string from currencyData
      List<dynamic> currenciesList = jsonDecode(currencyData);

      // Convert to Currency objects
      currencies = currenciesList.map((currencyJson) {
        return Currency.fromJson(currencyJson as Map<String, dynamic>);
      }).toList();

      isLoading = false;
      print('Successfully loaded ${currencies.length} currencies');
    } catch (e) {
      isLoading = false;
      errorMessage = 'Error loading currencies: $e';
      print(errorMessage);

      // Provide fallback currencies
      currencies = _getFallbackCurrencies();
    }
  }

  List<Currency> _getFallbackCurrencies() {
    return [
      Currency(
        code: 'USD',
        name: 'US Dollar',
        country: 'United States',
        countryCode: 'US',
        flag: '🇺🇸',
      ),
      Currency(
        code: 'EUR',
        name: 'Euro',
        country: 'European Union',
        countryCode: 'EU',
        flag: '🇪🇺',
      ),
      Currency(
        code: 'GBP',
        name: 'British Pound',
        country: 'United Kingdom',
        countryCode: 'GB',
        flag: '🇬🇧',
      ),
      Currency(
        code: 'JPY',
        name: 'Japanese Yen',
        country: 'Japan',
        countryCode: 'JP',
        flag: '🇯🇵',
      ),
      Currency(
        code: 'AUD',
        name: 'Australian Dollar',
        country: 'Australia',
        countryCode: 'AU',
        flag: '🇦🇺',
      ),
      Currency(
        code: 'CAD',
        name: 'Canadian Dollar',
        country: 'Canada',
        countryCode: 'CA',
        flag: '🇨🇦',
      ),
      Currency(
        code: 'CHF',
        name: 'Swiss Franc',
        country: 'Switzerland',
        countryCode: 'CH',
        flag: '🇨🇭',
      ),
      Currency(
        code: 'CNY',
        name: 'Chinese Yuan',
        country: 'China',
        countryCode: 'CN',
        flag: '🇨🇳',
      ),
      Currency(
        code: 'INR',
        name: 'Indian Rupee',
        country: 'India',
        countryCode: 'IN',
        flag: '🇮🇳',
      ),
      Currency(
        code: 'PKR',
        name: 'Pakistani Rupee',
        country: 'Pakistan',
        countryCode: 'PK',
        flag: '🇵🇰',
      ),
      Currency(
        code: 'SAR',
        name: 'Saudi Riyal',
        country: 'Saudi Arabia',
        countryCode: 'SA',
        flag: '🇸🇦',
      ),
      Currency(
        code: 'AED',
        name: 'UAE Dirham',
        country: 'United Arab Emirates',
        countryCode: 'AE',
        flag: '🇦🇪',
      ),
      Currency(
        code: 'TRY',
        name: 'Turkish Lira',
        country: 'Turkey',
        countryCode: 'TR',
        flag: '🇹🇷',
      ),
      Currency(
        code: 'BRL',
        name: 'Brazilian Real',
        country: 'Brazil',
        countryCode: 'BR',
        flag: '🇧🇷',
      ),
      Currency(
        code: 'ZAR',
        name: 'South African Rand',
        country: 'South Africa',
        countryCode: 'ZA',
        flag: '🇿🇦',
      ),
    ];
  }

  Currency? getCurrencyByCode(String code) {
    try {
      return currencies.firstWhere(
        (currency) => currency.code.toUpperCase() == code.toUpperCase(),
      );
    } catch (e) {
      return null;
    }
  }

  List<Currency> searchCurrencies(String query) {
    if (query.isEmpty) return currencies;

    query = query.toLowerCase();
    return currencies.where((currency) {
      return currency.code.toLowerCase().contains(query) ||
          currency.name.toLowerCase().contains(query) ||
          currency.country.toLowerCase().contains(query);
    }).toList();
  }
}
