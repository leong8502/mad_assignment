import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class ResetEmailScreen extends StatefulWidget {
  const ResetEmailScreen({super.key});

  @override
  State<ResetEmailScreen> createState() => _ResetEmailScreenState();
}

class _ResetEmailScreenState extends State<ResetEmailScreen> {
  final _currentPasswordController = TextEditingController();
  final _newEmailController = TextEditingController();
  String? _currentPasswordError;
  String? _newEmailError;
  bool _isLoading = false;
  bool _obscureCurrentPassword = true;
  StreamSubscription<User?>? _userChangesSubscription;

  @override
  void initState() {
    super.initState();
    // Set up listener for user changes to detect email updates
    _userChangesSubscription = FirebaseAuth.instance.userChanges().listen((user) async {
      if (user != null && mounted) {
        // Check if the email has changed and matches the pending email
        if (_newEmailController.text.trim() == user.email) {
          try {
            // Update Firestore with the new email
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .update({'email': user.email});
            // Show success dialog
            if (mounted) {
              await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Success'),
                  content: const Text('Your email has been updated successfully.'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context); // Close dialog
                        Navigator.pop(context); // Return to previous screen
                      },
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            }
            // Cancel the subscription after successful update
            await _userChangesSubscription?.cancel();
          } on FirebaseException catch (e) {
            if (mounted) {
              setState(() {
                _newEmailError = 'Failed to update email in database: ${e.message}';
              });
            }
          }
        }
      }
    });
  }

  Future<void> _sendVerificationEmail(String currentPassword, String newEmail) async {
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
      await user.verifyBeforeUpdateEmail(newEmail);

      if (mounted) {
        Navigator.pop(context); // Close the loading dialog
      }
      setState(() {
        _isLoading = false;
      });

      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Success'),
          content: const Text('A verification email has been sent to your new email address. Please verify to complete the email change.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close the loading dialog
      }
      String errorMessage;
      switch (e.code) {
        case 'invalid-email':
          errorMessage = 'The new email address is not valid.';
          break;
        case 'email-already-in-use':
          errorMessage = 'This email is already in use.';
          break;
        case 'wrong-password':
          errorMessage = 'Please make sure the current password is correct.';
          break;
        default:
          errorMessage = 'An error occurred. Please check your password.';
      }
      setState(() {
        _isLoading = false;
        if (e.code == 'wrong-password') {
          _currentPasswordError = errorMessage;
        } else {
          _newEmailError = errorMessage;
        }
      });
    }
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newEmailController.dispose();
    _userChangesSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Email'),
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
                      const Icon(size: 60, Icons.email),
                      const SizedBox(height: 12),
                      const Text(
                        'Change your email',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Enter your current password and new email to change your email.',
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
                  controller: _currentPasswordController,
                  obscureText: _obscureCurrentPassword,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    prefixIcon: const Icon(
                      Icons.lock,
                      color: Colors.grey,
                    ),
                    hintText: 'Enter your current password',
                    hintStyle: const TextStyle(color: Colors.grey),
                    errorText: _currentPasswordError,
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
                  'New Email',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _newEmailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    prefixIcon: const Icon(
                      Icons.email,
                      color: Colors.grey,
                    ),
                    hintText: 'Enter your new email',
                    hintStyle: const TextStyle(color: Colors.grey),
                    errorText: _newEmailError,
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
                      onPressed: _isLoading
                          ? null
                          : () async {
                        setDialogState(() {
                          _currentPasswordError = null;
                          _newEmailError = null;
                        });

                        final currentPassword = _currentPasswordController.text.trim();
                        final newEmail = _newEmailController.text.trim();

                        if (currentPassword.isEmpty) {
                          setDialogState(() {
                            _currentPasswordError = 'Current password cannot be empty';
                          });
                          return;
                        }
                        if (newEmail.isEmpty) {
                          setDialogState(() {
                            _newEmailError = 'New email cannot be empty';
                          });
                          return;
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(newEmail)) {
                          setDialogState(() {
                            _newEmailError = 'Please enter a valid email';
                          });
                          return;
                        }
                        if (newEmail == FirebaseAuth.instance.currentUser?.email) {
                          setDialogState(() {
                            _newEmailError = 'New email cannot be the same as current email';
                          });
                          return;
                        }

                        final bool? confirmed = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Confirm Email Change'),
                            content: const Text('Are you sure you want to change your email?'),
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
                          _isLoading = true;
                        });

                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => const AlertDialog(
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(height: 16),
                                Text('Sending Verification Email...'),
                              ],
                            ),
                          ),
                        );

                        await _sendVerificationEmail(currentPassword, newEmail);
                      },
                      child: const Text('Change'),
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