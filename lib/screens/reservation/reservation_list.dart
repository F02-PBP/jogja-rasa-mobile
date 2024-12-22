// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:jogjarasa_mobile/models/reservation_entry.dart';
import 'package:jogjarasa_mobile/screens/reservation/detail_reservation.dart';
import 'package:jogjarasa_mobile/widgets/left_drawer.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class ReservationPage extends StatefulWidget {
  const ReservationPage({super.key});

  @override
  State<ReservationPage> createState() => _ReservationPageState();
}

class _ReservationPageState extends State<ReservationPage> {
  Future<List<Reservation>> fetchReservation(CookieRequest request) async {
    final response = await request
        .get('https://jogja-rasa-production.up.railway.app/reservasi/json/');

    // Melakukan decode response menjadi bentuk json
    var data = response;

    // Melakukan konversi data json menjadi object Reservation
    List<Reservation> listReservation = [];
    for (var d in data) {
      if (d != null) {
        listReservation.add(Reservation.fromJson(d));
      }
    }
    return listReservation;
  }

  Future<void> deleteData(CookieRequest request, String id) async {
    final url = Uri.parse(
        'https://jogja-rasa-production.up.railway.app/reservasi/delete-reservation/$id/');

    try {
      final response = await http.delete(
        url,
        headers: request.headers,
      );

      if (response.statusCode == 200) {
        setState(() {
          fetchReservation(request);
        });
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error occurred: $e');
    }
  }

  Future<void> _showDeleteConfirmationDialog(
      CookieRequest request, String id) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Konfirmasi Penghapusan',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: Text(
            'Apakah Anda yakin ingin menghapus reservasi?',
            style: GoogleFonts.poppins(),
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              child: Text('Batal',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
              onPressed: () {
                // Close the dialog if "No"
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Ya',
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold, color: Colors.red)),
              onPressed: () {
                // Perform the delete operation
                deleteData(request, id);
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  void _showEditReservationDialog(
      CookieRequest request, Reservation reservation) async {
    // Temporary variables to store updated data
    DateTime updatedDate = reservation.fields.date;
    String updatedTime = reservation.fields.time;
    int updatedPeople = reservation.fields.numberOfPeople;

    // Generate time options (09:00 to 20:30, interval 30 minutes)
    List<String> generateFilteredTimeOptions(DateTime selectedDate) {
      final now = DateTime.now();

      return List<String>.generate(
        24 * 2, // 48 slots (30-minute intervals for 24 hours)
        (index) {
          final hour = 9 + index ~/ 2;
          final minute = (index % 2) * 30;
          if (hour > 20) return '';
          return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
        },
      ).where((time) {
        if (time.isEmpty) return false;

        // Parse the generated time slot
        final generatedTime = DateTime(
          now.year,
          now.month,
          now.day,
          int.parse(time.split(":")[0]), // Hour
          int.parse(time.split(":")[1]), // Minute
        );

        // Filter based on whether the selected date is today
        final isToday = selectedDate.year == now.year &&
            selectedDate.month == now.month &&
            selectedDate.day == now.day;

        return !isToday || !generatedTime.isBefore(now);
      }).toList();
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Edit Reservation',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: StatefulBuilder(
            builder: (context, setState) {
              return SizedBox(
                width: MediaQuery.of(context).size.width *
                    0.6, // Make the dialog wider
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Select Date",
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 5),
                    // Date Picker
                    TextFormField(
                      style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold),
                      readOnly: true,
                      decoration: InputDecoration(
                        hintText: DateFormat('dd/MM/yyyy').format(updatedDate),
                        filled: true, // Fill the field with white color
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(18), // More rounded corners
                          borderSide: const BorderSide(
                            width: 2, // Thicker border
                          ),
                        ),
                      ),
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: updatedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2101),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            updatedDate = pickedDate;
                            updatedTime =
                                ''; // Reset the selected time if the date changes
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    // Time Dropdown
                    Text(
                      "Select Time",
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 5),
                    DropdownButtonFormField<String>(
                      value: updatedTime.isNotEmpty ? updatedTime : null,
                      dropdownColor: Colors.white,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: const BorderSide(
                            width: 2,
                          ),
                        ),
                      ),
                      items:
                          generateFilteredTimeOptions(updatedDate).map((time) {
                        return DropdownMenuItem<String>(
                          value: time,
                          child: Text(
                            time,
                            style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.bold),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          updatedTime = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Number of People",
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 5),
                    // Number of People Dropdown
                    DropdownButtonFormField<int>(
                      value: updatedPeople,
                      dropdownColor: Colors.white,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: const BorderSide(
                            width: 2,
                          ),
                        ),
                      ),
                      items: List<int>.generate(8, (index) => index + 1)
                          .map((number) {
                        return DropdownMenuItem<int>(
                          value: number,
                          child: Text(number.toString(),
                              style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.bold)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          updatedPeople = value!;
                        });
                      },
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              child: Text('Cancel',
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold, color: Colors.grey)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Save',
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold, color: Colors.orange[800])),
              onPressed: () async {
                // Make API request to update the reservation
                final url = Uri.parse(
                    'https://jogja-rasa-production.up.railway.app/reservasi/edit-reservation/${reservation.fields.reservationId}/');
                final response = await http.put(
                  url,
                  headers: request.headers,
                  body: jsonEncode({
                    'date': DateFormat('yyyy-MM-dd').format(updatedDate),
                    'time': updatedTime,
                    'number_of_people': updatedPeople,
                  }),
                );

                if (response.statusCode == 200) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Reservation successfully updated!",
                          style: TextStyle(color: Colors.white)),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  setState(() {
                    fetchReservation(request); // Refresh reservations
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Failed to update reservation.",
                          style: TextStyle(color: Colors.white)),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    return Scaffold(
      drawer: const LeftDrawer(),
      backgroundColor: Colors.orange[50],
      appBar: AppBar(
        backgroundColor: Colors.orange[800],
        title: Text(
          'My Reservations',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
      ),
      body: FutureBuilder(
        future: fetchReservation(request),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (snapshot.data == null || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons
                        .event_busy, // You can change this to any other icon you prefer
                    color: Colors.orange[800],
                    size: 80,
                  ),
                  const SizedBox(width: 8), // Space between the icon and text
                  Text(
                    'No Reservations',
                    style: GoogleFonts.poppins(
                      color: Colors.orange[800],
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            );
          } else {
            return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (_, index) => GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                DetailPage(reservation: snapshot.data![index]),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 18),
                        padding: const EdgeInsets.all(20.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              height: 120,
                              width: 120,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  'https://via.placeholder.com/400x200',
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Center(
                                      child: Icon(
                                        Icons.restaurant,
                                        size: 60,
                                        color: Colors.grey[400],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            // Assuming you want an image (replace 'imageUrl' with actual URL)
                            const SizedBox(width: 23),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${snapshot.data![index].fields.restaurant.name}",
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.location_on_outlined,
                                        color: Colors.grey,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          "${snapshot.data![index].fields.restaurant.location}",
                                          style: GoogleFonts.poppins(
                                              fontSize: 14, color: Colors.grey),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    DateFormat('EEEE, d MMMM y').format(
                                        snapshot.data![index].fields.date),
                                    style: GoogleFonts.poppins(
                                        fontSize: 13, color: Colors.grey),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          _showEditReservationDialog(
                                              request, snapshot.data![index]);
                                        },
                                        label: Text('Edit',
                                            style: GoogleFonts.poppins()),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.orange,
                                          foregroundColor: Colors.white,
                                          elevation: 3,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(18),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 20),
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          _showDeleteConfirmationDialog(request,
                                              '${snapshot.data![index].fields.reservationId}');
                                        },
                                        label: Text('Delete',
                                            style: GoogleFonts.poppins()),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red[800],
                                          foregroundColor: Colors.white,
                                          elevation: 3,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(18),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ));
          }
        },
      ),
    );
  }
}
