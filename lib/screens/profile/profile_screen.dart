import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:jogjarasa_mobile/services/user_service.dart';
import 'package:jogjarasa_mobile/models/user_profile_entry.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserService userService = UserService();

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: FutureBuilder<UserProfile>(
        future: userService.getUserProfile(request),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: GoogleFonts.poppins(),
              ),
            );
          }

          if (!snapshot.hasData) {
            return Center(
              child: Text(
                'No profile data found',
                style: GoogleFonts.poppins(),
              ),
            );
          }

          final profile = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: CircleAvatar(
                    radius: 50,
                    child: Icon(
                      Icons.person,
                      size: 50,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ProfileInfoItem(label: 'Username', value: profile.username),
                ProfileInfoItem(label: 'Full Name', value: profile.fullName),
                ProfileInfoItem(label: 'Email', value: profile.email),
                ProfileInfoItem(
                    label: 'Interested In', value: profile.interestedIn),
              ],
            ),
          );
        },
      ),
    );
  }
}

class ProfileInfoItem extends StatelessWidget {
  final String label;
  final String value;

  const ProfileInfoItem({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Divider(),
        ],
      ),
    );
  }
}
