import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class PostLocationMapScreen extends StatefulWidget {
  final String postName;
  final String locationLabel;
  final double latitude;
  final double longitude;

  const PostLocationMapScreen({
    super.key,
    required this.postName,
    required this.locationLabel,
    required this.latitude,
    required this.longitude,
  });
  @override
  State<PostLocationMapScreen> createState() => _PostLocationMapScreenState();
}

class _PostLocationMapScreenState extends State<PostLocationMapScreen> {
  late final MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final point = LatLng(widget.latitude, widget.longitude);
      try {
        _mapController.move(point, 15);
      } catch (_) {}
    });
  }

  @override
  Widget build(BuildContext context) {
    final point = LatLng(widget.latitude, widget.longitude);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Location'),
        backgroundColor: const Color(0xFFF5F0E8),
        foregroundColor: const Color(0xFF25180F),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: point,
                initialZoom: 15,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                  subdomains: const ['a', 'b', 'c', 'd'],
                  userAgentPackageName: 'com.giu.travixy',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: point,
                      width: 48,
                      height: 48,
                      child: const Icon(
                        Icons.location_on,
                        size: 42,
                        color: Color(0xFF775242),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            color: const Color(0xFFF5F0E8),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.postName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF25180F),
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.locationLabel,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF775242),
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
