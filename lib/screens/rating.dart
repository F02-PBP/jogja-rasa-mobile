import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:jogjarasa_mobile/models/review_entry.dart';
import 'package:jogjarasa_mobile/models/restaurant_entry.dart';
import 'package:jogjarasa_mobile/services/review_services.dart' as service;
import 'package:jogjarasa_mobile/services/restaurant_service.dart' as restaurant_service;

class RatingPage extends StatefulWidget {
  const RatingPage({super.key});

  @override
  State<RatingPage> createState() => _RatingPageState();
}

class _RatingPageState extends State<RatingPage> {
  void _navigateToRestaurantDetails(BuildContext context, Restaurant restaurant) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(restaurant.name),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Location: ${restaurant.location}'),
              Text('Description: ${restaurant.description}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    service.ReviewServices servant = service.ReviewServices();
    restaurant_service.RestaurantService restaurantServant = restaurant_service.RestaurantService();

    return Scaffold(
      appBar: AppBar(title: const Text('Restaurant Ratings')),
      body: FutureBuilder(
        future: Future.wait([
          servant.getReviews(request: request),
          restaurantServant.getRestaurants(),
        ]),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('No data available'));
          }

          List<Review> reviews = snapshot.data![0];
          List<Restaurant> restaurants = snapshot.data![1];

          // Group reviews by restaurant
          Map<String, List<Review>> groupedReviews = {};
          for (var review in reviews) {
            String idRestaurant = review.idrestaurant;
            if (!groupedReviews.containsKey(idRestaurant)) {
              groupedReviews[idRestaurant] = [];
            }
            groupedReviews[idRestaurant]!.add(review);
          }

          return ListView.builder(
            itemCount: restaurants.length,
            itemBuilder: (context, index) {
              Restaurant restaurant = restaurants[index];
              String restaurantId = restaurant.id;
              
              // Calculate total reviews and average rating
              int totalReviews = servant.restaurantTotalReview(groupedReviews, restaurantId);
              double avgRating = servant.restaurantAverageRating(groupedReviews, restaurantId);

              return Card(
                margin: const EdgeInsets.all(10),
                elevation: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Restaurant Header
                    Container(
                      padding: const EdgeInsets.all(16),
                      color: Colors.blue[100],
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            restaurant.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () => _navigateToRestaurantDetails(context, restaurant),
                            child: const Text('More Info'),
                          ),
                        ],
                      ),
                    ),
                    // Reviews and Rating Cards
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          // Total Reviews Card
                          Expanded(
                            child: Card(
                              color: Colors.blue[50],
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: [
                                    const Text(
                                      'Total Reviews',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '$totalReviews',
                                      style: const TextStyle(
                                        fontSize: 24,
                                        color: Colors.amber,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Average Rating Card
                          Expanded(
                            child: Card(
                              color: Colors.green[50],
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: [
                                    const Text(
                                      'Average Rating',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.star, color: Colors.amber),
                                        Text(
                                          avgRating.toStringAsFixed(1),
                                          style: const TextStyle(
                                            fontSize: 24,
                                            color: Colors.green,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}