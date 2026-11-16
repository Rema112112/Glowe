import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'manage_account_screen.dart';
import 'my_reviews_screen.dart';
import 'language_screen.dart';
import 'welcome_screen.dart'; // Redirect to main WelcomeScreen

class ProfileScreen extends StatefulWidget {
  final bool isGuest;
  final bool isEnglish;
  final ValueChanged<bool> onLanguageChanged;

  const ProfileScreen({
    super.key,
    this.isGuest = false,
    required this.isEnglish,
    required this.onLanguageChanged,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Localization dictionary
  final Map<String, Map<String, String>> _localized = {
    'en': {
      'guest_title': 'Guest Profile',
      'user_title': 'Your Profile',
      'guest_msg': 'Log in or create an account to access all features.',
      'account_section': 'Account',
      'manage_account': 'Manage Account',
      'my_reviews': 'My Reviews',
      'settings_section': 'Settings',
      'language': 'Language',
      'about_section': 'About',
      'privacy': 'Privacy Policy',
      'terms': 'Terms of Use',
      'about_us': 'About Us',
      'contact_us': 'Contact Us',
      'logout': 'Log out',
      'login_signup': 'Sign up / Log in',
      'version': 'Glowé 1.0.0',
    },
    'ar': {
      'guest_title': 'حساب الزائر',
      'user_title': 'ملفك الشخصي',
      'guest_msg': 'سجل الدخول أو أنشئ حساباً للوصول لكافة الميزات.',
      'account_section': 'الحساب',
      'manage_account': 'إدارة الحساب',
      'my_reviews': 'تقييماتي',
      'settings_section': 'الإعدادات',
      'language': 'اللغة',
      'about_section': 'عن التطبيق',
      'privacy': 'سياسة الخصوصية',
      'terms': 'شروط الاستخدام',
      'about_us': 'من نحن',
      'contact_us': 'تواصل معنا',
      'logout': 'تسجيل الخروج',
      'login_signup': 'إنشاء حساب / دخول',
      'version': 'Glowé 1.0.0',
    },
  };

  // --- LEGAL & SUPPORT TEXT DOCUMENTS ---
  final String privacyPolicyText = """Privacy Policy – Glowé
Last Updated: [4/June/2026]

Thank you for using Glowé. Your privacy is important to us. This Privacy Policy explains how we collect, use, and protect your information when you use our application.

1. Information We Collect
Glowé may collect the following types of information:
• User-provided information: such as product reviews, comments, or feedback you choose to submit.
• Usage data: information about how you interact with the app.
• Product input data: such as product names, ingredients, or barcodes you enter for analysis.

2. How We Use Information
We use the collected information to:
• Analyze skincare and haircare products
• Improve ingredient analysis accuracy
• Provide personalized recommendations
• Enhance user experience and app performance

3. Data Sharing
We do not sell your personal data. We may share limited information only in the following cases:
• To improve app functionality and analytics
• When required by law or legal processes

4. Data Security
We take reasonable technical and organizational measures to protect your data from unauthorized access, loss, or misuse.

5. Changes to This Policy
We may update this Privacy Policy from time to time. Continued use of Glowé means you accept the updated policy.""";

  final String aboutUsText = """About Us – Glowé

Glowé is a smart skincare and haircare analysis application designed to help users better understand the products they use every day.

Our mission is to make ingredient transparency simple, accessible, and easy to understand for everyone. By analyzing product formulations, Glowé provides clear insights into what each ingredient does, whether it is beneficial or potentially harmful, and how suitable a product is for different skin and hair types.

We believe that everyone deserves to make informed decisions about their skincare routine without confusion or misleading marketing.""";

  final String termsOfUseText = """Terms of Use – Glowé
Last Updated: [4/June/2026]

Welcome to Glowé. By using this application, you agree to the following Terms of Use.

1. Acceptance of Terms
By accessing or using Glowé, you confirm that you have read, understood, and agreed to be bound by these Terms in full.

2. Service Description
Glowé is an application designed to analyze skincare and haircare product ingredients.
Note: All information provided is for educational and informational purposes only and is not a substitute for professional medical or dermatological advice.

3. Medical Disclaimer
Glowé does not provide medical diagnoses, treatments, or prescriptions. If you experience skin irritation or medical concerns, please consult a qualified healthcare professional.""";

  final String supportText = """Contact Support

Having trouble with Glowé?
Send us an email and we'll get back to you as soon as possible.

support@glowe.app

Thank you for helping us improve Glowé 🌷""";

  void _showContentModal(BuildContext context, String title, String content) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xfffffbee),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const Divider(height: 30, color: Colors.grey),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    children: [
                      Text(
                        content,
                        style: const TextStyle(
                          fontSize: 15,
                          height: 1.6,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _handleAuthAction(BuildContext context) async {
    if (widget.isGuest) {
      // Redirect Guest to Welcome Screen
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
        (route) => false,
      );
    } else {
      // Sign Out Logged-In User and Redirect to Welcome Screen
      await FirebaseAuth.instance.signOut();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final String lang = widget.isEnglish ? 'en' : 'ar';
    final User? currentUser = FirebaseAuth.instance.currentUser;

    return Directionality(
      textDirection: widget.isEnglish ? TextDirection.ltr : TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xffb9c6ae), // Soft sage green
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Padding(
            padding: const EdgeInsets.only(left: 4.0),
            child: Text(
              widget.isGuest
                  ? _localized[lang]!['guest_title']!
                  : _localized[lang]!['user_title']!,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- USER / GUEST INFORMATION CARD ---
                if (!widget.isGuest && currentUser != null)
                  StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(currentUser.uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      String userName = currentUser.displayName ?? 'User';
                      String userEmail = currentUser.email ?? '';

                      if (snapshot.hasData &&
                          snapshot.data != null &&
                          snapshot.data!.exists) {
                        final data =
                            snapshot.data!.data() as Map<String, dynamic>?;
                        if (data != null && data.containsKey('name')) {
                          userName = data['name'] ?? userName;
                        }
                      }

                      return _buildUserInfoCard(
                        name: userName,
                        email: userEmail,
                      );
                    },
                  )
                else if (widget.isGuest)
                  _buildGuestInfoCard(lang),

                const SizedBox(height: 20),

                // --- ACCOUNT SECTION ---
                if (!widget.isGuest) ...[
                  _buildSectionTitle(_localized[lang]!['account_section']!),
                  const SizedBox(height: 8),
                  _buildMenuCard(
                    title: _localized[lang]!['manage_account']!,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ManageAccountScreen(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildMenuCard(
                    title: _localized[lang]!['my_reviews']!,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MyReviewsScreen(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // --- SETTINGS SECTION ---
                _buildSectionTitle(_localized[lang]!['settings_section']!),
                const SizedBox(height: 8),
                _buildMenuCard(
                  title: _localized[lang]!['language']!,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LanguageScreen(
                        isEnglish: widget.isEnglish,
                        onLanguageChanged: widget.onLanguageChanged,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // --- ABOUT SECTION ---
                _buildSectionTitle(_localized[lang]!['about_section']!),
                const SizedBox(height: 8),
                _buildMenuCard(
                  title: _localized[lang]!['privacy']!,
                  onTap: () => _showContentModal(
                    context,
                    _localized[lang]!['privacy']!,
                    privacyPolicyText,
                  ),
                ),
                const SizedBox(height: 10),
                _buildMenuCard(
                  title: _localized[lang]!['terms']!,
                  onTap: () => _showContentModal(
                    context,
                    _localized[lang]!['terms']!,
                    termsOfUseText,
                  ),
                ),
                const SizedBox(height: 10),
                _buildMenuCard(
                  title: _localized[lang]!['about_us']!,
                  onTap: () => _showContentModal(
                    context,
                    _localized[lang]!['about_us']!,
                    aboutUsText,
                  ),
                ),
                const SizedBox(height: 10),
                _buildMenuCard(
                  title: _localized[lang]!['contact_us']!,
                  onTap: () => _showContentModal(
                    context,
                    _localized[lang]!['contact_us']!,
                    supportText,
                  ),
                ),

                const SizedBox(height: 40),

                // --- BOTTOM LOG OUT / SIGN IN BUTTON ---
                Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.65,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () => _handleAuthAction(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xffdcdcdc),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26),
                        ),
                      ),
                      child: Text(
                        widget.isGuest
                            ? _localized[lang]!['login_signup']!
                            : _localized[lang]!['logout']!,
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),
                Center(
                  child: Text(
                    _localized[lang]!['version']!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- HELPER WIDGETS ---

  Widget _buildUserInfoCard({required String name, required String email}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 28,
            backgroundColor: Color(0xff1d5341),
            child: Icon(Icons.person, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuestInfoCard(String lang) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 28,
            backgroundColor: Colors.grey,
            child: Icon(Icons.person_outline, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _localized[lang]!['guest_title']!,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _localized[lang]!['guest_msg']!,
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }

  Widget _buildMenuCard({required String title, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
