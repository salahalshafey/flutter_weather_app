import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(WeatherApp());
}

class WeatherApp extends StatefulWidget {
  const WeatherApp({super.key});

  @override
  State<WeatherApp> createState() => _WeatherAppState();
}

class _WeatherAppState extends State<WeatherApp> {
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
  }

  void _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('darkMode') ?? false;
    });
  }

  void toggleTheme() async {
    setState(() {
      isDarkMode = !isDarkMode;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', isDarkMode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Weather Dashboard',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: isDarkMode ? Brightness.dark : Brightness.light,
        scaffoldBackgroundColor:
            isDarkMode ? Color(0xFF1A1A2E) : Color(0xFFF5F7FA),
        cardColor: isDarkMode ? Color(0xFF16213E) : Colors.white,
        textTheme: TextTheme(
          bodyLarge: TextStyle(
            color: isDarkMode ? Color(0xFFE6E6E6) : Color(0xFF2C3E50),
          ),
          bodyMedium: TextStyle(
            color: isDarkMode ? Color(0xFFA2A2A2) : Color(0xFF7F8C8D),
          ),
        ),
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.blue,
          brightness: isDarkMode ? Brightness.dark : Brightness.light,
        ),
      ),
      home: WeatherDashboard(toggleTheme: toggleTheme, isDarkMode: isDarkMode),
    );
  }
}

class WeatherDashboard extends StatefulWidget {
  final Function toggleTheme;
  final bool isDarkMode;

  const WeatherDashboard({
    super.key,
    required this.toggleTheme,
    required this.isDarkMode,
  });

  @override
  State<WeatherDashboard> createState() => _WeatherDashboardState();
}

class _WeatherDashboardState extends State<WeatherDashboard> {
  final TextEditingController _cityController = TextEditingController();
  String? apiKey;
  Map<String, dynamic>? currentWeather;
  Map<String, dynamic>? forecastData;
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadApiKey();
    _loadLastCity();
  }

  void _loadApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    String? savedApiKey = prefs.getString('weatherApiKey');
    if (savedApiKey != null && savedApiKey.isNotEmpty) {
      setState(() {
        apiKey = savedApiKey;
      });
    } else {
      _promptForApiKey();
    }
  }

  void _loadLastCity() async {
    final prefs = await SharedPreferences.getInstance();
    String? lastCity = prefs.getString('lastSearchedCity');
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
      builder:
          (context) => AlertDialog(
            title: Text('OpenWeatherMap API Key'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Please enter your OpenWeatherMap API key to fetch weather data.',
                ),
                SizedBox(height: 16),
                TextField(
                  controller: apiKeyController,
                  decoration: InputDecoration(
                    labelText: 'API Key',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                child: Text('Save'),
                onPressed: () async {
                  if (apiKeyController.text.isNotEmpty) {
                    setState(() {
                      apiKey = apiKeyController.text;
                    });

                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setString(
                      'weatherApiKey',
                      apiKeyController.text,
                    );
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          ),
    );
  }

  Future<void> _fetchWeatherData(String city) async {
    if (apiKey == null || apiKey!.isEmpty) {
      _promptForApiKey();
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // Fetch current weather
      final currentResponse = await http.get(
        Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric',
        ),
      );

      if (currentResponse.statusCode != 200) {
        throw Exception(
          'Failed to load weather data (${currentResponse.statusCode})',
        );
      }

      final currentData = json.decode(currentResponse.body);

      // Fetch 5-day forecast
      final forecastResponse = await http.get(
        Uri.parse(
          'https://api.openweathermap.org/data/2.5/forecast?q=$city&appid=$apiKey&units=metric',
        ),
      );

      if (forecastResponse.statusCode != 200) {
        throw Exception(
          'Failed to load forecast data (${forecastResponse.statusCode})',
        );
      }

      final forecast = json.decode(forecastResponse.body);

      // Save last searched city
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('lastSearchedCity', city);

      setState(() {
        currentWeather = currentData;
        forecastData = forecast;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  IconData _getWeatherIcon(String main) {
    switch (main) {
      case 'Clear':
        return FontAwesomeIcons.sun;
      case 'Clouds':
        return FontAwesomeIcons.cloud;
      case 'Rain':
      case 'Drizzle':
        return FontAwesomeIcons.cloudRain;
      case 'Thunderstorm':
        return FontAwesomeIcons.bolt;
      case 'Snow':
        return FontAwesomeIcons.snowflake;
      case 'Mist':
      case 'Smoke':
      case 'Haze':
      case 'Dust':
      case 'Fog':
      case 'Sand':
      case 'Ash':
        return FontAwesomeIcons.smog;
      case 'Squall':
        return FontAwesomeIcons.wind;
      case 'Tornado':
        return FontAwesomeIcons.tornado;
      default:
        return FontAwesomeIcons.cloud;
    }
  }

  String _getWindDirection(int degrees) {
    const directions = [
      'N',
      'NNE',
      'NE',
      'ENE',
      'E',
      'ESE',
      'SE',
      'SSE',
      'S',
      'SSW',
      'SW',
      'WSW',
      'W',
      'WNW',
      'NW',
      'NNW',
    ];
    int index = ((degrees / 22.5) + 0.5).floor() % 16;
    return directions[index];
  }

  String _formatDate(DateTime date) {
    return DateFormat('EEEE, MMMM d, y - hh:mm a').format(date);
  }

  String _formatTime(DateTime date) {
    return DateFormat('hh:mm a').format(date);
  }

  String _formatDay(DateTime date) {
    return DateFormat('EEE, MMM d').format(date);
  }

  List<Map<String, dynamic>> _getDailyForecasts() {
    if (forecastData == null) return [];

    Map<String, dynamic> dailyForecasts = {};
    List<dynamic> forecastList = forecastData!['list'];

    for (var forecast in forecastList) {
      DateTime date = DateTime.fromMillisecondsSinceEpoch(
        forecast['dt'] * 1000,
      );
      String dateStr = DateFormat('yyyy-MM-dd').format(date);

      if (!dailyForecasts.containsKey(dateStr) ||
          (date.hour - 12).abs() <
              (DateTime.fromMillisecondsSinceEpoch(
                        dailyForecasts[dateStr]['dt'] * 1000,
                      ).hour -
                      12)
                  .abs()) {
        dailyForecasts[dateStr] = forecast;
      }
    }

    List<Map<String, dynamic>> result = [];
    dailyForecasts.forEach((key, value) {
      result.add(value);
    });

    return result.take(5).toList();
  }

  @override
  Widget build(BuildContext context) {
    // Get screen width to determine layout
    double width = MediaQuery.of(context).size.width;
    bool isLargeScreen = width > 1000;
    bool isMediumScreen = width > 700 && width <= 1000;

    return Scaffold(
      appBar: AppBar(
        title: Text('Weather Dashboard'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => widget.toggleTheme(),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 1400),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Search Bar - constrained width on large screens
                  Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 500),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _cityController,
                                  decoration: InputDecoration(
                                    hintText: 'Enter city name...',
                                    border: InputBorder.none,
                                  ),
                                  onSubmitted: (value) {
                                    if (value.isNotEmpty) {
                                      _fetchWeatherData(value);
                                    }
                                  },
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.search),
                                onPressed: () {
                                  if (_cityController.text.isNotEmpty) {
                                    _fetchWeatherData(_cityController.text);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 16),

                  // Error Message
                  if (errorMessage != null)
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red[300]!),
                      ),
                      child: Text(
                        errorMessage!,
                        style: TextStyle(color: Colors.red[900]),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  // Loading Indicator
                  if (isLoading)
                    Container(
                      height: 100,
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(),
                    ),

                  // Weather Dashboard - Responsive Layout
                  if (!isLoading && currentWeather != null)
                    Expanded(
                      child: SingleChildScrollView(
                        child:
                            isLargeScreen
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
            Expanded(flex: 2, child: _buildMainWeatherCard()),
            SizedBox(width: 16),
            // Right column with two cards
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  _buildWindPressureCard(),
                  SizedBox(height: 16),
                  _buildHumidityCloudsCard(),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        // Second row: Forecast
        _buildForecastCard(),
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
            Expanded(flex: 1, child: _buildMainWeatherCard()),
            SizedBox(width: 16),
            // Wind & Pressure Card
            Expanded(flex: 1, child: _buildWindPressureCard()),
          ],
        ),
        SizedBox(height: 16),
        // Second row: Humidity & Clouds Card
        _buildHumidityCloudsCard(),
        SizedBox(height: 16),
        // Third row: Forecast
        _buildForecastCard(),
      ],
    );
  }

  // Small Screen Layout (Mobile)
  Widget _buildSmallScreenLayout() {
    return Column(
      children: [
        // Stacked layout for small screens
        _buildMainWeatherCard(),
        SizedBox(height: 16),
        _buildWindPressureCard(),
        SizedBox(height: 16),
        _buildHumidityCloudsCard(),
        SizedBox(height: 16),
        _buildForecastCard(),
      ],
    );
  }

  // Main Weather Card
  Widget _buildMainWeatherCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    '${currentWeather!['name']}, ${currentWeather!['sys']['country']}',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Flexible(
                  child: Text(
                    _formatDate(
                      DateTime.fromMillisecondsSinceEpoch(
                        currentWeather!['dt'] * 1000,
                      ),
                    ),
                    style: Theme.of(context).textTheme.bodyMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            Center(
              child: Column(
                children: [
                  Icon(
                    _getWeatherIcon(currentWeather!['weather'][0]['main']),
                    size: 80,
                    color: Colors.blue,
                  ),
                  SizedBox(height: 16),
                  Text(
                    '${currentWeather!['main']['temp'].round()}°C',
                    style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '${currentWeather!['weather'][0]['description']}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Feels like: ${currentWeather!['main']['feels_like'].round()}°C',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Min: ${currentWeather!['main']['temp_min'].round()}°C',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      SizedBox(width: 16),
                      Text(
                        'Max: ${currentWeather!['main']['temp_max'].round()}°C',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Wind & Pressure Card
  Widget _buildWindPressureCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Wind & Pressure',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _DetailItem(
                    label: 'Wind Speed',
                    value: '${currentWeather!['wind']['speed']} m/s',
                  ),
                ),
                Expanded(
                  child: _DetailItem(
                    label: 'Wind Direction',
                    value: _getWindDirection(
                      currentWeather!['wind']['deg'] as int,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _DetailItem(
                    label: 'Pressure',
                    value: '${currentWeather!['main']['pressure']} hPa',
                  ),
                ),
                Expanded(
                  child: _DetailItem(
                    label: 'Visibility',
                    value:
                        '${(currentWeather!['visibility'] / 1000).toStringAsFixed(1)} km',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Humidity & Clouds Card
  Widget _buildHumidityCloudsCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Humidity & Clouds',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _DetailItem(
                    label: 'Humidity',
                    value: '${currentWeather!['main']['humidity']}%',
                  ),
                ),
                Expanded(
                  child: _DetailItem(
                    label: 'Cloud Cover',
                    value: '${currentWeather!['clouds']['all']}%',
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _DetailItem(
                    label: 'Sunrise',
                    value: _formatTime(
                      DateTime.fromMillisecondsSinceEpoch(
                        currentWeather!['sys']['sunrise'] * 1000,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: _DetailItem(
                    label: 'Sunset',
                    value: _formatTime(
                      DateTime.fromMillisecondsSinceEpoch(
                        currentWeather!['sys']['sunset'] * 1000,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Forecast Card
  Widget _buildForecastCard() {
    if (forecastData == null) return SizedBox();

    // Get screen width to determine forecast item size
    double width = MediaQuery.of(context).size.width;
    double itemWidth =
        width > 1200
            ? 180.0
            : width > 800
            ? 150.0
            : 120.0;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '5-Day Forecast',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            SizedBox(height: 16),
            SizedBox(
              height: 160,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children:
                    _getDailyForecasts().map((forecast) {
                      DateTime date = DateTime.fromMillisecondsSinceEpoch(
                        forecast['dt'] * 1000,
                      );
                      String weatherMain = forecast['weather'][0]['main'];
                      return Container(
                        width: itemWidth,
                        margin: EdgeInsets.only(right: 12),
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _formatDay(date),
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 12),
                            Icon(
                              _getWeatherIcon(weatherMain),
                              size: 32,
                              color: Colors.blue,
                            ),
                            SizedBox(height: 12),
                            Text(
                              '${forecast['main']['temp'].round()}°C',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              forecast['weather'][0]['description'],
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  final String label;
  final String value;

  const _DetailItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
