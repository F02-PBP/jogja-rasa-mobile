import 'dart:convert';
import 'package:jogjarasa_mobile/models/review_entry.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:http/http.dart' as http;

class ReviewServices {
  static const String baseUrl = 'http://localhost:8000';

  Future<List<Review>> getReviews({required CookieRequest request}) async {
    try {
        final response =
          await http.get(Uri.parse('$baseUrl/review/show_reviews_json_flutter/'));

      if (response.statusCode == 200) {
        final List<dynamic> reviewJson = json.decode(response.body);
        return reviewJson.map<Review>( (dynamic json) => Review.fromJson(json)).toList();
      }
      else {
        throw Exception(
          'Failed to load review. Status ${response.statusCode}'
        );
      }
    } catch (e) {
      throw Exception('Cannot get review: $e');
    }
  }

  Future<Map<String, dynamic>> restaurantReview(List<Review> reviews) async{
    Map<String, List<Review>> groupedReviews = {};
    for (var review in reviews) {

      String idRestaurant = review.idrestaurant;

      if (!groupedReviews.containsKey(idRestaurant)) {
        groupedReviews[idRestaurant] = [];
      }

      groupedReviews[idRestaurant]!.add(review);
    }

    return groupedReviews.map((key, value) => MapEntry(key, value));
  }

  double restaurantAverageRating(Map<String, List<Review>> groupedReviews, String idRestaurant)  {
    List<Review>? restaurantReview = groupedReviews[idRestaurant];
    double avgRating = 0.0;
    int totalReview = 0;
    if (restaurantReview != null && restaurantReview.isNotEmpty) {
      totalReview = restaurantReview.length;
      for (int i = 0; i < totalReview; i++) {
        avgRating += restaurantReview[i].rating;
      }
      avgRating = avgRating / totalReview;
    }

    return avgRating;
  }

  int restaurantTotalReview(Map<String, List<Review>> groupedReviews, String idRestaurant)  {
    int totalReview = 0;
    List<Review>? restaurantReview = groupedReviews[idRestaurant];
    if (restaurantReview != null && restaurantReview.isNotEmpty){
      totalReview = restaurantReview.length;
    }
    return totalReview;
  }


}