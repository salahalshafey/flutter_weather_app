import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'detail_item.dart';

class HumidityCloudCard extends StatelessWidget {
  final int humidity;
  final int cloudiness;

  const HumidityCloudCard({
    super.key,
    required this.humidity,
    required this.cloudiness,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            DetailItem(
              icon: FontAwesomeIcons.droplet,
              value: '$humidity%',
              label: 'Humidity',
            ),
            DetailItem(
              icon: FontAwesomeIcons.cloud,
              value: '$cloudiness%',
              label: 'Cloudiness',
            ),
          ],
        ),
      ),
    );
  }
}
