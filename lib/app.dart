import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';
import 'screens/weather_dashboard_screen.dart';

class WeatherApp extends StatelessWidget {
  const WeatherApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ThemeProvider>(
      create: (context) => ThemeProvider()..initialize(),
      builder: (context, _) {
        // Listen to theme changes
        final themeProvider = context.watch<ThemeProvider>();

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Weather Dashboard',
          theme: themeProvider.currentTheme,
          home: WeatherDashboardScreen(
            themeProvider: themeProvider,
          ),
        );
      },
    );
  }
}
