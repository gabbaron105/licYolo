import 'package:flutter/material.dart';
import '../components/custom_navbar.dart'; // Import the custom navigation bar

class DetailsPage extends StatelessWidget {
  final String title;
  final String subtitle;

  DetailsPage({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.keyboard_arrow_left_rounded, size: 32), // Increased icon size
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              subtitle,
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomNavBar(
        currentIndex: 0, // Set the appropriate index for the details page
        onTap: (index) {
          // Handle navigation if needed
        },
      ),
    );
  }
}
