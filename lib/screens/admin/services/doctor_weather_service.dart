import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:neuroinsight/screens/admin/models/doctor_weather_model.dart';

class WeatherService {
  static const String _apiKey = '50407f4c1555467da068409cca3d72e2';
  // --- ✅ CHANGED: Using the reliable 5-day forecast endpoint ---
  static const String _forecastUrl = 'https://api.openweathermap.org/data/2.5/forecast';

  Future<WeatherModel> getWeather(double lat, double lon) async {
    // --- ✅ MODIFIED: Simplified to a single API call ---
    final forecastUri = Uri.parse('$_forecastUrl?lat=$lat&lon=$lon&appid=$_apiKey&units=metric');
    final response = await http.get(forecastUri);

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      // Use the new factory constructor to create the WeatherModel
      return WeatherModel.fromForecastJson(jsonData);
    } else {
      // Throw a more descriptive error to help with debugging
      throw Exception('Failed to load weather forecast. Status: ${response.statusCode}, Body: ${response.body}');
    }
  }
}