import 'package:flutter/material.dart';
import '../utils/date_formatter.dart';
import 'detail_item.dart';

class HumidityCloudsCard extends StatelessWidget {
  final Map<String, dynamic> currentWeather;

  const HumidityCloudsCard({
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
              'Humidity & Clouds',
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
                    label: 'Humidity',
                    value: '${currentWeather['main']['humidity']}%',
                  ),
                ),
                Expanded(
                  child: DetailItem(
                    label: 'Cloud Cover',
                    value: '${currentWeather['clouds']['all']}%',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DetailItem(
                    label: 'Sunrise',
                    value: DateFormatter.formatTime(
                      DateTime.fromMillisecondsSinceEpoch(
                          currentWeather['sys']['sunrise'] * 1000),
                    ),
                  ),
                ),
                Expanded(
                  child: DetailItem(
                    label: 'Sunset',
                    value: DateFormatter.formatTime(
                      DateTime.fromMillisecondsSinceEpoch(
                          currentWeather['sys']['sunset'] * 1000),
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
}
