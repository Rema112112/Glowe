import 'package:flutter/material.dart';
import 'package:glowe/screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:glowe/screens/login_screen.dart';

class VerificationScreen extends StatefulWidget {
  final bool isEnglish;
  final String correctCode;
  final String email;
  final String name;
  final String password;

  const VerificationScreen({
    super.key,
    required this.isEnglish,
    required this.correctCode,
    required this.email,
    required this.name,
    required this.password,
  });

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  final Map<String, Map<String, String>> _localized = {
    'en': {
      'header': 'Verify Your Email',
      'title': 'ACCOUNT\nVERIFICATION',
      'instruction': 'Please enter the 4 digit code sent to Your Email',
      'resend': 'Resend Code',
      'verify': 'VERIFY',
      'error_title': 'Incorrect verification code.',
      'cancel': 'Cancel',
      'loading': 'Loading...',
      'err_exist': 'You already have an account.',
      'login_btn': 'Log in',
    },
    'ar': {
      'header': 'تأكيد بريدك الإلكتروني',
      'title': 'تأكيد الحساب',
      'instruction': 'الرجاء إدخال الرمز المكون من 4 أرقام المرسل لبريدك',
      'resend': 'إعادة إرسال الرمز',
      'verify': 'تأكيد',
      'error_title': 'رمز التحقق غير صحيح.',
      'cancel': 'إلغاء',
      'loading': 'جاري التحميل...',
      'err_exist': 'لديك حساب بالفعل.',
      'login_btn': 'دخول',
    },
  };

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _showAccountExistsDialog(String lang) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: Colors.black, width: 2.5),
        ),
        backgroundColor: Colors.white,
        contentPadding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(Icons.error, color: Color(0xffbe281a), size: 28),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _localized[lang]!['err_exist']!,
                    style: const TextStyle(
                      color: Color(0xffbe281a),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            LoginScreen(isEnglish: widget.isEnglish),
                      ),
                      (route) => false,
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: Color(0xff2d604e),
                      width: 2.5,
                    ),
                    minimumSize: const Size(100, 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    _localized[lang]!['login_btn']!,
                    style: const TextStyle(
                      color: Color(0xff2d604e),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: Color(0xff2d604e),
                      width: 2.5,
                    ),
                    minimumSize: const Size(100, 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    _localized[lang]!['cancel']!,
                    style: const TextStyle(
                      color: Color(0xff2d604e),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _registerUserInFirebase(String lang) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: Color(0xff1d5341)),
            const SizedBox(height: 12),
            Text(
              _localized[lang]!['loading']!,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: widget.email,
            password: widget.password,
          );

      if (userCredential.user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
              'uid': userCredential.user!.uid,
              'name': widget.name,
              'email': widget.email,
              'createdAt': FieldValue.serverTimestamp(),
            });
      }

      // تحسين: نقوم بالانتقال مباشرة واستبدال كل الشاشات والـ Dialogs المفتوحة لمنع أي تداخل
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const HomeScreen(isGuest: false),
          ),
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) Navigator.pop(context); // إغلاق الـ Loading dialog فقط

      if (e.code == 'email-already-in-use') {
        if (mounted) {
          _showAccountExistsDialog(lang);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Firebase Error: ${e.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showErrorDialog(String lang) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.black, width: 1.5),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, color: Color(0xffe05345), size: 24),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _localized[lang]!['error_title']!,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xffbe2b1a),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: Color(0xff1d5341),
                          width: 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        _localized[lang]!['resend']!,
                        style: const TextStyle(
                          color: Color(0xff1d5341),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: Color(0xff1d5341),
                          width: 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        _localized[lang]!['cancel']!,
                        style: const TextStyle(
                          color: Color(0xff1d5341),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String lang = widget.isEnglish ? 'en' : 'ar';
    return Directionality(
      textDirection: widget.isEnglish ? TextDirection.ltr : TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xffb2c4af),
        body: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 60),
                    Text(
                      _localized[lang]!['header']!,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Color(0xff1d5341),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _localized[lang]!['title']!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: Color(0xff1d5341),
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 80),
                    Text(
                      _localized[lang]!['instruction']!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xff1d5341),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 4 Digit Input Blocks
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(4, (index) {
                        return SizedBox(
                          width: 60,
                          child: TextField(
                            controller: _controllers[index],
                            focusNode: _focusNodes[index],
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            maxLength: 1,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff1d5341),
                            ),
                            decoration: InputDecoration(
                              counterText: "",
                              filled: true,
                              fillColor: const Color(0xfffaf6ee),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                  color: Color(0xff1d5341),
                                  width: 2,
                                ),
                              ),
                            ),
                            onChanged: (value) {
                              if (value.isNotEmpty && index < 3) {
                                _focusNodes[index + 1].requestFocus();
                              } else if (value.isEmpty && index > 0) {
                                _focusNodes[index - 1].requestFocus();
                              }
                            },
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 24),
                    GestureDetector(
                      onTap: () {
                        // هنا يمكن ربط دالة إعادة إرسال الكود إذا جهزتِها مستقبلاً
                      },
                      child: Text(
                        _localized[lang]!['resend']!,
                        style: const TextStyle(
                          color: Color(0xff1d5341),
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    OutlinedButton(
                      onPressed: () {
                        String enteredCode = _controllers
                            .map((e) => e.text)
                            .join();

                        if (enteredCode == widget.correctCode &&
                            enteredCode.isNotEmpty) {
                          _registerUserInFirebase(lang);
                        } else {
                          _showErrorDialog(lang);
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: Color(0xff1d5341),
                          width: 2.5,
                        ),
                        minimumSize: const Size(160, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: Text(
                        _localized[lang]!['verify']!,
                        style: const TextStyle(
                          color: Color(0xff1d5341),
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 20,
                left: widget.isEnglish ? 24 : null,
                right: widget.isEnglish ? null : 24,
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    size: 32,
                    color: Colors.black,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
