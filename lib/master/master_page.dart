import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mad_assignment/user/reset_email_screen.dart';
import '/dashboard_screen.dart';
import '/schedule_screen.dart';
import '/inbox_screen.dart';
import '/worklist_screen.dart';
import 'package:mad_assignment/user/notification_settings_screen.dart';
import 'package:mad_assignment/user/edit_profile_screen.dart';
import 'package:mad_assignment/user/reset_password_screen.dart';
import 'package:mad_assignment/user/info_screen.dart';
import 'package:mad_assignment/user/preferences_helper.dart';
import 'dart:io';

class MasterPage extends StatefulWidget {
  final String? preloadedImagePath;
  final Map<String, dynamic>? preloadedUserData;
  final bool? preloadedIsMuted;
  final int? preloadedMuteDuration;
  final bool? preloadedVibrationEnabled;
  final String? preloadedNotificationSound;

  const MasterPage({
    super.key,
    this.preloadedImagePath,
    this.preloadedUserData,
    this.preloadedIsMuted,
    this.preloadedMuteDuration,
    this.preloadedVibrationEnabled,
    this.preloadedNotificationSound,
  });

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
  String? _localImagePath;
  bool _isMuted = false;
  int _muteDuration = 0; // Cache notification settings
  bool _vibrationEnabled = true;
  String _notificationSound = 'default';
  Map<String, dynamic>? _userData; // Cache user data

  @override
  void initState() {
    super.initState();
    // Use preloaded data if provided from SplashScreen, else load it
    if (widget.preloadedImagePath != null ||
        widget.preloadedUserData != null ||
        widget.preloadedIsMuted != null) {
      setState(() {
        _localImagePath = widget.preloadedImagePath;
        _userData = widget.preloadedUserData;
        _isMuted = widget.preloadedIsMuted ?? false;
        _muteDuration = widget.preloadedMuteDuration ?? 0;
        _vibrationEnabled = widget.preloadedVibrationEnabled ?? true;
        _notificationSound = widget.preloadedNotificationSound ?? 'default';
      });
    } else {
      _loadPreferencesAndData();
    }
  }

  Future<void> _loadPreferencesAndData() async {
    final isLoggedIn = await PreferencesHelper.getLoginStatus();
    final isMuted = await PreferencesHelper.getMuteStatus();
    final muteDuration = await PreferencesHelper.getMuteDuration();
    final vibrationEnabled = await PreferencesHelper.getVibrationEnabled();
    final notificationSound = await PreferencesHelper.getNotificationSound();
    final imagePath = await PreferencesHelper.getProfileImagePath();
    final user = FirebaseAuth.instance.currentUser;

    Map<String, dynamic>? userData;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      userData = doc.data();
    }

    setState(() {
      _localImagePath = imagePath;
      _isMuted = isMuted;
      _muteDuration = muteDuration;
      _vibrationEnabled = vibrationEnabled;
      _notificationSound = notificationSound;
      _userData = userData; // Store user data in state
    });

    // Sync login status with Firebase
    if (isLoggedIn && FirebaseAuth.instance.currentUser == null) {
      await PreferencesHelper.setLoginStatus(false);
    }
  }

  Future<void> _toggleMuteNotifications() async {
    setState(() {
      _isMuted = !_isMuted;
      _muteDuration = _isMuted ? -1 : 0; // Set -1 for mute, 0 for unmute
    });
    await PreferencesHelper.setMuteStatus(_isMuted);
    await PreferencesHelper.setMuteDuration(_muteDuration);
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
              icon: Icon(
                _isMuted ? Icons.notifications_off : Icons.notifications,
                color: Colors.black,
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Notifications'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading: Icon(
                            _isMuted ? Icons.volume_off : Icons.volume_up,
                          ),
                          title: Text(
                            _isMuted ? 'Unmute Notifications' : 'Mute Notifications',
                          ),
                          onTap: () async {
                            await _toggleMuteNotifications();
                            Navigator.pop(context);
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.notifications),
                          title: const Text('Notification Settings'),
                          onTap: () async {
                            Navigator.pop(context);
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => NotificationSettingsScreen(
                                  isMuted: _isMuted,
                                  muteDuration: _muteDuration,
                                  vibrationEnabled: _vibrationEnabled,
                                  notificationSound: _notificationSound,
                                ),
                              ),
                            );
                            await _loadPreferencesAndData(); // Refresh preferences after settings
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
                            backgroundImage: _localImagePath != null && File(_localImagePath!).existsSync()
                                ? FileImage(File(_localImagePath!)) as ImageProvider
                                : (user?.photoURL != null
                                ? NetworkImage(user!.photoURL!) as ImageProvider
                                : const AssetImage('assets/images/profile.png') as ImageProvider),
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
                  backgroundImage: _localImagePath != null && File(_localImagePath!).existsSync()
                      ? FileImage(File(_localImagePath!)) as ImageProvider
                      : (user?.photoURL != null
                      ? NetworkImage(user!.photoURL!) as ImageProvider
                      : const AssetImage('assets/images/profile.png') as ImageProvider),
                  backgroundColor: Colors.grey,
                ),
              ),
            ),
          ],
        ),
        drawer: Drawer(
          child: ListView(
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 80.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.settings,
                            color: Colors.white,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Settings',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Edit Profile'),
                onTap: () async {
                  Navigator.pop(context); // Close the drawer
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditProfileScreen(
                        localImagePath: _localImagePath,
                        userData: _userData,
                      ),
                    ),
                  );
                  await _loadPreferencesAndData(); // Refresh preferences and data after returning
                  setState(() {}); // Trigger UI rebuild
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
                leading: const Icon(Icons.email),
                title: const Text('Change Email'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ResetEmailScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.info),
                title: const Text('About this app'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const InfoScreen(),
                    ),
                  );
                },
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
                  await PreferencesHelper.clearPreferences();
                  Navigator.pushReplacementNamed(context, '/login');
                },
              ),
            ],
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
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              unselectedLabelStyle: TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 12,
              ),
              selectedIconTheme: IconThemeData(
                size: 28,
                color: Colors.indigoAccent,
              ),
              unselectedIconTheme: IconThemeData(
                size: 24,
                color: Colors.grey,
              ),
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
              BottomNavigationBarItem(icon: Icon(Icons.inbox), label: 'Inbox'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.check_circle_rounded), label: 'Work List'),
            ],
          ),
        ),
      ),
    );
  }
}