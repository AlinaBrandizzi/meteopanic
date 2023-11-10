class WeatherInfo {
  final DateTime time;
  final double temperature;
  final double windSpeed;
  final double humidity;
  final bool isDay;
  final double rain;
  final double snowfall;
  final int weatherCode;
  final double cloudCover;

  WeatherInfo({
    required this.time,
    required this.temperature,
    required this.windSpeed,
    required this.humidity,
    required this.isDay,
    required this.rain,
    required this.snowfall,
    required this.weatherCode,
    required this.cloudCover,
  });

  factory WeatherInfo.fromJson(Map<String, dynamic> json) {
    return WeatherInfo(
      time: DateTime.parse(json['time']),
      temperature: json['temperature_2m'],
      windSpeed: json['wind_speed_10m'],
      humidity: json['relative_humidity_2m'],
      isDay: json['is_day'] == 1,
      rain: json['rain'],
      snowfall: json['snowfall'],
      weatherCode: json['weather_code'],
      cloudCover: json['cloud_cover'],
    );
  }
}
