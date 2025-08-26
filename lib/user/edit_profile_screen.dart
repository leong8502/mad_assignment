import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  Future<void> _uploadProfileImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No image selected')),
      );
      return;
    }

    final imageFile = File(image.path);
    if (!await imageFile.exists()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selected image file does not exist')),
      );
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No user signed in')),
        );
        return;
      }

      await user.getIdToken();
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg');

      final uploadTask = storageRef.putFile(imageFile);
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload progress: ${progress.toStringAsFixed(1)}%')),
        );
      });

      final snapshot = await uploadTask;
      if (snapshot.state == TaskState.success) {
        await Future.delayed(const Duration(seconds: 3));

        String? photoURL;
        for (int attempt = 1; attempt <= 7; attempt++) {
          try {
            photoURL = await storageRef.getDownloadURL();
            break;
          } catch (e) {
            if (attempt == 7) {
              throw Exception('Failed to retrieve download URL after $attempt attempts: $e');
            }
            await Future.delayed(const Duration(seconds: 3));
          }
        }

        await user.updatePhotoURL(photoURL);
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
          {'photoURL': photoURL},
          SetOptions(merge: true),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile image updated successfully')),
        );

        setState(() {});
      } else {
        throw Exception('Upload failed: ${snapshot.state}');
      }
    } on FirebaseException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload image: ${e.message}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload image: $e')),
      );
    }
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
              String fullName = 'John';
              String email = user?.email ?? 'John@gmail.com';
              String jobType = 'Developer';
              String workId = 'N/A';
              if (snapshot.hasData && snapshot.data!.exists) {
                fullName = snapshot.data!['username'] ?? fullName;
                email = snapshot.data!['email'] ?? email;
                jobType = snapshot.data!['jobType'] ?? jobType;
                workId = snapshot.data!['workId'] ?? workId;
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
                          backgroundImage: user?.photoURL != null
                              ? NetworkImage(user!.photoURL!)
                              : const AssetImage('assets/images/profile.png'),
                          backgroundColor: Colors.grey,
                        ),
                        GestureDetector(
                          onTap: _uploadProfileImage,
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(4),
                            child: const Icon(
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
                              'email': emailController.text.trim(),
                              'jobType': jobTypeController.text.trim(),
                              'workId': workIdController.text.trim(),
                            }, SetOptions(merge: true));
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