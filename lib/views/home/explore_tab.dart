import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/places_provider.dart';
import '../../providers/recommendations_provider.dart';
import '../../models/place_model.dart';
import 'travixy_drawer.dart';

class ExploreTab extends StatelessWidget {
  const ExploreTab({super.key});

  @override
  Widget build(BuildContext context) {
    final placesProvider = Provider.of<PlacesProvider>(context);
    final recommendationsProvider = Provider.of<RecommendationsProvider>(context);
    final places = placesProvider.places;
    final recommended = recommendationsProvider.recommended;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Color(0xFF775242), size: 28),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
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
      drawer: const TravixyDrawer(),
      body: places.isEmpty
          ? const Center(
              child: Text('No places yet. Add some!'),
            )
          : ListView(
              children: [
                if (recommended.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Recommended for you', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        TextButton(
                          onPressed: () {},
                          child: const Text('See all'),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 160,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: recommended.length,
                      itemBuilder: (ctx, idx) {
                        final place = recommended[idx];
                        return SizedBox(
                          width: 260,
                          child: Card(
                            margin: const EdgeInsets.all(8),
                            child: ListTile(
                              leading: place.isHiddenGem ? const Icon(Icons.diamond, color: Colors.amber) : const Icon(Icons.place, color: Colors.blue),
                              title: Text(place.name),
                              subtitle: Text(place.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                              onTap: () {
                                Navigator.of(context).pushNamed('/place-detail', arguments: place.id);
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const Divider(),
                ],
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
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
              ],
            ),
    );
  }
}