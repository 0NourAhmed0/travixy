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
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Toggle buttons
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(30),
          ),

          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTab('Trips', 0),
              _buildTab(icon: Icons.panorama_fisheye ,'Recently Viewed', 1, iconSize: 14),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Content
        if (_selected == 0)
          Consumer<PostProvider>(
            builder: (context, postProvider, _) {
              // fetch on first load
              WidgetsBinding.instance.addPostFrameCallback((_) {
                final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
                if (postProvider.userPosts.isEmpty) {
                  postProvider.fetchUserPosts(userId);
                }
              });

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
                  childAspectRatio: 1, // 👈 adjust this value
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
                        //Positioned(
                        //   bottom: 0,
                        //   left: 0,
                        //   right: 0,
                          // child: Container(
                          //   padding: const EdgeInsets.all(8),
                          //   color: Colors.black45,
                          //   child: Text(
                          //     post.name,
                          //     style: const TextStyle(color: Colors.white, fontSize: 12),
                          //     overflow: TextOverflow.ellipsis,
                          //   ),
                          // ),
                        //),
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
    return GestureDetector(
      onTap: () => setState(() => _selected = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
            if (icon != null) ...[
              const SizedBox(width: 4),
              Icon(icon, size: iconSize, color: Colors.black),
            ],
          ],
        ),
      ),
    );
  }
}