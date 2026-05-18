import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/material.dart';
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
  final CollectionReference<Map<String, dynamic>> _placesRef =
      FirebaseFirestore.instance.collection('places');

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

  Future<void> _ensurePlacesLoaded() async {
    if (_places.isEmpty && _cachedPlaces.isEmpty) {
      await fetchPlaces();
    }
  }

  String _normalizeText(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'\s*,\s*'), ',')
        .replaceAll(RegExp(r'[^\w\s,]'), '')
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  String _normalizeLocation(String value) {
    return _normalizeText(value).replaceAll(',', ', ');
  }

  List<Place> _allKnownPlaces() {
    final byId = <String, Place>{};

    for (final place in [
      ..._places,
      ..._cachedPlaces,
      ..._recentlyViewedPlaces,
    ]) {
      byId[place.id] = place;
    }

    return byId.values.toList();
  }

  Place? _findExistingPlace({
    required String name,
    required String location,
  }) {
    final normalizedName = _normalizeText(name);
    final normalizedLocation = _normalizeLocation(location);

    for (final place in _allKnownPlaces()) {
      final placeName = _normalizeText(place.name);
      final placeLocation = _normalizeLocation(place.location);

      final nameMatches = placeName == normalizedName ||
          (normalizedName.isNotEmpty && placeName.contains(normalizedName)) ||
          (normalizedName.isNotEmpty && normalizedName.contains(placeName));

      final locationMatches = normalizedLocation.isEmpty ||
          placeLocation == normalizedLocation ||
          (normalizedLocation.isNotEmpty &&
              placeLocation.contains(normalizedLocation)) ||
          (normalizedLocation.isNotEmpty &&
              normalizedLocation.contains(placeLocation));

      if (nameMatches && locationMatches) {
        return place;
      }
    }

    return null;
  }

  String _inferCategory(List<String> tags, String placeName, String location) {
    final normalizedTags = tags.map(_normalizeText).toList();
    final combined = _normalizeText('$placeName $location');

    const foodTags = {
      'coffee',
      'brunch',
      'street food',
      'fine dining',
      'desserts',
      'bar',
    };

    const hiddenGemTags = {'hidden gem'};

    if (normalizedTags.any(foodTags.contains) ||
        combined.contains('cafe') ||
        combined.contains('restaurant') ||
        combined.contains('coffee')) {
      return 'restaurant';
    }

    if (normalizedTags.any(hiddenGemTags.contains) ||
        combined.contains('hidden gem')) {
      return 'hidden_gem';
    }

    return 'experience';
  }

  String _inferBudget(List<String> tags) {
    final normalizedTags = tags.map(_normalizeText).toSet();

    if (normalizedTags.contains('free entry') ||
        normalizedTags.contains('budget-friendly')) {
      return '\$';
    }

    if (normalizedTags.contains('splurge-worthy') ||
        normalizedTags.contains('fine dining')) {
      return '\$\$\$';
    }

    return '\$\$';
  }

  String _inferAtmosphere(List<String> tags) {
    final normalizedTags = tags.map(_normalizeText).toSet();

    if (normalizedTags.contains('cozy') ||
        normalizedTags.contains('romantic') ||
        normalizedTags.contains('peaceful')) {
      return 'cozy';
    }

    if (normalizedTags.contains('lively') ||
        normalizedTags.contains('nightlife') ||
        normalizedTags.contains('rooftop')) {
      return 'luxury';
    }

    if (normalizedTags.contains('adventure') ||
        normalizedTags.contains('culture') ||
        normalizedTags.contains('art')) {
      return 'adventurous';
    }

    return 'casual';
  }

  bool _inferHiddenGem(List<String> tags, String placeName, String location) {
    final normalizedTags = tags.map(_normalizeText).toSet();
    final combined = _normalizeText('$placeName $location');

    return normalizedTags.contains('hidden gem') ||
        combined.contains('hidden gem');
  }

  Future<List<Location>> _geocodeLocation(String locationText) async {
    if (locationText.trim().isEmpty) return <Location>[];

    try {
      return await locationFromAddress(locationText);
    } catch (_) {
      return <Location>[];
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

  Future<Place> addPlace(Place place) async {
    try {
      final doc = _placesRef.doc();

      final newPlace = Place(
        id: doc.id,
        name: place.name.trim(),
        location: place.location.trim(),
        description: place.description,
        latitude: place.latitude,
        longitude: place.longitude,
        category: place.category,
        imageUrl: place.imageUrl,
        rating: place.rating,
        reviewCount: place.reviewCount,
        postCount: place.postCount,
        isHiddenGem: place.isHiddenGem,
        ownerId: place.ownerId,
        ownerName: place.ownerName,
        tags: place.tags,
        budget: place.budget,
        atmosphere: place.atmosphere,
        createdAt: place.createdAt,
      );

      await doc.set(newPlace.toJson());

      _places.add(newPlace);
      _cachedPlaces = [..._places];

      await _cacheService.saveCachedPlaces(_cachedPlaces);

      notifyListeners();
      return newPlace;
    } catch (err) {
      print('Error adding place: $err');
      rethrow;
    }
  }

  Future<Place> findOrCreatePlace({
    required String placeName,
    required String location,
    required String description,
    required List<String> tags,
    required String ownerId,
    required String ownerName,
    String? coverImageUrl,
    double? latitude,
    double? longitude,
  }) async {
    await _ensurePlacesLoaded();

    final cleanedPlaceName = placeName.trim();
    final cleanedLocation = location.trim();

    final existing = _findExistingPlace(
      name: cleanedPlaceName,
      location: cleanedLocation,
    );

    if (existing != null) {
      return existing;
    }

    final resolvedLocation = await _geocodeLocation(cleanedLocation);
    final resolvedCategory =
      _inferCategory(tags, cleanedPlaceName, cleanedLocation);
    final resolvedBudget = _inferBudget(tags);
    final resolvedAtmosphere = _inferAtmosphere(tags);

    final lat = latitude ?? (resolvedLocation.isNotEmpty ? resolvedLocation.first.latitude : 0.0);
    final lon = longitude ?? (resolvedLocation.isNotEmpty ? resolvedLocation.first.longitude : 0.0);

    final newPlace = Place(
      id: '',
      name: cleanedPlaceName,
      location: cleanedLocation,
      description: description,
      latitude: lat,
      longitude: lon,
      category: resolvedCategory,
      imageUrl: coverImageUrl,
      rating: 0,
      reviewCount: 0,
      postCount: 0,
      isHiddenGem: _inferHiddenGem(tags, cleanedPlaceName, cleanedLocation),
      ownerId: ownerId,
      ownerName: ownerName,
      tags: tags,
      budget: resolvedBudget,
      atmosphere: resolvedAtmosphere,
      createdAt: DateTime.now(),
    );

    return addPlace(newPlace);
  }

  Future<void> incrementPlacePostCount(String placeId, {int amount = 1}) async {
    if (placeId.isEmpty) return;

    final index = _places.indexWhere((place) => place.id == placeId);
    if (index == -1) return;

    final place = _places[index];

    final updatedPlace = Place(
      id: place.id,
      name: place.name,
      location: place.location,
      description: place.description,
      latitude: place.latitude,
      longitude: place.longitude,
      category: place.category,
      imageUrl: place.imageUrl,
      rating: place.rating,
      reviewCount: place.reviewCount,
      postCount: place.postCount + amount,
      isHiddenGem: place.isHiddenGem,
      ownerId: place.ownerId,
      ownerName: place.ownerName,
      tags: place.tags,
      budget: place.budget,
      atmosphere: place.atmosphere,
      createdAt: place.createdAt,
    );

    _places[index] = updatedPlace;
    _cachedPlaces = [..._places];

    await _placesRef.doc(placeId).update({
      'postCount': updatedPlace.postCount,
    });

    await _cacheService.saveCachedPlaces(_cachedPlaces);

    notifyListeners();
  }

  Future<void> fetchPlaces() async {
    _isOffline = false;

    try {
      final snapshot =
          await _placesRef.orderBy('createdAt', descending: true).get();

      final loadedPlaces = snapshot.docs
          .map((doc) => Place.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();

      if (loadedPlaces.isEmpty && _cachedPlaces.isNotEmpty) {
        _places = [..._cachedPlaces];
        notifyListeners();
        return;
      }

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

  List<Place> getNearbyPlaces(double lat, double lng, double radiusKm) {
    return _places.where((place) {
      final distance = _calculateDistance(
        lat,
        lng,
        place.latitude,
        place.longitude,
      );

      return distance <= radiusKm;
    }).toList();
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const earthRadius = 6371.0;

    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

  double _toRadians(double degrees) {
    return degrees * math.pi / 180;
  }

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