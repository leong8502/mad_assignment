import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mad_assignment/user/login_screen.dart';
import 'package:mad_assignment/user/preferences_helper.dart';
import 'package:mad_assignment/master/master_page.dart'; // Import MasterPage for direct navigation

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String? _localImagePath;
  Map<String, dynamic>? _userData;
  bool _isMuted = false;
  int _muteDuration = 0;
  bool _vibrationEnabled = true;
  String _notificationSound = 'default';
  bool _isLoading = false; // Track loading state

  @override
  void initState() {
    super.initState();
    _preloadData(); // Preload data when splash screen initializes
  }

  Future<void> _preloadData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Preload preferences and user data if user exists
      final imagePath = await PreferencesHelper.getProfileImagePath();
      final isMuted = await PreferencesHelper.getMuteStatus();
      final muteDuration = await PreferencesHelper.getMuteDuration();
      final vibrationEnabled = await PreferencesHelper.getVibrationEnabled();
      final notificationSound = await PreferencesHelper.getNotificationSound();

      Map<String, dynamic>? userData;
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      userData = doc.data();

      // Update state with preloaded data
      if (mounted) {
        setState(() {
          _localImagePath = imagePath;
          _isMuted = isMuted;
          _muteDuration = muteDuration;
          _vibrationEnabled = vibrationEnabled;
          _notificationSound = notificationSound;
          _userData = userData;
        });
      }
    }
  }

  Future<bool> _checkAuthStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    final isLoggedIn = await PreferencesHelper.getLoginStatus();
    // Return true if user is authenticated, login status is true, and email is verified
    return user != null && isLoggedIn && user.emailVerified;
  }

  void _handleGetStarted(BuildContext context) async {
    setState(() {
      _isLoading = true; // Show loading indicator
    });

    // Ensure a minimum delay for smoother UX (e.g., 1 second)
    await Future.delayed(const Duration(seconds: 1));

    final isAuthenticated = await _checkAuthStatus();
    if (isAuthenticated) {
      // Navigate to MasterPage with preloaded data and fade transition
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => MasterPage(
            preloadedImagePath: _localImagePath,
            preloadedUserData: _userData,
            preloadedIsMuted: _isMuted,
            preloadedMuteDuration: _muteDuration,
            preloadedVibrationEnabled: _vibrationEnabled,
            preloadedNotificationSound: _notificationSound,
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = 0.0;
            const end = 1.0;
            const curve = Curves.easeInOut;

            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var opacityAnimation = animation.drive(tween);

            return FadeTransition(
              opacity: opacityAnimation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    } else {
      // Navigate to login with fade transition
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(), // Replace with your LoginScreen widget
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = 0.0;
            const end = 1.0;
            const curve = Curves.easeInOut;

            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var opacityAnimation = animation.drive(tween);

            return FadeTransition(
              opacity: opacityAnimation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
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
            _isLoading
                ? const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.black87),
            )
                : ElevatedButton(
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