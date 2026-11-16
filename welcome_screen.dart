import 'package:flutter/material.dart';
import 'package:glowe/screens/home_screen.dart';
import 'package:glowe/screens/signup_screen.dart';
import 'package:glowe/screens/login_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool _isAnimated = false;
  bool _isEnglish =
      true; // Tracks language toggle state (true = EN, false = AR)

  // Language Strings Dictionary
  final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'login': 'I have an account',
      'signup': 'Create an account',
      'guest': 'Continue as guest',
    },
    'ar': {
      'login': 'لدي حساب بالفعل',
      'signup': 'إنشاء حساب جديد',
      'guest': 'المتابعة كزائر',
    },
  };

  String _getTxt(String key) {
    String langCode = _isEnglish ? 'en' : 'ar';
    return _localizedValues[langCode]![key]!;
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _isAnimated = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final textDirection = _isEnglish ? TextDirection.ltr : TextDirection.rtl;

    return Directionality(
      textDirection: textDirection,
      child: Scaffold(
        backgroundColor: const Color(0xffc2b2cf),
        body: Stack(
          children: [
            // 1. Custom Flower Pattern Background
            Positioned.fill(
              child: Image.asset(
                'assets/flower_pattern.png',
                fit: BoxFit.cover,
              ),
            ),

            // 2. Custom Floating Language Switch Pill
            PositionedDirectional(
              top: 60,
              end: 24, // Keeps top-right alignment regardless of RTL/LTR
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _isEnglish = !_isEnglish;
                  });
                },
                child: Container(
                  width: 90,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xff2d2d2d).withOpacity(0.85),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Stack(
                    children: [
                      // Animated Indicator Slider
                      AnimatedPositionedDirectional(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        start: _isEnglish ? 4 : 46,
                        top: 4,
                        child: Container(
                          width: 40,
                          height: 28,
                          decoration: BoxDecoration(
                            color: const Color(0xffe9eef2),
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                      // Text Labels Overlay
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text(
                              'EN',
                              style: TextStyle(
                                color: _isEnglish ? Colors.black : Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              'ع',
                              style: TextStyle(
                                color: !_isEnglish
                                    ? Colors.black
                                    : Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 3. Winking Robot Logo
            AnimatedPositioned(
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeInOut,
              top: _isAnimated ? screenHeight * 0.12 : screenHeight * 0.32,
              left: 0,
              right: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/robot_logo.png', height: 200, width: 200),
                ],
              ),
            ),

            // 4. Localized Action Menu Buttons
            AnimatedPositioned(
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeInOut,
              bottom: _isAnimated ? screenHeight * 0.32 : -300,
              left: 24,
              right: 24,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 500),
                opacity: _isAnimated ? 1.0 : 0.0,
                child: Column(
                  children: [
                    // "I have an account" (Login) Button
                    OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                LoginScreen(isEnglish: _isEnglish),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(56),
                        side: const BorderSide(
                          color: Color(0xff2d4a43),
                          width: 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: Text(
                        _getTxt('login'),
                        style: const TextStyle(
                          color: Color(0xff2d4a43),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // "Create an account" (Sign Up) Button
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                SignUpScreen(isEnglish: _isEnglish),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xffa68cb5),
                        minimumSize: const Size.fromHeight(56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        _getTxt('signup'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // "Continue as guest" Text Link
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const HomeScreen(isGuest: true),
                          ),
                        );
                      },
                      child: Text(
                        _getTxt('guest'),
                        style: const TextStyle(
                          color: Color(0xff2d4a43),
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
