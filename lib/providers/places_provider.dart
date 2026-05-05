import 'dart:convert';
import 'dart:math' as math;  // ← ADD THIS with prefix
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/place_model.dart';

class PlacesProvider with ChangeNotifier {
  List<Place> _places = [];
  List<String> _pinnedPlaceIds = [];
  
  String? _token;
  String? _userId;

  List<Place> get places => [..._places];
  List<String> get pinnedPlaceIds => [..._pinnedPlaceIds];
  int get pinCount => _pinnedPlaceIds.length;
  
  static const int maxFreePins = 5;
  bool get hasReachedPinLimit => _pinnedPlaceIds.length >= maxFreePins;

  void updateTokenAndUser(String token, String userId) {
    _token = token;
    _userId = userId;
  }

  void clearAuthContext() {
    _token = null;
    _userId = null;
    _pinnedPlaceIds = [];
    notifyListeners();
  }

  bool isPinned(String placeId) {
    return _pinnedPlaceIds.contains(placeId);
  }

  // Add a new place
  Future<void> addPlace(Place place) async {
    if (_token == null) throw Exception('Not authenticated');
    
    final url = Uri.parse(
        'https://likealocal-default-rtdb.firebaseio.com/places.json?auth=$_token');
    
    try {
      final response = await http.post(
        url,
        body: json.encode(place.toJson()),
      );
      
      final responseData = json.decode(response.body);
      final newPlace = Place(
        id: responseData['name'],
        name: place.name,
        description: place.description,
        latitude: place.latitude,
        longitude: place.longitude,
        category: place.category,
        imageUrl: place.imageUrl,
        rating: place.rating,
        reviewCount: place.reviewCount,
        isHiddenGem: place.isHiddenGem,
        ownerId: _userId!,
        ownerName: place.ownerName,
        tags: place.tags,
        budget: place.budget,
        atmosphere: place.atmosphere,
        createdAt: DateTime.now(),
      );
      
      _places.add(newPlace);
      notifyListeners();
    } catch (err) {
      print('Error adding place: $err');
      throw err;
    }
  }

  // Fetch places from Firebase
  Future<void> fetchPlaces() async {
    if (_token == null) return;
    
    final url = Uri.parse(
        'https://likealocal-default-rtdb.firebaseio.com/places.json?auth=$_token');
    
    try {
      final response = await http.get(url);
      final Map<String, dynamic>? data = json.decode(response.body);
      
      if (data == null) {
        _places = [];
        notifyListeners();
        return;
      }
      
      final List<Place> loadedPlaces = [];
      data.forEach((id, value) {
        loadedPlaces.add(Place.fromJson({
          'id': id,
          ...value as Map<String, dynamic>,
        }));
      });
      
      _places = loadedPlaces;
      notifyListeners();
    } catch (err) {
      print('Error fetching places: $err');
    }
  }

  // Toggle pin
  Future<void> togglePin(String placeId) async {
    if (_pinnedPlaceIds.contains(placeId)) {
      _pinnedPlaceIds.remove(placeId);
    } else {
      _pinnedPlaceIds.add(placeId);
    }
    notifyListeners();
  }

  // Get places near a location
  List<Place> getNearbyPlaces(double lat, double lng, double radiusKm) {
    return _places.where((place) {
      final distance = _calculateDistance(
        lat, lng,
        place.latitude, place.longitude,
      );
      return distance <= radiusKm;
    }).toList();
  }

  // FIXED: Use math.sin, math.cos, etc.
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // kilometers
    
    double dLat = _toRadians(lat2 - lat1);
    double dLon = _toRadians(lon2 - lon1);
    
    double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) * math.cos(_toRadians(lat2)) *
        math.sin(dLon / 2) * math.sin(dLon / 2);
    
    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    
    return earthRadius * c;
  }

  double _toRadians(double degrees) {
    return degrees * math.pi / 180;  // Use math.pi
  }

  // Filter places by category and preferences
  List<Place> filterPlaces({
    String? category,
    String? budget,
    String? atmosphere,
    bool? onlyHiddenGems,
  }) {
    return _places.where((place) {
      if (category != null && place.category != category) return false;
      if (budget != null && place.budget != budget) return false;
      if (atmosphere != null && place.atmosphere != atmosphere) return false;
      if (onlyHiddenGems == true && !place.isHiddenGem) return false;
      return true;
    }).toList();
  }
}