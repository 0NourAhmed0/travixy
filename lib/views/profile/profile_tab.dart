import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travixy/providers/post_provider.dart';
import 'package:travixy/views/profile/profile_toggle_tabs.dart';
import 'package:travixy/views/profile/settings_tab.dart';
import 'package:travixy/views/home/view_pins_tab.dart';
import '../../providers/auth_provider.dart';
import '../../providers/places_provider.dart';
import '../../providers/profile_provider.dart';
import '../ai/ai_chat_screen.dart';
import '../auth/login_screen.dart';
import '../post/add_post_tab.dart';
import 'edit_profile_tab.dart';
import '../home/travixy_drawer.dart';
import '../home/upgrade_page.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      final profileProvider = context.read<ProfileProvider>();
      final postProvider = context.read<PostProvider>();
      print('🧪 isGuestMode: ${authProvider.isGuestMode}');
      print('🧪 userId: "${authProvider.userId}"');

      if (!authProvider.isGuestMode && authProvider.userId.isNotEmpty) {
        profileProvider.fetchUserProfile(authProvider.userId);
        postProvider.fetchUserStats(authProvider.userId);


      }
    });
  }

  Widget _statTile(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color.fromRGBO(86, 60, 60, 1),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color.fromRGBO(86, 60, 60, 1),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final placesProvider = Provider.of<PlacesProvider>(context);
    final profileProvider = Provider.of<ProfileProvider>(context);
    final postProvider = Provider.of<PostProvider>(context);

    return Scaffold(
        extendBodyBehindAppBar: true,
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
                SizedBox(
                  width: double.infinity,
                  height: 250,
                  child: profileProvider.user?.coverImageUrl != null
                      ? Image.network(
                    profileProvider.user!.coverImageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: const Color(0xFFEBE1D2),
                      child: const Icon(Icons.landscape, color: Color(0xFF775242), size: 48),
                    ),
                  )
                      : Container(
                    color: const Color(0xFFEBE1D2),
                    child: const Icon(Icons.landscape, color: Color(0xFF775242), size: 48),
                  ),
                ),
                Positioned(
                  bottom: -40,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: const Color.fromRGBO(86, 60, 60, 1),
                      backgroundImage: profileProvider.user?.photoUrl != null
                          ? NetworkImage(profileProvider.user!.photoUrl!)
                          : null,
                      child: profileProvider.user?.photoUrl == null
                          ? const Icon(Icons.person, size: 50, color: Colors.white)
                          : null,
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
                authProvider.username.isNotEmpty == true
                    ? '@${authProvider.username}'
                    : authProvider.userEmail,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold ,  color: Color.fromRGBO(86, 60, 60, 1)),
            textAlign: TextAlign.center ),
            if (profileProvider.isSuperUser)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF775242),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'Super User',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 8),

            // User ID
            // Text(
            //   'User ID: ${authProvider.userId.substring(0, 8)}...',
            //   style: const TextStyle(color: Colors.grey, fontSize: 13),
            // ),
             const SizedBox(height: 16),
            // Text('DEBUG count: ${profileProvider.uniquePlacesCount} | badge: ${profileProvider.badge}'),
            // Text(profileProvider.badge),
            const SizedBox(height: 16),


            // Description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: profileProvider.isLoading
                  ? const CircularProgressIndicator()
                  : Text(
                profileProvider.profileDescription ?? 'Add a description',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color.fromRGBO(86, 60, 60, 1),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              // child: Card(
              //   //color: const Color(0xFFEBE1D2),
              //   elevation: 4,
              //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              //   child: Padding(
              //     padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _statTile('Posts','${postProvider.postCount}'),
                          _statTile('Reviews', '${postProvider.reviewCount}'),
                          _statTile('Helpful', profileProvider.helpfulActivityCount.toString()),
                          _statTile('Score', profileProvider.contributionScore.toString()),
                        ],
                      ),
                    ],
                  ),
                //),
              //),
            ),


            // Pinned places card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                color: const Color(0xFFEBE1D2),
                elevation: 8,
                // margin: const EdgeInsets.symmetric(
                //   horizontal: 16,
                //   vertical: 12,
                // ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  // side: const BorderSide(
                  //   color: Colors.brown,
                  //   width: 1.5,
                  // ),
                ),
                child: ListTile(
                  title: const Text('Pinned Places' ,  style: TextStyle(
                    fontSize: 20,
                    color: Color.fromRGBO(86, 60, 60, 1),
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                  ),) ,
                  trailing: Text('${placesProvider.pinCount} / 5' ,  style: TextStyle(fontSize: 19, color: Color.fromRGBO(86, 60, 60, 1))),
                ),
              ),
            ),

            // Upgrade to premium card
            if (placesProvider.hasReachedPinLimit && !placesProvider.isPremium)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Card(
                  color: Colors.orange.shade100,
                  child: ListTile(
                    leading: const Icon(Icons.workspace_premium, color: Color(0xFF775242)),
                    title: const Text('5-pin limit reached'),
                    subtitle: const Text('Upgrade to Premium for unlimited pins and no ads.'),
                    trailing: TextButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const UpgradePage()));
                      },
                      child: const Text('Upgrade'),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 12),
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 16),
            //   child: Card(
            //     color: const Color(0xFFEBE1D2),
            //     elevation: 8,
            //     margin: const EdgeInsets.symmetric(
            //       horizontal: 16,
            //       vertical: 12,
            //     ),
            //     shape: RoundedRectangleBorder(
            //       borderRadius: BorderRadius.circular(20),
            //     ),
            //     child: ListTile(
            //       onTap: () => Navigator.push(
            //         context,
            //         MaterialPageRoute(builder: (_) => const AiChatScreen()),
            //       ),
            //       leading: const Icon(
            //         Icons.auto_awesome, // ← sparkle icon
            //         color: Color.fromRGBO(86, 60, 60, 1),
            //       ),
            //       title: const Text(
            //         'Chat with AI',
            //         style: TextStyle(
            //           fontSize: 20,
            //           color: Color.fromRGBO(86, 60, 60, 1),
            //           fontWeight: FontWeight.w500,
            //           fontFamily: 'Poppins',
            //         ),
            //       ),
            //       trailing: const Icon(
            //         Icons.chevron_right,
            //         color: Color.fromRGBO(86, 60, 60, 1),
            //       ),
            //     ),
            //   ),
            // ),

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
                  child: const Icon(Icons.settings, color: Color.fromRGBO(86, 60, 60, 1), size: 25),
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
                  child: const Icon(Icons.add, color: Color.fromRGBO(86, 60, 60, 1), size: 25),
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