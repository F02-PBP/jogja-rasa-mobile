// To parse this JSON data, do
//
//     final topic = topicFromJson(jsonString);

import 'dart:convert';

List<Topic> topicFromJson(String str) => List<Topic>.from(json.decode(str).map((x) => Topic.fromJson(x)));

String topicToJson(List<Topic> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Topic {
    String model;
    int pk;
    Fields fields;

    Topic({
        required this.model,
        required this.pk,
        required this.fields,
    });

    factory Topic.fromJson(Map<String, dynamic> json) => Topic(
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
    String title;
    String description;
    int author;
    DateTime createdAt;

    Fields({
        required this.title,
        required this.description,
        required this.author,
        required this.createdAt,
    });

    factory Fields.fromJson(Map<String, dynamic> json) => Fields(
        title: json["title"],
        description: json["description"],
        author: json["author"],
        createdAt: DateTime.parse(json["created_at"]),
    );

    Map<String, dynamic> toJson() => {
        "title": title,
        "description": description,
        "author": author,
        "created_at": createdAt.toIso8601String(),
    };
}
