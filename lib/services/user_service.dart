import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:jogjarasa_mobile/models/user_profile_entry.dart';

class UserService {
  static const String baseUrl = 'https://jogja-rasa-production.up.railway.app';

  Future<UserProfile> getUserProfile(CookieRequest request) async {
    try {
      final response = await request.get('$baseUrl/auth/check_auth_status/');

      if (response['status'] == true && response['user'] != null) {
        return UserProfile.fromJson(response['user']);
      }
      throw Exception('Failed to get user profile');
    } catch (e) {
      throw Exception('Error getting user profile: $e');
    }
  }
}
