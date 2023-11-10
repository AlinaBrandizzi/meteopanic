import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('WeatherScreen has a title and message',
      (WidgetTester tester) async {
    await tester.pumpWidget(MeteoPanicApp() as Widget);
    // Add more tests as per your need
  });
}

class MeteoPanicApp {}
