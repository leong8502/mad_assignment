import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:mad_assignment/user/preferences_helper.dart';

class EditProfileScreen extends StatefulWidget {
  final String? localImagePath;
  final Map<String, dynamic>? userData;

  const EditProfileScreen({
    super.key,
    this.localImagePath,
    this.userData,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  bool _isUploading = false;
  String? _localImagePath;

  @override
  void initState() {
    super.initState();
    _localImagePath = widget.localImagePath; // Use preloaded image path
  }

  Future<bool> _requestGalleryPermission() async {
    PermissionStatus status;
    // Check platform and request appropriate permission
    if (Platform.isAndroid) {
      // For Android 13+, use READ_MEDIA_IMAGES; otherwise, READ_EXTERNAL_STORAGE
      status = await Permission.photos.request();
      if (status.isPermanentlyDenied || status.isDenied) {
        // For older Android versions, fall back to storage permission
        status = await Permission.storage.request();
      }
    } else {
      // iOS uses photos permission
      status = await Permission.photos.request();
    }

    if (status.isPermanentlyDenied) {
      _showSnackBar('Gallery access denied. Please enable it in settings.');
      await openAppSettings(); // Prompt user to open settings
      return false;
    } else if (status.isDenied) {
      _showSnackBar('Gallery access denied. Please allow access to continue.');
      return false;
    }
    return true;
  }

  Future<void> _uploadProfileImage() async {
    setState(() {
      _isUploading = true;
    });

    try {
      // Request gallery permission
      final hasPermission = await _requestGalleryPermission();
      if (!hasPermission) {
        setState(() {
          _isUploading = false;
        });
        return;
      }

      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image == null) {
        _showSnackBar('No image selected');
        return;
      }

      final imageFile = File(image.path);
      if (!await imageFile.exists()) {
        _showSnackBar('Selected image file does not exist.');
        return;
      }

      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final localFile = await imageFile.copy('${directory.path}/$fileName');

      setState(() {
        _localImagePath = localFile.path;
      });
      await _saveImagePath(_localImagePath);

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

  Future<void> _saveImagePath(String? path) async {
    if (path == null) {
      await PreferencesHelper.clearProfileImagePath();
    } else {
      await PreferencesHelper.setProfileImagePath(path);
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

    // Use preloaded user data or fallback to defaults for non-email fields
    String fullName = widget.userData?['username'] ?? '-';
    String jobType = widget.userData?['jobType'] ?? '-';
    String workId = widget.userData?['workId'] ?? 'N/A';
    // Use Firebase Authentication for email
    String email = user?.email ?? '-@gmail.com';

    final fullNameController = TextEditingController(text: fullName);
    final emailController = TextEditingController(text: email);
    final jobTypeController = TextEditingController(text: jobType);
    final workIdController = TextEditingController(text: workId);

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: _localImagePath != null && File(_localImagePath!).existsSync()
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
                  hintText: 'Your email...',
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
                    child: const Text('Cancel'),
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
                          // Do not update email in Firestore, it's managed by Firebase Auth
                          // Only username using, other just put only
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
          ),
        ),
      ),
    );
  }
}