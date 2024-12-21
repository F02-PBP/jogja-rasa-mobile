import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jogjarasa_mobile/models/forum_topic_entry.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class AddCommentPage extends StatefulWidget {
  final Topic topic;

  const AddCommentPage({super.key, required this.topic});

  @override
  State<AddCommentPage> createState() => _AddCommentPageState();
}

class _AddCommentPageState extends State<AddCommentPage> {
  final _formKey = GlobalKey<FormState>();
  String _comment = "";

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange[800],
        title: Text(
          'Tambah Komentar',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tambah komentar:',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.orange[800],
                ),
              ),
              const SizedBox(height: 12.0),
              TextFormField(
                decoration: InputDecoration(
                  hintText: 'Tulis komentarmu di sini...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                maxLines: 4,
                onChanged: (String? value) {
                  setState(() {
                    _comment = value!;
                  });
                },
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Komentar tidak boleh kosong!';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20.0),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[800],
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final response = await request.postJson(
                      "http://localhost:8000/forum/create-comment/",
                      jsonEncode({
                        'topic_id': widget.topic.pk,
                        'comment': _comment,
                      }),
                    );

                    if (response['status'] == 'success') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Komentar berhasil ditambahkan!"),
                        ),
                      );
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Terjadi kesalahan, silakan coba lagi."),
                        ),
                      );
                    }
                  }
                },
                child: Text(
                  "Submit",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
