// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  String _weather = 'Sunny';
  double _temperature = 24.0;
  String _cityName = 'Loading...';
  bool _isDay = true;

  bool _isCelsius = true;
  int _selectedHour = -1;

  String _currentTime = '';

  final Stream<DateTime> _timeStream =
      Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now());

  @override
  void initState() {
    super.initState();
    _determinePosition().then((position) {
      setState(() {
        _fetchCityName(position);
        _isDay = _isDaytime();
        _fetchWeatherData(position.latitude, position.longitude);
      });
    });

    _timeStream.listen((time) {
      _updateTime(time);
    });
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled; stop further execution.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied; stop further execution.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever; handle appropriately.
      return Future.error(
          'Location permissions are permanently denied; we cannot request permissions.');
    }

    // When we reach here, permissions are granted, and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  Future<void> _fetchCityName(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        setState(() {
          _cityName = placemarks[0].locality ?? 'Unknown location';
        });
      } else {
        setState(() {
          _cityName = 'Unknown location';
        });
      }
    } catch (e) {
      setState(() {
        _cityName = 'Failed to get city name';
      });
    }
  }

  bool _isDaytime() {
    final currentTime = DateTime.now().hour;
    return currentTime >= 7 && currentTime <= 19;
  }

  void _fetchWeatherData(double latitude, double longitude) async {
    final url = 'https://api.open-meteo.com/v1/forecast'
        '?latitude=$latitude&longitude=$longitude'
        '&current=temperature_2m,relative_humidity_2m,is_day,rain,snowfall,weather_code,cloud_cover'
        '&hourly=temperature_2m,relative_humidity_2m,precipitation,rain,weather_code,cloud_cover,visibility,is_day'
        '&timezone=auto&forecast_days=1';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final weatherData = json.decode(response.body);
      setState(() {
        _weather = weatherData['current']['weather_code'].toString();
        _temperature = weatherData['current']['temperature_2m'].toDouble();
        _isDay = weatherData['current']['is_day'] == "yes";
      });
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  void _toggleUnit() {
    setState(() {
      _isCelsius = !_isCelsius;
    });
  }

  void _selectHour(int hour) {
    setState(() {
      _selectedHour = hour;
    });
  }

  void _updateTime(DateTime time) {
    final formattedTime = DateFormat('dd/MM - HH:mm:ss').format(time);
    setState(() {
      _currentTime = formattedTime;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // ignore: prefer_const_constructors
        backgroundColor: Color.fromARGB(255, 192, 133, 16),
        title: const Text('Meteopanic'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: () {
              // navigare per il weekly forecast/hourly
            },
          ),
        ],
      ),
      body: Center(
        child: SizedBox(
          width: double.infinity,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              _backgroundAnimation(),
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    const SizedBox(height: 20),
                    const Text(
                      'Now',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _cityName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _selectedHour != -1
                        ? _selectedHourlyWeather()
                        : _defaultWeather(),
                    const SizedBox(height: 20),
                    _hourlyWeather(),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _toggleUnit,
                      child: Text(_isCelsius
                          ? 'Switch to Fahrenheit'
                          : 'Switch to Celsius'),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _currentTime,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _backgroundAnimation() {
    final backgroundAsset = _isDay
        ? 'assets/lottie/backgroundday.json'
        : 'assets/lottie/backgroundnight.json';

    return Lottie.asset(backgroundAsset,
        width: double.infinity, height: double.infinity, fit: BoxFit.cover);
  }

  Widget _defaultWeather() {
    return Column(
      children: [
        Lottie.asset('assets/lottie/sunny.json', width: 200, height: 200),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _isCelsius
                  ? '${_temperature.toStringAsFixed(1)}°C'
                  : '${(_temperature * 9 / 5 + 32).toStringAsFixed(1)}°F',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              _weather,
              style: const TextStyle(
                fontSize: 24,
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _selectedHourlyWeather() {
    List<Map<String, dynamic>> hourlyWeather = [
      {
        'time': '11:00 AM',
        'icon': 'assets/lottie/sunny.json',
        'weather': 'Sunny',
        'temp': 22,
      },
      {
        'time': '12:00 PM',
        'icon': 'assets/lottie/cloudy.json',
        'weather': 'Cloudy',
        'temp': 23,
      },
      {
        'time': '01:00 PM',
        'icon': 'assets/lottie/rainy.json',
        'weather': 'Rainy',
        'temp': 20,
      },
      {
        'time': '02:00 PM',
        'icon': 'assets/lottie/cloudy.json',
        'weather': 'Cloudy',
        'temp': 21,
      },
      {
        'time': '03:00 PM',
        'icon': 'assets/lottie/sunny.json',
        'weather': 'Sunny',
        'temp': 23,
      },
      {
        'time': '04:00 PM',
        'icon': 'assets/lottie/cloudy.json',
        'weather': 'Cloudy',
        'temp': 22,
      },
    ];

    final selectedHourData = hourlyWeather[_selectedHour];

    return Column(
      children: [
        Text(
          selectedHourData['time'],
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        Lottie.asset(selectedHourData['icon'], width: 200, height: 200),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _isCelsius
                  ? '${selectedHourData['temp']}°C'
                  : '${(selectedHourData['temp'] * 9 / 5 + 32).toStringAsFixed(1)}°F',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              selectedHourData['weather'],
              style: const TextStyle(
                fontSize: 24,
                color: Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            _selectHour(-1);
          },
          child: const Text('Back to now\'s Weather'),
        ),
      ],
    );
  }

  Widget _hourlyWeather() {
    List<Map<String, dynamic>> hourlyWeather = [
      {
        'time': '11:00 AM',
        'icon': 'assets/lottie/sunny.json',
        'weather': 'Sunny',
        'temp': 22,
      },
      {
        'time': '12:00 PM',
        'icon': 'assets/lottie/cloudy.json',
        'weather': 'Cloudy',
        'temp': 23,
      },
      {
        'time': '01:00 PM',
        'icon': 'assets/lottie/rainy.json',
        'weather': 'Rainy',
        'temp': 20,
      },
      {
        'time': '02:00 PM',
        'icon': 'assets/lottie/cloudy.json',
        'weather': 'Cloudy',
        'temp': 21,
      },
      {
        'time': '03:00 PM',
        'icon': 'assets/lottie/sunny.json',
        'weather': 'Sunny',
        'temp': 23,
      },
      {
        'time': '04:00 PM',
        'icon': 'assets/lottie/cloudy.json',
        'weather': 'Cloudy',
        'temp': 22,
      },
    ];

    return SizedBox(
      height: 120,
      child: ListView.builder(
        itemCount: hourlyWeather.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final hourData = hourlyWeather[index];
          return GestureDetector(
            onTap: () {
              _selectHour(index);
            },
            child: Container(
              width: 120,
              margin: const EdgeInsets.symmetric(horizontal: 10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    hourData['time'],
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 5),
                  Lottie.asset(hourData['icon'], width: 50, height: 50),
                  const SizedBox(height: 5),
                  Text(
                    '${hourData['temp']}°C',
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    hourData['weather'],
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: WeatherScreen(),
  ));
}
