class UserProfile {
  final String username;
  final String email;
  final String fullName;
  final String interestedIn;

  UserProfile({
    required this.username,
    required this.email,
    required this.fullName,
    required this.interestedIn,
  });

  Map<String, dynamic> toJson() => {
        "username": username,
        "email": email,
        "full_name": fullName,
        "interested_in": interestedIn,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      fullName: json['full_name'] ?? '',
      interestedIn: json['interested_in'] ?? '',
    );
  }
}
