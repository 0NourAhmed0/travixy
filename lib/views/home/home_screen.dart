import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/places_provider.dart';
import '../../providers/recommendations_provider.dart';
import '../../providers/notification_provider.dart';
import '../../services/location_notification_service.dart';
import 'explore_tab.dart';
import 'search_tab.dart';
import 'map_tab.dart';
import '../profile/profile_tab.dart';
import '../chat/chat_list_tab.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _tabs = [
    const ExploreTab(),
    const SearchTab(),
    const MapScreen(),
  // cont addPostTab(), why isnt it working
    const ChatListTab(),
    const ProfileTab(),
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final placesProvider = Provider.of<PlacesProvider>(context, listen: false);
    final recommendationsProvider = Provider.of<RecommendationsProvider>(context, listen: false);
    final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);

    if (authProvider.isAuthenticated && !authProvider.isGuestMode) {
      placesProvider.updateTokenAndUser(
        authProvider.token,
        authProvider.userId,
      );
      await placesProvider.fetchPlaces();
      
      // Convert loaded places to geofenced places for location monitoring
      final geofencedPlaces = placesProvider.places.map((place) {
        return GeofencedPlace(
          id: place.id,
          name: place.name,
          latitude: place.latitude,
          longitude: place.longitude,
          radiusMeters: 500, // 500m proximity radius
          description: place.description,
          isHidden: false,
        );
      }).toList();

      // Set monitored places in notification provider
      notificationProvider.setMonitoredPlaces(geofencedPlaces);

      // build recommendations after places are loaded
      try {
        await recommendationsProvider.loadRecommendations(
          uid: authProvider.userId,
          places: placesProvider.places,
          limit: 10,
        );
      } catch (_) {}
    }
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    body: IndexedStack(
      index: _selectedIndex,
      children: _tabs,
    ),
    bottomNavigationBar: BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });
      },
      type: BottomNavigationBarType.fixed,
      backgroundColor: const Color(0xFFFFF8F1),
      selectedItemColor: const Color(0xFFC9673B),
      unselectedItemColor: const Color(0xFF775242),
      selectedFontSize: 12,
      unselectedFontSize: 12,
      elevation: 8,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_rounded),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.travel_explore),
          label: 'Search',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.map_rounded),
          label: 'Map',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat_bubble_outline_rounded),
          label: 'Chat',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_rounded),
          label: 'Profile',
        ),
      ],
    ),
  );
}
}