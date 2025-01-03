import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:jogjarasa_mobile/services/review_services.dart'
    as review_services;
import 'package:jogjarasa_mobile/models/review_entry.dart';
import 'package:jogjarasa_mobile/models/restaurant_entry.dart';

class RestaurantReviewPage extends StatefulWidget {
  final Restaurant restaurant;

  const RestaurantReviewPage({
    super.key,
    required this.restaurant,
  });

  @override
  State<RestaurantReviewPage> createState() => _RestaurantReviewPageState();
}

class _RestaurantReviewPageState extends State<RestaurantReviewPage> {
  List<Review>? reviews;

  final _formKey = GlobalKey<FormState>();
  final _reviewController = TextEditingController();
  final reviewServant = review_services.ReviewServices();
  int _rating = 5;

  Set<int> _selectedRatings = {1, 2, 3, 4, 5};
  DateTime? _startDate;
  DateTime? _endDate;
  String _searchUsername = '';

  @override
  void initState() {
    super.initState();
    _fetchReviews(); // Start fetching reviews when the widget is initialized
  }

  Future<void> _fetchReviews() async {
    reviews =
        await reviewServant.getRestaurantReviews(id: widget.restaurant.id);
    setState(() {});
  }

  List<Review> _getFilteredReviews() {
    return (reviews ?? []).where((review) {
      if (!_selectedRatings.contains(review.rating)) {
        return false;
      }

      if (_startDate != null && review.date.isBefore(_startDate!)) {
        return false;
      }
      if (_endDate != null && review.date.isAfter(_endDate!)) {
        return false;
      }

      if (_searchUsername.isNotEmpty &&
          !review.username
              .toLowerCase()
              .contains(_searchUsername.toLowerCase())) {
        return false;
      }
      return true;
    }).toList();
  }

  Future<void> _selectDate(bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Map<int, int> _calculateRatingDistribution(List<Review> reviews) {
    Map<int, int> distribution = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    for (var review in reviews) {
      distribution[review.rating] = (distribution[review.rating] ?? 0) + 1;
    }
    return distribution;
  }

  Widget _buildRatingBar(int starCount, int count, int totalReviews) {
    double percentage = totalReviews > 0 ? (count / totalReviews) * 100 : 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 50,
            child: Row(
              children: [
                Text(
                  '$starCount',
                  style: const TextStyle(fontSize: 16),
                ),
                const Icon(Icons.star, color: Colors.amber, size: 16),
              ],
            ),
          ),
          Expanded(
            flex: 7,
            child: Stack(
              children: [
                Container(
                  height: 15,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: percentage / 100,
                  child: Container(
                    height: 15,
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 50,
            child: Text(
              ' $count',
              textAlign: TextAlign.end,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final ratingDistribution = _calculateRatingDistribution(reviews ?? []);
    final totalReviews = reviews?.length ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.restaurant.name),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Rating Distribution Card
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Distribusi Rating',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      for (int i = 5; i >= 1; i--)
                        _buildRatingBar(
                            i, ratingDistribution[i]!, totalReviews),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Add Review Form
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Berikan pengalamanmu disini',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Rating Selection
                        Row(
                          children: [
                            const Text('Rating: '),
                            const SizedBox(width: 8),
                            for (int i = 1; i <= 5; i++)
                              IconButton(
                                icon: Icon(
                                  Icons.star,
                                  color:
                                      i <= _rating ? Colors.amber : Colors.grey,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _rating = i;
                                  });
                                },
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Review Text Field
                        TextFormField(
                          controller: _reviewController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'Review Kamu',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Isi komentar kamu dulu ya!';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                final response = await request.postJson(
                                    "https://jogja-rasa-production.up.railway.app/review/create_review_flutter/",
                                    jsonEncode({
                                      "review": _reviewController.text,
                                      "rating": _rating,
                                      "pk_resto": widget.restaurant.id
                                    }));

                                if (context.mounted) {
                                  if (response['status'] == true) {
                                    // Use the _fetchReviews() method instead of direct assignment
                                    await _fetchReviews();
                                    _reviewController
                                        .clear(); // Clear the input field

                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(const SnackBar(
                                      content:
                                          Text('Berhasil menambahkan review'),
                                      backgroundColor: Colors.green,
                                      behavior: SnackBarBehavior.floating,
                                    ));
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(response['message']),
                                        backgroundColor: Colors.red,
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  }
                                }
                              }
                            },
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Text(
                                'Submit Review',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Filter Reviews',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Rating filter
                      const Text('Filter by Rating:'),
                      Wrap(
                        spacing: 8,
                        children: [1, 2, 3, 4, 5].map((rating) {
                          return FilterChip(
                            label: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('$rating'),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.star,
                                  size: 16,
                                  color: _selectedRatings.contains(rating)
                                      ? Colors.amber
                                      : Colors.grey,
                                ),
                              ],
                            ),
                            selected: _selectedRatings.contains(rating),
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedRatings.add(rating);
                                } else if (_selectedRatings.length > 1) {
                                  _selectedRatings.remove(rating);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),

                      // Date filter
                      const Text('Filter by Date Range:'),
                      Row(
                        children: [
                          Expanded(
                            child: TextButton.icon(
                              icon: const Icon(Icons.calendar_today),
                              label: Text(_startDate == null
                                  ? 'Start Date'
                                  : 'From: ${_startDate!.toString().split(' ')[0]}'),
                              onPressed: () => _selectDate(true),
                            ),
                          ),
                          Expanded(
                            child: TextButton.icon(
                              icon: const Icon(Icons.calendar_today),
                              label: Text(_endDate == null
                                  ? 'End Date'
                                  : 'To: ${_endDate!.toString().split(' ')[0]}'),
                              onPressed: () => _selectDate(false),
                            ),
                          ),
                        ],
                      ),

                      // Username filter
                      const SizedBox(height: 16),
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'Search by Username',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchUsername = value;
                          });
                        },
                      ),

                      // Clear filters button
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.clear_all),
                          label: const Text('Clear All Filters'),
                          onPressed: () {
                            setState(() {
                              _selectedRatings = {1, 2, 3, 4, 5};
                              _startDate = null;
                              _endDate = null;
                              _searchUsername = '';
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Reviews List
              const Text(
                'All Reviews',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _getFilteredReviews().length,
                itemBuilder: (context, index) {
                  final review = _getFilteredReviews()[index];
                  // final String? _username = review.username;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      review.username,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      review.date
                                          .toString()
                                          .split(' ')[0], // Format the date
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: List.generate(
                                  5,
                                  (index) => Icon(
                                    Icons.star,
                                    size: 16,
                                    color: index < review.rating
                                        ? Colors.amber
                                        : Colors.grey,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(review.review),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }
}
