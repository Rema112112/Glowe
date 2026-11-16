import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/user_provider.dart';
import 'change_password_screen.dart';

class ManageAccountScreen extends ConsumerStatefulWidget {
  const ManageAccountScreen({super.key});

  @override
  ConsumerState<ManageAccountScreen> createState() =>
      _ManageAccountScreenState();
}

class _ManageAccountScreenState extends ConsumerState<ManageAccountScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();

  bool _isEditingName = false;
  bool _isEditingEmail = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  Future<void> _toggleEditName() async {
    if (_isEditingName) {
      final newName = _nameController.text.trim();
      if (newName.isEmpty) {
        _showSnackBar("Name cannot be empty", isError: true);
        return;
      }

      await ref.read(userProfileNotifierProvider.notifier).updateName(newName);
      final profileState = ref.read(userProfileNotifierProvider);

      if (profileState.hasError) {
        _showSnackBar(
          "Failed to update name: ${profileState.error}",
          isError: true,
        );
      } else {
        _showSnackBar("Name updated successfully!");
      }

      _nameFocusNode.unfocus();
      setState(() => _isEditingName = false);
    } else {
      setState(() => _isEditingName = true);
      _nameFocusNode.requestFocus();
    }
  }

  Future<void> _toggleEditEmail() async {
    if (_isEditingEmail) {
      final newEmail = _emailController.text.trim();
      if (newEmail.isEmpty || !newEmail.contains('@')) {
        _showSnackBar("Please enter a valid email address", isError: true);
        return;
      }

      await ref
          .read(userProfileNotifierProvider.notifier)
          .updateEmail(newEmail);
      final profileState = ref.read(userProfileNotifierProvider);

      if (profileState.hasError) {
        _showSnackBar(
          "Failed to update email: ${profileState.error}",
          isError: true,
        );
      } else {
        _showSnackBar("Verification link sent to new email!");
      }

      _emailFocusNode.unfocus();
      setState(() => _isEditingEmail = false);
    } else {
      setState(() => _isEditingEmail = true);
      _emailFocusNode.requestFocus();
    }
  }

  Future<void> _deleteAccount() async {
    Navigator.pop(context); // Close confirmation dialog

    await ref.read(userProfileNotifierProvider.notifier).deleteAccount();
    final profileState = ref.read(userProfileNotifierProvider);

    if (profileState.hasError) {
      _showSnackBar(
        "Failed to delete account: ${profileState.error}",
        isError: true,
      );
    } else {
      if (mounted) {
        _showSnackBar("Account deleted successfully.");
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: Colors.black, width: 2),
        ),
        backgroundColor: Colors.white,
        content: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Row(
                children: [
                  Icon(Icons.error, color: Color(0xfff44336), size: 28),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Are you sure you want to permanently delete your account?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xffb71c1c),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton(
                    onPressed: _deleteAccount,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                    child: const Text(
                      'Confirm',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.black54, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.black54,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
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
    // Watch real-time user data from Firestore
    final userDocAsync = ref.watch(userDocProvider);
    final profileState = ref.watch(userProfileNotifierProvider);
    final isLoading = profileState.isLoading;

    // Synchronize text fields when Firestore user data updates
    ref.listen(userDocProvider, (previous, next) {
      next.whenData((userModel) {
        if (userModel != null) {
          if (!_isEditingName) _nameController.text = userModel.name;
          if (!_isEditingEmail) _emailController.text = userModel.email;
        }
      });
    });

    return Scaffold(
      backgroundColor: const Color(0xffcfc0d7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Manage Account',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        titleSpacing: 0,
      ),
      body: SafeArea(
        child: userDocAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) =>
              Center(child: Text('Error loading user details: $err')),
          data: (userModel) {
            // Seed initial text controller values if empty
            if (_nameController.text.isEmpty && userModel != null) {
              _nameController.text = userModel.name;
            }
            if (_emailController.text.isEmpty && userModel != null) {
              _emailController.text = userModel.email;
            }

            return Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Name'),
                      _buildEditableField(
                        controller: _nameController,
                        focusNode: _nameFocusNode,
                        isEditing: _isEditingName,
                        isLoading: isLoading,
                        hintText: 'Enter your name',
                        onToggleEdit: _toggleEditName,
                      ),

                      const SizedBox(height: 16),

                      _buildLabel('Email'),
                      _buildEditableField(
                        controller: _emailController,
                        focusNode: _emailFocusNode,
                        isEditing: _isEditingEmail,
                        isLoading: isLoading,
                        hintText: 'Enter your email address',
                        keyboardType: TextInputType.emailAddress,
                        onToggleEdit: _toggleEditEmail,
                      ),

                      const SizedBox(height: 16),

                      _buildLabel('Password'),
                      _buildClickableBox(
                        text: 'Change Password',
                        isLoading: isLoading,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ChangePasswordScreen(),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 16),

                      _buildLabel('Account'),
                      _buildClickableBox(
                        text: 'Delete Account',
                        isLoading: isLoading,
                        onTap: _showDeleteConfirmation,
                      ),
                    ],
                  ),
                ),
                if (isLoading)
                  Container(
                    color: Colors.black26,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 6.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildEditableField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required bool isEditing,
    required bool isLoading,
    required String hintText,
    required VoidCallback onToggleEdit,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              enabled: isEditing && !isLoading,
              keyboardType: keyboardType,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: const TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.normal,
                ),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          TextButton(
            onPressed: isLoading ? null : onToggleEdit,
            child: Text(
              isEditing ? 'Save' : 'Edit',
              style: const TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClickableBox({
    required String text,
    required bool isLoading,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: isLoading ? null : onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
