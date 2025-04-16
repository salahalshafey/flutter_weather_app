import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/weather_data.dart';

class WeatherService {
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';
  String? _apiKey;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _apiKey = prefs.getString('weatherApiKey');
  }

  Future<void> saveApiKey(String apiKey) async {
    _apiKey = apiKey;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('weatherApiKey', apiKey);
  }

  String? get apiKey => _apiKey;

  Future<String?> getLastSearchedCity() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('lastSearchedCity');
  }

  Future<void> saveLastSearchedCity(String city) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastSearchedCity', city);
  }

  Future<WeatherData> fetchWeatherData(String city) async {
    if (_apiKey == null || _apiKey!.isEmpty) {
      throw Exception('API key is not set');
    }

    // Fetch current weather
    final currentResponse = await http.get(
        Uri.parse('$_baseUrl/weather?q=$city&appid=$_apiKey&units=metric'));

    if (currentResponse.statusCode != 200) {
      throw Exception(
          'Failed to load weather data (${currentResponse.statusCode})');
    }

    final currentData = json.decode(currentResponse.body);

    // Fetch 5-day forecast
    final forecastResponse = await http.get(
        Uri.parse('$_baseUrl/forecast?q=$city&appid=$_apiKey&units=metric'));

    if (forecastResponse.statusCode != 200) {
      throw Exception(
          'Failed to load forecast data (${forecastResponse.statusCode})');
    }

    final forecast = json.decode(forecastResponse.body);

    // Save last searched city
    await saveLastSearchedCity(city);

    return WeatherData.fromJson(
        currentWeather: currentData, forecastData: forecast);
  }
}
