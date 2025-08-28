import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mad_assignment/user/preferences_helper.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  Future<bool> _checkAuthStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    final isLoggedIn = await PreferencesHelper.getLoginStatus();
    // Return true if user is authenticated, login status is true, and email is verified
    return user != null && isLoggedIn && user.emailVerified;
  }

  void _handleGetStarted(BuildContext context) async {
    final isAuthenticated = await _checkAuthStatus();
    if (isAuthenticated) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/logo.png', height: 175), // Replace with your logo asset
            const Text(
              'GREENSTEM MECHANICS',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Welcome ~',
              style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black87,
                foregroundColor: Colors.white,
                minimumSize: const Size(200, 50), // Width: 200, Height: 50
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => _handleGetStarted(context),
              child: const Text('Get Started'),
            ),
          ],
        ),
      ),
    );
  }
}