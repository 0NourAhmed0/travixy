import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/place_model.dart';
import '../../providers/places_provider.dart';
import '../../models/post_model.dart';
import '../../providers/post_provider.dart';
import '../post/post_detail_tab.dart';

class PlaceDetailScreen extends StatefulWidget {
  final String placeId;

  const PlaceDetailScreen({super.key, required this.placeId});

  @override
  State<PlaceDetailScreen> createState() => _PlaceDetailScreenState();
}

class _PlaceDetailScreenState extends State<PlaceDetailScreen> {
  bool _trackedView = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_trackedView) return;

    final place = context.read<PlacesProvider>().getPlaceById(widget.placeId);
    if (place != null) {
      _trackedView = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<PlacesProvider>().markPlaceAsViewed(place);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PlacesProvider>(
      builder: (context, placesProvider, _) {
        final place = placesProvider.getPlaceById(widget.placeId);

        return Scaffold(
          appBar: AppBar(
            title: Text(place?.name ?? 'Place Details'),
          ),
          body: place == null
              ? _OfflineFallback(
                  placeId: widget.placeId,
                  placesProvider: placesProvider,
                )
              : _PlaceDetailsContent(
                  place: place,
                  isOffline: placesProvider.isOffline,
                ),
        );
      },
    );
  }
}

class _PlaceDetailsContent extends StatelessWidget {
  final Place place;
  final bool isOffline;

  const _PlaceDetailsContent({
    required this.place,
    required this.isOffline,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isOffline)
            _StatusBanner(
              title: 'Offline mode',
              subtitle: 'Showing cached place content.',
              icon: Icons.cloud_off,
            ),
          if (isOffline) const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: place.imageUrl != null && place.imageUrl!.isNotEmpty
                  ? Image.network(
                      place.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildImageFallback(),
                    )
                  : _buildImageFallback(),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            place.name,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _chip(place.category),
              _chip(place.budget),
              _chip(place.atmosphere),
              if (place.isHiddenGem) _chip('Hidden gem'),
            ],
          ),
          const SizedBox(height: 16),
          _infoRow(Icons.star, '${place.rating.toStringAsFixed(1)} rating'),
          _infoRow(Icons.reviews, '${place.reviewCount} reviews'),
          if (place.location.isNotEmpty) _infoRow(Icons.location_on, place.location),
          _infoRow(Icons.place, '${place.latitude}, ${place.longitude}'),
          const SizedBox(height: 20),
          Text(
            'About',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(place.description),
          if (place.tags.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text(
              'Tags',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: place.tags.map((tag) => _chip(tag)).toList(),
            ),
          ],
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Directions coming soon')),
                    );
                  },
                  icon: const Icon(Icons.directions),
                  label: const Text('Directions'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Related user posts about this place
          Consumer<PostProvider>(
            builder: (context, postProvider, _) {
              final related = postProvider.posts
                  .where((p) => p.placeId == place.id)
                  .toList();

              final legacyRelated = related.isNotEmpty
                  ? related
                  : postProvider.posts.where((p) {
                      final placeName = place.name.toLowerCase();
                      final loc = p.location.toLowerCase();
                      final desc = p.description.toLowerCase();
                      final tags = p.tags.map((t) => t.toLowerCase()).toList();

                      return loc.contains(placeName) ||
                          desc.contains(placeName) ||
                          tags.contains(placeName);
                    }).toList();

              if (legacyRelated.isEmpty) return const SizedBox.shrink();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    'User posts about this place',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 200,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: legacyRelated.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final post = legacyRelated[index];

                        return GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => PostDetailTab(post: post)),
                          ),
                          child: Container(
                            width: 260,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                  child: post.imageUrls.isNotEmpty
                                      ? Image.network(
                                          post.imageUrls[0],
                                          height: 110,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                        )
                                      : Container(
                                          height: 110,
                                          color: Colors.grey[200],
                                          child: const Icon(Icons.image, color: Colors.grey),
                                        ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        post.name,
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        post.description,
                                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          const Icon(Icons.person, size: 14, color: Colors.grey),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              post.userId ?? 'Anonymous',
                                              style: const TextStyle(fontSize: 12),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildImageFallback() {
    return Container(
      color: const Color(0xFFE8DDD2),
      child: Center(
        child: Icon(
          place.isHiddenGem ? Icons.diamond : Icons.place,
          size: 72,
          color: const Color(0xFF775242).withOpacity(0.8),
        ),
      ),
    );
  }

  Widget _chip(String label) {
    return Chip(
      label: Text(label),
      backgroundColor: const Color(0xFFF0E7DE),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF775242)),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _StatusBanner({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF775242).withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF775242)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF25180F),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: Color(0xFF25180F)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OfflineFallback extends StatelessWidget {
  final String placeId;
  final PlacesProvider placesProvider;

  const _OfflineFallback({
    required this.placeId,
    required this.placesProvider,
  });

  @override
  Widget build(BuildContext context) {
    final cachedMatch = placesProvider.cachedPlaces
        .where((place) => place.id == placeId)
        .cast<Place?>()
        .firstOrNull;

    final fallbackPlace = cachedMatch ?? placesProvider.recentlyViewedPlaces
        .where((place) => place.id == placeId)
        .cast<Place?>()
        .firstOrNull;

    if (fallbackPlace != null) {
      return _PlaceDetailsContent(
        place: fallbackPlace,
        isOffline: true,
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off, size: 72, color: Color(0xFF775242)),
            const SizedBox(height: 16),
            Text(
              'No cached content available',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Reconnect to load this place, or open a place you viewed before while online.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => placesProvider.fetchPlaces(),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

extension _FirstOrNullExtension<E> on Iterable<E> {
  E? get firstOrNull => isEmpty ? null : first;
}