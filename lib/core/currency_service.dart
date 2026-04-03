
import 'dart:convert';
import 'package:http/http.dart' as http;

class CurrencyService {
  static const String _apiKey = '225a515afb1cd8ea06950e62b3f04316';
  static const String _baseUrl = 'http://data.fixer.io/api';

  static Future<double> getExchangeRate(String from, String to) async {
    try {
      // Fixer.io Free tier usually uses EUR as base.
      // We'll fetch latest rates and calculate relative to EUR if needed.
      final response = await http.get(Uri.parse('$_baseUrl/latest?access_key=$_apiKey&symbols=$from,$to'));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final rates = data['rates'];
          final fromRate = rates[from] ?? 1.0;
          final toRate = rates[to] ?? 1.0;
          
          // Calculate: (1 / fromRate) * toRate = rate for 1 from to to
          return (1.0 / fromRate) * toRate;
        }
      }
      return 82.5; // Fallback
    } catch (e) {
      return 82.5; // Fallback
    }
  }
}
