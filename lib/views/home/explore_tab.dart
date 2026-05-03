import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/places_provider.dart';

class ExploreTab extends StatelessWidget {
  const ExploreTab({super.key});

  @override
  Widget build(BuildContext context) {
    final placesProvider = Provider.of<PlacesProvider>(context);
    final places = placesProvider.places;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Use the Search tab for filtering')),
              );
            },
          ),
        ],
      ),
      body: places.isEmpty
          ? const Center(
              child: Text('No places yet. Add some!'),
            )
          : ListView.builder(
              itemCount: places.length,
              itemBuilder: (ctx, index) {
                final place = places[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    leading: place.isHiddenGem
                        ? const Icon(Icons.diamond, color: Colors.amber)
                        : const Icon(Icons.place, color: Colors.blue),
                    title: Text(place.name),
                    subtitle: Text(place.description),
                    trailing: IconButton(
                      icon: Icon(
                        placesProvider.isPinned(place.id)
                            ? Icons.bookmark
                            : Icons.bookmark_border,
                        color: Colors.orange,
                      ),
                      onPressed: () {
                        placesProvider.togglePin(place.id);
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}