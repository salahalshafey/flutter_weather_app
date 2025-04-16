import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_data.dart';

class WeatherService {
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';
  static const String _apiKey =
      '84014c2fb00a92237eddf64a60c62b6a'; // Replace with your actual API key

  Future<WeatherData> getCurrentWeather(String city) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/weather?q=$city&units=metric&appid=$_apiKey'),
    );

    if (response.statusCode == 200) {
      return WeatherData.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  Future<List<ForecastData>> getForecast(String city) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/forecast?q=$city&units=metric&appid=$_apiKey'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> list = data['list'];
      return list.map((item) => ForecastData.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load forecast data');
    }
  }
}
