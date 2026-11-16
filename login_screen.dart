import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:glowe/screens/home_screen.dart';
import 'package:glowe/screens/signup_screen.dart';
import 'package:glowe/screens/forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  final bool isEnglish;

  const LoginScreen({super.key, required this.isEnglish});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;

  final Map<String, Map<String, String>> _localized = {
    'en': {
      'title': 'LOG IN',
      'email': 'Email',
      'password': 'Password',
      'btn': 'Login',
      'forgot': 'Forgot Password?',

      'err_pass': 'The password is incorrect.',
      'err_no_acc': 'No account was found.',

      'err_empty_email': 'Please enter your email',
      'err_invalid_email': 'Please enter a valid email address',
      'err_empty_pass': 'Please enter your password',

      'ok': 'Ok',
      'signup': 'Sign up',
      'cancel': 'Cancel',
    },

    'ar': {
      'title': 'تسجيل الدخول',
      'email': 'البريد الإلكتروني',
      'password': 'كلمة المرور',
      'btn': 'دخول',
      'forgot': 'هل نسيت كلمة المرور؟',

      'err_pass': 'كلمة المرور غير صحيحة.',
      'err_no_acc': 'لم يتم العثور على حساب.',

      'err_empty_email': 'الرجاء إدخال البريد الإلكتروني',
      'err_invalid_email': 'الرجاء إدخال بريد إلكتروني صحيح',
      'err_empty_pass': 'الرجاء إدخال كلمة المرور',

      'ok': 'موافق',
      'signup': 'إنشاء حساب',
      'cancel': 'إلغاء',
    },
  };

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  void _showAlertDialog(
    String message,
    String confirmTxt,
    VoidCallback onConfirm, {
    String? cancelTxt,
    VoidCallback? onCancel,
  }) {
    String lang = widget.isEnglish ? 'en' : 'ar';

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
                children: [
                  const Icon(Icons.error, color: Color(0xffe05345), size: 24),

                  const SizedBox(width: 8),

                  Expanded(
                    child: Text(
                      message,

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
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  OutlinedButton(onPressed: onConfirm, child: Text(confirmTxt)),

                  if (cancelTxt != null) ...[
                    const SizedBox(width: 12),

                    OutlinedButton(
                      onPressed: onCancel ?? () => Navigator.pop(context),

                      child: Text(cancelTxt),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitLogin(String lang) async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();

    final password = _passwordController.text.trim();

    showDialog(
      context: context,

      barrierDismissible: false,

      builder: (_) => const Center(
        child: CircularProgressIndicator(color: Color(0xff1d5341)),
      ),
    );

    try {
      final signInMethods = await FirebaseAuth.instance
          .fetchSignInMethodsForEmail(email);

      if (signInMethods.isEmpty) {
        if (!mounted) return;

        Navigator.pop(context);

        _showAlertDialog(
          _localized[lang]!['err_no_acc']!,

          _localized[lang]!['signup']!,

          () {
            Navigator.pop(context);

            Navigator.pushReplacement(
              context,

              MaterialPageRoute(
                builder: (_) => SignUpScreen(isEnglish: widget.isEnglish),
              ),
            );
          },

          cancelTxt: _localized[lang]!['cancel']!,

          onCancel: () => Navigator.pop(context),
        );

        return;
      }

      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      if (!mounted) return;

      Navigator.pop(context);

      if (userCredential.user != null) {
        Navigator.pushAndRemoveUntil(
          context,

          MaterialPageRoute(builder: (_) => const HomeScreen(isGuest: false)),

          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      Navigator.pop(context);

      _showAlertDialog(
        e.message ?? "Error",

        _localized[lang]!['ok']!,

        () => Navigator.pop(context),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String lang = widget.isEnglish ? 'en' : 'ar';

    return Directionality(
      textDirection: widget.isEnglish ? TextDirection.ltr : TextDirection.rtl,

      child: Scaffold(
        backgroundColor: const Color(0xffe2ebfc),

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
                      const SizedBox(height: 100),

                      Text(
                        _localized[lang]!['title']!,

                        style: const TextStyle(
                          fontSize: 42,

                          fontWeight: FontWeight.w900,

                          color: Color(0xff2d604e),
                        ),
                      ),

                      const SizedBox(height: 40),

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

                          fillColor: const Color(0xffcdd7eb),

                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),

                            borderSide: BorderSide.none,
                          ),
                        ),

                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return _localized[lang]!['err_empty_email'];
                          }

                          if (!value.contains('@') || !value.contains('.')) {
                            return _localized[lang]!['err_invalid_email'];
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 24),

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

                          fillColor: const Color(0xffcdd7eb),

                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),

                            borderSide: BorderSide.none,
                          ),

                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,

                              color: const Color(0xff2d604e),
                            ),

                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),

                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return _localized[lang]!['err_empty_pass'];
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 40),

                      Center(
                        child: OutlinedButton(
                          onPressed: () => _submitLogin(lang),

                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: Color(0xff1d5341),

                              width: 2.5,
                            ),

                            minimumSize: const Size(140, 44),

                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22),
                            ),
                          ),

                          child: Text(
                            _localized[lang]!['btn']!,

                            style: const TextStyle(
                              color: Color(0xff1d5341),

                              fontSize: 16,

                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      Center(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,

                              MaterialPageRoute(
                                builder: (context) => ForgotPasswordScreen(
                                  isEnglish: widget.isEnglish,
                                ),
                              ),
                            );
                          },

                          child: Text(
                            _localized[lang]!['forgot']!,

                            style: const TextStyle(
                              color: Color(0xff1d5341),

                              fontWeight: FontWeight.bold,

                              fontSize: 15,
                            ),
                          ),
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
