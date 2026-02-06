import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app/app.dart';
import 'features/weather/presentation/providers/weather_provider.dart';
import 'core/network/network_info.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  final networkInfo = NetworkInfoImpl(Connectivity());
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => WeatherProvider(networkInfo: networkInfo),
        ),
      ],
      child: const MyApp(),
    ),
  );
}