import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/single_child_widget.dart';

class RatingPage extends StatefulWidget{
  const RatingPage({super.key});

  State<RatingPage> createState() => _RatingPageState();
}

class _RatingPageState extends State<RatingPage>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar : AppBar(title : Text('Rating')),
      body : const Center(
        
      )
    );
  }
}