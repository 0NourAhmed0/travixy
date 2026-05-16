import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/place_model.dart';

class PlaceCacheService {
  static final PlaceCacheService _instance = PlaceCacheService._internal();

  static const String _cachedPlacesKey = 'travixy_cached_places_v1';
  static const String _recentPlacesKey = 'travixy_recent_places_v1';
  static const String _pinnedPlaceIdsKey = 'travixy_pinned_place_ids_v1';
  static const int _recentPlacesLimit = 10;

  factory PlaceCacheService() => _instance;

  PlaceCacheService._internal();

  Future<SharedPreferences> get _prefs async => SharedPreferences.getInstance();

  Future<void> saveCachedPlaces(List<Place> places) async {
    final prefs = await _prefs;
    final encoded = places.map((place) => jsonEncode(place.toJson())).toList();
    await prefs.setStringList(_cachedPlacesKey, encoded);
  }

  Future<List<Place>> loadCachedPlaces() async {
    final prefs = await _prefs;
    final encoded = prefs.getStringList(_cachedPlacesKey) ?? <String>[];
    return encoded.map(_placeFromEncodedJson).toList();
  }

  Future<void> saveRecentlyViewedPlace(Place place) async {
    final places = await loadRecentlyViewedPlaces();
    places.removeWhere((item) => item.id == place.id);
    places.insert(0, place);

    if (places.length > _recentPlacesLimit) {
      places.removeRange(_recentPlacesLimit, places.length);
    }

    final prefs = await _prefs;
    await prefs.setStringList(
      _recentPlacesKey,
      places.map((item) => jsonEncode(item.toJson())).toList(),
    );
  }

  Future<void> clearRecentlyViewedPlaces() async {
    final prefs = await _prefs;
    await prefs.remove(_recentPlacesKey);
  }

  Future<List<Place>> loadRecentlyViewedPlaces() async {
    final prefs = await _prefs;
    final encoded = prefs.getStringList(_recentPlacesKey) ?? <String>[];
    return encoded.map(_placeFromEncodedJson).toList();
  }

  Future<void> savePinnedPlaceIds(List<String> placeIds) async {
    final prefs = await _prefs;
    await prefs.setStringList(_pinnedPlaceIdsKey, placeIds);
  }

  Future<List<String>> loadPinnedPlaceIds() async {
    final prefs = await _prefs;
    return prefs.getStringList(_pinnedPlaceIdsKey) ?? <String>[];
  }

  Future<void> savePlaceToCache(Place place) async {
    final cachedPlaces = await loadCachedPlaces();
    cachedPlaces.removeWhere((item) => item.id == place.id);
    cachedPlaces.insert(0, place);
    await saveCachedPlaces(cachedPlaces);
  }

  Place _placeFromEncodedJson(String encoded) {
    final decoded = jsonDecode(encoded) as Map<String, dynamic>;
    return Place.fromJson(decoded);
  }
}