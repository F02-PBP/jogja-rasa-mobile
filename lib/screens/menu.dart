import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jogjarasa_mobile/models/restaurant_entry.dart';
import 'package:jogjarasa_mobile/services/restaurant_service.dart';
import 'package:jogjarasa_mobile/widgets/left_drawer.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

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
        _recommendations = result['recommendations'] as List<Restaurant>;
        _interestedFood = result['interested_food'] as String;
      });
    } catch (e) {
      print('Failed to load recommendations: $e');
    }
  }

  Future<void> _loadRestaurants() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final request = context.read<CookieRequest>();
      if (_searchQuery.isNotEmpty ||
          _selectedLocation != null ||
          (_selectedFoodType != null && _selectedFoodType != "Semua Jenis")) {
        final restaurants = await _restaurantService.searchRestaurants(
          request: request,
          query: _searchQuery,
          region: _selectedLocation,
          foodType:
              _selectedFoodType == "Semua Jenis" ? null : _selectedFoodType,
        );

        setState(() {
          _restaurants = restaurants;
          _isLoading = false;
        });
      } else {
        final restaurants = await _restaurantService.getRestaurants();
        setState(() {
          _restaurants = restaurants;
          _isLoading = false;
        });
      }
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
      body: Column(
        children: [
          if (_recommendations.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.orange[800],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Rekomendasi untuk Anda',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Berdasarkan preferensi: $_interestedFood',
                    style: GoogleFonts.poppins(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _recommendations.length,
                      itemBuilder: (context, index) {
                        final restaurant = _recommendations[index];
                        return Card(
                          margin: const EdgeInsets.only(right: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Container(
                            width: 280,
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  restaurant.name,
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  restaurant.location,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  restaurant.description,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange[800],
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
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
                    decoration: const InputDecoration(
                      hintText: 'Cari restoran...',
                      border: InputBorder.none,
                      icon: Icon(Icons.search),
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
                      hint: const Text("Pilih Lokasi"),
                      items: _locations.map((String location) {
                        return DropdownMenuItem(
                          value: location,
                          child: Text(location),
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
                      hint: const Text("Jenis Makanan"),
                      items: _foodTypes.map((String type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(type),
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
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: Colors.orange[800],
                    ),
                  )
                : _error != null
                    ? Center(
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
                      )
                    : RefreshIndicator(
                        onRefresh: _loadRestaurants,
                        color: Colors.orange[800],
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: _getFilteredRestaurants().length,
                          itemBuilder: (context, index) {
                            return buildRestaurantCard(
                                _getFilteredRestaurants()[index]);
                          },
                        ),
                      ),
          ),
        ],
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
              image: const DecorationImage(
                image: NetworkImage('https://via.placeholder.com/400x200'),
                fit: BoxFit.cover,
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
                      onPressed: () {},
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
                    IconButton(
                      onPressed: () {
                        setState(() {
                          restaurant.isBookmarked = !restaurant.isBookmarked;
                        });
                      },
                      icon: Icon(
                        restaurant.isBookmarked
                            ? Icons.bookmark
                            : Icons.bookmark_border,
                        color: Colors.orange[800],
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
