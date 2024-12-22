import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LeftDrawerUnauth extends StatelessWidget {
  const LeftDrawerUnauth({super.key});

  @override
  Widget build(BuildContext context) {
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
              leading: const Icon(Icons.explore),
              title: Text(
                'Jelajah JogjaRasa',
                style: GoogleFonts.poppins(),
              ),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/explore');
              },
            ),
            ListTile(
              leading: const Icon(Icons.restaurant),
              title: Text(
                'Lihat Restoran',
                style: GoogleFonts.poppins(),
              ),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/restaurants');
              },
            ),
            ListTile(
              leading: const Icon(Icons.forum),
              title: Row(
                children: [
                  Text(
                    'Forum',
                    style: GoogleFonts.poppins(),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Preview',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/forum_lagi');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.login, color: Colors.orange),
              title: Text(
                'Login',
                style: GoogleFonts.poppins(
                  color: Colors.orange[800],
                  fontWeight: FontWeight.bold,
                ),
              ),
              tileColor: Colors.orange[50],
              onTap: () {
                Navigator.pushNamed(context, '/welcome');
              },
            ),
          ],
        ),
      ),
    );
  }
}
