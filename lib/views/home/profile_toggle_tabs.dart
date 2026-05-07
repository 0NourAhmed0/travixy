import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../providers/post_provider.dart';

class ProfileToggleTabs extends StatefulWidget {
  const ProfileToggleTabs({super.key});

  @override
  State<ProfileToggleTabs> createState() => _ProfileTabsState();
}

class _ProfileTabsState extends State<ProfileToggleTabs> {

  int _selected = 0; // 0 = Trips, 1 = Recently Viewed

  @override
  //Once the widget is on screen, get the logged-in user's ID and fetch their posts from Firestore
  void initState() {
    super.initState(); //runs once
    WidgetsBinding.instance.addPostFrameCallback((_) { //checks page is rendered
      final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
      context.read<PostProvider>().fetchUserPosts(userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Toggle buttons
        //build pill shaped row

        Container(
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(30),
          ),

          //build tap
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTab('Trips', 0 ,  icon: Icons.travel_explore , iconSize: 14),
              _buildTab('Recently Viewed', 1, icon: Icons.signpost , iconSize: 14),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Content
        if (_selected == 0)
          Consumer<PostProvider>(
            builder: (context, postProvider, _) {


              if (postProvider.isLoading) {
                return const CircularProgressIndicator();
              }

              if (postProvider.userPosts.isEmpty) {
                return const Text('No trips yet');
              }

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1, // changes size of post, bigger = smaller size
                ),
                itemCount: postProvider.userPosts.length,
                itemBuilder: (context, index) {
                  final post = postProvider.userPosts[index];
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          post.imageUrls.isNotEmpty ? post.imageUrls[0] : '',
                          fit: BoxFit.cover,
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          )
      ],
    );
  }

  Widget _buildTab(String label, int index, {IconData? icon, double iconSize = 14}) {

    final isSelected = _selected == index;

    //When tapped, updates _selected to this tab's index, triggering a rebuild to show it as active

    return GestureDetector(
      onTap: () => setState(() => _selected = index),

      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),

        //selected tab styling
        decoration: BoxDecoration(
          color: isSelected ? Color.fromRGBO(235, 225, 210,1) : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),

        child: Row(
          children: [
            if (icon != null)  //With ... it unpacks the items individually into children
              const SizedBox(width: 4),
              Icon(icon, size: iconSize, color: Color.fromRGBO(86, 60, 60, 1)),
              Text(
                label,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, color: Color.fromRGBO(86, 60, 60, 1)
                ),
              ),
            ],
        ),
      ),
    );
  }
}