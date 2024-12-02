import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:jogjarasa_mobile/models/restaurant_entry.dart';

class RestaurantService {
  static const String baseUrl = 'http://localhost:8000';

  static const int itemsPerPage = 10;

  Future<List<Restaurant>> getRestaurants() async {
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/restaurant/get_restaurants/'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> restaurantsJson = data['restaurants'];
        return restaurantsJson
            .map((json) => Restaurant.fromJson(json))
            .toList();
      } else {
        throw Exception(
            'Failed to load restaurants. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error connecting to server: $e');
    }
  }
}
