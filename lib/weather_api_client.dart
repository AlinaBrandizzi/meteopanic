import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherApiClient {
  Future<Map<String, dynamic>> fetchWeather(
      double latitude, double longitude) async {
    final url = Uri.parse('https://api.open-meteo.com/v1/forecast'
        '?latitude=$latitude&longitude=$longitude'
        '&current=temperature_2m,relative_humidity_2m,is_day,rain,snowfall,weather_code,cloud_cover'
        '&hourly=temperature_2m,relative_humidity_2m,precipitation,rain,weather_code,cloud_cover,visibility,is_day'
        '&timezone=auto&forecast_days=1');

    final response = await http.get(url);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load weather data');
    }
  }
}
