class WeatherData {
  final String cityName;
  final String country;
  final DateTime timestamp;
  final double temperature;
  final double feelsLike;
  final double minTemp;
  final double maxTemp;
  final String description;
  final String main;
  final double windSpeed;
  final int windDegree;
  final int pressure;
  final int visibility;
  final int humidity;
  final int cloudiness;
  final DateTime sunrise;
  final DateTime sunset;

  WeatherData({
    required this.cityName,
    required this.country,
    required this.timestamp,
    required this.temperature,
    required this.feelsLike,
    required this.minTemp,
    required this.maxTemp,
    required this.description,
    required this.main,
    required this.windSpeed,
    required this.windDegree,
    required this.pressure,
    required this.visibility,
    required this.humidity,
    required this.cloudiness,
    required this.sunrise,
    required this.sunset,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      cityName: json['name'],
      country: json['sys']['country'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
      temperature: json['main']['temp'].toDouble(),
      feelsLike: json['main']['feels_like'].toDouble(),
      minTemp: json['main']['temp_min'].toDouble(),
      maxTemp: json['main']['temp_max'].toDouble(),
      description: json['weather'][0]['description'],
      main: json['weather'][0]['main'],
      windSpeed: json['wind']['speed'].toDouble(),
      windDegree: json['wind']['deg'],
      pressure: json['main']['pressure'],
      visibility: json['visibility'],
      humidity: json['main']['humidity'],
      cloudiness: json['clouds']['all'],
      sunrise:
          DateTime.fromMillisecondsSinceEpoch(json['sys']['sunrise'] * 1000),
      sunset: DateTime.fromMillisecondsSinceEpoch(json['sys']['sunset'] * 1000),
    );
  }
}

class ForecastData {
  final DateTime date;
  final double temperature;
  final String description;
  final String main;

  ForecastData({
    required this.date,
    required this.temperature,
    required this.description,
    required this.main,
  });

  factory ForecastData.fromJson(Map<String, dynamic> json) {
    return ForecastData(
      date: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
      temperature: json['main']['temp'].toDouble(),
      description: json['weather'][0]['description'],
      main: json['weather'][0]['main'],
    );
  }
}
