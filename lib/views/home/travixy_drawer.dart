import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';
import '../onboarding/onboarding_wizard.dart';
import 'chat_list_tab.dart';
import 'map_tab.dart';
import 'settings_tab.dart';

class TravixyDrawer extends StatelessWidget {
  const TravixyDrawer({super.key});

  static const Color bg = Color(0xFFEDE3D4);
  static const Color text = Color(0xFF775242);
  static const Color dark = Color(0xFF25180F);
  static const Color logout = Color(0xFFE45B4F);

  void _openPage(BuildContext context, Widget page) {
    final navigator = Navigator.of(context);
    navigator.pop();
    navigator.push(MaterialPageRoute(builder: (_) => page));
  }

  void _showComingSoon(BuildContext context, String title) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$title is coming soon')),
    );
  }

  Future<void> _logout(BuildContext context) async {
    final navigator = Navigator.of(context);
    navigator.pop();
    await context.read<AuthProvider>().logout();
    if (!context.mounted) {
      return;
    }
    navigator.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen(initialMode: AuthMode.login)),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Drawer(
      width: MediaQuery.sizeOf(context).width * 0.78,
      backgroundColor: bg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(0),
          bottomRight: Radius.circular(0),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Menu',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: dark,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: dark),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              const _SectionTitle('Navigation'),
              _DrawerItem(
                icon: Icons.location_on_outlined,
                title: 'Trips',
                onTap: () => _showComingSoon(context, 'Trips'),
              ),
              _DrawerItem(
                icon: Icons.chat_bubble_outline,
                title: 'Messages',
                onTap: () => _openPage(context, const ChatListTab()),
              ),
              _DrawerItem(
                icon: Icons.place_outlined,
                title: 'Nearby Me',
                onTap: () => _openPage(context, const MapScreen()),
              ),

              const SizedBox(height: 28),

              const _SectionTitle('Account'),
              _DrawerItem(
                icon: Icons.payment_outlined,
                title: 'Payment',
                onTap: () => _showComingSoon(context, 'Payment'),
              ),
              _DrawerItem(
                icon: Icons.workspace_premium_outlined,
                title: 'Subscription',
                onTap: () => _showComingSoon(context, 'Subscription'),
              ),
              _DrawerItem(
                icon: Icons.person_outline,
                title: 'Preference',
                enabled: !authProvider.isGuestMode,
                onTap: authProvider.isGuestMode
                    ? null
                    : () => _openPage(context, const OnboardingWizard(editPreferences: true)),
              ),
              _DrawerItem(
                icon: Icons.settings_outlined,
                title: 'Settings',
                onTap: () => _openPage(context, const SettingsTab()),
              ),

              const SizedBox(height: 28),

              const _SectionTitle('Support'),
              _DrawerItem(
                icon: Icons.help_outline,
                title: 'Help & Support',
                onTap: () => _showComingSoon(context, 'Help & Support'),
              ),
              _DrawerItem(
                icon: Icons.help_outline,
                title: 'FAQ',
                onTap: () => _showComingSoon(context, 'FAQ'),
              ),
              _DrawerItem(
                icon: Icons.notifications_none,
                title: 'Help & Support',
                onTap: () => _showComingSoon(context, 'Help & Support'),
              ),

              const Spacer(),

              Divider(
                color: const Color(0xFF775242).withOpacity(0.18),
                thickness: 2,
              ),

              const SizedBox(height: 20),

              InkWell(
                onTap: () => _logout(context),
                child: const Row(
                  children: [
                    Icon(Icons.logout, color: logout, size: 22),
                    SizedBox(width: 8),
                    Text(
                      'LOGOUT',
                      style: TextStyle(
                        color: logout,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFF9A7A66),
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.enabled = true,
  });

  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: InkWell(
        onTap: enabled ? onTap : null,
        child: Opacity(
          opacity: enabled ? 1.0 : 0.42,
          child: Row(
            children: [
              Icon(icon, size: 21, color: const Color(0xFF775242)),
              const SizedBox(width: 14),
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF775242),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}