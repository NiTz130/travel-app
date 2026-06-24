import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_app/repositories/directions/directions_repo.dart';

void main() {
  setUp(() {
    dotenv.clean();
  });

  test(
    'calculateDistance returns empty list when currentLocation is missing',
    () async {
      SharedPreferences.setMockInitialValues({});
      const repo = DirectionsRepo(lat: 10.0, lng: 106.0);

      final result = await repo.calculateDistance();

      expect(result, isEmpty);
    },
  );

  test(
    'calculateDistance returns empty list when Google Maps API key is missing',
    () async {
      SharedPreferences.setMockInitialValues({
        'currentLocation': jsonEncode({'lat': 10.0, 'lng': 106.0}),
      });
      dotenv.loadFromString(envString: '', isOptional: true);
      const repo = DirectionsRepo(lat: 10.0, lng: 106.0);

      final result = await repo.calculateDistance();

      expect(result, isEmpty);
    },
  );
}
