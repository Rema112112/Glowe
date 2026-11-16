import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _isSaving = false;

  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();

  // Validating text indicators.
  // NOTE: every check requires the field to be non-empty first — otherwise
  // an empty string trivially "contains no uppercase / no number / no
  // punctuation" and would show as valid (green) before the user types
  // anything.
  bool get _isNotEmpty => _newPasswordController.text.isNotEmpty;

  bool get hasEightChars => _newPasswordController.text.length >= 8;
  bool get hasUppercase =>
      _isNotEmpty && _newPasswordController.text.contains(RegExp(r'[A-Z]'));
  bool get hasNumber =>
      _isNotEmpty && _newPasswordController.text.contains(RegExp(r'[0-9]'));
  bool get hasNoPunctuation =>
      _isNotEmpty &&
      !_newPasswordController.text.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'));

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _processPasswordSave() async {
    final currentPassword = _currentPasswordController.text;
    final newPassword = _newPasswordController.text;

    if (currentPassword.isEmpty) {
      _showResponseDialog(
        isSuccess: false,
        message: "Please enter your current password.",
      );
      return;
    }

    if (!(hasEightChars && hasUppercase && hasNumber && hasNoPunctuation)) {
      _showResponseDialog(
        isSuccess: false,
        message: "Your password does not meet the requirements.",
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) {
      _showResponseDialog(
        isSuccess: false,
        message: "You need to be logged in to change your password.",
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Step 1: Re-authenticate with the CURRENT password. Firebase requires
      // a recent login before allowing a sensitive change like this, and
      // this also confirms the current password is actually correct.
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // Step 2: Update the password in Firebase Auth. This is what actually
      // controls sign-in going forward — from now on the user must use the
      // NEW password to log in.
      await user.updatePassword(newPassword);

      if (!mounted) return;
      setState(() => _isSaving = false);

      _showResponseDialog(
        isSuccess: true,
        message: "Password changed successfully.",
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);

      String message;
      switch (e.code) {
        case 'wrong-password':
        case 'invalid-credential':
          message = "Your current password is incorrect.";
          break;
        case 'weak-password':
          message = "The new password is too weak.";
          break;
        case 'requires-recent-login':
          message = "Please log out and log back in, then try again.";
          break;
        default:
          message = e.message ?? "Failed to change password. Please try again.";
      }
      _showResponseDialog(isSuccess: false, message: message);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      _showResponseDialog(
        isSuccess: false,
        message: "Failed to change password. Please try again.",
      );
    }
  }

  void _showResponseDialog({required bool isSuccess, required String message}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: Colors.black, width: 2),
        ),
        backgroundColor: Colors.white,
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isSuccess)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, color: Color(0xfff44336), size: 28),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                )
              else
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  if (isSuccess) {
                    Navigator.pop(context); // Return to Manage Account screen
                  }
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xff1b5e20), width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 8,
                  ),
                ),
                child: const Text(
                  'Ok',
                  style: TextStyle(
                    color: Color(0xff1b5e20),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xffdbe6ff,
      ), // Light blue tone background reference
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Change Password',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        titleSpacing: 0,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFieldLabel('Current Password'),
                _buildInputField(
                  hint: '',
                  controller: _currentPasswordController,
                  obscure: _obscureCurrent,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureCurrent
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () =>
                        setState(() => _obscureCurrent = !_obscureCurrent),
                  ),
                ),

                const SizedBox(height: 16),
                _buildFieldLabel('New Password'),
                _buildInputField(
                  hint: '',
                  controller: _newPasswordController,
                  obscure: _obscureNew,
                  onChanged: (val) => setState(() {}),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureNew
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () => setState(() => _obscureNew = !_obscureNew),
                  ),
                ),

                const SizedBox(height: 20),

                // Validation Rules Checkbox Lists
                _buildValidationRow(
                  'Must be at least 8 characters long.',
                  hasEightChars,
                ),
                _buildValidationRow(
                  'Must contain at least one uppercase letter (A–Z).',
                  hasUppercase,
                ),
                _buildValidationRow(
                  'Must contain at least one number (0–9).',
                  hasNumber,
                ),
                _buildValidationRow(
                  'Must not contain punctuation marks or special characters.',
                  hasNoPunctuation,
                ),

                const Spacer(),

                Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.7,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _processPasswordSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xffdedede),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: 0,
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.black54,
                              ),
                            )
                          : const Text(
                              'Save',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          if (_isSaving) Container(color: Colors.black12),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 4.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String hint,
    TextEditingController? controller,
    required bool obscure,
    Widget? suffixIcon,
    Function(String)? onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        onChanged: onChanged,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        decoration: InputDecoration(
          hintText: hint,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: InputBorder.none,
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }

  Widget _buildValidationRow(String ruleText, bool isValid) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Icon(
            isValid ? Icons.check_circle : Icons.check_circle_outline,
            color: isValid ? Colors.green : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              ruleText,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isValid
                    ? Colors.red[900]
                    : Colors.red[900]?.withOpacity(0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
