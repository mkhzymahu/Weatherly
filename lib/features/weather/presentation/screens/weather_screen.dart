import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_settings/app_settings.dart';
import '../../../../shared/widgets/animated_weather_background.dart';
import '../providers/weather_provider.dart';
import '../widgets/current_weather_card.dart';
import '../widgets/forecast_list.dart';
import '../widgets/loading_shimmer.dart';
import '../widgets/error_state_screen.dart';
import '../widgets/location_search_bar.dart';
import '../../domain/entities/weather_condition.dart';
import 'settings_screen.dart';

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
      ErrorStateType errorType = ErrorStateType.generic;

      if (provider.isOffline) {
        errorType = ErrorStateType.offline;
      } else if (provider.permissionStatus == LocationPermissionStatus.denied ||
          provider.permissionStatus == LocationPermissionStatus.permanentlyDenied) {
        errorType = ErrorStateType.permissionDenied;
      } else if (provider.errorMessage.contains('Failed to get location')) {
        errorType = ErrorStateType.notFound;
      } else if (provider.errorMessage.contains('connection')) {
        errorType = ErrorStateType.networkError;
      }

      return ErrorStateScreen(
        errorType: errorType,
        customMessage: provider.errorMessage,
        onRetry: () => _retry(provider),
        onOpenSettings: errorType == ErrorStateType.permissionDenied
            ? () async {
                await AppSettings.openAppSettings();
              }
            : null,
      );
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 40),

          // Advanced Header with date, time, and quick stats
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row with app name and controls
                Row(
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
                        const SizedBox(height: 4),
                        Text(
                          _getCurrentDateTime(),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
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
                        IconButton(
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.settings,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SettingsScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Location with icon
                if (provider.hasWeather)
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: Colors.white.withOpacity(0.9),
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${provider.weather!.cityName}${provider.usingCurrentLocation ? ' • Current Location' : ''}',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                const SizedBox(height: 20),

                // Removed redundant top temperature card — main display below

                // Search bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: LocationSearchBar(
                    onSearch: (city) => provider.fetchWeather(city),
                  ),
                ),

                const SizedBox(height: 24),

                // Current weather
                if (provider.hasWeather) CurrentWeatherCard(weather: provider.weather!),

                const SizedBox(height: 32),

                // 7-Day Forecast
                if (provider.forecast.isNotEmpty) ForecastList(forecasts: provider.forecast),

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

  String _getCurrentDateTime() {
    final now = DateTime.now();
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final dayName = days[now.weekday - 1];
    final monthName = months[now.month - 1];
    final time = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    return '$dayName, $monthName ${now.day} • $time';
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white.withOpacity(0.8),
          size: 20,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}
