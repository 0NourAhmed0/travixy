import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();

  LatLng? _currentLocation;
  bool _loading = true;
  String? _errorMessage;

  List<Marker> _markers = [];

  @override
  void initState() {
    super.initState();
    _initMap();
  }

  Future<void> _initMap() async {
    try {
      await _getCurrentLocation();
      await _loadPostMarkers();

      setState(() {
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      throw Exception('Location services are disabled. Please enable GPS.');
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw Exception('Location permission was denied.');
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Location permission is permanently denied. Enable it from settings.',
      );
    }

    final position = await Geolocator.getCurrentPosition();

    _currentLocation = LatLng(position.latitude, position.longitude);
  }

  Future<void> _loadPostMarkers() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('posts').get();

    final markers = snapshot.docs.where((doc) {
      final data = doc.data();
      return data['latitude'] != null && data['longitude'] != null;
    }).map((doc) {
      final data = doc.data();

      final double latitude = (data['latitude'] as num).toDouble();
      final double longitude = (data['longitude'] as num).toDouble();

      return Marker(
        point: LatLng(latitude, longitude),
        width: 45,
        height: 45,
        child: GestureDetector(
          onTap: () {
            _showPlaceBottomSheet(doc.id, data);
          },
          child: const Icon(
            Icons.location_on,
            size: 42,
            color: Color(0xFF775242),
          ),
        ),
      );
    }).toList();

    _markers = markers;
  }

  void _showPlaceBottomSheet(String postId, Map<String, dynamic> data) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFF5F0E8),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data['title'] ?? 'Unknown place',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF25180F),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                data['category'] ?? 'No category',
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF775242),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                data['description'] ?? 'No description available.',
                style: const TextStyle(fontSize: 15),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);

                    // Later: navigate to your post details screen.
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (_) => PostDetailsScreen(postId: postId),
                    //   ),
                    // );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF775242),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('View Details'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _goToMyLocation() {
    if (_currentLocation == null) return;

    _mapController.move(_currentLocation!, 15);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Map')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              _errorMessage!,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore Nearby'),
        backgroundColor: const Color(0xFFF5F0E8),
        foregroundColor: const Color(0xFF25180F),
        elevation: 0,
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentLocation!,
              initialZoom: 14,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'com.example.travixy',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _currentLocation!,
                    width: 45,
                    height: 45,
                    child: const Icon(
                      Icons.my_location,
                      size: 34,
                      color: Colors.blue,
                    ),
                  ),
                  ..._markers,
                ],
              ),
            ],
          ),

          Positioned(
            right: 16,
            bottom: 24,
            child: FloatingActionButton(
              backgroundColor: const Color(0xFF775242),
              onPressed: _goToMyLocation,
              child: const Icon(Icons.my_location, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}