import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:jogjarasa_mobile/models/reservation_entry.dart';

class DetailPage extends StatelessWidget {
  final Reservation reservation;

  const DetailPage({super.key, required this.reservation});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange[800],
        title: Text(
          'Reservation Details',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: screenWidth,
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Restaurant Information
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
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
                                  size: 40,
                                  color: Colors.grey[400],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              reservation.fields.restaurant.name,
                              style: GoogleFonts.poppins(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
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
                                    reservation.fields.restaurant.location,
                                    style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: Colors.grey),
                  const SizedBox(height: 6),
                  // Reservation Details
                  // Reservation Details
                  Table(
                    columnWidths: const {
                      0: FixedColumnWidth(150), // Column for labels
                      1: FixedColumnWidth(220), // Column for values
                    },
                    children: [
                      TableRow(
                        children: [
                          Text(
                            "Date:",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            DateFormat('EEEE, d MMMM y').format(reservation.fields.date),
                            style: GoogleFonts.poppins(fontSize: 14),
                          ),
                        ],
                      ),
                      const TableRow(
                        children: [
                          SizedBox(height: 8), // Add spacing between rows
                          SizedBox(height: 8),
                        ],
                      ),
                      TableRow(
                        children: [
                          Text(
                            "Time:",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            "${reservation.fields.time} WIB",
                            style: GoogleFonts.poppins(fontSize: 14),
                          ),
                        ],
                      ),
                      const TableRow(
                        children: [
                          SizedBox(height: 8),
                          SizedBox(height: 8),
                        ],
                      ),
                      TableRow(
                        children: [
                          Text(
                            "Number of People:",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            "${reservation.fields.numberOfPeople} people",
                            style: GoogleFonts.poppins(fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "Please arrive at least 10 minutes before the scheduled time to avoid any inconvenience. Wishing you a pleasant experience!",
                      style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Barcode Section
                  Column(
                    children: [
                      const Divider(color: Colors.grey),
                      const SizedBox(height: 12),
                      Image.network(
                        'https://static.vecteezy.com/system/resources/previews/022/722/100/non_2x/barcode-qr-code-transparent-free-free-png.png', // Replace with actual barcode image
                        height: 90,
                        width: 400,
                        fit: BoxFit.cover,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "ID: ${reservation.fields.reservationId}",
                        style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Back to Home Button
            Container(
              margin: const EdgeInsets.only(left: 16, right: 16, bottom: 12, top: 0), // Define margin here
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[800],
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context); // Navigate back to the previous screen
                },
                child: Text(
                  "Back",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}