// lib/screens/forum_unauth.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jogjarasa_mobile/models/forum_topic_entry.dart';
import 'package:jogjarasa_mobile/widgets/left_drawer_unauth.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class ForumPageUnauth extends StatefulWidget {
  const ForumPageUnauth({super.key});

  @override
  State<ForumPageUnauth> createState() => _ForumPageUnauthState();
}

class _ForumPageUnauthState extends State<ForumPageUnauth> {
  Map<int, String> usernames = {};
  List<Topic> topics = [];
  bool _isLoading = true;

  Future<String> fetchUserNameById(CookieRequest request, int user_id) async {
    final response = await request.get(
        'https://jogja-rasa-production.up.railway.app/forum/get-user-name-by-id/$user_id/');
    return response['username'];
  }

  Future<void> fetchTopics(CookieRequest request) async {
    try {
      setState(() {
        _isLoading = true;
      });

      final response = await request.get(
          'https://jogja-rasa-production.up.railway.app/forum/json/all/topics/');

      List<Topic> listTopics = [];
      for (var d in response) {
        if (d != null) {
          Topic topicFetched = Topic.fromJson(d);
          String usernameTopic =
              await fetchUserNameById(request, topicFetched.fields.author);
          usernames[topicFetched.fields.author] = usernameTopic;
          listTopics.add(topicFetched);
        }
      }

      setState(() {
        topics = listTopics;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    final request = context.read<CookieRequest>();
    fetchTopics(request);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange[800],
        title: Text(
          'Forum JogjaRasa',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      drawer: const LeftDrawerUnauth(),
      body: Column(
        children: [
          // Preview Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.orange[50],
            child: Column(
              children: [
                Text(
                  'Mode Preview',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[800],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Login untuk ikut berdiskusi dan berbagi pengalaman kuliner',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/welcome');
                  },
                  icon: const Icon(Icons.login),
                  label: Text(
                    'Login Sekarang',
                    style: GoogleFonts.poppins(),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange[800],
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // Topics List
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Colors.orange,
                    ),
                  )
                : topics.isEmpty
                    ? Center(
                        child: Text(
                          'Belum ada topik diskusi',
                          style: GoogleFonts.poppins(),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () async {
                          final request = context.read<CookieRequest>();
                          await fetchTopics(request);
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: topics.length,
                          itemBuilder: (context, index) {
                            var topic = topics[index];
                            return Card(
                              elevation: 2,
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                title: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      topic.fields.title,
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      topic.fields.description,
                                      style: GoogleFonts.poppins(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.person_outline,
                                        size: 16,
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        usernames[topic.fields.author] ??
                                            'Unknown User',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Icon(
                                        Icons.calendar_today,
                                        size: 16,
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        topic.fields.createdAt
                                            .toString()
                                            .split('.')[0],
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Login untuk melihat detail diskusi',
                                        style: GoogleFonts.poppins(),
                                      ),
                                      action: SnackBarAction(
                                        label: 'Login',
                                        onPressed: () {
                                          Navigator.pushNamed(
                                              context, '/welcome');
                                        },
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
