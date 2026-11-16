import 'package:flutter/material.dart';

class LanguageScreen extends StatefulWidget {
  final bool isEnglish;
  final ValueChanged<bool> onLanguageChanged;

  const LanguageScreen({
    super.key,
    required this.isEnglish,
    required this.onLanguageChanged,
  });

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  late String _selectedLanguage;

  @override
  void initState() {
    super.initState();
    // Synchronize initial state selection with the global setting passed in
    _selectedLanguage = widget.isEnglish ? 'English' : 'عربي';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffcfc0d7), // Exact soft pastel purple
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Language',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        titleSpacing: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          children: [
            _buildLanguageRow('English'),
            const SizedBox(height: 10),
            _buildLanguageRow('عربي'),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageRow(String language) {
    bool isSelected = _selectedLanguage == language;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedLanguage = language;
        });

        // Triggers the state update globally across your entire app architecture
        bool targetIsEnglish = language == 'English';
        widget.onLanguageChanged(targetIsEnglish);
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              language,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            if (isSelected)
              const Icon(Icons.check, color: Colors.black, size: 24),
          ],
        ),
      ),
    );
  }
}
