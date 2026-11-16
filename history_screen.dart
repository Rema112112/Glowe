import 'package:flutter/material.dart';

class HistoryScreen extends StatefulWidget {
  final bool isGuest;

  const HistoryScreen({super.key, this.isGuest = false});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  // Clean empty list waiting for user scan items from the backend database later
  final List<Map<String, String>> _scanHistory = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 166, 178, 200), // Kept your designated blue tone background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Scan History',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      body: SafeArea(
        child: widget.isGuest
            ? _buildGuestHistoryView(context)
            : _buildUserHistoryView(),
      ),
    );
  }

  // Beautifully remodeled guest view matching the layout cards architecture
  Widget _buildGuestHistoryView(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.history_toggle_off_outlined,
                size: 64,
                color: Color.fromARGB(255, 62, 83, 127), // Soft blue tint accent icon color
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Track Your History',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Create an account or sign in to keep a historical log of your scanned items and tracking metrics.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.6,
              height: 50,
              child: ElevatedButton(
                onPressed: () =>
                    Navigator.of(context).popUntil((route) => route.isFirst),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 133, 150, 196),
                  foregroundColor: Colors.black,
          
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Log In / Sign Up',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Aesthetic blank-state handler matching your favorites configuration layout
  Widget _buildUserHistoryView() {
    if (_scanHistory.isEmpty) {
      return const Center(
        child: Text(
          'Your scan history is empty ✨',
          style: TextStyle(
            fontSize: 16,
            color: Colors.black54,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    // Your production list view builder goes here once database elements are mapped out
    return const SizedBox.shrink();
  }
}
