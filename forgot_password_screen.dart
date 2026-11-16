import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordScreen extends StatefulWidget {
  final bool isEnglish;

  const ForgotPasswordScreen({super.key, required this.isEnglish});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final emailController = TextEditingController();

  Future<void> sendResetLink() async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      // لا نمرر actionCodeSettings إطلاقاً، عشان فايربيس
      // يستخدم صفحته الجاهزة (الافتراضية) لتغيير كلمة المرور
      // بدون ما يوديك لأي صفحة ثانية بعدها.
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: emailController.text.trim(),
      );

      messenger.showSnackBar(
        SnackBar(
          content: Text(
            widget.isEnglish
                ? "Reset link sent to your email"
                : "تم إرسال رابط إعادة التعيين إلى بريدك",
          ),
        ),
      );

      // الرجوع لصفحة تسجيل الدخول بعد إرسال الرابط
      if (mounted) navigator.pop();
    } on FirebaseAuthException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message ?? "Error")));
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8EA),

      body: SafeArea(
        child: Stack(
          children: [
            // المحتوى الرئيسي
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 125),

                  // العنوان
                  Center(
                    child: Text(
                      widget.isEnglish ? "FORGOT PASSWORD" : "نسيت كلمة المرور",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                        color: Color(0xFF16705F),
                      ),
                    ),
                  ),

                  const SizedBox(height: 70),

                  // Email
                  Text(
                    widget.isEnglish ? "Email" : "البريد الإلكتروني",
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF16705F),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // حقل الإيميل
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: widget.isEnglish ? "" : "البريد الإلكتروني",
                      filled: true,
                      fillColor: const Color(0xFFC9D8F2),

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),

                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),

                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(
                          color: Color(0xFF16705F),
                          width: 2,
                        ),
                      ),

                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 13,
                      ),
                    ),
                  ),

                  const SizedBox(height: 60),

                  // Send Link
                  Center(
                    child: OutlinedButton(
                      onPressed: sendResetLink,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF16705F),
                        side: const BorderSide(
                          color: Color(0xFF16705F),
                          width: 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 8,
                        ),
                      ),
                      child: Text(
                        widget.isEnglish ? "Send Link" : "إرسال الرابط",
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // زر الرجوع أسفل اليسار
            Positioned(
              left: 20,
              bottom: 25,
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFFFF8EA),
                    border: Border.all(color: Colors.black87, width: 1.5),
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    size: 24,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
