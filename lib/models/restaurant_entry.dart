class Restaurant {
  final String id;
  final String name;
  final double longitude;
  final double latitude;
  final String description;
  bool isBookmarked;
  double rating;
  String location;

  Restaurant({
    required this.id,
    required this.name,
    required this.longitude,
    required this.latitude,
    required this.description,
    this.isBookmarked = false,
    this.rating = 0.0,
    required this.location,
  });


  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id'],
      name: json['name'],
      longitude: json['longitude'].toDouble(),
      latitude: json['latitude'].toDouble(),
      description: json['description'],
      location: json['location'] ??
          getLocationFromCoordinates(
              json['longitude'].toDouble(), json['latitude'].toDouble()),
      isBookmarked: json['is_bookmarked'] ?? false,
      rating: (json['rating'] != null) ? json['rating'].toDouble() : 0.0,

    );
  }

  get imageUrl => null;

  static String getLocationFromCoordinates(double longitude, double latitude) {
    if (longitude >= 110.70) {
      return "Solo";
    } else if (110.38 <= longitude && longitude <= 110.41 ||
        longitude >= 110.41) {
      return "Yogyakarta Timur";
    } else if (110.35 <= longitude && longitude <= 110.38) {
      return "Yogyakarta Pusat";
    } else if (110.32 <= longitude && longitude <= 110.35 ||
        longitude <= 110.32) {
      return "Yogyakarta Barat";
    } else if (-7.770 >= latitude && latitude >= -7.750) {
      return "Yogyakarta Utara";
    } else if (-7.820 <= latitude && latitude <= -7.810) {
      return "Yogyakarta Selatan";
    }
    return "Yogyakarta";
  }
}
