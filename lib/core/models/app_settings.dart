import 'package:equatable/equatable.dart';

enum TemperatureUnit {
  celsius,
  fahrenheit,
  kelvin,
}

enum ThemeMode {
  light,
  dark,
  system,
}

enum RefreshInterval {
  fifteenMinutes(15),
  thirtyMinutes(30),
  oneHour(60),
  threeHours(180),
  sixHours(360),
  twelveHours(720);

  final int minutes;
  const RefreshInterval(this.minutes);
}

class AppSettings extends Equatable {
  final TemperatureUnit temperatureUnit;
  final ThemeMode themeMode;
  final RefreshInterval refreshInterval;
  final bool notificationsEnabled;
  final bool useCurrentLocation;
  final List<String> favoriteCities;
  final bool showAirQuality;
  final bool showUvIndex;
  final bool showSunTimes;
  final String languageCode;

  const AppSettings({
    this.temperatureUnit = TemperatureUnit.celsius,
    this.themeMode = ThemeMode.system,
    this.refreshInterval = RefreshInterval.oneHour,
    this.notificationsEnabled = true,
    this.useCurrentLocation = true,
    this.favoriteCities = const [],
    this.showAirQuality = true,
    this.showUvIndex = true,
    this.showSunTimes = true,
    this.languageCode = 'en',
  });

  AppSettings copyWith({
    TemperatureUnit? temperatureUnit,
    ThemeMode? themeMode,
    RefreshInterval? refreshInterval,
    bool? notificationsEnabled,
    bool? useCurrentLocation,
    List<String>? favoriteCities,
    bool? showAirQuality,
    bool? showUvIndex,
    bool? showSunTimes,
    String? languageCode,
  }) {
    return AppSettings(
      temperatureUnit: temperatureUnit ?? this.temperatureUnit,
      themeMode: themeMode ?? this.themeMode,
      refreshInterval: refreshInterval ?? this.refreshInterval,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      useCurrentLocation: useCurrentLocation ?? this.useCurrentLocation,
      favoriteCities: favoriteCities ?? this.favoriteCities,
      showAirQuality: showAirQuality ?? this.showAirQuality,
      showUvIndex: showUvIndex ?? this.showUvIndex,
      showSunTimes: showSunTimes ?? this.showSunTimes,
      languageCode: languageCode ?? this.languageCode,
    );
  }

  @override
  List<Object?> get props => [
        temperatureUnit,
        themeMode,
        refreshInterval,
        notificationsEnabled,
        useCurrentLocation,
        favoriteCities,
        showAirQuality,
        showUvIndex,
        showSunTimes,
        languageCode,
      ];
}