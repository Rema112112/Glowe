import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:glowe/screens/analysis_result_screen.dart';
import 'package:glowe/screens/favorites_screen.dart';
import 'package:glowe/screens/history_screen.dart';
import 'package:glowe/screens/profile_screen.dart';
import 'package:glowe/services/barcode_scanner_service.dart';
import 'package:glowe/services/image_scanner_service.dart';
import 'package:glowe/screens/scan_controller.dart';
import 'skin_analysis_result_screen.dart';

class HomeScreen extends StatefulWidget {
  final bool isGuest;

  const HomeScreen({super.key, this.isGuest = false});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _isEnglish = true;

  // Services & Controllers
  final ImageScannerService _scannerService = ImageScannerService();
  final BarcodeScannerService _barcodeService = BarcodeScannerService();
  final ScanController _scanController = ScanController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void onSkinAnalysisPhotoCaptured(
    BuildContext context,
    ImageSource source,
  ) async {
    final File? imageFile = await _scanController.pickImageForSkinAnalysis(
      source,
    );

    if (imageFile != null && context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SkinAnalysisResultScreen(imageFile: imageFile),
        ),
      );
    }
  }

  Map<String, Map<String, String>> get _localized => {
    'en': {
      'greeting': 'Welcome to Glowé',
      'subtitle': 'Smart skincare analysis & ingredient safety.',
      'search_hint': 'Search product by name...',
      'scan_text': 'Scan Ingredients',
      'scan_text_sub': 'Take a photo or upload from gallery',
      'scan_barcode': 'Scan Barcode',
      'scan_barcode_sub': 'Scan product barcode for instant analysis',
      'skin_analysis': 'Skin Analysis',
      'skin_analysis_sub': 'AI face scan for custom routine & skin report',
      'safety_title': 'Smart Safety Check',
      'safety_sub':
          'AI flags allergens, pregnancy hazards & medication interactions.',
      'nav_home': 'Home',
      'nav_history': 'History',
      'nav_favorites': 'Favorites',
      'nav_profile': 'Profile',
      'guest_alert_title': 'Sign In Required',
      'guest_alert_msg': 'Please log in to access Favorites and History.',
      'close': 'Close',
      'processing_ocr': 'Extracting ingredient text...',
      'sheet_title': 'Select Image Source',
      'camera_option': 'Take a Photo',
      'gallery_option': 'Choose from Gallery',
    },
    'ar': {
      'greeting': 'أهلاً بك في جلوّي',
      'subtitle': 'تحليل ذكي للمنتجات وأمان المكونات.',
      'search_hint': 'ابحث عن منتج بالاسم...',
      'scan_text': 'مسح المكونات',
      'scan_text_sub': 'التقط صورة أو اختر من المعرض',
      'scan_barcode': 'مسح الباركود',
      'scan_barcode_sub': 'امسح باركود المنتج للتحليل الفوري',
      'skin_analysis': 'تحليل البشرة الذكي',
      'skin_analysis_sub': 'فحص الوجه بالكاميرا للحصول على روتين مخصص',
      'safety_title': 'فحص الأمان الذكي',
      'safety_sub':
          'الذكاء الاصطناعي يحدد الحساسية، خطورة الحمل، وتعارض الأدوية.',
      'nav_home': 'الرئيسية',
      'nav_history': 'السجل',
      'nav_favorites': 'المفضلة',
      'nav_profile': 'الملف الشخصي',
      'guest_alert_title': 'تسجيل الدخول مطلوب',
      'guest_alert_msg': 'يرجى تسجيل الدخول للوصول إلى المفضلة والسجل.',
      'close': 'إغلاق',
      'processing_ocr': 'جاري استخراج المكونات...',
      'sheet_title': 'اختر مصدر الصورة',
      'camera_option': 'التقاط صورة بالكاميرا',
      'gallery_option': 'اختيار من المعرض',
    },
  };

  String _txt(String key) => _localized[_isEnglish ? 'en' : 'ar']?[key] ?? key;

  void _navigateToResult(String queryOrText, bool isProductName) {
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AnalysisResultScreen(
          queryOrText: queryOrText,
          isProductName: isProductName,
        ),
      ),
    );
  }

  void _showLoadingDialog(String messageKey) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: Color(0xffa68cb5)),
              const SizedBox(height: 16),
              Text(
                _txt(messageKey),
                style: const TextStyle(
                  color: Color(0xff2d4a43),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _hideLoadingDialog() {
    if (mounted && Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  void _showScanOptionsBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xfffffbee),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _txt('sheet_title'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xff2d4a43),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xfff3edf7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.camera_alt, color: Color(0xffa68cb5)),
              ),
              title: Text(
                _txt('camera_option'),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xff2d4a43),
                ),
              ),
              onTap: () async {
                Navigator.pop(context);
                _showLoadingDialog('processing_ocr');
                final text = await _scannerService.scanTextFromCamera();
                _hideLoadingDialog();

                if (mounted && text != null && text.isNotEmpty) {
                  _navigateToResult(text, false);
                }
              },
            ),
            const Divider(height: 20),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xfff3edf7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.photo_library,
                  color: Color(0xffa68cb5),
                ),
              ),
              title: Text(
                _txt('gallery_option'),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xff2d4a43),
                ),
              ),
              onTap: () async {
                Navigator.pop(context);
                _showLoadingDialog('processing_ocr');
                final text = await _scannerService.scanTextFromGallery();
                _hideLoadingDialog();

                if (mounted && text != null && text.isNotEmpty) {
                  _navigateToResult(text, false);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showGuestModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xfffffbee),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_outline, size: 48, color: Color(0xffa68cb5)),
            const SizedBox(height: 12),
            Text(
              _txt('guest_alert_title'),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xff2d4a43),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _txt('guest_alert_msg'),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xffa68cb5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () => Navigator.pop(context),
              child: Text(
                _txt('close'),
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> get _screens => [
    _buildHomeDashboard(),
    HistoryScreen(isGuest: widget.isGuest),
    FavoritesScreen(isGuest: widget.isGuest),
    ProfileScreen(
      isGuest: widget.isGuest,
      isEnglish: _isEnglish,
      onLanguageChanged: (bool updatedLanguageState) {
        setState(() {
          _isEnglish = updatedLanguageState;
        });
      },
    ),
  ];

  void _onItemTapped(int index) {
    if (widget.isGuest && (index == 1 || index == 2)) {
      _showGuestModal();
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textDirection = _isEnglish ? TextDirection.ltr : TextDirection.rtl;

    return Directionality(
      textDirection: textDirection,
      child: Scaffold(
        backgroundColor: const Color(0xfffffbee),
        body: SafeArea(child: _screens[_selectedIndex]),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: Color(0xffe0e0e0), width: 0.5),
            ),
          ),
          child: BottomNavigationBar(
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: const Icon(Icons.home_outlined),
                activeIcon: const Icon(Icons.home),
                label: _txt('nav_home'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.access_time),
                label: _txt('nav_history'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.favorite_border),
                activeIcon: const Icon(Icons.favorite),
                label: _txt('nav_favorites'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.person_outline),
                activeIcon: const Icon(Icons.person),
                label: _txt('nav_profile'),
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: const Color(0xffa68cb5),
            unselectedItemColor: Colors.grey,
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            elevation: 0,
            onTap: _onItemTapped,
          ),
        ),
      ),
    );
  }

  Widget _buildHomeDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting
          Text(
            _txt('greeting'),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xff2d4a43),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _txt('subtitle'),
            style: const TextStyle(fontSize: 14, color: Colors.black),
          ),
          const SizedBox(height: 20),

          // Search Bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: _txt('search_hint'),
              prefixIcon: const Icon(Icons.search, color: Color(0xffa68cb5)),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: const BorderSide(
                  color: Color(0xffe0e0e0),
                  width: 0.5,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: const BorderSide(
                  color: Color(0xffe0e0e0),
                  width: 0.5,
                ),
              ),
            ),
            onSubmitted: (query) {
              if (query.trim().isNotEmpty) {
                _navigateToResult(query.trim(), true);
              }
            },
          ),
          const SizedBox(height: 20),

          // Safety Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xfff3edf7),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xffa68cb5).withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.health_and_safety_outlined,
                  size: 38,
                  color: Color(0xff4a7c59),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _txt('safety_title'),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Color(0xff2d4a43),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _txt('safety_sub'),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Action Cards
          // 1. Scan Ingredients
          _buildLargeActionCard(
            icon: Icons.camera_alt_outlined,
            title: _txt('scan_text'),
            subtitle: _txt('scan_text_sub'),
            onTap: _showScanOptionsBottomSheet,
          ),
          const SizedBox(height: 14),

          // 2. Scan Barcode
          _buildLargeActionCard(
            icon: Icons.qr_code_scanner,
            title: _txt('scan_barcode'),
            subtitle: _txt('scan_barcode_sub'),
            onTap: () async {
              if (!mounted) return;
              final currentContext = context;

              String? barcode;
              try {
                barcode = await (_barcodeService as dynamic).scanBarcode(
                  currentContext,
                );
              } catch (_) {
                barcode = await (_barcodeService as dynamic).scanBarcode();
              }

              if (mounted && barcode != null && barcode.isNotEmpty) {
                _navigateToResult('Barcode: $barcode', true);
              }
            },
          ),
          const SizedBox(height: 14),

          // 3. Skin Analysis
          _buildLargeActionCard(
            icon: Icons.face_retouching_natural,
            title: _txt('skin_analysis'),
            subtitle: _txt('skin_analysis_sub'),
            onTap: () {
              onSkinAnalysisPhotoCaptured(context, ImageSource.camera);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLargeActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xffe0e0e0), width: 0.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xfff3edf7),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, size: 30, color: const Color(0xffa68cb5)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xff2d4a43),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black.withOpacity(0.55),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              _isEnglish
                  ? Icons.arrow_forward_ios_rounded
                  : Icons.arrow_back_ios_new_rounded,
              size: 16,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
