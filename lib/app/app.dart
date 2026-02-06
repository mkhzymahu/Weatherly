import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weatherly/features/weather/presentation/screens/weather_screen.dart';
import 'package:weatherly/features/weather/presentation/providers/settings_provider.dart';
import 'package:weatherly/app/theme/app_theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return MaterialApp(
          title: 'Weatherly',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: settings.isInitialized ? settings.themeMode : ThemeMode.system,
          debugShowCheckedModeBanner: false,
          home: const WeatherScreen(),
        );
      },
    );
  }
}