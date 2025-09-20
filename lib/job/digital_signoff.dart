// digital_signoff.dart
import 'dart:io';
import 'package:flutter/material.dart';

class DigitalSignoffPage extends StatelessWidget {
  final List<File> images;
  final String remark;

  const DigitalSignoffPage({
    super.key,
    required this.images,
    required this.remark,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Digital Sign-off"),
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Placeholder Customer Info Box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Customer Information",
                      style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  SizedBox(height: 8),
                  Text("Name: (to be filled)"),
                  Text("Phone: (to be filled)"),
                  Text("Email: (to be filled)"),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Remark Section
            if (remark.isNotEmpty) ...[
              const Text("Remark:", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(remark),
              const SizedBox(height: 20),
            ],

            // Image Section
            if (images.isNotEmpty) ...[
              const Text("Proof Images:", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: images.map((file) {
                  return Image.file(
                    file,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
            ],

            // Submit button (ADD THIS) - after signoff step (signature etc.)
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // TODO: handle signature upload/validation here later
                  // For now, assume signoff is done and return to WorkList.
                  // This will pop all routes until the first (root) route,
                  // which in your app is the WorkListScreen. Adjust if needed.
                  Navigator.of(context).popUntil((route) => route.isFirst); // ADD THIS
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text("Submit", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
