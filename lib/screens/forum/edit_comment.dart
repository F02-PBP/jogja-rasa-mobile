import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jogjarasa_mobile/models/forum_comment_entry.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class EditCommentPage extends StatefulWidget {
  final Comment comment;

  const EditCommentPage({super.key, required this.comment});

  @override
  State<EditCommentPage> createState() => _EditCommentPageState();
}

class _EditCommentPageState extends State<EditCommentPage> {
  final _formKey = GlobalKey<FormState>();
  late String _comment;

  @override
  void initState() {
    super.initState();
    _comment = widget.comment.fields.comment;
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange[800],
        title: Text(
          'Edit Komentar',
          style: GoogleFonts.poppins(
              color: Colors.white, fontWeight: FontWeight.bold),
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
                'Edit komentar:',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.orange[800],
                ),
              ),
              const SizedBox(height: 12.0),
              TextFormField(
                initialValue: _comment,
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final response = await request.postJson(
                      "https://jogja-rasa-production.up.railway.app/forum/comment/${widget.comment.pk}/edit-flutter/",
                      jsonEncode({
                        'comment': _comment,
                      }),
                    );

                    if (response['status'] == 'success') {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Komentar berhasil diubah!"),
                        ),
                      );
                      Navigator.pop(context);
                    } else {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text("Terjadi kesalahan, silakan coba lagi."),
                        ),
                      );
                    }
                  }
                },
                child: Text(
                  "Simpan",
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
