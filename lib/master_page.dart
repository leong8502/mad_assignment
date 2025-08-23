import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '/dashboard_screen.dart';
import '/schedule_screen.dart';
import '/inbox_screen.dart';
import '/worklist_screen.dart';

class MasterPage extends StatefulWidget {
  const MasterPage({super.key});

  @override
  State<MasterPage> createState() => _MasterPageState();
}

class _MasterPageState extends State<MasterPage> {
  int _selectedIndex = 0;
  final List<Widget> _screens = const [
    DashboardScreen(),
    ScheduleScreen(),
    InboxScreen(),
    WorklistScreen(),
  ];
  final List<String> _titles = const [
    'Dashboard',
    'Schedule',
    'Inbox',
    'Work List',
  ];

  Future<void> _uploadProfileImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No image selected')),
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

      // Create a unique storage reference
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg');

      // Log the storage path for debugging
      print('Storage Reference: ${storageRef.fullPath}');

      // Upload file and monitor progress
      final uploadTask = storageRef.putFile(File(image.path));
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload progress: ${progress.toStringAsFixed(1)}%')),
        );
      });

      // Wait for upload completion
      final snapshot = await uploadTask.whenComplete(() => null);

      // Check if the upload was successful
      if (snapshot.state == TaskState.success) {
        // Add a slight delay to ensure Firebase processes the file
        await Future.delayed(const Duration(milliseconds: 500));

        // Retrieve download URL with retry logic
        String? photoURL;
        for (int attempt = 1; attempt <= 3; attempt++) {
          try {
            photoURL = await storageRef.getDownloadURL();
            break;
          } catch (e) {
            if (attempt == 3) rethrow;
            print('Retry $attempt failed: $e');
            await Future.delayed(const Duration(seconds: 1));
          }
        }

        // Update Firebase Authentication profile
        await user.updatePhotoURL(photoURL);

        // Update Firestore
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
          {'photoURL': photoURL},
          SetOptions(merge: true),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile image updated successfully')),
        );

        // Force UI refresh to display new image
        setState(() {});
      } else {
        throw Exception('Upload failed: ${snapshot.state}');
      }
    } on FirebaseException catch (e) {
      print('Firebase Error Code: ${e.code}, Message: ${e.message}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload image: ${e.message}')),
      );
    } catch (e) {
      print('Error uploading image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload image: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Theme(
      data: Theme.of(context).copyWith(
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: Colors.grey, size: 24),
          actionsIconTheme: IconThemeData(color: Colors.grey, size: 24),
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(_titles[_selectedIndex]),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications, color: Colors.black),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Notifications'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading: const Icon(Icons.volume_off),
                          title: const Text('Mute notifications'),
                        ),
                        ListTile(
                          leading: const Icon(Icons.notifications),
                          title: const Text('Notification settings'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      contentPadding: EdgeInsets.zero,
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 100,
                            backgroundImage: user?.photoURL != null
                                ? NetworkImage(user!.photoURL!)
                                : const AssetImage('assets/images/profile.png'),
                            backgroundColor: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          IconButton(
                            icon: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 30,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                child: CircleAvatar(
                  radius: 15,
                  backgroundImage: user?.photoURL != null
                      ? NetworkImage(user!.photoURL!)
                      : const AssetImage('assets/images/profile.png'),
                  backgroundColor: Colors.grey,
                ),
              ),
            ),
          ],
        ),
        drawer: Drawer(
          child: StreamBuilder<DocumentSnapshot>(
            stream: user != null
                ? FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots()
                : null,
            builder: (context, snapshot) {
              String displayName = 'Guest';
              if (snapshot.hasData && snapshot.data!.exists) {
                displayName = snapshot.data!['username'] ?? user?.email ?? 'Guest';
              }
              return ListView(
                padding: EdgeInsets.zero,
                children: [
                  DrawerHeader(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: const AssetImage('assets/images/drawer.png'),
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(
                          Colors.black.withOpacity(0.3),
                          BlendMode.darken,
                        ),
                      ),
                    ),
                    child: Text(
                      displayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: const Text('Edit Profile'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Scaffold(
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
                                    if (snapshot.hasData && snapshot.data!.exists) {
                                      fullName = snapshot.data!['username'] ?? fullName;
                                      email = snapshot.data!['email'] ?? email;
                                      jobType = snapshot.data!['jobType'] ?? jobType;
                                    }
                                    final fullNameController = TextEditingController(text: fullName);
                                    final emailController = TextEditingController(text: email);
                                    final jobTypeController = TextEditingController(text: jobType);
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
                          ),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.settings),
                    title: const Text('Settings'),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: const Icon(Icons.help),
                    title: const Text('Help & resources'),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text(
                      'Logout',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () async {
                      await FirebaseAuth.instance.signOut();
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                  ),
                ],
              );
            },
          ),
        ),
        body: Column(
          children: [
            Expanded(child: _screens[_selectedIndex]),
            Container(height: 1, color: Colors.grey[300]),
          ],
        ),
        bottomNavigationBar: Theme(
          data: Theme.of(context).copyWith(
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              backgroundColor: Colors.white,
              elevation: 0,
              selectedItemColor: Colors.indigoAccent,
              unselectedItemColor: Colors.grey,
              selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal, fontSize: 12),
              selectedIconTheme: IconThemeData(size: 28, color: Colors.indigoAccent),
              unselectedIconTheme: IconThemeData(size: 24, color: Colors.grey),
              showSelectedLabels: true,
              showUnselectedLabels: true,
              type: BottomNavigationBarType.fixed,
            ),
          ),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) {
              if (index == _selectedIndex) return;
              setState(() {
                _selectedIndex = index;
              });
            },
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Schedule'),
              BottomNavigationBarItem(icon: Icon(Icons.email), label: 'Inbox'),
              BottomNavigationBarItem(icon: Icon(Icons.check_circle_rounded), label: 'Work List'),
            ],
          ),
        ),
      ),
    );
  }
}