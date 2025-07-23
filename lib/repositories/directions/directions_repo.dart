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
    final getSheardData = prefs.getString('currentLocation');
    final currentLocation = jsonDecode(getSheardData!);
    String apiKey = dotenv.env['GOOGLE_MAPS_API_KEY']!;

    // Google Directions API endpoint
    final url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${currentLocation['lat']},${currentLocation['lng']}&destination=$lat,$lng&key=$apiKey';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final route = data['routes']?[0];
      if (route != null) {
        final leg = route['legs'][0];
        final distance = leg['distance']['text'];
        final duration = leg['duration']['text'];
        String? currentCity = prefs.getString('currentCity');
        return [
          {
            "currentCity": currentCity,
            "distance": distance,
            "duration": duration
          }
        ];
      }
    }
    return [];
  }
}
