import 'package:flutter/material.dart';
import '../models/weather_data.dart';
import '../utils/weather_icons.dart';
import '../utils/date_formatter.dart';

class MainWeatherCard extends StatelessWidget {
  final WeatherData weather;

  const MainWeatherCard({
    super.key,
    required this.weather,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${weather.cityName}, ${weather.country}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormatter.formatFullDateTime(weather.timestamp),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                Icon(
                  WeatherIcons.getWeatherIcon(weather.main),
                  size: 48,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${weather.temperature.round()}°',
                  style: Theme.of(context).textTheme.displayLarge,
                ),
                Text(
                  'C',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
            Text(
              weather.description.toUpperCase(),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Feels like ${weather.feelsLike.round()}°C',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const Text(' | '),
                Text(
                  'H:${weather.maxTemp.round()}° L:${weather.minTemp.round()}°',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
