import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DirectionsRepo {
  final double lat;
  final double lng;
  const DirectionsRepo({required this.lat, required this.lng});

  Future<List> calculateDistance() async {
    final prefs = await SharedPreferences.getInstance();
    final sharedData = prefs.getString('currentLocation');
    if (sharedData == null || sharedData.trim().isEmpty) {
      return [];
    }

    final currentLocation = _decodeLocation(sharedData);
    if (currentLocation == null) {
      return [];
    }

    final originLat = currentLocation['lat'];
    final originLng = currentLocation['lng'];
    if (_isMissing(originLat) || _isMissing(originLng)) {
      return [];
    }

    final apiKey = _googleMapsApiKey();
    if (apiKey == null || apiKey.trim().isEmpty) {
      return [];
    }

    // Google Directions API endpoint
    final url = Uri.https('maps.googleapis.com', '/maps/api/directions/json', {
      'origin': '$originLat,$originLng',
      'destination': '$lat,$lng',
      'key': apiKey,
    });

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = _decodeResponse(response.body);
      final directions = _extractDirections(data);
      if (directions != null) {
        String? currentCity = prefs.getString('currentCity');
        return [
          {
            "currentCity": currentCity,
            "distance": directions['distance'],
            "duration": directions['duration'],
          },
        ];
      }
    }
    return [];
  }

  Map<String, dynamic>? _decodeLocation(String sharedData) {
    try {
      final decoded = jsonDecode(sharedData);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  Map<String, dynamic>? _decodeResponse(String responseBody) {
    try {
      final decoded = jsonDecode(responseBody);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  Map<String, String>? _extractDirections(Map<String, dynamic>? data) {
    final routes = data?['routes'];
    if (routes is! List || routes.isEmpty) {
      return null;
    }

    final route = routes.first;
    if (route is! Map) {
      return null;
    }

    final legs = route['legs'];
    if (legs is! List || legs.isEmpty) {
      return null;
    }

    final leg = legs.first;
    if (leg is! Map) {
      return null;
    }

    final distanceData = leg['distance'];
    final durationData = leg['duration'];
    if (distanceData is! Map || durationData is! Map) {
      return null;
    }

    final distance = distanceData['text'];
    final duration = durationData['text'];
    if (distance is! String ||
        distance.trim().isEmpty ||
        duration is! String ||
        duration.trim().isEmpty) {
      return null;
    }

    return {'distance': distance, 'duration': duration};
  }

  String? _googleMapsApiKey() {
    try {
      return dotenv.env['GOOGLE_MAPS_API_KEY'];
    } catch (_) {
      return null;
    }
  }

  bool _isMissing(Object? value) {
    return value == null || value.toString().trim().isEmpty;
  }
}
