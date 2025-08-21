import 'package:flutter/material.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset('assets/logo.png', height: 30), // Replace with your logo asset
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Username', style: TextStyle(fontSize: 16)),
            TextField(decoration: const InputDecoration(hintText: 'Enter your username...')),
            const SizedBox(height: 10),
            const Text('Work ID', style: TextStyle(fontSize: 16)),
            TextField(decoration: const InputDecoration(hintText: 'Enter your work ID...')),
            const SizedBox(height: 10),
            const Text('Email', style: TextStyle(fontSize: 16)),
            TextField(decoration: const InputDecoration(hintText: 'Enter your email...')),
            const SizedBox(height: 10),
            const Text('Password', style: TextStyle(fontSize: 16)),
            TextField(obscureText: true, decoration: const InputDecoration(hintText: 'Enter your password...')),
            const SizedBox(height: 10),
            const Text('Confirm Password', style: TextStyle(fontSize: 16)),
            TextField(obscureText: true, decoration: const InputDecoration(hintText: 'Enter your password again...')),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.pushReplacementNamed(context, '/dashboard'),
              child: const Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}