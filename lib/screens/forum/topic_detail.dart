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

  Future<List<Comment>> fetchComments(CookieRequest request) async {
    final response = await request.get(
      'http://localhost:8000/forum/json/user/comments/'
    );
    var data = response;
    List<Comment> listComments = [];
    for (var d in data) {
      if (d != null) {
        listComments.add(Comment.fromJson(d));
      }
    }
    return listComments;
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
            color: Colors.white,
            fontWeight: FontWeight.bold
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange[800],
        onPressed: () {
          Navigator.pushNamed(
            context,
            '/add-comment',
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
                  'By ${widget.topic.fields.author}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const Divider(height: 32),
                Text(
                  'Komentar',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold
                  ),
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
                                Text(
                                  comment.fields.comment,
                                  style: GoogleFonts.poppins(fontSize: 14),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'By ${comment.fields.author}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
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