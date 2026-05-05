import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/places_provider.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final placesProvider = Provider.of<PlacesProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.logout();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              child: Icon(Icons.person, size: 50),
            ),
            const SizedBox(height: 16),
            Text(
              authProvider.isGuestMode
                  ? 'Guest User'
                  : authProvider.userEmail,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (!authProvider.isGuestMode) ...[
              Text('User ID: ${authProvider.userId.substring(0, 8)}...'),
              const SizedBox(height: 16),
              Card(
                child: ListTile(
                  title: const Text('Pinned Places'),
                  trailing: Text('${placesProvider.pinCount} / 5'),
                ),
              ),
              if (placesProvider.hasReachedPinLimit)
                const Card(
                  color: Colors.orange,
                  child: ListTile(
                    title: Text('Upgrade to Premium'),
                    subtitle: Text('Get unlimited pins and remove ads'),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}