import 'package:flutter/material.dart';
import 'weather_screen.dart';

void main() {
  runApp(const MeteoPanicApp());
}

class MeteoPanicApp extends StatelessWidget {
  const MeteoPanicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MeteoPanic',
      theme: ThemeData(
        primarySwatch: Colors.amber,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const WeatherScreen(),
    );
  }
}
