import 'package:flutter/material.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    // This is a placeholder representing your current body content with the search bar and 3 buttons
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Your custom search bar decoration...
            TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Your 3 custom scanner feature boxes (Barcode, Text, Gallery)
            _buildGridButton(
              'barcode scanner',
              const Color(0xffd1c4e9),
              Icons.qr_code_scanner,
            ),
            const SizedBox(height: 20),
            _buildGridButton(
              'Text scanner',
              const Color(0xffdcedc8),
              Icons.camera_alt,
            ),
            const SizedBox(height: 20),
            _buildGridButton(
              'Gallery Lookup',
              const Color(0xffcfd8dc),
              Icons.image,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridButton(String title, Color color, IconData icon) {
    return Container(
      width: double.infinity,
      height: 140,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 50, color: const Color(0xff555555)),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xff555555),
            ),
          ),
        ],
      ),
    );
  }
}
