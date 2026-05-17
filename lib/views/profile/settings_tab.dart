import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;

import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';
import '../../services/post_service.dart';
import '../auth/auth_gate.dart';
import 'edit_profile_tab.dart';
import '../onboarding/onboarding_wizard.dart';
import '../home/upgrade_page.dart';

class SettingsTab extends StatefulWidget {
  const SettingsTab({super.key});

  @override
  State<SettingsTab> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsTab> {
  bool notificationsEnabled = true;
  bool chatEnabled = true;
  bool privateTrips = false;
  bool locationNotificationsEnabled = false;

  static const _kNotifications = 'settings_notifications';
  static const _kChat = 'settings_allow_chat';
  static const _kPrivateTrips = 'settings_private_trips';
  static const _kLocationNotifications = 'settings_location_notifications';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      notificationsEnabled = prefs.getBool(_kNotifications) ?? true;
      chatEnabled = prefs.getBool(_kChat) ?? true;
      privateTrips = prefs.getBool(_kPrivateTrips) ?? false;
      locationNotificationsEnabled = prefs.getBool(_kLocationNotifications) ?? false;
    });
  }

  Future<void> _saveSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> _logout() async {
    await context.read<AuthProvider>().logout();

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AuthGate()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final userEmail = auth.isGuestMode ? 'Guest User' : auth.userEmail;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: const Color(0xFFF5F0E8),
        foregroundColor: const Color(0xFF25180F),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _profileCard(userEmail),

          const SizedBox(height: 20),

          _sectionTitle('Account'),
          _settingsTile(
            icon: Icons.person,
            title: 'Edit Profile',
            subtitle: 'Update your name and profile photo',
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfilePage()));
            },
            enabled: !auth.isGuestMode,
          ),
          _settingsTile(
            icon: Icons.favorite,
            title: 'Preferences',
            subtitle: 'Edit interests, budget and travel style',
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const OnboardingWizard(editPreferences: true)));
            },
            enabled: !auth.isGuestMode,
          ),

          const SizedBox(height: 16),

          _sectionTitle('App Preferences'),
          _switchTile(
            icon: Icons.notifications,
            title: 'Notifications',
            subtitle: 'Receive push notifications',
            value: notificationsEnabled,
            enabled: !auth.isGuestMode,
            onChanged: (value) {
              setState(() => notificationsEnabled = value);
              _saveSetting(_kNotifications, value);
            },
          ),
          _switchTile(
            icon: Icons.location_on,
            title: 'Location Notifications',
            subtitle: 'Get notified when near recommended places',
            value: locationNotificationsEnabled,
            enabled: !auth.isGuestMode && notificationsEnabled,
            onChanged: (value) async {
              setState(() => locationNotificationsEnabled = value);
              _saveSetting(_kLocationNotifications, value);
              // Enable/disable location-based notifications in provider
              await context.read<NotificationProvider>().setLocationNotificationsEnabled(value);
            },
          ),
          _switchTile(
            icon: Icons.chat,
            title: 'Allow Chat',
            subtitle: 'Let users message you about your posts',
            value: chatEnabled,
            enabled: !auth.isGuestMode,
            onChanged: (value) {
              setState(() => chatEnabled = value);
              _saveSetting(_kChat, value);
            },
          ),
          _switchTile(
            icon: Icons.lock,
            title: 'Private Trips',
            subtitle: 'Keep your saved trips private',
            value: privateTrips,
            enabled: !auth.isGuestMode,
            onChanged: (value) async {
              setState(() => privateTrips = value);
              _saveSetting(_kPrivateTrips, value);
              
              // If toggled ON, update all user posts to private in Firestore
              if (value) {
                try {
                  final userId = FirebaseAuth.instance.currentUser?.uid;
                  if (userId != null) {
                    final postService = PostService();
                    await postService.makeAllUserPostsPrivate(userId);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('All your trips are now private'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error making trips private: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
          ),

          const SizedBox(height: 16),

          _sectionTitle('Premium'),
          _settingsTile(
            icon: Icons.workspace_premium,
            title: 'Upgrade to Premium',
            subtitle: 'Unlimited pins, no ads, and priority visibility',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UpgradePage())),
            enabled: !auth.isGuestMode,
          ),

          const SizedBox(height: 16),

          _sectionTitle('Support'),
          _settingsTile(
            icon: Icons.help,
            title: 'Help & About',
            subtitle: 'App information and support',
            onTap: () => showAboutDialog(
              context: context,
              applicationName: 'Travixy',
              applicationVersion: '1.0',
              children: const [Text('Travixy — travel like a local')],
            ),
          ),

          const SizedBox(height: 28),

          ElevatedButton.icon(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            label: const Text('Log Out'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF775242),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileCard(String email) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFEBE1D2),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 34,
            backgroundColor: Color(0xFF775242),
            child: Icon(Icons.person, color: Colors.white, size: 34),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              email,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF25180F),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFF775242),
        ),
      ),
    );
  }

  Widget _settingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool enabled = true,
  }) {
    return Card(
      color: Colors.white.withOpacity(0.75),
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Opacity(
        opacity: enabled ? 1.0 : 0.5,
        child: ListTile(
          leading: Icon(icon, color: const Color(0xFF775242)),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          subtitle: Text(subtitle),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: enabled ? onTap : null,
        ),
      ),
    );
  }

  Widget _switchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool enabled = true,
  }) {
    return Card(
      color: Colors.white.withOpacity(0.75),
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Opacity(
        opacity: enabled ? 1.0 : 0.5,
        child: SwitchListTile(
          secondary: Icon(icon, color: const Color(0xFF775242)),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          subtitle: Text(subtitle),
          value: value,
          activeColor: const Color(0xFF775242),
          onChanged: enabled ? onChanged : null,
        ),
      ),
    );
  }
}