import 'package:flutter/material.dart';
import '../utils/date_formatter.dart';
import '../utils/weather_icons.dart';

class ForecastCard extends StatelessWidget {
  final List<Map<String, dynamic>> dailyForecasts;

  const ForecastCard({
    Key? key,
    required this.dailyForecasts,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (dailyForecasts.isEmpty) return const SizedBox();

    // context.watch<ThemeProvider>();

    // Get screen width to determine forecast item size
    double width = MediaQuery.of(context).size.width;
    double itemWidth = width > 1200
        ? 180.0
        : width > 800
            ? 150.0
            : 120.0;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '5-Day Forecast',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 160,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: dailyForecasts.length,
                itemBuilder: (ctx, index) {
                  final forecast = dailyForecasts[index];
                  final date = DateTime.fromMillisecondsSinceEpoch(
                      forecast['dt'] * 1000);
                  final weatherMain = forecast['weather'][0]['main'];

                  return Container(
                    // key: UniqueKey(),
                    width: itemWidth,
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormatter.formatDay(date),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        Icon(
                          WeatherIcons.getWeatherIcon(weatherMain),
                          size: 32,
                          color: Colors.blue,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '${forecast['main']['temp'].round()}°C',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          forecast['weather'][0]['description'],
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
