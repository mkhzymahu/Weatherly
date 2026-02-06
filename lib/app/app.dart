import 'package:flutter/material.dart';
import 'package:weatherly/features/weather/presentation/screens/weather_screen.dart';
import 'package:weatherly/app/theme/app_theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weatherly',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: const WeatherScreen(),
    );
  }
}