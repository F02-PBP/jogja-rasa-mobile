import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jogjarasa_mobile/models/forum_topic_entry.dart';
import 'package:jogjarasa_mobile/widgets/left_drawer.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class ForumHomePage extends StatefulWidget {
  const ForumHomePage({super.key});

  @override
  State<ForumHomePage> createState() => _ForumHomePageState();
}

class _ForumHomePageState extends State<ForumHomePage> {
  Future<List<Topic>> fetchTopics(CookieRequest request) async {
    final response = await request.get('http://localhost:8000/forum/json/user/topics/');
    
    // Melakukan decode response menjadi bentuk json
    var data = response;
    
    // Melakukan konversi data json menjadi object Topic
    List<Topic> listTopics = [];
    for (var d in data) {
      if (d != null) {
        listTopics.add(Topic.fromJson(d));
      }
    }
    return listTopics;
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange[800],
        title: Text(
          'Forum JogjaRasa',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold
          ),
        ),
      ),
      drawer: const LeftDrawer(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange[800],
        onPressed: () {
          Navigator.pushNamed(context, '/add-topic');
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: FutureBuilder<List<Topic>>(
        future: fetchTopics(request),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'Belum ada topik. Buat topik baru yuk!',
                style: GoogleFonts.poppins(),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              var topic = snapshot.data![index];
              return Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  title: Text(
                    topic.fields.title,
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'By ${topic.fields.author} on ${topic.fields.createdAt}',
                    style: GoogleFonts.poppins(fontSize: 12),
                  ),
                  onTap: () {
                    Navigator.pushNamed(
                      context, 
                      '/topic-detail',
                      arguments: topic,
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
} 