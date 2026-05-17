import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/place_model.dart';
import '../services/place_cache_service.dart';

class PlacesProvider with ChangeNotifier {
  List<Place> _places = [];
  List<Place> _cachedPlaces = [];
  List<Place> _recentlyViewedPlaces = [];
  List<String> _pinnedPlaceIds = [];
  bool _isOffline = false;
  bool _isPremium = false;

  final PlaceCacheService _cacheService = PlaceCacheService();
  
  String? _token;
  String? _userId;

  List<Place> get places => [..._places];
  List<Place> get cachedPlaces => [..._cachedPlaces];
  List<Place> get recentlyViewedPlaces => [..._recentlyViewedPlaces];
  List<String> get pinnedPlaceIds => [..._pinnedPlaceIds];
  int get pinCount => _pinnedPlaceIds.length;
  bool get isOffline => _isOffline;
  bool get isPremium => _isPremium;
  
  static const int maxFreePins = 5;
  bool get hasReachedPinLimit => _pinnedPlaceIds.length >= maxFreePins;

  PlacesProvider() {
    _loadCachedState();
  }

  void updateTokenAndUser(String token, String userId) {
    _token = token;
    _userId = userId;
  }

  void clearAuthContext() {
    _token = null;
    _userId = null;
    notifyListeners();
  }

  Future<void> _loadCachedState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isPremium = prefs.getBool('is_premium') ?? false;
      _cachedPlaces = await _cacheService.loadCachedPlaces();
      _recentlyViewedPlaces = await _cacheService.loadRecentlyViewedPlaces();
      _pinnedPlaceIds = await _cacheService.loadPinnedPlaceIds();
      notifyListeners();
    } catch (err) {
      print('Error loading cached places: $err');
    }
  }

  Place? getPlaceById(String placeId) {
    for (final place in _places) {
      if (place.id == placeId) return place;
    }
    for (final place in _cachedPlaces) {
      if (place.id == placeId) return place;
    }
    for (final place in _recentlyViewedPlaces) {
      if (place.id == placeId) return place;
    }
    return null;
  }

  Future<void> markPlaceAsViewed(Place place) async {
    _recentlyViewedPlaces.removeWhere((item) => item.id == place.id);
    _recentlyViewedPlaces.insert(0, place);

    if (_recentlyViewedPlaces.length > 10) {
      _recentlyViewedPlaces.removeRange(10, _recentlyViewedPlaces.length);
    }

    await _cacheService.saveRecentlyViewedPlace(place);
    await _cacheService.savePlaceToCache(place);
    notifyListeners();
  }

  Future<void> clearRecentlyViewed() async {
    _recentlyViewedPlaces.clear();
    await _cacheService.clearRecentlyViewedPlaces();
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
    _isOffline = false;
    
    final url = Uri.parse(
        'https://likealocal-default-rtdb.firebaseio.com/places.json?auth=$_token');
    
    try {
      final response = await http.get(url);
      if (response.statusCode >= 400) {
        throw Exception('Failed to load places');
      }
      final Map<String, dynamic>? data = json.decode(response.body);
      
      if (data == null) {
        _places = [];
        _cachedPlaces = [];
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
      _cachedPlaces = [...loadedPlaces];
      await _cacheService.saveCachedPlaces(loadedPlaces);
      notifyListeners();
    } catch (err) {
      print('Error fetching places: $err');
      _isOffline = true;
      if (_cachedPlaces.isNotEmpty) {
        _places = [..._cachedPlaces];
      } else {
        _places = [];
      }
      notifyListeners();
    }
  }

  // Toggle pin
  Future<void> togglePin(String placeId) async {
    if (_pinnedPlaceIds.contains(placeId)) {
      _pinnedPlaceIds.remove(placeId);
    } else {
      if (!isPremium && hasReachedPinLimit) {
        throw Exception('pin-limit-reached');
      }
      _pinnedPlaceIds.add(placeId);
    }

    await _cacheService.savePinnedPlaceIds(_pinnedPlaceIds);

    final place = getPlaceById(placeId);
    if (place != null) {
      await _cacheService.savePlaceToCache(place);
    }

    notifyListeners();
  }

  Future<void> refreshPremiumState() async {
    final prefs = await SharedPreferences.getInstance();
    _isPremium = prefs.getBool('is_premium') ?? false;
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