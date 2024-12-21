import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jogjarasa_mobile/models/bookmark_entry.dart';
import 'package:jogjarasa_mobile/models/restaurant_entry.dart';
import 'package:jogjarasa_mobile/screens/reservation/reservation_form.dart';
import 'package:jogjarasa_mobile/services/restaurant_service.dart';
import 'package:jogjarasa_mobile/widgets/left_drawer.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _searchController = TextEditingController();
  final RestaurantService _restaurantService = RestaurantService();
  final ScrollController _scrollController = ScrollController();

  String _searchQuery = '';
  List<Restaurant> _restaurants = [];
  List<Restaurant> _recommendations = [];
  String _interestedFood = '';
  bool _isLoading = true;
  String? _error;
  String? _selectedLocation;
  String? _selectedFoodType;

  final List<String> _locations = [
    "Semua Lokasi",
    "Yogyakarta Timur",
    "Yogyakarta Pusat",
    "Yogyakarta Barat",
    "Yogyakarta Utara",
    "Yogyakarta Selatan",
    "Solo",
  ];

  final List<String> _foodTypes = [
    "Semua Jenis",
    "soto",
    "gudeg",
    "bakpia",
    "sate",
    "nasi goreng",
    "olahan ayam",
    "olahan ikan",
    "olahan mie",
    "kopi",
    "pencuci_mulut",
    "olahan_daging",
  ];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await Future.wait([
      _loadRecommendations(),
      _loadRestaurants(),
    ]);
  }

  Future<void> _loadRecommendations() async {
    try {
      final request = context.read<CookieRequest>();
      final result = await _restaurantService.getRecommendations(request);

      setState(() {
        _recommendations = (result['recommendations'] as List<Restaurant>);
        _interestedFood = result['interested_food'] as String;
      });
    } catch (e) {
      print('Failed to load recommendations: $e');
      setState(() {
        _recommendations = [];
        _interestedFood = '';
      });
    }
  }

  Future<void> _loadRestaurants() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final request = context.read<CookieRequest>();

      List<Restaurant> restaurants = [];
      List<Bookmark> bookmarks = [];

      if (_searchQuery.isNotEmpty ||
          _selectedLocation != null ||
          (_selectedFoodType != null && _selectedFoodType != "Semua Jenis")) {
        restaurants = await _restaurantService.searchRestaurants(
          request: request,
          query: _searchQuery,
          region: _selectedLocation,
          foodType:
              _selectedFoodType == "Semua Jenis" ? null : _selectedFoodType,
        );
      } else {
        restaurants = await _restaurantService.getRestaurants(request);
      }
      bookmarks = await _restaurantService.getBookmarks(request);

      final bookmarkedIds = bookmarks.map((b) => b.id).toSet();

      for (var restaurant in restaurants) {
        restaurant.isBookmarked = bookmarkedIds.contains(restaurant.id);
      }

      setState(() {
        _restaurants = restaurants;
        _isLoading = false;
      });

    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<Restaurant> _getFilteredRestaurants() {
    return _restaurants;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: LeftDrawer(),
      backgroundColor: Colors.orange[50],
      appBar: AppBar(
        backgroundColor: Colors.orange[800],
        title: Text(
          'JogjaRasa',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadInitialData,
          ),
        ],
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _loadInitialData,
        color: Colors.orange[800],
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.orange[800],
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          // Search Bar
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _searchController,
                              onChanged: (value) {
                                setState(() {
                                  _searchQuery = value.toLowerCase();
                                });
                                _loadRestaurants();
                              },
                              decoration: InputDecoration(
                                hintText: 'Cari restoran...',
                                hintStyle: GoogleFonts.poppins(
                                  color: Colors.grey[500],
                                ),
                                border: InputBorder.none,
                                icon: Icon(Icons.search,
                                    color: Colors.orange[800]),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedLocation ?? "Semua Lokasi",
                                isExpanded: true,
                                hint: Text(
                                  "Pilih Lokasi",
                                  style: GoogleFonts.poppins(),
                                ),
                                items: _locations.map((String location) {
                                  return DropdownMenuItem(
                                    value: location,
                                    child: Text(
                                      location,
                                      style: GoogleFonts.poppins(),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedLocation = newValue;
                                  });
                                  _loadRestaurants();
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedFoodType ?? "Semua Jenis",
                                isExpanded: true,
                                hint: Text(
                                  "Jenis Makanan",
                                  style: GoogleFonts.poppins(),
                                ),
                                items: _foodTypes.map((String type) {
                                  return DropdownMenuItem(
                                    value: type,
                                    child: Text(
                                      type,
                                      style: GoogleFonts.poppins(),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedFoodType = newValue;
                                  });
                                  _loadRestaurants();
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_recommendations.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.recommend,
                            color: Colors.orange[800],
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Rekomendasi untuk Anda',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange[800],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Berdasarkan preferensi: $_interestedFood',
                        style: GoogleFonts.poppins(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 250,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _recommendations.length,
                          itemBuilder: (context, index) {
                            final restaurant = _recommendations[index];
                            return Card(
                              margin: const EdgeInsets.only(right: 16),
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: SizedBox(
                                width: 280,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(12),
                                      ),
                                      child: Image.network(
                                        'https://via.placeholder.com/400x120',
                                        height: 120,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Container(
                                            height: 120,
                                            color: Colors.grey[300],
                                            child: Center(
                                              child: Icon(
                                                Icons.restaurant,
                                                color: Colors.grey[400],
                                                size: 40,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              restaurant.name,
                                              style: GoogleFonts.poppins(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.location_on,
                                                  color: Colors.orange[800],
                                                  size: 14,
                                                ),
                                                const SizedBox(width: 4),
                                                Expanded(
                                                  child: Text(
                                                    restaurant.location,
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 12,
                                                      color: Colors.grey[600],
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Expanded(
                                              child: Text(
                                                restaurant.description,
                                                style: GoogleFonts.poppins(
                                                  fontSize: 12,
                                                  color: Colors.grey[600],
                                                ),
                                                maxLines: 3,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const Divider(height: 32),
                    ],
                  ),
                ),
              ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.restaurant_menu,
                      color: Colors.orange[800],
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Semua Restoran',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange[800],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _isLoading
                ? const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Colors.orange,
                      ),
                    ),
                  )
                : _error != null
                    ? SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Error: $_error'),
                              ElevatedButton(
                                onPressed: _loadRestaurants,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange[800],
                                ),
                                child: const Text('Coba Lagi'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : SliverPadding(
                        padding: const EdgeInsets.all(16.0),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              return buildRestaurantCard(
                                  _getFilteredRestaurants()[index]);
                            },
                            childCount: _getFilteredRestaurants().length,
                          ),
                        ),
                      ),
          ],
        ),
      ),
    );
  }

  Widget buildRestaurantCard(Restaurant restaurant) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                'https://via.placeholder.com/400x200',
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Icon(
                      Icons.restaurant,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        restaurant.name,
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber[600], size: 20),
                        const SizedBox(width: 4),
                        Text(
                          restaurant.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on,
                        color: Colors.orange[800], size: 16),
                    const SizedBox(width: 4),
                    Text(
                      restaurant.location,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  restaurant.description,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        // Navigate to the ReservationFormPage
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ReservationFormPage(
                              restaurantModel: restaurant,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.calendar_today, size: 18),
                      label: const Text('Reservasi'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange[800],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.star_border),
                      label: const Text('Nilai'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.orange[800],
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        try {
                          final request = context.read<CookieRequest>();

                          print('Before toggle: ${restaurant.isBookmarked}');

                          final isBookmarked = await _restaurantService
                              .toggleBookmark(request, restaurant.id);

                          print('Toggle response: $isBookmarked');

                          setState(() {
                            restaurant.isBookmarked = isBookmarked;
                            print('After toggle: ${restaurant.isBookmarked}');
                          });
                        } catch (e) {
                          // ignore: use_build_context_synchronously
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('Error toggling bookmark: $e')));
                        }
                      },
                      icon: Icon(
                        restaurant.isBookmarked
                            ? Icons.bookmark
                            : Icons.bookmark_border,
                        color: Colors.orange[800],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
