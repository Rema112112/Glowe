import 'package:flutter/material.dart';

class ReviewItem {
  final String text;
  final IconData placeholderIcon;
  final Color iconColor;

  ReviewItem({
    required this.text,
    required this.placeholderIcon,
    required this.iconColor,
  });
}

class MyReviewsScreen extends StatefulWidget {
  const MyReviewsScreen({super.key});

  @override
  State<MyReviewsScreen> createState() => _MyReviewsScreenState();
}

class _MyReviewsScreenState extends State<MyReviewsScreen> {
  // CLEAN & EMPTY: No mock items. Ready to pull real inputs from the database later!
  final List<ReviewItem> _userReviews = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xffdbe6ff,
      ), // Matches your light review frame color background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'My Reviews',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        titleSpacing: 0,
      ),
      // DYNAMIC CONDITIONAL VIEW SWITCHER
      body: _userReviews.isEmpty
          ? _buildEmptyReviewsPlaceholder()
          : _buildReviewsListView(),
    );
  }

  // --- VIEW A: CLEAN EMPTY STATE ---
  Widget _buildEmptyReviewsPlaceholder() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.rate_review_outlined,
                size: 60,
                color: Color(0xffa68cb5), // Theme styling accent color
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Reviews Yet',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "You haven't written any product ingredient reviews yet. Once you analyze and rate products, they'll appear right here!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.black54,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- VIEW B: CORE LIST BUILDER (Activates once database updates length > 0) ---
  Widget _buildReviewsListView() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _userReviews.length,
      itemBuilder: (context, index) {
        final item = _userReviews[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
            ),
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Product Graphic Illustration Placeholder
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: item.iconColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    item.placeholderIcon,
                    color: item.iconColor,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 12),

                // Review Content Text
                Expanded(
                  child: Text(
                    item.text,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // Vertical Divider Strip
                Container(
                  height: 40,
                  width: 1,
                  color: Colors.grey[300],
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                ),

                // Delete Button
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.grey,
                    size: 28,
                  ),
                  onPressed: () {
                    setState(() {
                      _userReviews.removeAt(index);
                    });
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
