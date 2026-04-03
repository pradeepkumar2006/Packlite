import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherData {
  final String city;
  final double temp;
  final double feelsLike;
  final String condition;
  final String description;
  final DateTime time;

  WeatherData({
    required this.city,
    required this.temp,
    required this.feelsLike,
    required this.condition,
    required this.description,
    required this.time,
  });
}

class WeatherService {
  static const String _apiKey = '3c99f665eb532f3d2ec20b3b1538ac84';
  
  static Future<WeatherData?> fetchWeather(String city) async {
    try {
      // Using http because WeatherStack free tier doesn't support https
      final url = Uri.http('api.weatherstack.com', '/current', {
        'access_key': _apiKey,
        'query': city,
      });
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // WeatherStack error handling
        if (data['error'] != null) {
          return null;
        }

        final descriptions = data['current']['weather_descriptions'] as List?;
        final cond = (descriptions != null && descriptions.isNotEmpty) 
            ? descriptions.first.toString() 
            : 'Unknown';

        return WeatherData(
          city: data['location']?['name']?.toString() ?? 'Unknown',
          temp: (data['current']?['temperature'] as num?)?.toDouble() ?? 0.0,
          feelsLike: (data['current']?['feelslike'] as num?)?.toDouble() ?? 0.0,
          condition: cond,
          description: cond,
          time: DateTime.now(),
        );
      }
    } catch (e) {
      // Handle exception properly in a production app
    }
    return null;
  }
}
