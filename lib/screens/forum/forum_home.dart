import 'dart:convert';

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
  String username = '';
  Map<int, String> usernames = {};
  List<Topic> topics = [];

    Future<String> fetchUserNameById(CookieRequest request, int user_id) async {
    final response = await request.get('http://localhost:8000/forum/get-user-name-by-id/$user_id/');
    var data = response;
    return data['username'];
  }

  Future<List<Topic>> fetchTopics(CookieRequest request) async {
    final response = await request.get('http://localhost:8000/forum/json/all/topics/');
    
    // Melakukan decode response menjadi bentuk json
    var data = response;
    
    // Melakukan konversi data json menjadi object Topic
    List<Topic> listTopics = [];
    for (var d in data) {
      if (d != null) {
        Topic topicFetched = Topic.fromJson(d);
        String usernameTopic = await fetchUserNameById(request, topicFetched.fields.author);
        usernames[topicFetched.fields.author] = usernameTopic;
        listTopics.add(topicFetched);
      }
    }
    setState(() {
      topics = listTopics;
    });

    return listTopics;
  }

    Future<String> fetchUserName(CookieRequest request) async {
    final response = await request.get('http://localhost:8000/forum/get-user-name/');
    var data = response;
    setState(() {
      username = data['username'];
    });
    return data['username'];
  }

  Future<bool> isTopicAuthor(CookieRequest request, int topicAuthorId) async {
    final response = await request.get('http://localhost:8000/forum/get-user-name-by-id/$topicAuthorId/');
    return username == response['username'];
  }

  @override
  void initState() {
    super.initState();
    final request = context.read<CookieRequest>();
    fetchUserName(request);
    fetchTopics(request);
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
          Navigator.pushNamed(context, '/add-topic-flutter');
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: ListView.builder(
      // body: FutureBuilder<List<Topic>>(
      //   future: fetchTopics(request),
      //   builder: (context, snapshot) {
      //     if (snapshot.connectionState == ConnectionState.waiting) {
      //       return const Center(child: CircularProgressIndicator());
      //     }
      //     if (!snapshot.hasData || snapshot.data!.isEmpty) {
      //       return Center(
      //         child: Text(
      //           'Belum ada topik. Buat topik baru yuk!',
      //           style: GoogleFonts.poppins(),
      //         ),
      //       );
      //     }
      //     return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: topics.length,
            itemBuilder: (context, index) {
              var topic = topics[index];
              return Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ListTile(
                          title: Text(
                            topic.fields.title,
                            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'By ${usernames[topic.fields.author] ?? 'Unknown User'} on ${topic.fields.createdAt}',
                            style: GoogleFonts.poppins(fontSize: 12),
                          ),
                          onTap: () async {
                            Navigator.pushNamed(
                              context, 
                              '/topic-detail',
                              arguments: topic,
                            ).then((_) {
                              setState(() {
                                fetchTopics(request);
                              });
                            });
                          },
                        ),
                      ),
                      FutureBuilder<bool>(
                        future: isTopicAuthor(request, topic.fields.author),
                        builder: (context, snapshot) {
                          if (snapshot.hasData && snapshot.data == true) {
                            return PopupMenuButton<String>(
                              onSelected: (value) async {
                                if (value == 'edit') {
                                  Navigator.pushNamed(
                                    context,
                                    '/edit-topic-flutter',
                                    arguments: topic,
                                  ).then((_) {
                                    setState(() {
                                      fetchTopics(request);
                                    }); // Refresh topics after returning from edit page
                                  });
                                } else if (value == 'delete') {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Delete Topic'),
                                      content: const Text('Are you sure you want to delete this topic?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            Navigator.pop(context);
                                            try {
                                              final response = await request.get(
                                                'http://localhost:8000/forum/topic/${topic.pk}/delete-flutter/',
                                              );
                                              if (response is String) {
                                                final Map<String, dynamic> parsedResponse = json.decode(response);
                                                if (parsedResponse['status'] == 'success') {
                                                  setState(() {});  // Refresh the topics list
                                                  if (!context.mounted) return;
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    const SnackBar(content: Text("Topic deleted successfully!")),
                                                  );
                                                }
                                              } else if (response is Map) {
                                                if (response['status'] == 'success') {
                                                  setState(() {});  // Refresh the topics list
                                                  if (!context.mounted) return;
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    const SnackBar(content: Text("Topic deleted successfully!")),
                                                  );
                                                }
                                              }
                                            } catch (e) {
                                              if (!context.mounted) return;
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text("Error: $e")),
                                              );
                                            }
                                          },
                                          child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              },
                              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                                const PopupMenuItem<String>(
                                  value: 'edit',
                                  child: Text('Edit Topic'),
                                ),
                                const PopupMenuItem<String>(
                                  value: 'delete',
                                  child: Text('Delete Topic', style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      );
  }
} 