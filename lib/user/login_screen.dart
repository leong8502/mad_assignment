import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mad_assignment/user/preferences_helper.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _emailError;
  String? _passwordError;
  String? _generalError;
  bool _obscurePassword = true;
  bool _isLoading = false;

  Future<void> _login() async {
    setState(() {
      _emailError = null;
      _passwordError = null;
      _generalError = null;
      _isLoading = true;
    });

    if (_emailController.text.trim().isEmpty) {
      setState(() {
        _emailError = 'Email cannot be empty';
        _isLoading = false;
      });
      return;
    }
    if (_passwordController.text.trim().isEmpty) {
      setState(() {
        _passwordError = 'Password cannot be empty';
        _isLoading = false;
      });
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Logging in...'),
          ],
        ),
      ),
    );

    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      Navigator.pop(context); // Close loading dialog

      if (!userCredential.user!.emailVerified) {
        setState(() {
          _generalError = 'Please verify your email before logging in.';
          _isLoading = false;
        });
        await FirebaseAuth.instance.signOut();
        return;
      }

      await PreferencesHelper.setLoginStatus(true); // Save login status
      setState(() {
        _isLoading = false;
      });
      Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context); // Close loading dialog

      setState(() {
        _isLoading = false;
        switch (e.code) {
          case 'invalid-email':
            _emailError = 'The email address is badly formatted.';
            break;
          case 'invalid-credential':
            _generalError = 'Incorrect email or password.';
            break;
          default:
            _generalError = e.message ?? 'An error occurred during login';
        }
      });
    }
  }

  Future<void> _resetPassword() async {
    final TextEditingController resetEmailController = TextEditingController();
    String? dialogErrorMessage;

    final bool? sent = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Reset Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Enter the email address to receive a password reset link.'),
              const SizedBox(height: 10),
              TextField(
                controller: resetEmailController,
                decoration: InputDecoration(
                  hintText: 'Enter your email...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  errorText: dialogErrorMessage,
                ),
                keyboardType: TextInputType.emailAddress,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (resetEmailController.text.trim().isEmpty) {
                  setDialogState(() {
                    dialogErrorMessage = 'Email cannot be empty.';
                  });
                  return;
                }
                try {
                  await FirebaseAuth.instance.sendPasswordResetEmail(
                    email: resetEmailController.text.trim(),
                  );
                  Navigator.pop(context, true);
                } on FirebaseAuthException catch (e) {
                  setDialogState(() {
                    if (e.code == 'invalid-email') {
                      dialogErrorMessage = 'Please enter a valid email.';
                    } else {
                      dialogErrorMessage = e.message ?? 'An error occurred while sending reset email';
                    }
                  });
                }
              },
              child: const Text('Send'),
            ),
          ],
        ),
      ),
    );

    if (sent == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset email sent.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16.0, 40.0, 16.0, 16.0),
          child: Stack(
            children: [
              Positioned(
                top: -10,
                left: 0,
                child: Image.asset('assets/images/logo.png', height: 80),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 100.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Sign In',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Email', style: TextStyle(fontSize: 16)),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              hintText: 'Enter your email...',
                              prefixIcon: const Icon(Icons.email, color: Colors.grey),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              errorText: _emailError,
                            ),
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 15),
                          const Text('Password', style: TextStyle(fontSize: 16)),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              hintText: 'Enter your password...',
                              prefixIcon: const Icon(Icons.lock, color: Colors.grey),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              errorText: _passwordError,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                          ),
                          if (_generalError != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Text(
                                _generalError!,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                          const SizedBox(height: 20),
                          Center(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                foregroundColor: Colors.white,
                                minimumSize: const Size(200, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: _login,
                              child: const Text('Sign In'),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton(
                                onPressed: _resetPassword,
                                child: const Text(
                                  'Forgot password?',
                                  style: TextStyle(color: Colors.blue),
                                ),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pushNamed(context, '/register'),
                                child: const Text(
                                  'Register?',
                                  style: TextStyle(color: Colors.blue),
                                ),
                              ),
                            ],
                          ),
                          if (_generalError != null && _generalError!.contains('verify'))
                            TextButton(
                              onPressed: () async {
                                final user = FirebaseAuth.instance.currentUser;
                                if (user != null && !user.emailVerified) {
                                  await user.sendEmailVerification();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Verification email resent.')),
                                  );
                                }
                              },
                              child: const Text(
                                'Resend Verification Email',
                                style: TextStyle(color: Colors.blue),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}