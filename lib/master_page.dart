import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/dashboard_screen.dart';
import '/schedule_screen.dart';
import '/inbox_screen.dart';
import '/worklist_screen.dart';
import '/notification_settings_screen.dart';
import '/edit_profile_screen.dart';
import '/reset_password_screen.dart';

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

  Future<void> _saveNotificationPreferences({
    required bool muted,
    required int muteDuration,
    required bool vibration,
    required String sound,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final user = FirebaseAuth.instance.currentUser;
    await prefs.setBool('notificationsMuted', muted);
    await prefs.setInt('muteDuration', muteDuration);
    await prefs.setBool('vibrationEnabled', vibration);
    await prefs.setString('notificationSound', sound);

    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
        {
          'notificationsMuted': muted,
          'muteDuration': muteDuration,
          'vibrationEnabled': vibration,
          'notificationSound': sound,
        },
        SetOptions(merge: true),
      );
    }
  }

  Future<void> _muteNotifications(int durationInHours) async {
    final muteUntil = DateTime.now().add(Duration(hours: durationInHours));
    await _saveNotificationPreferences(
      muted: true,
      muteDuration: muteUntil.millisecondsSinceEpoch,
      vibration: await SharedPreferences.getInstance().then((prefs) =>
      prefs.getBool('vibrationEnabled') ?? true),
      sound: await SharedPreferences.getInstance().then((prefs) =>
      prefs.getString('notificationSound') ?? 'default'),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Notifications muted for $durationInHours hours')),
    );
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
                  builder: (context) =>
                      AlertDialog(
                        title: const Text('Notifications'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: const Icon(Icons.volume_off),
                              title: const Text('Mute notifications'),
                              onTap: () async {
                                Navigator.pop(context);
                                await _muteNotifications(1);
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.notifications),
                              title: const Text('Notification settings'),
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        NotificationSettingsScreen(
                                          onSave: _saveNotificationPreferences,
                                        ),
                                  ),
                                );
                              },
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
                    builder: (context) =>
                        AlertDialog(
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
                                    : const AssetImage(
                                    'assets/images/profile.png'),
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
                ? FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .snapshots()
                : null,
            builder: (context, snapshot) {
              String displayName = 'Guest';
              if (snapshot.hasData && snapshot.data!.exists) {
                displayName =
                    snapshot.data!['username'] ?? user?.email ?? 'Guest';
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
                          builder: (context) => const EditProfileScreen(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.lock),
                    title: const Text('Reset Password'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ResetPasswordScreen(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.settings),
                    title: const Text('Settings'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              NotificationSettingsScreen(
                                onSave: _saveNotificationPreferences,
                              ),
                        ),
                      );
                    },
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
              selectedLabelStyle: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 14),
              unselectedLabelStyle: TextStyle(
                  fontWeight: FontWeight.normal, fontSize: 12),
              selectedIconTheme: IconThemeData(
                  size: 28, color: Colors.indigoAccent),
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
              BottomNavigationBarItem(
                  icon: Icon(Icons.calendar_today), label: 'Schedule'),
              BottomNavigationBarItem(icon: Icon(Icons.email), label: 'Inbox'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.check_circle_rounded), label: 'Work List'),
            ],
          ),
        ),
      ),
    );
  }
}