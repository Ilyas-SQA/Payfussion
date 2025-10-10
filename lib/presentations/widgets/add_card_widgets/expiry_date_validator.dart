import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text.replaceAll('/', '');
    if (text.length > 4) return oldValue;

    String formatted = '';
    if (text.length >= 3) {
      formatted = '${text.substring(0, 2)}/${text.substring(2)}';
    } else if (text.isNotEmpty) {
      formatted = text;
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

bool isExpiryDateValid(String expiryDate) {
  if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(expiryDate)) return false;

  final parts = expiryDate.split('/');
  final month = int.tryParse(parts[0]);
  final year = int.tryParse(parts[1]);

  if (month == null || year == null || month < 1 || month > 12) return false;

  final now = DateTime.now();
  final currentYear = int.parse(DateFormat('yy').format(now));
  final currentMonth = now.month;

  if (year < currentYear || (year == currentYear && month < currentMonth)) {
    return false;
  }

  return true;
}