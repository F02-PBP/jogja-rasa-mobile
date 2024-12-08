import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:jogjarasa_mobile/screens/welcome.dart';
import 'package:jogjarasa_mobile/screens/login.dart';
import 'package:jogjarasa_mobile/screens/register.dart';
import 'package:jogjarasa_mobile/screens/menu.dart';
// import 'package:jogjarasa_mobile/screens/forum.dart';
// import 'package:jogjarasa_mobile/screens/rating.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (_) {
        CookieRequest request = CookieRequest();
        return request;
      },
      child: MaterialApp(
        title: 'JogjaRasa',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: Colors.orange,
          ).copyWith(
            secondary: Colors.orange[400],
            background: Colors.orange[50],
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.orange[800],
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange[800],
              foregroundColor: Colors.white,
            ),
          ),
        ),
        initialRoute: '/welcome',
        routes: {
          '/welcome': (context) => const WelcomePage(),
          '/login': (context) => const LoginPage(),
          '/register': (context) => const RegisterPage(),
          '/home': (context) => const MyHomePage(),
          // '/forum': (context) => const ForumPage(),
          // '/rating': (context) => const RatingPage(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
