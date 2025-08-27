import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  String? currentPasswordError;
  String? newPasswordError;
  bool _isLoading = false; // State variable for loading animation
  bool _obscureCurrentPassword = true; // State variable for current password visibility
  bool _obscureNewPassword = true; // State variable for new password visibility

  Future<void> _resetPassword(String currentPassword, String newPassword) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw FirebaseAuthException(
          code: 'no-user',
          message: 'No user signed in',
        );
      }

      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);

      // Close loading dialog
      if (mounted) {
        Navigator.pop(context); // Close the loading dialog
      }

      setState(() {
        _isLoading = false; // Hide loading animation
      });

      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Success'),
          content: const Text('Password has been successfully reset.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } on FirebaseAuthException catch (e) {
      // Close loading dialog
      if (mounted) {
        Navigator.pop(context); // Close the loading dialog
      }

      String errorMessage = 'Failed reset, please confirm current password is correct.';
      if (e.code == 'weak-password') {
        errorMessage = 'New password is too weak';
      }
      throw FirebaseAuthException(
        code: e.code,
        message: errorMessage,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: StatefulBuilder(
            builder: (context, setDialogState) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      const Icon(size: 60, Icons.lock),
                      const SizedBox(height: 12),
                      const Text(
                        'Reset your password',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Enter your current password and new password to reset your password.',
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 36),
                    ],
                  ),
                ),
                const Text(
                  'Current Password',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: currentPasswordController,
                  obscureText: _obscureCurrentPassword,
                  decoration: InputDecoration(
                    hintText: 'Enter your current password...', // Added placeholder
                    prefixIcon: const Icon(Icons.lock, color: Colors.grey), // Added prefix icon
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    errorText: currentPasswordError,
                    errorStyle: const TextStyle(color: Colors.red),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureCurrentPassword ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureCurrentPassword = !_obscureCurrentPassword;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'New Password',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: newPasswordController,
                  obscureText: _obscureNewPassword,
                  decoration: InputDecoration(
                    hintText: 'Enter your new password...', // Added placeholder
                    prefixIcon: const Icon(Icons.lock, color: Colors.grey), // Added prefix icon
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    errorText: newPasswordError,
                    errorStyle: const TextStyle(color: Colors.red),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureNewPassword ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureNewPassword = !_obscureNewPassword;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(80, 40),
                      ),
                      onPressed: () async {
                        setDialogState(() {
                          currentPasswordError = null;
                          newPasswordError = null;
                        });

                        final currentPassword = currentPasswordController.text.trim();
                        final newPassword = newPasswordController.text.trim();

                        if (currentPassword.isEmpty) {
                          setDialogState(() {
                            currentPasswordError = 'Current password cannot be empty';
                          });
                          return;
                        }
                        if (newPassword.isEmpty) {
                          setDialogState(() {
                            newPasswordError = 'New password cannot be empty';
                          });
                          return;
                        }
                        if (currentPassword == newPassword) {
                          setDialogState(() {
                            newPasswordError = 'New password cannot same as current password';
                          });
                          return;
                        }

                        final bool? confirmed = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Confirm Password Reset'),
                            content: const Text('Are you sure you want to reset your password?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Confirm'),
                              ),
                            ],
                          ),
                        );

                        if (confirmed != true) {
                          return;
                        }

                        setDialogState(() {
                          _isLoading = true; // Show loading animation
                        });

                        // Show loading dialog
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => const AlertDialog(
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(height: 16),
                                Text('Resetting Password...'),
                              ],
                            ),
                          ),
                        );

                        try {
                          await _resetPassword(currentPassword, newPassword);
                          Navigator.pop(context); // Close the main screen
                        } on FirebaseAuthException catch (e) {
                          setDialogState(() {
                            if (e.code == 'weak-password') {
                              newPasswordError = 'New password is too weak';
                            } else if (e.code == 'wrong-password') {
                              currentPasswordError = 'Please make sure the current password is correct.';
                            } else {
                              newPasswordError = 'Failed to reset. Please check your current password.';
                            }
                            _isLoading = false; // Hide loading animation
                          });
                        }
                      },
                      child: const Text('Reset'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}