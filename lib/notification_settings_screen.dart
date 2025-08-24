import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationSettingsScreen extends StatefulWidget {
  final Function({
  required bool muted,
  required int muteDuration,
  required bool vibration,
  required String sound,
  }) onSave;

  const NotificationSettingsScreen({super.key, required this.onSave});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _isMuted = false;
  int _muteDuration = 0;
  bool _vibrationEnabled = true;
  String _selectedSound = 'default';

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isMuted = prefs.getBool('notificationsMuted') ?? false;
      _muteDuration = prefs.getInt('muteDuration') ?? 0;
      _vibrationEnabled = prefs.getBool('vibrationEnabled') ?? true;
      _selectedSound = prefs.getString('notificationSound') ?? 'default';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
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
              const Text(
                'Notification Settings',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Mute Notifications'),
                trailing: Switch(
                  value: _isMuted,
                  onChanged: (value) {
                    setState(() {
                      _isMuted = value;
                      if (!value) _muteDuration = 0;
                    });
                    widget.onSave(
                      muted: value,
                      muteDuration: _muteDuration,
                      vibration: _vibrationEnabled,
                      sound: _selectedSound,
                    );
                  },
                ),
              ),
              if (_isMuted)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Mute for Period',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    DropdownButton<int>(
                      value: _muteDuration == 0 ? null : _muteDuration,
                      hint: const Text('Select duration'),
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(value: 1, child: Text('1 Hour')),
                        DropdownMenuItem(value: 4, child: Text('4 Hours')),
                        DropdownMenuItem(value: 8, child: Text('8 Hours')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _muteDuration = value;
                          });
                          widget.onSave(
                            muted: _isMuted,
                            muteDuration: value,
                            vibration: _vibrationEnabled,
                            sound: _selectedSound,
                          );
                        }
                      },
                    ),
                  ],
                ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Vibration'),
                trailing: Switch(
                  value: _vibrationEnabled,
                  onChanged: (value) {
                    setState(() {
                      _vibrationEnabled = value;
                    });
                    widget.onSave(
                      muted: _isMuted,
                      muteDuration: _muteDuration,
                      vibration: value,
                      sound: _selectedSound,
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Notification Sound',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButton<String>(
                value: _selectedSound,
                isExpanded: true,
                items: const [
                  DropdownMenuItem(value: 'default', child: Text('Default')),
                  DropdownMenuItem(value: 'chime', child: Text('Chime')),
                  DropdownMenuItem(value: 'bell', child: Text('Bell')),
                  DropdownMenuItem(value: 'alert', child: Text('Alert')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedSound = value;
                    });
                    widget.onSave(
                      muted: _isMuted,
                      muteDuration: _muteDuration,
                      vibration: _vibrationEnabled,
                      sound: value,
                    );
                  }
                },
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
                    onPressed: () => Navigator.pop(context),
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