class ApiConstants {
  static const String baseUrl = 'https://api.openweathermap.org/data/2.5';
  static const String apiKey = 'API_KEY_HERE';
  
  static const String currentWeather = '/weather';
  static const String forecast = '/forecast';
  static const String weatherIcon = 'https://openweathermap.org/img/wn/';
}

class AppConstants {
  static const String appName = 'Weatherly';
  static const String defaultCity = 'London';
  static const String locationError = 'Unable to get location';
  static const String networkError = 'No internet connection';
  static const String apiError = 'Failed to fetch weather data';
}
