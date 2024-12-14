// // To parse this JSON data, do
// //
// //     final bookmark = bookmarkFromJson(jsonString);

// import 'dart:convert';

// List<Bookmark> bookmarkFromJson(String str) => List<Bookmark>.from(json.decode(str).map((x) => Bookmark.fromJson(x)));

// String bookmarkToJson(List<Bookmark> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Bookmark {
  final String id;
  final String name;
  final String description;
  final String location;
  bool isBookmarked;

  Bookmark({
    required this.id,
    required this.name,
    required this.description,
    required this.location, 
    required this.isBookmarked,
  });

  factory Bookmark.fromJson(Map<String, dynamic> json) {
    // Use default empty string if a field is null
    return Bookmark(
      id: json['id'] ?? '', // If 'id' is null, use an empty string
      name: json['name'] ?? 'No Name', // Default name if null
      description: json['description'] ?? 'No Description', // Default description if null
      location: json['location'] ?? 'No Location', // Default location if null
      isBookmarked: json['is_bookmark'] ?? false,
    );
  }
}
