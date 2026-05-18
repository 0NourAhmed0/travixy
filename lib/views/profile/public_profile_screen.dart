import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../providers/post_provider.dart';
import '../../models/post_model.dart';
import '../../services/profile_services.dart';
import '../chat/chat_screen.dart';
import '../post/post_detail_tab.dart';

class PublicProfileScreen extends StatefulWidget {
  final String userId;

  const PublicProfileScreen({
    super.key,
    required this.userId,
  });

  @override
  State<PublicProfileScreen> createState() => _PublicProfileScreenState();
}

class _PublicProfileScreenState extends State<PublicProfileScreen> {
  final ProfileService _profileService = ProfileService();
  UserModel? _user;
  List<PostModel> _userPosts = [];
  bool _isLoading = true;
  String? _error;
  TravelerBadge _badge = TravelerBadge.none;

  static const _brown = Color.fromRGBO(86, 60, 60, 1);
  static const _cream = Color(0xFFEBE1D2);

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final results = await Future.wait([
        _profileService.fetchUserProfile(widget.userId),
        _profileService.fetchUniquePlacesCount(widget.userId),
      ]);

      final user = results[0] as UserModel?;
      final uniquePlacesCount = results[1] as int;

      if (!mounted) return;

      setState(() {
        _user = user;
        _badge = _profileService.resolveBadge(uniquePlacesCount);
        _isLoading = false;
      });

      if (user != null) {
        await _loadUserPosts();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadUserPosts() async {
    try {
      final postProvider = context.read<PostProvider>();
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      await postProvider.fetchUserPosts(widget.userId, currentUserId: currentUserId);

      if (mounted) {
        setState(() {
          _userPosts = postProvider.userPosts;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
        });
      }
    }
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
              color: _brown,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: _brown,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: Center(
          child: Text('Error: ${_error ?? "User not found"}'),
        ),
      );
    }

    final user = _user!;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Cover image + avatar + badge
            Stack(
              clipBehavior: Clip.none,
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 250,
                  child: user.coverImageUrl != null
                      ? Image.network(
                    user.coverImageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: _cream,
                      child: const Icon(Icons.landscape, color: Color(0xFF775242), size: 48),
                    ),
                  )
                      : Container(
                    color: _cream,
                    child: const Icon(Icons.landscape, color: Color(0xFF775242), size: 48),
                  ),
                ),

                // Avatar
                Positioned(
                  bottom: -40,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: CircleAvatar(
                      radius: 55,
                      backgroundColor: _brown,
                      backgroundImage: user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
                      child: user.photoUrl == null
                          ? const Icon(Icons.person, size: 50, color: Colors.white)
                          : null,
                    ),
                  ),
                ),

                // Badge chip
                if (_badge != TravelerBadge.none)
                  Positioned(
                    bottom: -18,
                    left: 9,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: _brown,
                        borderRadius: BorderRadius.circular(999),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        '⛨ ${_badge.label}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 56),

            // Username + super user star
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '@${user.username}',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: _brown,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (user.isSuperUser) ...[
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('⭐ Super User — trusted community contributor'),
                          duration: Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    child: const Icon(
                      Icons.star_rounded,
                      color: Color(0xFF775242),
                      size: 26,
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 8),

            // Description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                user.profileDescription ?? 'No description',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: _brown,
                ),
              ),
            ),

            // Stats row — same as ProfileTab
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _statTile('Posts', user.postCount.toString()),
                  _statTile('Reviews', user.reviewCount.toString()),
                  _statTile('Helpful', user.helpfulActivityCount.toString()),
                  _statTile('Score', user.contributionScore.toString()),
                ],
              ),
            ),

            // Message button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _brown,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatScreen(
                          receiverId: user.id,
                          receiverName: user.username,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: const Text('Message User'),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Posts grid — same as ProfileTab trips grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Posts (${_userPosts.length})',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _brown,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            if (_userPosts.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Text(
                  'No posts yet',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(top: 8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1,
                  ),
                  itemCount: _userPosts.length,
                  itemBuilder: (context, index) {
                    final post = _userPosts[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PostDetailTab(post: post),
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
                            color: _cream,
                            child: const Icon(Icons.image, color: Colors.grey),
                          ),
                        )
                            : Container(
                          color: _cream,
                          child: const Icon(Icons.image, color: Colors.grey),
                        ),
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}