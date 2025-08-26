import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
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
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    String? currentPasswordError;
    String? newPasswordError;

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
                const Text(
                  'Current Password',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: currentPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    errorText: currentPasswordError,
                    errorStyle: const TextStyle(color: Colors.red),
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
                  obscureText: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    errorText: newPasswordError,
                    errorStyle: const TextStyle(color: Colors.red),
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

                        try {
                          await _resetPassword(currentPassword, newPassword);
                          Navigator.pop(context);
                        } on FirebaseAuthException catch (e) {
                          setDialogState(() {
                            if (e.code == 'weak-password') {
                              newPasswordError = 'New password is too weak';
                            } else if (e.code == 'wrong-password') {
                              currentPasswordError = 'Please make sure the current password is correct.';
                            } else {
                              newPasswordError = 'Failed to reset. Please check your current password.';
                            }
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