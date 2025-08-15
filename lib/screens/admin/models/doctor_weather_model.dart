// lib/screens/admin/models/doctor_weather_model.dart

class HourlyWeather {
  final DateTime time;
  final double temperature;
  final String iconCode;

  HourlyWeather({
    required this.time,
    required this.temperature,
    required this.iconCode,
  });
}

class WeatherModel {
  final String cityName;
  final double temperature;
  final String condition;
  final String iconCode;
  final List<HourlyWeather> hourlyForecast;

  WeatherModel({
    required this.cityName,
    required this.temperature,
    required this.condition,
    required this.iconCode,
    required this.hourlyForecast,
  });

  // This constructor is no longer used, but we can keep it for reference
  factory WeatherModel.fromOneCallJson(Map<String, dynamic> currentData, Map<String, dynamic> oneCallData) {
    List<HourlyWeather> forecast = [];
    if (oneCallData['hourly'] != null) {
      // Get the next 5 hours of forecast
      for (int i = 1; i < 6 && i < oneCallData['hourly'].length; i++) {
        var hour = oneCallData['hourly'][i];
        forecast.add(HourlyWeather(
          time: DateTime.fromMillisecondsSinceEpoch(hour['dt'] * 1000),
          temperature: hour['temp'].toDouble(),
          iconCode: hour['weather'][0]['icon'],
        ));
      }
    }

    return WeatherModel(
      cityName: currentData['name'],
      temperature: currentData['main']['temp'].toDouble(),
      condition: currentData['weather'][0]['main'],
      iconCode: currentData['weather'][0]['icon'],
      hourlyForecast: forecast,
    );
  }

  // --- ✅ ADDED: New factory for the 5-day/3-hour forecast endpoint ---
  factory WeatherModel.fromForecastJson(Map<String, dynamic> json) {
    final List<dynamic> forecastList = json['list'];

    // Current weather details are taken from the first item in the forecast list
    final currentWeather = forecastList.first;

    // Hourly forecast details are taken from the subsequent items
    List<HourlyWeather> forecast = [];
    // Get the next 5 forecast intervals (which are 3 hours apart)
    for (int i = 1; i < 6 && i < forecastList.length; i++) {
      var entry = forecastList[i];
      forecast.add(HourlyWeather(
        time: DateTime.fromMillisecondsSinceEpoch(entry['dt'] * 1000),
        temperature: entry['main']['temp'].toDouble(),
        iconCode: entry['weather'][0]['icon'],
      ));
    }

    return WeatherModel(
      cityName: json['city']['name'],
      temperature: currentWeather['main']['temp'].toDouble(),
      condition: currentWeather['weather'][0]['main'],
      iconCode: currentWeather['weather'][0]['icon'],
      hourlyForecast: forecast,
    );
  }
}