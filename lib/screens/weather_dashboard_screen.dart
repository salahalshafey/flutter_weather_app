import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/weather_data.dart';
import '../services/weather_service.dart';
import '../providers/theme_provider.dart';
import '../widgets/search_bar.dart';
import '../widgets/main_weather_card.dart';
import '../widgets/wind_pressure_card.dart';
import '../widgets/humidity_clouds_card.dart';
import '../widgets/forecast_card.dart';

class WeatherDashboardScreen extends StatefulWidget {
  const WeatherDashboardScreen({super.key});

  @override
  State<WeatherDashboardScreen> createState() => _WeatherDashboardScreenState();
}

class _WeatherDashboardScreenState extends State<WeatherDashboardScreen> {
  final WeatherService _weatherService = WeatherService();
  final TextEditingController _searchController = TextEditingController();
  WeatherData? _weatherData;
  List<ForecastData> _forecastData = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchWeatherData('London'); // Default city
  }

  Future<void> _fetchWeatherData(String city) async {
    try {
      setState(() => _error = null);
      final weather = await _weatherService.getCurrentWeather(city);
      final forecast = await _weatherService.getForecast(city);
      setState(() {
        _weatherData = weather;
        _forecastData = forecast;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load weather data. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather App'),
        actions: [
          IconButton(
            icon: Icon(
              Provider.of<ThemeProvider>(context).isDarkMode
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () {
              Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          WeatherSearchBar(
            controller: _searchController,
            onSearch: _fetchWeatherData,
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                _error!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            )
          else if (_weatherData == null)
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          else
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => _fetchWeatherData(_weatherData!.cityName),
                child: ListView(
                  children: [
                    MainWeatherCard(weather: _weatherData!),
                    WindPressureCard(
                      windSpeed: _weatherData!.windSpeed,
                      windDegree: _weatherData!.windDegree,
                      pressure: _weatherData!.pressure,
                    ),
                    HumidityCloudCard(
                      humidity: _weatherData!.humidity,
                      cloudiness: _weatherData!.cloudiness,
                    ),
                    if (_forecastData.isNotEmpty)
                      ForecastCard(forecast: _forecastData),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
