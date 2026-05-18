import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../providers/post_provider.dart';
import '../post/post_detail_tab.dart';

class ProfileToggleTabs extends StatefulWidget {
  const ProfileToggleTabs({super.key});

  @override
  State<ProfileToggleTabs> createState() => _ProfileTabsState();
}

class _ProfileTabsState extends State<ProfileToggleTabs> {
  int _selected = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
     // print(' ProfileToggleTabs userId: $userId');
      context.read<PostProvider>().fetchUserPosts(userId, currentUserId: userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTab('Trips', 0, icon: Icons.travel_explore, iconSize: 14),
              _buildTab('Recently Viewed', 1, icon: Icons.signpost, iconSize: 14),
            ],
          ),
        ),

        Consumer<PostProvider>(
          builder: (context, postProvider, _) {
            if (postProvider.isLoading) {
              return const Padding(
                padding: EdgeInsets.only(top: 24),
                child: CircularProgressIndicator(),
              );
            }

            final posts = _selected == 0
                ? postProvider.userPosts
                .where((post) => post.userId == currentUserId)
                .toList()
                : postProvider.recentlyViewed;

            if (posts.isEmpty) {
              return Padding(
                padding: const EdgeInsets.only(top: 32),
                child: Text(
                  _selected == 0 ? 'No trips yet' : 'Nothing viewed yet',
                  style: const TextStyle(color: Color.fromRGBO(86, 60, 60, 1)),
                ),
              );
            }

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.only(top: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1,
              ),
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PostDetailTab(post: post),
                      ),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: post.imageUrls.isNotEmpty
                        ? Image.network(
                      post.imageUrls[0],
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFFEBE1D2),
                        child: const Icon(Icons.image, color: Colors.grey),
                      ),
                    )
                        : Container(
                      color: const Color(0xFFEBE1D2),
                      child: const Icon(Icons.image, color: Colors.grey),
                    ),
                  ),
                );
              },
            );
          },
        ),
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
          color: isSelected ? const Color.fromRGBO(235, 225, 210, 1) : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: iconSize, color: const Color.fromRGBO(86, 60, 60, 1)),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: const Color.fromRGBO(86, 60, 60, 1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}