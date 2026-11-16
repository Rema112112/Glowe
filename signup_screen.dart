import 'package:flutter/material.dart';
import 'package:glowe/screens/verification_screen.dart';
import 'package:glowe/screens/login_screen.dart';
import 'dart:convert'; 
import 'package:http/http.dart' as http; 
import 'package:firebase_auth/firebase_auth.dart'; // 👈 تأكدي من وجود هذا الاستيراد لفحص فايربيس

class SignUpScreen extends StatefulWidget {
  final bool isEnglish;
  const SignUpScreen({super.key, required this.isEnglish});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true; 
  bool _hasLength = false;
  bool _hasUppercase = false;
  bool _hasNumber = false;
  bool _hasNoSpecial = false;

  final Map<String, Map<String, String>> _localized = {
    'en': {
      'title': 'Sign Up',
      'name': 'Name',
      'email': 'Email',
      'password': 'Password',
      'next': 'Next',
      'footer': 'Already have an account? ',
      'signin': 'Sign in',
      'rule_len': 'Must be at least 8 characters long.',
      'rule_up': 'Must contain at least one uppercase letter (A–Z).',
      'rule_num': 'Must contain at least one number (0–9).',
      'rule_spec': 'Must not contain punctuation marks or special characters.',
      'err_exist': 'You already have an account.',
      'err_empty_name': 'Please enter your name',
      'err_empty_email': 'Please enter your email',
      'err_invalid_email': 'Your email is incorrect',
      'err_password_requirements': 'Your password does not meet the requirements.',
      'login_btn': 'Log in',
      'cancel': 'Cancel',
    },
    'ar': {
      'title': 'إنشاء حساب',
      'name': 'الاسم',
      'email': 'البريد الإلكتروني',
      'password': 'كلمة المرور',
      'next': 'التالي',
      'footer': 'لديك حساب بالفعل؟ ',
      'signin': 'تسجيل الدخول',
      'rule_len': 'يجب أن يكون طولها 8 رموز على الأقل.',
      'rule_up': 'يجب أن تحتوي على حرف كبير واحد على الأقل (A-Z).',
      'rule_num': 'يجب أن تحتوي على رقم واحد على الأقل (0-9).',
      'rule_spec': 'يجب ألا تحتوي على علامات ترقيم أو رموز خاصة.',
      'err_exist': 'لديك حساب بالفعل.',
      'err_empty_name': 'الرجاء إدخال الاسم',
      'err_empty_email': 'الرجاء إدخال البريد الإلكتروني',
      'err_invalid_email': 'البريد الإلكتروني غير صحيح',
      'err_password_requirements': 'كلمة المرور لا تستوفي الشروط المطلوبة.',
      'login_btn': 'دخول',
      'cancel': 'إلغاء',
    },
  };

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_validatePassword);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _validatePassword() {
    final val = _passwordController.text;
    setState(() {
      _hasLength = val.length >= 8;
      _hasUppercase = val.contains(RegExp(r'[A-Z]'));
      _hasNumber = val.contains(RegExp(r'[0-9]'));
      _hasNoSpecial =
          val.isNotEmpty && !val.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    });
  }

  // 🛠️ دالة بناء النوافذ المنبثقة المخصصة حسب التصميم المرسل بالصور
  void _showCustomDialog({
    required BuildContext context,
    required String message,
    bool showTwoButtons = false,
    VoidCallback? onConfirm,
    String? confirmText,
    String? cancelText,
  }) {
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
                const Icon(
                  Icons.error, 
                  color: Color(0xffbe281a), 
                  size: 28,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    message,
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
            if (!showTwoButtons)
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xff2d604e), width: 2.5),
                  minimumSize: const Size(110, 40),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text('Ok', style: TextStyle(color: Color(0xff2d604e), fontWeight: FontWeight.bold, fontSize: 16)),
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton(
                    onPressed: onConfirm,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xff2d604e), width: 2.5),
                      minimumSize: const Size(100, 40),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: Text(confirmText ?? 'Log in', style: const TextStyle(color: Color(0xff2d604e), fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xff2d604e), width: 2.5),
                      minimumSize: const Size(100, 40),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: Text(cancelText ?? 'Cancel', style: const TextStyle(color: Color(0xff2d604e), fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  void _handleSignUpSubmit(String lang) async {
    print("🔘 تم ضغط زر التالي بنجاح!");
    
    final email = _emailController.text.trim();
    
    // 1️⃣ التحقق من صياغة الإيميل أولاً (الصورة الأولى)
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (email.isEmpty || !emailRegex.hasMatch(email)) {
      _showCustomDialog(
        context: context,
        message: _localized[lang]!['err_invalid_email']!,
      );
      return;
    }

    // 2️⃣ التحقق من شروط الباسورد (الصورة الثانية)
    if (!_hasLength || !_hasUppercase || !_hasNumber || !_hasNoSpecial) {
      _showCustomDialog(
        context: context,
        message: _localized[lang]!['err_password_requirements']!,
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      
      // 🌟 جاري إظهار مؤشر التحميل أثناء فحص فايربيس
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator(color: Color(0xff2d604e))),
      );

      try {
        // 🔥 فحص ما إذا كان الإيميل مسجلاً مسبقاً في فايربيس أم لا
        try {
  await FirebaseAuth.instance.createUserWithEmailAndPassword(
    email: email,
    password: 'temp_check_123',
  );
  // لو نجح يعني الإيميل جديد، احذف الحساب المؤقت فوراً
  await FirebaseAuth.instance.currentUser?.delete();
} on FirebaseAuthException catch (e) {
  if (mounted) Navigator.pop(context); // إغلاق مؤشر التحميل
  if (e.code == 'email-already-in-use') {
    _showCustomDialog(
      context: context,
      message: _localized[lang]!['err_exist']!,
      showTwoButtons: true,
      confirmText: _localized[lang]!['login_btn']!,
      cancelText: _localized[lang]!['cancel']!,
      onConfirm: () {
        Navigator.pop(context);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen(isEnglish: widget.isEnglish)),
        );
      },
    );
    return;
  }
}

if (mounted) Navigator.pop(context); // إغلاق مؤشر التحميل

        // 4️⃣ الإيميل جديد تماماً -> يتم توليد الكود وإرساله عبر EmailJS والانتقال طبيعي
        String generatedCode = (1000 + DateTime.now().millisecond % 9000).toString(); 
        print("🔢 الرمز السري المولد: $generatedCode");

        final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'service_id': 'service_i9jbnkd',   
            'template_id': 'template_r3i76r5', 
            'user_id': 'hbphDF0qw4PXaKkml',      
            'accessToken': 'Q4ifx32qHEsJZmaaSOB9T', 
            'template_params': {
              'user_name': _nameController.text.trim(),
              'user_email': email,
              'reply_to': email,
              'auth_code': generatedCode,
            }
          }),
        );

        if (response.statusCode == 200) {
          if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VerificationScreen(
                  isEnglish: widget.isEnglish,
                  correctCode: generatedCode,
                  email: _emailController.text.trim(),
                  name: _nameController.text.trim(),
                  password: _passwordController.text.trim(),
                ),
              ),
            );
          }
        } else {
          print("❌ فشل EmailJS: ${response.body}");
        }
      } catch (e) {
        if (mounted) Navigator.pop(context); // إغلاق مؤشر التحميل في حال حدوث خطأ شبكة
        print("💥 خطأ أثناء عملية الفحص والإرسال: $e");
      }
    }
  }

  Widget _buildRuleRow(bool isMet, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle,
            size: 16,
            color: isMet ? const Color(0xff4caf50) : const Color(0xff8e8e8e),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isMet ? const Color(0xff4caf50) : const Color(0xffbe281a),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String lang = widget.isEnglish ? 'en' : 'ar';

    return Directionality(
      textDirection: widget.isEnglish ? TextDirection.ltr : TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xffdbe5f9), 
        body: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Form(
                  key: _formKey, 
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 60),
                      Text(
                        _localized[lang]!['title']!,
                        style: const TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.w900,
                          color: Color(0xff2d604e),
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Name Field
                      Text(
                        _localized[lang]!['name']!,
                        style: const TextStyle(
                          color: Color(0xff2d604e),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _nameController,
                        keyboardType: TextInputType.name,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xffcbbece),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                          errorStyle: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return _localized[lang]!['err_empty_name']!;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Email Field
                      Text(
                        _localized[lang]!['email']!,
                        style: const TextStyle(
                          color: Color(0xff2d604e),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xffcbbece),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                          errorStyle: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return _localized[lang]!['err_empty_email']!;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Password Field
                      Text(
                        _localized[lang]!['password']!,
                        style: const TextStyle(
                          color: Color(0xff2d604e),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xffcbbece),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                          suffixIcon: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0),
                            child: IconButton(
                              icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: const Color(0xff2d604e)),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                          errorStyle: const TextStyle(height: 0), 
                        ),
                      ),
                      const SizedBox(height: 12),

                      _buildRuleRow(_hasLength, _localized[lang]!['rule_len']!),
                      _buildRuleRow(_hasUppercase, _localized[lang]!['rule_up']!),
                      _buildRuleRow(_hasNumber, _localized[lang]!['rule_num']!),
                      _buildRuleRow(_hasNoSpecial, _localized[lang]!['rule_spec']!),

                      const SizedBox(height: 40),
                      Center(
                        child: OutlinedButton(
                          onPressed: () => _handleSignUpSubmit(lang),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xff1d5341), width: 2.5),
                            minimumSize: const Size(160, 46),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(23)),
                          ),
                          child: Text(
                            _localized[lang]!['next']!,
                            style: const TextStyle(color: Color(0xff1d5341), fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(_localized[lang]!['footer']!, style: const TextStyle(color: Color(0xff1d5341), fontWeight: FontWeight.bold)),
                            GestureDetector(
                              onTap: () => Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => LoginScreen(isEnglish: widget.isEnglish)),
                              ),
                              child: Text(
                                _localized[lang]!['signin']!,
                                style: const TextStyle(color: Color(0xff1d5341), fontWeight: FontWeight.w900, decoration: TextDecoration.underline),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 20,
                left: widget.isEnglish ? 24 : null,
                right: widget.isEnglish ? null : 24,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, size: 32, color: Colors.black),
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