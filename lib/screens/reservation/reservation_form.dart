// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:jogjarasa_mobile/screens/menu.dart';
import 'package:jogjarasa_mobile/widgets/left_drawer.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:jogjarasa_mobile/models/restaurant_entry.dart';
import 'package:intl/intl.dart'; // For date and time formatting

class ReservationFormPage extends StatefulWidget {
  final Restaurant restaurantModel;

  const ReservationFormPage({
    super.key,
    required this.restaurantModel,
  });

  @override
  State<ReservationFormPage> createState() => _ReservationFormPageState();
}

class _ReservationFormPageState extends State<ReservationFormPage> {
  final _formKey = GlobalKey<FormState>();
  DateTime _date = DateTime.now();
  String _time = '';
  int _numberOfPeople = 0;

  List<String> generateTimeSlots() {
    List<String> timeSlots = [];
    for (int hour = 9; hour <= 20; hour++) {
      timeSlots.add("${hour.toString().padLeft(2, '0')}:00");
      timeSlots.add("${hour.toString().padLeft(2, '0')}:30");
    }
    return timeSlots;
  }
  
  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange[800],
        title: Text(
          'Create Reservation',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
      ),
      drawer: const LeftDrawer(),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                'Select Date',
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                // Date input
                Padding(
                  padding: const EdgeInsets.all(0),
                  child: TextFormField(
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.bold, // Makes the text bold
                    ),
                    readOnly: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      fillColor: Colors.white,
                      filled: true,
                    ),
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: _date,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2101),
                      );
                      if (pickedDate != null && pickedDate != _date) {
                        setState(() {
                          _date = pickedDate;
                        });
                      }
                    },
                    controller: TextEditingController(
                      text: DateFormat('dd/MM/yyyy').format(_date), // Display selected date
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                Text(
                  "Select Time",
                  style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: generateTimeSlots().map((time) {
                      // Parse the current time and the generated time slot
                      final now = DateTime.now();
                      final generatedTime = DateTime(
                        now.year,
                        now.month,
                        now.day,
                        int.parse(time.split(":")[0]), // Hour
                        int.parse(time.split(":")[1]), // Minute
                      );

                      // Check if the selected date is today
                      final isToday = _date.year == now.year &&
                          _date.month == now.month &&
                          _date.day == now.day;

                      // Determine if the time is valid (only check if the date is today)
                      final isValidTime = !isToday || !generatedTime.isBefore(now);

                      return GestureDetector(
                        onTap: isValidTime
                            ? () {
                                setState(() {
                                  _time = time;
                                });
                              }
                            : null, // Disable onTap for invalid times
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: _time == time
                                ? Colors.orange[800]
                                : (isValidTime ? Colors.white : Colors.grey[300]),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Text(
                            time,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isValidTime
                                  ? (_time == time ? Colors.white : Colors.grey[500])
                                  : Colors.grey[400], // Greyed out for invalid times
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                "Number of People",
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(8, (index) {
                      final number = index + 1;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _numberOfPeople = number;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          decoration: BoxDecoration(
                            color: _numberOfPeople == number
                                ? Colors.orange[100]
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _numberOfPeople == number
                              ? (Colors.orange[800] ?? Colors.orange)
                              : Colors.transparent,  // Border color
                              width: 2,  // Optional: set the width of the border
                            ),
                          ),
                          child: Text(
                            "$number",
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.bold,
                              fontSize: 40,
                              color: _numberOfPeople == number
                                  ? Colors.orange[800]
                                  : Colors.grey[500],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 20),

                // Save button
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 3,
                          backgroundColor: Colors.orange[800],
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 12,
                          ),
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        onPressed: () async {
                          if (_time.isEmpty || _numberOfPeople == 0) {
                            // Show a warning if any field is not filled
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Please fill in all the fields.",
                                  style: TextStyle(color: Colors.white),
                                ),
                                backgroundColor: Colors.red,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            return; // Stop execution if validation fails
                          }
                          if (_formKey.currentState!.validate()) {
                            // Format the date and time
                            String formattedDate = DateFormat('yyyy-MM-dd').format(_date);
                            String formattedTime = _time;

                            // Prepare data for the API request
                            final response = await request.postJson(
                              'http://localhost:8000/reservasi/create-reservation/',
                              jsonEncode(<String, dynamic>{
                                'date': formattedDate.toString(),
                                'time': formattedTime,
                                'number_of_people': _numberOfPeople,
                                'restaurant': widget.restaurantModel.toJson(),
                              }),
                            );

                            if (response['status'] == 'success') {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Reservation successfully created!",
                                    style: TextStyle(color: Colors.white)),
                                  backgroundColor: Colors.green,
                                  behavior: SnackBarBehavior.floating,),
                              );
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => const MyHomePage()),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Failed to create reservation.",
                                    style: TextStyle(color: Colors.white)),
                                  backgroundColor: Colors.red,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          }
                        },
                        child: Text(
                          "Save Reservation",
                          style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ]
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
