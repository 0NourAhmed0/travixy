import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/places_provider.dart';
import '../../providers/recommendations_provider.dart';
import '../../models/place_model.dart';
import 'upgrade_page.dart';
import 'travixy_drawer.dart';

class ExploreTab extends StatelessWidget {
  const ExploreTab({super.key});

  @override
  Widget build(BuildContext context) {
    final placesProvider = Provider.of<PlacesProvider>(context);
    final recommendationsProvider = Provider.of<RecommendationsProvider>(context);
    final places = placesProvider.places;
    final recommended = recommendationsProvider.recommended;
    final pinnedPlaces = placesProvider.cachedPlaces
        .where((place) => placesProvider.pinnedPlaceIds.contains(place.id))
        .toList();
    final recentPlaces = placesProvider.recentlyViewedPlaces;
    final offline = placesProvider.isOffline;

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
      body: ListView(
        children: [
          if (offline)
            Padding(
              padding: const EdgeInsets.all(12),
              child: _OfflineBanner(
                title: 'You are offline',
                subtitle: 'Showing cached places and your saved content.',
                actionLabel: 'Refresh',
                onRetry: () => placesProvider.fetchPlaces(),
              ),
            ),
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
          if (recentPlaces.isNotEmpty) ...[
            _SectionHeader(
              title: offline ? 'Recently viewed offline' : 'Recently viewed',
              actionLabel: 'Clear',
              onAction: () => placesProvider.clearRecentlyViewed(),
            ),
            SizedBox(
              height: 140,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                scrollDirection: Axis.horizontal,
                itemCount: recentPlaces.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final place = recentPlaces[index];
                  return _MiniPlaceCard(place: place);
                },
              ),
            ),
          ],
          if (pinnedPlaces.isNotEmpty) ...[
            _SectionHeader(
              title: offline ? 'Pinned places offline' : 'Pinned places',
              actionLabel: 'See all',
              onAction: () {},
            ),
            SizedBox(
              height: 140,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                scrollDirection: Axis.horizontal,
                itemCount: pinnedPlaces.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final place = pinnedPlaces[index];
                  return _MiniPlaceCard(place: place);
                },
              ),
            ),
          ],
          if (places.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    offline ? Icons.cloud_off : Icons.place_outlined,
                    size: 64,
                    color: const Color(0xFF775242).withOpacity(0.7),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    offline ? 'Using cached content' : 'No places yet',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    offline
                        ? 'Reconnect to refresh data. Your recent and pinned places stay available offline when cached.'
                        : 'Add some places to get started.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => placesProvider.fetchPlaces(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            )
          else
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
                        _handlePinTap(context, placesProvider, place.id);
                      },
                    ),
                    onTap: () {
                      Navigator.of(context).pushNamed('/place-detail', arguments: place.id);
                    },
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

Future<void> _handlePinTap(
  BuildContext context,
  PlacesProvider placesProvider,
  String placeId,
) async {
  final wasPinned = placesProvider.isPinned(placeId);

  try {
    await placesProvider.togglePin(placeId);
  } catch (e) {
    if (e.toString().contains('pin-limit-reached')) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Free plan allows 5 pins only. Upgrade to unlock unlimited pins.'),
        ),
      );
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const UpgradePage()),
      );
      return;
    }

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Could not update pin: $e')),
    );
    return;
  }

  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        wasPinned ? 'Removed from pins' : 'Saved to pins',
      ),
    ),
  );
}

class _OfflineBanner extends StatelessWidget {
  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onRetry;

  const _OfflineBanner({
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF775242).withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.cloud_off, color: Color(0xFF775242)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(subtitle),
              ],
            ),
          ),
          TextButton(onPressed: onRetry, child: Text(actionLabel)),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String actionLabel;
  final VoidCallback onAction;

  const _SectionHeader({
    required this.title,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          TextButton(onPressed: onAction, child: Text(actionLabel)),
        ],
      ),
    );
  }
}

class _MiniPlaceCard extends StatelessWidget {
  final Place place;

  const _MiniPlaceCard({required this.place});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      child: Card(
        child: InkWell(
          onTap: () {
            Navigator.of(context).pushNamed('/place-detail', arguments: place.id);
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  place.isHiddenGem ? Icons.diamond : Icons.place,
                  color: place.isHiddenGem ? Colors.amber : Colors.blue,
                ),
                const SizedBox(height: 10),
                Text(
                  place.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  place.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}