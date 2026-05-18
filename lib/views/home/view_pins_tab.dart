import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/places_provider.dart';
import '../place/place_detail_screen.dart';
import 'upgrade_page.dart';

class ViewPinsPage extends StatelessWidget {
  const ViewPinsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final placesProvider = context.watch<PlacesProvider>();

    final pinnedPlaces = placesProvider.pinnedPlaceIds
        .map((id) => placesProvider.getPlaceById(id))
        .whereType()
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Pins'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                placesProvider.isPremium
                    ? '${placesProvider.pinCount} pins'
                    : '${placesProvider.pinCount}/5',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: pinnedPlaces.isEmpty
          ? const Center(
              child: Text('No pinned places yet.'),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: pinnedPlaces.length + 1,
              itemBuilder: (context, index) {
                if (index == pinnedPlaces.length) {
                  if (placesProvider.isPremium) {
                    return const SizedBox.shrink();
                  }

                  return Card(
                    color: Colors.orange.shade100,
                    child: ListTile(
                      leading: const Icon(Icons.workspace_premium),
                      title: const Text('Need more pins?'),
                      subtitle: const Text(
                        'Upgrade to Premium for unlimited pins.',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const UpgradePage(),
                          ),
                        );
                      },
                    ),
                  );
                }

                final place = pinnedPlaces[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: place.imageUrl != null && place.imageUrl!.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              place.imageUrl!,
                              width: 56,
                              height: 56,
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Icon(Icons.place, size: 40),
                    title: Text(place.name),
                    subtitle: Text(place.location),
                    trailing: IconButton(
                      icon: const Icon(Icons.push_pin),
                      onPressed: () {
                        placesProvider.togglePin(place.id);
                      },
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PlaceDetailScreen(placeId: place.id),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}