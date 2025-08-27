import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mad_assignment/user/preferences_helper.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _isMuted = false;
  int _muteDuration = 0;
  bool _vibrationEnabled = false;
  String _selectedSound = 'default';
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final isMuted = await PreferencesHelper.getMuteStatus();
    final muteDuration = await PreferencesHelper.getMuteDuration();
    final vibrationEnabled = await PreferencesHelper.getVibrationEnabled();
    final selectedSound = await PreferencesHelper.getNotificationSound();
    setState(() {
      _isMuted = isMuted;
      _muteDuration = muteDuration;
      _vibrationEnabled = vibrationEnabled;
      _selectedSound = selectedSound;
    });
  }

  Future<void> _savePreferences() async {
    await PreferencesHelper.setMuteStatus(_isMuted);
    await PreferencesHelper.setMuteDuration(_muteDuration);
    await PreferencesHelper.setVibrationEnabled(_vibrationEnabled);
    await PreferencesHelper.setNotificationSound(_selectedSound);
  }

  void _playNotificationSound() async {
    String soundPath;
    switch (_selectedSound) {
      case 'default':
        soundPath = 'assets/sounds/sound0.mp3';
        break;
      case 'sound1':
        soundPath = 'assets/sounds/sound1.mp3';
        break;
      case 'sound2':
        soundPath = 'assets/sounds/sound2.mp3';
        break;
      case 'sound3':
        soundPath = 'assets/sounds/sound3.mp3';
        break;
      default:
        soundPath = 'assets/sounds/sound0.mp3';
    }
    try {
      await _audioPlayer.setAsset(soundPath);
      await _audioPlayer.play();
    } catch (e, stackTrace) {
      // Handle error silently or log as needed
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
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
          padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 30.0),
          child: Container(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.notifications, color: Colors.black),
                    SizedBox(width: 8),
                    Text(
                      'Notification Settings',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                ListTile(
                  leading: const Icon(Icons.volume_off, color: Colors.black),
                  title: const Text(
                    'Mute Notifications',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  trailing: Switch(
                    value: _isMuted,
                    onChanged: (value) {
                      setState(() {
                        _isMuted = value;
                        if (!value) _muteDuration = 0;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 32),
                if (_isMuted)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.timer, color: Colors.black),
                          SizedBox(width: 8),
                          Text(
                            'Mute for Period',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      DropdownButton<int>(
                        value: _muteDuration == 0 ? null : _muteDuration,
                        hint: const Text('Select duration'),
                        isExpanded: true,
                        items: const [
                          DropdownMenuItem(value: -1, child: Text('Forever', style: TextStyle(fontSize: 14))),
                          DropdownMenuItem(value: 1, child: Text('1 Hour', style: TextStyle(fontSize: 14))),
                          DropdownMenuItem(value: 4, child: Text('4 Hours', style: TextStyle(fontSize: 14))),
                          DropdownMenuItem(value: 8, child: Text('8 Hours', style: TextStyle(fontSize: 14))),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _muteDuration = value;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ListTile(
                  leading: const Icon(Icons.vibration, color: Colors.black),
                  title: const Text(
                    'Vibration',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  trailing: Switch(
                    value: _vibrationEnabled,
                    onChanged: (value) {
                      setState(() {
                        _vibrationEnabled = value;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 32),
                const Row(
                  children: [
                    Icon(Icons.music_note, color: Colors.black),
                    SizedBox(width: 8),
                    Text(
                      'Notification Sound',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                DropdownButton<String>(
                  value: _selectedSound,
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(value: 'default', child: Text('Default', style: TextStyle(fontSize: 14))),
                    DropdownMenuItem(value: 'sound1', child: Text('Chime', style: TextStyle(fontSize: 14))),
                    DropdownMenuItem(value: 'sound2', child: Text('Bell', style: TextStyle(fontSize: 14))),
                    DropdownMenuItem(value: 'sound3', child: Text('Alert', style: TextStyle(fontSize: 14))),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedSound = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(20, 36),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.play_arrow),
                    label: const Text(
                      'Play',
                      style: TextStyle(fontSize: 16),
                    ),
                    onPressed: _playNotificationSound,
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(80, 40),
                      ),
                      onPressed: () async {
                        await _savePreferences();
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Apply',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}