import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/widgets/animated_weather_background.dart';
import '../providers/weather_provider.dart';
import '../widgets/current_weather_card.dart';
import '../widgets/forecast_list.dart';
import '../widgets/loading_shimmer.dart';
import '../widgets/error_widget.dart';
import '../widgets/location_search_bar.dart';
import '../../domain/entities/weather_condition.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WeatherProvider>().fetchWeatherByLocation();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherProvider>(
      builder: (context, provider, child) {
        final isNight = _isNightTime();
        final condition = _getWeatherCondition(
          provider.weather?.description ?? '',
        );
        final windSpeed = provider.weather?.windSpeed ?? 0;

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              // Animated weather background
              AnimatedWeatherBackground(
                condition: condition,
                isNight: isNight,
                windSpeed: windSpeed,
                child: const SizedBox.expand(),
              ),
              // Scrollable content on top
              _buildContent(context, provider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, WeatherProvider provider) {
    if (provider.status == WeatherStatus.loading) {
      return LoadingShimmer(currentWeather: provider.weather);
    }

    if (provider.status == WeatherStatus.error) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: CustomErrorWidget(
            message: provider.errorMessage,
            onRetry: () => _retry(provider),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 40),

          // App Header with location and refresh
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Weatherly',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    if (provider.hasWeather)
                      Text(
                        provider.weather!.cityName,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                  ],
                ),
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.refresh,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  onPressed: () => _retry(provider),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Search bar
          LocationSearchBar(
            onSearch: (city) => provider.fetchWeather(city),
          ),

          const SizedBox(height: 24),

          // Current weather
          if (provider.hasWeather)
            CurrentWeatherCard(weather: provider.weather!),

          const SizedBox(height: 32),

          // 7-Day Forecast
          if (provider.forecast.isNotEmpty)
            ForecastList(forecasts: provider.forecast),

          const SizedBox(height: 32),

          // Footer
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Center(
              child: Text(
                'Updated ${_getUpdateTime(provider.weather?.dateTime)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.6),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _isNightTime() {
    final hour = DateTime.now().hour;
    return hour < 6 || hour >= 18;
  }

  WeatherCondition _getWeatherCondition(String description) {
    final desc = description.toLowerCase();
    if (desc.contains('rain') || desc.contains('drizzle')) {
      return WeatherCondition.rainy;
    } else if (desc.contains('thunder') || desc.contains('storm')) {
      return WeatherCondition.thunderstorm;
    } else if (desc.contains('snow') || desc.contains('ice')) {
      return WeatherCondition.snowy;
    } else if (desc.contains('mist') ||
        desc.contains('fog') ||
        desc.contains('haze')) {
      return WeatherCondition.misty;
    } else if (desc.contains('cloud')) {
      return WeatherCondition.cloudy;
    }
    return WeatherCondition.clear;
  }

  void _retry(WeatherProvider provider) {
    if (provider.hasWeather) {
      provider.fetchWeather(provider.weather!.cityName);
    } else {
      provider.fetchWeatherByLocation();
    }
  }

  String _getUpdateTime(DateTime? dateTime) {
    if (dateTime == null) return 'Just now';
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes} min ago';
    if (difference.inHours < 24) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    }
    return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
  }
}
