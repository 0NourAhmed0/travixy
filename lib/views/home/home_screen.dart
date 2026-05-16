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
import '../notifications/notifications_screen.dart';

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
    const NotificationScreen(),
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
      bottomNavigationBar: Consumer<NotificationProvider>(
        builder: (context, notificationProvider, _) {
          return BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            type: BottomNavigationBarType.fixed,
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.search),
                label: 'Search',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.map),
                label: 'Map',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.chat),
                label: 'Chat',
              ),
              BottomNavigationBarItem(
                icon: Stack(
                  children: [
                    const Icon(Icons.notifications),
                    if (notificationProvider.unreadCount > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            notificationProvider.unreadCount > 99
                                ? '99+'
                                : '${notificationProvider.unreadCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
                label: 'Notifications',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          );
        },
      ),
    );
  }
}