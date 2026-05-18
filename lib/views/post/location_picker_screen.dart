import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';

class LocationPickerScreen extends StatefulWidget {
  final LatLng? initialLocation;

  const LocationPickerScreen({
    super.key,
    this.initialLocation,
  });

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  final MapController _mapController = MapController();
  LatLng? _selectedLocation;
  String _selectedAddress = '';
  bool _isLoading = true;
  bool _isGettingAddress = false;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    try {
      // Request location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        // Get current location
        final position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
          ),
        );

        setState(() {
          _selectedLocation =
              LatLng(position.latitude, position.longitude);
        });

        // Get address for current location
        await _getAddressFromCoordinates(
          position.latitude,
          position.longitude,
        );
      } else {
        // Fallback to a default location (e.g., Cairo, Egypt)
        setState(() {
          _selectedLocation = const LatLng(30.0444, 31.2357);
        });
        await _getAddressFromCoordinates(30.0444, 31.2357);
      }
    } catch (e) {
      // Fallback to a default location
      setState(() {
        _selectedLocation = const LatLng(30.0444, 31.2357);
      });
      await _getAddressFromCoordinates(30.0444, 31.2357);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      setState(() => _isGettingAddress = true);
      final placemarks = await placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final address =
            '${place.thoroughfare ?? ''} ${place.subLocality ?? ''}, ${place.locality ?? ''}, ${place.administrativeArea ?? ''}, ${place.country ?? ''}'
                .replaceAll(RegExp(r'\s+'), ' ')
                .trim();

        setState(() => _selectedAddress = address.isNotEmpty ? address : 'Unknown location');
      } else {
        setState(() => _selectedAddress = '$latitude, $longitude');
      }
    } catch (e) {
      setState(() => _selectedAddress = '$latitude, $longitude');
    } finally {
      if (mounted) {
        setState(() => _isGettingAddress = false);
      }
    }
  }

  Future<void> _onMapTapped(TapPosition _, LatLng location) async {
    setState(() {
      _selectedLocation = location;
    });
    await _getAddressFromCoordinates(location.latitude, location.longitude);
  }

  void _confirmLocation() {
    if (_selectedLocation != null) {
      Navigator.of(context).pop({
        'latitude': _selectedLocation!.latitude,
        'longitude': _selectedLocation!.longitude,
        'address': _selectedAddress,
      });
    }
  }

  void _useCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      final newLocation = LatLng(position.latitude, position.longitude);
      setState(() {
        _selectedLocation = newLocation;
      });

      _mapController.move(newLocation, _mapController.camera.zoom);

      await _getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error getting current location: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF8B6F47),
        foregroundColor: Colors.white,
        title: const Text(
          'Pick Location',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF8B6F47),
              ),
            )
          : Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _selectedLocation ?? const LatLng(30.0444, 31.2357),
                    initialZoom: 14,
                    onTap: _onMapTapped,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                      subdomains: const ['a', 'b', 'c', 'd'],
                      userAgentPackageName: 'com.giu.travixy',
                    ),
                    MarkerLayer(
                      markers: _selectedLocation == null
                          ? const []
                          : [
                              Marker(
                                point: _selectedLocation!,
                                width: 45,
                                height: 45,
                                child: const Icon(
                                  Icons.location_on,
                                  size: 40,
                                  color: Color(0xFFB08968),
                                ),
                              ),
                            ],
                    ),
                  ],
                ),

                // Center marker (optional, helps user see what's in center)
                const Center(
                  child: Icon(
                    Icons.location_on,
                    size: 40,
                    color: Color(0xFFB08968),
                  ),
                ),

                // Location details at bottom
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Selected Location',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                            color: Color(0xFF562E2E),
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (_isGettingAddress)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFF8B6F47),
                                ),
                              ),
                            ),
                          )
                        else
                          Text(
                            _selectedAddress,
                            style: const TextStyle(
                              fontSize: 14,
                              fontFamily: 'Poppins',
                              color: Color.fromRGBO(37, 24, 15, 0.7),
                            ),
                          ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 16,
                              color: Color(0xFF8B6F47),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${_selectedLocation?.latitude.toStringAsFixed(4)}, ${_selectedLocation?.longitude.toStringAsFixed(4)}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontFamily: 'Poppins',
                                color: Color.fromRGBO(37, 24, 15, 0.5),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _useCurrentLocation,
                                icon: const Icon(Icons.my_location),
                                label: const Text('Current'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF8B6F47),
                                  side: const BorderSide(
                                    color: Color(0xFF8B6F47),
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _confirmLocation,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF8B6F47),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'Confirm',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

}
