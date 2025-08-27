import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:mad_assignment/user/preferences_helper.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  bool _isUploading = false;
  String? _localImagePath;

  @override
  void initState() {
    super.initState();
    _loadImagePath(); // Load saved image path on init
  }

  Future<void> _loadImagePath() async {
    final imagePath = await PreferencesHelper.getProfileImagePath();
    setState(() {
      _localImagePath = imagePath;
    });
  }

  Future<void> _saveImagePath(String? path) async {
    if (path == null) {
      await PreferencesHelper.clearProfileImagePath();
    } else {
      await PreferencesHelper.setProfileImagePath(path);
    }
  }

  Future<void> _uploadProfileImage() async {
    setState(() {
      _isUploading = true;
    });

    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image == null) {
        _showSnackBar('No image selected');
        return;
      }

      final imageFile = File(image.path);
      if (!await imageFile.exists()) {
        _showSnackBar('Selected image file does not exist. Check permissions.');
        return;
      }

      // Use documents directory for persistent storage
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final localFile = await imageFile.copy('${directory.path}/$fileName');

      setState(() {
        _localImagePath = localFile.path;
      });
      await _saveImagePath(_localImagePath); // Save to preferences

      _showSnackBar('Profile image saved locally');
    } catch (e) {
      _showSnackBar('Failed to save image: $e');
      print('Error: $e');
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: StreamBuilder<DocumentSnapshot>(
            stream: user != null
                ? FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots()
                : null,
            builder: (context, snapshot) {
              String fullName = '-';
              String email = user?.email ?? '-@gmail.com';
              String jobType = '-';
              String workId = 'N/A';
              if (snapshot.hasData && snapshot.data!.exists) {
                final data = snapshot.data!.data() as Map<String, dynamic>?;
                fullName = data?['username'] ?? fullName;
                email = data?['email'] ?? email;
                jobType = data?['jobType'] ?? jobType;
                workId = data?['workId'] ?? workId;
              }
              final fullNameController = TextEditingController(text: fullName);
              final emailController = TextEditingController(text: email);
              final jobTypeController = TextEditingController(text: jobType);
              final workIdController = TextEditingController(text: workId);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundImage: _localImagePath != null
                              ? FileImage(File(_localImagePath!)) as ImageProvider
                              : const AssetImage('assets/images/profile.png') as ImageProvider,
                          backgroundColor: Colors.grey,
                        ),
                        GestureDetector(
                          onTap: _isUploading ? null : _uploadProfileImage,
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(4),
                            child: _isUploading
                                ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                                : const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Full name',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: fullNameController,
                    decoration: InputDecoration(
                      hintText: 'Enter your full name...',
                      prefixIcon: const Icon(Icons.person, color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Work ID',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: workIdController,
                    enabled: false,
                    decoration: InputDecoration(
                      hintText: 'Your work ID...',
                      prefixIcon: const Icon(Icons.badge, color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Email',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: emailController,
                    enabled: false,
                    decoration: InputDecoration(
                      hintText: 'Enter your email...',
                      prefixIcon: const Icon(Icons.email, color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Job Type',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: jobTypeController,
                    enabled: false,
                    decoration: InputDecoration(
                      hintText: 'Your job type...',
                      prefixIcon: const Icon(Icons.work, color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const

                        Text('Cancel'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(80, 40),
                        ),
                        onPressed: () async {
                          if (user != null) {
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(user.uid)
                                .set({
                              'username': fullNameController.text.trim(),
                              'email': emailController.text.trim(),
                              'jobType': jobTypeController.text.trim(),
                              'workId': workIdController.text.trim(),
                            }, SetOptions(merge: true));
                            _showSnackBar('Profile updated successfully');
                          }
                          Navigator.pop(context);
                        },
                        child: const Text('Done'),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}