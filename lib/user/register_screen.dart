import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  String? _selectedJobType = 'Select Job Type';
  String? _usernameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;
  String? _jobTypeError;
  String? _generalError;
  bool _obscurePassword = true; // State variable for password visibility
  bool _obscureConfirmPassword = true; // State variable for confirm password visibility
  bool _isLoading = false; // State variable for loading animation

  bool _isValidEmail(String email) {
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return regex.hasMatch(email);
  }

  Future<String> _generateWorkId() async {
    final usersCollection = FirebaseFirestore.instance.collection('users');
    final querySnapshot = await usersCollection
        .orderBy('workId', descending: true)
        .limit(1)
        .get();

    String newWorkId = 'WM001'; // Default first work ID
    if (querySnapshot.docs.isNotEmpty) {
      final lastWorkId = querySnapshot.docs.first['workId'] as String?;
      if (lastWorkId != null && lastWorkId.startsWith('WM')) {
        final number = int.tryParse(lastWorkId.substring(2)) ?? 0;
        newWorkId = 'WM${(number + 1).toString().padLeft(3, '0')}';
      }
    }
    return newWorkId;
  }

  Future<void> _register() async {
    setState(() {
      _usernameError = null;
      _emailError = null;
      _passwordError = null;
      _confirmPasswordError = null;
      _jobTypeError = null;
      _generalError = null;
      _isLoading = true; // Show loading animation
    });

    // Validate inputs
    if (_usernameController.text.trim().isEmpty) {
      setState(() {
        _usernameError = 'Username cannot be empty';
      });
      return;
    }
    if (_emailController.text.trim().isEmpty) {
      setState(() {
        _emailError = 'Email cannot be empty';
      });
      return;
    }
    if (!_isValidEmail(_emailController.text.trim())) {
      setState(() {
        _emailError = 'Invalid email format';
      });
      return;
    }
    if (_passwordController.text.trim().isEmpty) {
      setState(() {
        _passwordError = 'Password cannot be empty';
      });
      return;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _confirmPasswordError = 'Passwords do not match';
      });
      return;
    }
    if (_selectedJobType == 'Select Job Type') {
      setState(() {
        _jobTypeError = 'Please select a job type';
      });
      return;
    }

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
            Text('Registering...'),
          ],
        ),
      ),
    );

    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final workId = await _generateWorkId();

      await userCredential.user?.sendEmailVerification();

      await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
        'username': _usernameController.text.trim(),
        'email': _emailController.text.trim(),
        'jobType': _selectedJobType,
        'workId': workId,
        'createdAt': FieldValue.serverTimestamp(),
      });

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
          title: const Text('Registration Successful'),
          content: const Text('Verification email sent. Please check your inbox.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );

      Navigator.pushReplacementNamed(context, '/login');
    } on FirebaseAuthException catch (e) {
      // Close loading dialog
      if (mounted) {
        Navigator.pop(context); // Close the loading dialog
      }

      setState(() {
        _isLoading = false; // Hide loading animation
        switch (e.code) {
          case 'invalid-email':
            _emailError = 'The email address is badly formatted.';
            break;
          case 'email-already-in-use':
            _emailError = 'The email address is already in use.';
            break;
          case 'weak-password':
            _passwordError = 'The password is too weak.';
            break;
          default:
            _generalError = e.message ?? 'An error occurred during registration';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 48.0,
        title: Transform.translate(
          offset: const Offset(-12.0, 4.0),
          child: Image.asset('assets/images/logo.png', height: 60),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 40.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Sign Up',
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
                    const Text('Full name', style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        hintText: 'Enter your Full name...', // Already present as placeholder
                        prefixIcon: const Icon(Icons.person, color: Colors.grey), // Added prefix icon
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        errorText: _usernameError,
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text('Email', style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        hintText: 'Enter your email...', // Already present as placeholder
                        prefixIcon: const Icon(Icons.email, color: Colors.grey), // Added prefix icon
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                        hintText: 'Enter your password...', // Already present as placeholder
                        prefixIcon: const Icon(Icons.lock, color: Colors.grey), // Added prefix icon
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                    const SizedBox(height: 15),
                    const Text('Confirm Password', style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      decoration: InputDecoration(
                        hintText: 'Enter your password again...', // Already present as placeholder
                        prefixIcon: const Icon(Icons.lock, color: Colors.grey), // Added prefix icon
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        errorText: _confirmPasswordError,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword = !_obscureConfirmPassword;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text('Job Type', style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: _selectedJobType,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        errorText: _jobTypeError,
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Select Job Type', child: Text('Select Job Type')),
                        DropdownMenuItem(value: 'Workshop Mechanic', child: Text('Workshop Mechanic')),
                        DropdownMenuItem(value: 'Service Advisor', child: Text('Service Advisor')),
                        DropdownMenuItem(value: 'Workshop Supervisor / Foreman', child: Text('Workshop Supervisor / Foreman')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedJobType = value;
                        });
                      },
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
                        onPressed: _register,
                        child: const Text('Sign Up'),
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