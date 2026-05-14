import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travixy/views/home/profile_toggle_tabs.dart';
import 'package:travixy/views/home/settings_tab.dart';
import 'package:travixy/views/home/view_pins_tab.dart';
import '../../providers/auth_provider.dart';
import '../../providers/places_provider.dart';
import '../auth/login_screen.dart';
import '../post/add_post_tab.dart';
import 'edit_profile_tab.dart';
import 'travixy_drawer.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final placesProvider = Provider.of<PlacesProvider>(context);

    return Scaffold(

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Color(0xFF775242), size: 28),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: const TravixyDrawer(),
      body:
      SingleChildScrollView( child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [

          //  Cover image + avatar (only for logged in)
          if (!authProvider.isGuestMode)
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 180,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/pic1.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  bottom: -40,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: AssetImage('assets/pic3.png'),
                      backgroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),

          // GUEST MODE UI
          if (authProvider.isGuestMode) ...[
            const SizedBox(height: 60),
            const CircleAvatar(
              radius: 60,
              backgroundColor: Color(0xFFEBE1D2),
              child: Icon(Icons.person, size: 60, color: Color.fromRGBO(86, 60, 60, 1)),
            ),
            const SizedBox(height: 20),
            const Text(
              'Guest User',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'You are browsing as a guest. Sign in or create an account to unlock all features.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Color.fromRGBO(86, 60, 60, 1)),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: 280,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB08968),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(
                      color: Color(0xFF8B6F47),
                      width: 1.5,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/signup');
                },
                child: const Text('Create an Account', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: 280,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  backgroundColor: const Color(0xFFF5F0E8),
                  foregroundColor: const Color(0xFF8B6F47),
                  side: const BorderSide(
                    color: Color(0xFF8B6F47),
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen(initialMode: AuthMode.login)),
                  );
                },
                child: const Text('Sign In', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],

          //  LOGGED IN UI
          if (!authProvider.isGuestMode) ...[
            const SizedBox(height: 56),

            // Name - NEED TO CHANGE
            Text(
              authProvider.username.isNotEmpty ? '@${authProvider.username}' : authProvider.userEmail,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold ,  color: Color.fromRGBO(86, 60, 60, 1)),
            textAlign: TextAlign.center ),
            const SizedBox(height: 8),

            // User ID
            // Text(
            //   'User ID: ${authProvider.userId.substring(0, 8)}...',
            //   style: const TextStyle(color: Colors.grey, fontSize: 13),
            // ),
            // const SizedBox(height: 16),

            // Description
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Add Description',
                textAlign: TextAlign.center,
                style: TextStyle( fontSize: 20, fontWeight: FontWeight.bold ,color: Color.fromRGBO(86, 60, 60, 1)),
              ),
            ),
            const SizedBox(height: 24),

            // Pinned places card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                child: ListTile(
                  title: const Text('Pinned Places'),
                  trailing: Text('${placesProvider.pinCount} / 5'),
                ),
              ),
            ),

            // Upgrade to premium card
            if (placesProvider.hasReachedPinLimit)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Card(
                  color: Colors.orange,
                  child: ListTile(
                    title: Text('Upgrade to Premium'),
                    subtitle: Text('Get unlimited pins and remove ads'),
                  ),
                ),
              ),

            const SizedBox(height: 24),

            // Buttons row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                //Edit profile button
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFFEBE1D2),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfilePage()));
                  },
                  child: const Text('Edit Profile', style: TextStyle(fontSize: 16, color: Color.fromRGBO(86, 60, 60, 1))),
                ),

                //View pins button
                const SizedBox(width: 12),
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFFEBE1D2),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ViewPinsPage()));
                  },
                  child: const Text('View Pins', style: TextStyle(fontSize: 16, color: Color.fromRGBO(86, 60, 60, 1))),
                ),

                const SizedBox(width: 12),

                //settings button
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFFEBE1D2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsTab()));
                  },
                  child: const Icon(Icons.settings, color: Colors.grey, size: 25),
                ),
                const SizedBox(width: 12),

                //Add post button
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFFEBE1D2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => AddPostTab()));
                  },
                  child: const Icon(Icons.add, color: Colors.grey, size: 25),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ProfileToggleTabs()
          ],
        ],
      ),
    )
    );
  }
}