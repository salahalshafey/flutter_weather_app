import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class WeatherIcons {
  static IconData getWeatherIcon(String main) {
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

  static String getWindDirection(int degrees) {
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
      'NNW'
    ];
    int index = ((degrees / 22.5) + 0.5).floor() % 16;
    return directions[index];
  }
}
