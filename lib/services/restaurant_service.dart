import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:jogjarasa_mobile/models/restaurant_entry.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

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

  Future<List<Restaurant>> searchRestaurants({
    required CookieRequest request,
    String? query,
    String? region,
    String? foodType,
  }) async {
    try {
      String url = '$baseUrl/search_restaurants/';
      List<String> queryParams = [];

      if (query != null && query.isNotEmpty) {
        queryParams.add('query=${Uri.encodeComponent(query)}');
      }
      if (region != null && region != "Semua Lokasi") {
        queryParams.add('region=${Uri.encodeComponent(region)}');
      }
      if (foodType != null && foodType.isNotEmpty) {
        queryParams.add('food_type=${Uri.encodeComponent(foodType)}');
      }

      if (queryParams.isNotEmpty) {
        url += '?' + queryParams.join('&');
      }

      final response = await request.get(url);

      if (response['results'] != null) {
        final List<dynamic> results = response['results'];
        return results
            .map((json) => Restaurant(
                  id: json['id'].toString(),
                  name: json['name'],
                  description: json['description'],
                  longitude: json['longitude'].toDouble(),
                  latitude: json['latitude'].toDouble(),
                  location: json['location'],
                  isBookmarked: json['is_bookmarked'] ?? false,
                ))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to search restaurants: $e');
    }
  }

  Future<Map<String, dynamic>> getRecommendations(CookieRequest request) async {
    try {
      final response = await request.get('$baseUrl/get_recommendations/');

      if (response['recommendations'] != null) {
        final List<dynamic> recommendationData =
            response['recommendations'] as List;
        final String interestedFood = response['interested_food'] ?? '';

        final List<Restaurant> recommendations = recommendationData.map((json) {
          return Restaurant.fromJson(json as Map<String, dynamic>);
        }).toList();

        return {
          'recommendations': recommendations,
          'interested_food': interestedFood,
        };
      }
      return {
        'recommendations': <Restaurant>[],
        'interested_food': '',
      };
    } catch (e) {
      print('Recommendation error: $e');
      return {
        'recommendations': <Restaurant>[],
        'interested_food': '',
      };
    }
  }
}
