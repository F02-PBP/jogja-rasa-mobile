import 'package:flutter/material.dart';
import 'package:jogjarasa_mobile/models/forum_comment_entry.dart';
import 'package:jogjarasa_mobile/models/forum_topic_entry.dart';
import 'package:jogjarasa_mobile/screens/bookmark/bookmark.dart';
import 'package:jogjarasa_mobile/screens/forum/add_comment.dart';
import 'package:jogjarasa_mobile/screens/forum/add_topic.dart';
import 'package:jogjarasa_mobile/screens/forum/edit_comment.dart';
import 'package:jogjarasa_mobile/screens/forum/edit_topic.dart';
import 'package:jogjarasa_mobile/screens/forum/forum_home.dart';
import 'package:jogjarasa_mobile/screens/forum/topic_detail.dart';
import 'package:jogjarasa_mobile/screens/login.dart';
import 'package:jogjarasa_mobile/screens/menu.dart';
import 'package:jogjarasa_mobile/screens/register.dart';
import 'package:jogjarasa_mobile/screens/reservation/reservation_list.dart';
import 'package:jogjarasa_mobile/screens/welcome.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:jogjarasa_mobile/screens/rating.dart';
import 'package:jogjarasa_mobile/screens/profile/profile_screen.dart';

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
            surface: Colors.orange[50],
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
          '/profile': (context) => const ProfileScreen(),
          '/login': (context) => const LoginPage(),
          '/register': (context) => const RegisterPage(),
          '/home': (context) => const MyHomePage(),
          '/reservasi': (context) => const ReservationPage(),
          // Tambahkan routes untuk forum
          '/forum': (context) => const ForumHomePage(),
          '/add-topic-flutter': (context) => const AddTopicPage(),
          '/topic-detail': (context) {
            final topic = ModalRoute.of(context)!.settings.arguments as Topic;
            return TopicDetailPage(topic: topic);
          },
          '/add-comment-flutter': (context) {
            final topic = ModalRoute.of(context)!.settings.arguments as Topic;
            return AddCommentPage(topic: topic);
          },
          // '/forum': (context) => const F
          '/rating': (context) => const RatingPage(),
          '/edit-topic-flutter': (context) {
            final topic = ModalRoute.of(context)!.settings.arguments as Topic;
            return EditTopicPage(topic: topic);
          },
          '/bookmark': (context) => const BookmarkPage(),
          '/edit-comment-flutter': (context) => EditCommentPage(
                comment: ModalRoute.of(context)!.settings.arguments as Comment,
              ),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
