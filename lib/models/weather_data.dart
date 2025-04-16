class WeatherData {
  final Map<String, dynamic> currentWeather;
  final Map<String, dynamic> forecastData;

  WeatherData({
    required this.currentWeather,
    required this.forecastData,
  });

  factory WeatherData.fromJson({
    required Map<String, dynamic> currentWeather,
    required Map<String, dynamic> forecastData,
  }) {
    return WeatherData(
      currentWeather: currentWeather,
      forecastData: forecastData,
    );
  }

  List<Map<String, dynamic>> getDailyForecasts() {
    if (forecastData.isEmpty) return [];

    Map<String, dynamic> dailyForecasts = {};
    List<dynamic> forecastList = forecastData['list'];

    for (var forecast in forecastList) {
      DateTime date =
          DateTime.fromMillisecondsSinceEpoch(forecast['dt'] * 1000);
      String dateStr = '${date.year}-${date.month}-${date.day}';

      if (!dailyForecasts.containsKey(dateStr) ||
          (date.hour - 12).abs() <
              (DateTime.fromMillisecondsSinceEpoch(
                              dailyForecasts[dateStr]['dt'] * 1000)
                          .hour -
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
}
