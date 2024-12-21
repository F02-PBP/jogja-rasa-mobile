// To parse this JSON data, do
//
//     final comment = commentFromJson(jsonString);

import 'dart:convert';

List<Comment> commentFromJson(String str) => List<Comment>.from(json.decode(str).map((x) => Comment.fromJson(x)));

String commentToJson(List<Comment> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Comment {
    String model;
    int pk;
    Fields fields;

    Comment({
        required this.model,
        required this.pk,
        required this.fields,
    });

    factory Comment.fromJson(Map<String, dynamic> json) => Comment(
        model: json["model"],
        pk: json["pk"],
        fields: Fields.fromJson(json["fields"]),
    );

    Map<String, dynamic> toJson() => {
        "model": model,
        "pk": pk,
        "fields": fields.toJson(),
    };
}

class Fields {
    int topic;
    String comment;
    int author;
    DateTime createdAt;

    Fields({
        required this.topic,
        required this.comment,
        required this.author,
        required this.createdAt,
    });

    factory Fields.fromJson(Map<String, dynamic> json) => Fields(
        topic: json["topic"],
        comment: json["comment"],
        author: json["author"],
        createdAt: DateTime.parse(json["created_at"]),
    );

    Map<String, dynamic> toJson() => {
        "topic": topic,
        "comment": comment,
        "author": author,
        "created_at": createdAt.toIso8601String(),
    };
}
