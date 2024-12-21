import 'package:flutter/material.dart';
import 'package:jogjarasa_mobile/models/bookmark_entry.dart';
import 'package:jogjarasa_mobile/models/restaurant_entry.dart';
import 'package:jogjarasa_mobile/services/restaurant_service.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class BookmarkPage extends StatefulWidget {
  const BookmarkPage({Key? key}) : super(key: key);

  @override
  State<BookmarkPage> createState() => _BookmarkPageState();
}

class _BookmarkPageState extends State<BookmarkPage> {
  final RestaurantService _restaurantService = RestaurantService();
  List<Bookmark> _bookmarkedRestaurants = [];
  List<Restaurant> _restaurants = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    final request = context.read<CookieRequest>();
    setState(() {
      _isLoading = true;
    });

    try {
      final restaurants = await _restaurantService.getRestaurants(request);
      final bookmarks = await _restaurantService.getBookmarks(request);
      final bookmarkedIds = bookmarks.map((b) => b.id).toSet();

      for (var restaurant in restaurants) {
        restaurant.isBookmarked = bookmarkedIds.contains(restaurant.id);
        debugPrint(
            "restaurant ${restaurant.id} dah bookmark: ${restaurant.isBookmarked}");
      }

      setState(() {
        _bookmarkedRestaurants = bookmarks;
        _restaurants = restaurants;
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      debugPrint("error di _loadBookmarks: $e");
      debugPrint("stack trace: $stackTrace");

      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/home');
          },
        ),
        title: Text(
          'Bookmark',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.orange[800],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _bookmarkedRestaurants.isEmpty
              ? Center(
                  child: Text(
                    'Anda belum menambahkan bookmark.',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                )
              : ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: _bookmarkedRestaurants.length,
                  itemBuilder: (context, index) {
                    final bookmark = _bookmarkedRestaurants[index];
                    return _buildBookmarkCard(bookmark);
                  },
                ),
    );
  }

  Widget _buildBookmarkCard(Bookmark bookmark) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: IntrinsicHeight(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                bookmark.name,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                bookmark.description,
                style: GoogleFonts.poppins(
                  color: Colors.grey[600],
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.location_on, color: Colors.orange[800], size: 16),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      bookmark.location,
                      style: GoogleFonts.poppins(
                        color: Colors.grey[600],
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () async {
                    final request = context.read<CookieRequest>();
                    await _restaurantService.toggleBookmark(
                        request, bookmark.id);
                    _loadBookmarks();
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.orange[800]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.bookmark_remove,
                          color: Colors.orange[800],
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Remove Bookmark',
                          style: GoogleFonts.poppins(
                            color: Colors.orange[800],
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
