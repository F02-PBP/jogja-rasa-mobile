import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jogjarasa_mobile/screens/reservation/reservation_list.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class LeftDrawer extends StatelessWidget {
  const LeftDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Drawer(
      child: Container(
        color: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.orange[800],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 30,
                    child: Icon(
                      Icons.restaurant_menu,
                      size: 35,
                      color: Colors.orange[800],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'JogjaRasa',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.restaurant),
              title: Text(
                'Lihat Restoran',
                style: GoogleFonts.poppins(),
              ),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/home');
              },
            ),
            ListTile(
              leading: const Icon(Icons.forum),
              title: Text(
                'Forum',
                style: GoogleFonts.poppins(),
              ),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/forum');
              },
            ),
            ListTile(
              leading: const Icon(Icons.star),
              title: Text(
                'Rating',
                style: GoogleFonts.poppins(),
              ),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/rating');
              },
            ),
            ListTile(
              leading: const Icon(Icons.bookmarks),
              title: Text(
                'Bookmark',
                style: GoogleFonts.poppins(),
              ),
              onTap: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/bookmark',
                  (route) => route.isFirst,
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: Text(
                'Reservasi',
                style: GoogleFonts.poppins(),
              ),
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ReservationPage()),
                  (route) => false,
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: Text(
                'Profile',
                style: GoogleFonts.poppins(),
              ),
              onTap: () {
                Navigator.pushNamed(context, '/profile');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: Text(
                'Logout',
                style: GoogleFonts.poppins(
                  color: Colors.red,
                ),
              ),
              onTap: () async {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text(
                        'Konfirmasi Logout',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      content: Text(
                        'Apakah Anda yakin ingin keluar?',
                        style: GoogleFonts.poppins(),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            'Batal',
                            style: GoogleFonts.poppins(),
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            try {
                              final response = await request.logout(
                                  "https://jogja-rasa-production.up.railway.app/auth/logout/");

                              if (response['status'] == true) {
                                if (context.mounted) {
                                  Navigator.of(context).pop();

                                  Navigator.of(context).pushNamedAndRemoveUntil(
                                    '/',
                                    (route) => false,
                                  );

                                  ScaffoldMessenger.of(context)
                                    ..hideCurrentSnackBar()
                                    ..showSnackBar(
                                      SnackBar(
                                        content: Text(response['message'] ??
                                            "Berhasil logout"),
                                        backgroundColor: Colors.green,
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                }
                              } else {
                                if (context.mounted) {
                                  Navigator.of(context).pop();

                                  ScaffoldMessenger.of(context)
                                    ..hideCurrentSnackBar()
                                    ..showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            "Gagal logout. Silakan coba lagi."),
                                        backgroundColor: Colors.red,
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                }
                              }
                            } catch (e) {
                              if (context.mounted) {
                                Navigator.of(context).pop();

                                ScaffoldMessenger.of(context)
                                  ..hideCurrentSnackBar()
                                  ..showSnackBar(
                                    SnackBar(
                                      content: Text("Error: $e"),
                                      backgroundColor: Colors.red,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                              }
                            }
                          },
                          child: Text(
                            'Ya',
                            style: GoogleFonts.poppins(
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
