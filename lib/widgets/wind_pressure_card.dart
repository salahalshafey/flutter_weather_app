import 'package:flutter/material.dart';
import '../utils/weather_icons.dart';
import 'detail_item.dart';

class WindPressureCard extends StatelessWidget {
  final Map<String, dynamic> currentWeather;

  const WindPressureCard({
    Key? key,
    required this.currentWeather,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
              'Wind & Pressure',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DetailItem(
                    label: 'Wind Speed',
                    value: '${currentWeather['wind']['speed']} m/s',
                  ),
                ),
                Expanded(
                  child: DetailItem(
                    label: 'Wind Direction',
                    value: WeatherIcons.getWindDirection(
                        currentWeather['wind']['deg'] as int),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DetailItem(
                    label: 'Pressure',
                    value: '${currentWeather['main']['pressure']} hPa',
                  ),
                ),
                Expanded(
                  child: DetailItem(
                    label: 'Visibility',
                    value:
                        '${(currentWeather['visibility'] / 1000).toStringAsFixed(1)} km',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
