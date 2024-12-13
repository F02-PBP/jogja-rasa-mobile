import 'dart:convert';
class Review {
  final String idreview;
  final String idrestaurant;
  final String iduser;
  final DateTime date;
  final int rating;
  final String review;
  // method return List<Review> from json
  List<Review> reviewFromJson(String str) 
    => List<Review>.from(json.decode(str).map((x)
    =>  Review.fromJson(x)));
  // method return List<Review> to json
  String reviewToJson(List<Review> data) 
    => json.encode(List<dynamic>.from(data.map((x) 
    => x.toJson())));

  Review({
    required this.iduser,
    required this.idreview,
    required this.idrestaurant,
    required this.date,
    required this.rating,
    required this.review,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      idreview: json['pk'],
      idrestaurant: json['fields']['restaurant'],
      iduser: json['fields']['user'],
      date: DateTime.parse(json["date"]),
      rating: json['fields']['rating'],
      review: json['fields']['review']
    );
  }

  Map<String, dynamic> toJson() => {
    "pk" : idreview,
    "user": iduser,
    "restaurant": idrestaurant,
    "date": "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
    "rating": rating,
    "review": review,
  };
}
