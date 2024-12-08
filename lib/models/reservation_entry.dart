import 'dart:convert';

List<Reservation> reservationFromJson(String str) => List<Reservation>.from(json.decode(str).map((x) => Reservation.fromJson(x)));

String reservationToJson(List<Reservation> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Reservation {
    String pk;
    Fields fields;

    Reservation({
        required this.pk,
        required this.fields,
    });

    factory Reservation.fromJson(Map<String, dynamic> json) => Reservation(
        pk: json["pk"],
        fields: Fields.fromJson(json["fields"]),
    );

    Map<String, dynamic> toJson() => {
        "pk": pk,
        "fields": fields.toJson(),
    };
}

class Fields {
    String reservationId;
    int user;
    DateTime date;
    String time;
    int numberOfPeople;
    Restaurant restaurant;

    Fields({
        required this.reservationId,
        required this.user,
        required this.date,
        required this.time,
        required this.numberOfPeople,
        required this.restaurant,
    });

    factory Fields.fromJson(Map<String, dynamic> json) => Fields(
        reservationId: json["reservation_id"],
        user: json["user"],
        date: DateTime.parse(json["date"]),
        time: json["time"],
        numberOfPeople: json["number_of_people"],
        restaurant: Restaurant.fromJson(json["restaurant"]),
    );

    Map<String, dynamic> toJson() => {
        "reservation_id": reservationId,
        "user": user,
        "date": "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
        "time": time,
        "number_of_people": numberOfPeople,
        "restaurant": restaurant.toJson(),
    };
}

class Restaurant {
    String id;
    String name;
    double longitude;
    double latitude;
    String description;

    Restaurant({
        required this.id,
        required this.name,
        required this.longitude,
        required this.latitude,
        required this.description,
    });

    factory Restaurant.fromJson(Map<String, dynamic> json) => Restaurant(
        id: json["id"],
        name: json["name"],
        longitude: json["longitude"]?.toDouble(),
        latitude: json["latitude"]?.toDouble(),
        description: json["description"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "longitude": longitude,
        "latitude": latitude,
        "description": description,
    };
}
