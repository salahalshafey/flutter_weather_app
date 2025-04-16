import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../utils/weather_icons.dart';
import 'detail_item.dart';

class WindPressureCard extends StatelessWidget {
  final double windSpeed;
  final int windDegree;
  final int pressure;

  const WindPressureCard({
    super.key,
    required this.windSpeed,
    required this.windDegree,
    required this.pressure,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            DetailItem(
              icon: FontAwesomeIcons.wind,
              value: '${windSpeed.toStringAsFixed(1)} m/s',
              label: WeatherIcons.getWindDirection(windDegree),
            ),
            DetailItem(
              icon: FontAwesomeIcons.gauge,
              value: '$pressure hPa',
              label: 'Pressure',
            ),
          ],
        ),
      ),
    );
  }
}
