import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jogjarasa_mobile/models/forum_comment_entry.dart';
import 'package:jogjarasa_mobile/models/forum_topic_entry.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class TopicDetailPage extends StatefulWidget {
  final Topic topic;

  const TopicDetailPage({super.key, required this.topic});

  @override
  State<TopicDetailPage> createState() => _TopicDetailPageState();
}

class _TopicDetailPageState extends State<TopicDetailPage> {
  bool isAuthor = false;
  String username = '';
  Map<int, String> usernames = {};

  @override
  void initState() {
    super.initState();
    final request = context.read<CookieRequest>();
    checkIsAuthor(request);
    fetchUserName(request);
  }

  Future<void> checkIsAuthor(CookieRequest request) async {
    final response = await request.get(
        'https://jogja-rasa-production.up.railway.app/forum/get-user-name-by-id/${widget.topic.fields.author}/');
    setState(() {
      isAuthor = widget.topic.fields.author.toString() == response['username'];
    });
  }

  Future<List<Comment>> fetchComments(CookieRequest request) async {
    final response = await request.get(
        'https://jogja-rasa-production.up.railway.app/forum/json/topic/${widget.topic.pk}/comments/');
    var data = response;
    List<Comment> listComments = [];
    for (var d in data) {
      if (d != null) {
        Comment commentFetched = Comment.fromJson(d);
        String usernameComment =
            await fetchUserNameById(request, commentFetched.fields.author);
        usernames[commentFetched.fields.author] = usernameComment;
        listComments.add(commentFetched);
      }
    }
    return listComments;
  }

  Future<void> fetchUserName(CookieRequest request) async {
    final response = await request.get(
        'https://jogja-rasa-production.up.railway.app/forum/get-user-name/');
    var data = response;
    setState(() {
      username = data['username'];
    });
  }

  Future<String> fetchUserNameById(CookieRequest request, int user_id) async {
    final response = await request.get(
        'https://jogja-rasa-production.up.railway.app/forum/get-user-name-by-id/$user_id/');
    var data = response;
    return data['username'];
  }

  Future<void> _deleteTopic(CookieRequest request) async {
    try {
      final response = await request.get(
        'https://jogja-rasa-production.up.railway.app/forum/topic/${widget.topic.pk}/delete-flutter/',
      );
      if (response['status'] == 'success') {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Topic deleted successfully!")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Future<bool> isCommentAuthor(
      CookieRequest request, int commentAuthorId) async {
    final response = await request.get(
        'https://jogja-rasa-production.up.railway.app/forum/get-user-name-by-id/$commentAuthorId/');
    return username == response['username'];
  }

  Future<void> _deleteComment(CookieRequest request, Comment comment) async {
    try {
      final response = await request.get(
        'https://jogja-rasa-production.up.railway.app/forum/comment/${comment.pk}/delete-flutter/',
      );

      // Handle response yang mungkin string JSON
      var responseData = response;
      if (response is String) {
        responseData = json.decode(response);
      }

      if (responseData['status'] == 'success') {
        setState(() {}); // Refresh comments list
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Comment deleted successfully!")),
        );
      } else {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text("Error: ${responseData['message'] ?? 'Unknown error'}")),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange[800],
        title: Text(
          widget.topic.fields.title,
          style: GoogleFonts.poppins(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: isAuthor
            ? [
                PopupMenuButton<String>(
                  onSelected: (value) async {
                    if (value == 'edit') {
                      Navigator.pushNamed(context, '/edit-topic-flutter',
                          arguments: widget.topic);
                    } else if (value == 'delete') {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete Topic'),
                          content: const Text(
                              'Are you sure you want to delete this topic?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                _deleteTopic(request);
                              },
                              child: const Text('Delete',
                                  style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'edit',
                      child: Text('Edit Topic'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: Text('Delete Topic',
                          style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              ]
            : null,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange[800],
        onPressed: () {
          Navigator.pushNamed(
            context,
            '/add-comment-flutter',
            arguments: widget.topic,
          );
        },
        child: const Icon(Icons.add_comment, color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.topic.fields.description,
                  style: GoogleFonts.poppins(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  'By $username',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const Divider(height: 32),
                Text(
                  'Komentar',
                  style: GoogleFonts.poppins(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Comment>>(
              future: fetchComments(request),
              builder: (context, AsyncSnapshot snapshot) {
                if (snapshot.data == null) {
                  return const Center(child: CircularProgressIndicator());
                } else {
                  if (!snapshot.hasData) {
                    return const Column(
                      children: [
                        Text(
                          'Belum ada komentar.',
                          style: TextStyle(fontSize: 20),
                        ),
                        SizedBox(height: 8),
                      ],
                    );
                  } else {
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        var comment = snapshot.data![index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            comment.fields.comment,
                                            style: GoogleFonts.poppins(
                                                fontSize: 14),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'By ${usernames[comment.fields.author] ?? 'Unknown User'}',
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    FutureBuilder<bool>(
                                      future: isCommentAuthor(
                                          request, comment.fields.author),
                                      builder: (context, snapshot) {
                                        if (snapshot.hasData &&
                                            snapshot.data == true) {
                                          return PopupMenuButton<String>(
                                            onSelected: (value) async {
                                              if (value == 'edit') {
                                                Navigator.pushNamed(
                                                  context,
                                                  '/edit-comment-flutter',
                                                  arguments: comment,
                                                ).then((_) {
                                                  setState(
                                                      () {}); // Refresh comments after returning from edit page
                                                });
                                              } else if (value == 'delete') {
                                                showDialog(
                                                  context: context,
                                                  builder: (context) =>
                                                      AlertDialog(
                                                    title: const Text(
                                                        'Delete Comment'),
                                                    content: const Text(
                                                        'Are you sure you want to delete this comment?'),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                                context),
                                                        child: const Text(
                                                            'Cancel'),
                                                      ),
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                          _deleteComment(
                                                              request, comment);
                                                        },
                                                        child: const Text(
                                                            'Delete',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .red)),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              }
                                            },
                                            itemBuilder:
                                                (BuildContext context) =>
                                                    <PopupMenuEntry<String>>[
                                              const PopupMenuItem<String>(
                                                value: 'edit',
                                                child: Text('Edit Comment'),
                                              ),
                                              const PopupMenuItem<String>(
                                                value: 'delete',
                                                child: Text('Delete Comment',
                                                    style: TextStyle(
                                                        color: Colors.red)),
                                              ),
                                            ],
                                          );
                                        }
                                        return const SizedBox.shrink();
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
