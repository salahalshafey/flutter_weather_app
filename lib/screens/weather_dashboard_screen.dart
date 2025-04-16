import 'package:flutter/material.dart';

import '../models/weather_data.dart';
import '../providers/theme_provider.dart';
import '../services/weather_service.dart';
import '../widgets/search_bar.dart';
import '../widgets/main_weather_card.dart';
import '../widgets/wind_pressure_card.dart';
import '../widgets/humidity_clouds_card.dart';
import '../widgets/forecast_card.dart';

class WeatherDashboardScreen extends StatefulWidget {
  final ThemeProvider themeProvider;

  const WeatherDashboardScreen({
    Key? key,
    required this.themeProvider,
  }) : super(key: key);

  @override
  State<WeatherDashboardScreen> createState() => _WeatherDashboardScreenState();
}

class _WeatherDashboardScreenState extends State<WeatherDashboardScreen> {
  final TextEditingController _cityController = TextEditingController();
  final WeatherService _weatherService = WeatherService();
  WeatherData? _weatherData;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeWeatherService();
  }

  Future<void> _initializeWeatherService() async {
    await _weatherService.initialize();
    _loadLastCity();
  }

  Future<void> _loadLastCity() async {
    String? lastCity = await _weatherService.getLastSearchedCity();
    if (lastCity != null && lastCity.isNotEmpty) {
      _cityController.text = lastCity;
      _fetchWeatherData(lastCity);
    }
  }

  void _promptForApiKey() async {
    await Future.delayed(Duration.zero);
    _showApiKeyDialog();
  }

  void _showApiKeyDialog() {
    final apiKeyController = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('OpenWeatherMap API Key'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
                'Please enter your OpenWeatherMap API key to fetch weather data.'),
            const SizedBox(height: 16),
            TextField(
              controller: apiKeyController,
              decoration: const InputDecoration(
                labelText: 'API Key',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('Save'),
            onPressed: () async {
              if (apiKeyController.text.isNotEmpty) {
                await _weatherService.saveApiKey(apiKeyController.text);
                Navigator.of(context).pop();

                // If there's a city in the text field, fetch weather
                if (_cityController.text.isNotEmpty) {
                  _fetchWeatherData(_cityController.text);
                }
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _fetchWeatherData(String city) async {
    if (_weatherService.apiKey == null || _weatherService.apiKey!.isEmpty) {
      _promptForApiKey();
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final weatherData = await _weatherService.fetchWeatherData(city);

      setState(() {
        _weatherData = weatherData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get screen width to determine layout
    double width = MediaQuery.of(context).size.width;
    bool isLargeScreen = width > 1000;
    bool isMediumScreen = width > 700 && width <= 1000;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather Dashboard'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(widget.themeProvider.isDarkMode
                ? Icons.light_mode
                : Icons.dark_mode),
            onPressed: () => widget.themeProvider.toggleTheme(),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1400),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Search Bar
                  WeatherSearchBar(
                    controller: _cityController,
                    onSearch: _fetchWeatherData,
                  ),

                  const SizedBox(height: 16),

                  // Error Message
                  if (_errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red[300]!),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red[900]),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  // Loading Indicator
                  if (_isLoading)
                    const SizedBox(
                      height: 100,
                      child: Center(child: CircularProgressIndicator()),
                    ),

                  // Weather Dashboard - Responsive Layout
                  if (!_isLoading && _weatherData != null)
                    Expanded(
                      child: SingleChildScrollView(
                        child: isLargeScreen
                            ? _buildLargeScreenLayout()
                            : isMediumScreen
                                ? _buildMediumScreenLayout()
                                : _buildSmallScreenLayout(),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Large Screen Layout (Desktop/Tablet Landscape)
  Widget _buildLargeScreenLayout() {
    return Column(
      children: [
        // First row: Main weather card, Wind & Pressure, Humidity & Clouds
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main Weather Card
            Expanded(
              flex: 2,
              child: MainWeatherCard(
                currentWeather: _weatherData!.currentWeather,
              ),
            ),
            const SizedBox(width: 16),
            // Right column with two cards
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  WindPressureCard(
                    currentWeather: _weatherData!.currentWeather,
                  ),
                  const SizedBox(height: 16),
                  HumidityCloudsCard(
                    currentWeather: _weatherData!.currentWeather,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Second row: Forecast
        ForecastCard(
          dailyForecasts: _weatherData!.getDailyForecasts(),
        ),
      ],
    );
  }

  // Medium Screen Layout (Tablet Portrait)
  Widget _buildMediumScreenLayout() {
    return Column(
      children: [
        // First row: Main weather card and Wind & Pressure
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main Weather Card
            Expanded(
              flex: 1,
              child: MainWeatherCard(
                currentWeather: _weatherData!.currentWeather,
              ),
            ),
            const SizedBox(width: 16),
            // Wind & Pressure Card
            Expanded(
              flex: 1,
              child: WindPressureCard(
                currentWeather: _weatherData!.currentWeather,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Second row: Humidity & Clouds Card
        HumidityCloudsCard(
          currentWeather: _weatherData!.currentWeather,
        ),
        const SizedBox(height: 16),
        // Third row: Forecast
        ForecastCard(
          dailyForecasts: _weatherData!.getDailyForecasts(),
        ),
      ],
    );
  }

  // Small Screen Layout (Mobile)
  Widget _buildSmallScreenLayout() {
    return Column(
      children: [
        // Stacked layout for small screens
        MainWeatherCard(
          currentWeather: _weatherData!.currentWeather,
        ),
        const SizedBox(height: 16),
        WindPressureCard(
          currentWeather: _weatherData!.currentWeather,
        ),
        const SizedBox(height: 16),
        HumidityCloudsCard(
          currentWeather: _weatherData!.currentWeather,
        ),
        const SizedBox(height: 16),
        ForecastCard(
          dailyForecasts: _weatherData!.getDailyForecasts(),
        ),
      ],
    );
  }
}
