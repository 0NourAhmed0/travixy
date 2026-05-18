import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/notification_provider.dart';
import '../notifications/notifications_screen.dart';

import '../../constants/post_tags.dart';
import '../../models/post_model.dart';
import '../../providers/post_provider.dart';
import '../post/post_detail_tab.dart';
import 'travixy_drawer.dart';

class ExploreTab extends StatefulWidget {
  const ExploreTab({super.key});

  @override
  State<ExploreTab> createState() => _ExploreTabState();
}

class _ExploreTabState extends State<ExploreTab> {
  static const Color _brown = Color(0xFF775242);
  static const Color _surface = Color(0xFFF6EBDD);

  final Set<String> _superUserIds = {};
  final List<String> _userPreferences = [];
  final Set<String> _normalizedPreferenceTags = {};

  bool _loadingRankingData = true;

  //sponteneity mode
  bool _spontaneityMode = false ;

  bool _initialized = false;


  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_initialized) {
        _initialized = true;
        _loadHomeData();
      }
    });
  }

  // Future<void> _loadHomeData() async {
  //   final postProvider = context.read<PostProvider>();
  //
  //   await postProvider.fetchAllPosts();
  //
  //   await _loadUserPreferences();
  //   await _loadSuperUsers(postProvider.posts);
  //
  //   if (mounted) {
  //     setState(() {
  //       _loadingRankingData = false;
  //     });
  //   }
 // }

  Future<void> _loadHomeData() async {
    if (!mounted) return;
    setState(() => _loadingRankingData = true); // must be FIRST

    final postProvider = context.read<PostProvider>();
    await postProvider.fetchAllPosts();

    if (!_spontaneityMode) {
      await _loadUserPreferences();
    } else {
      // Explicitly wipe in case stale tags remain from a previous session
      _normalizedPreferenceTags.clear();
      _userPreferences.clear();
    }

    await _loadSuperUsers(postProvider.posts);

    if (mounted) setState(() => _loadingRankingData = false);
  }

  Future<void> _loadUserPreferences() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    final data = userDoc.data();
    if (data == null) return;

    final preferencesMap = data['preferences'];
    List<String> rawInterests = [];

    if (preferencesMap is Map) {
      final interests = preferencesMap['interests'];
      if (interests is List) {
        rawInterests = interests.map((e) => e.toString()).toList();
      }

      final travelStyle = preferencesMap['travelStyle'];
      if (travelStyle is String && travelStyle.isNotEmpty) {
        rawInterests.add(travelStyle);
      }

      final budget = preferencesMap['budget'];
      if (budget is String && budget.isNotEmpty) {
        rawInterests.add(budget);
      }
    } else if (preferencesMap is List) {
      rawInterests = preferencesMap.map((e) => e.toString()).toList();
    }

   // print(' DEBUG rawInterests: $rawInterests');

    _userPreferences
      ..clear()
      ..addAll(rawInterests);

    _normalizedPreferenceTags
      ..clear()
      ..addAll(
        _userPreferences.expand(
                (pref) => PostTags.expandPreferenceToTagLabels(pref) // ← pass as-is first
        ).map((tag) => tag.toLowerCase()),
      );

  //  print(' DEBUG _normalizedPreferenceTags: $_normalizedPreferenceTags');
  }



  Future<void> _loadSuperUsers(List<PostModel> posts) async {
    _superUserIds.clear();

    final uniqueUserIds = posts.map((post) => post.userId).toSet();

    for (final userId in uniqueUserIds) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      final data = userDoc.data();
      if (data == null) continue;

      final isSuperUser =
          data['isSuperUser'] == true || data['superUser'] == true;

      if (isSuperUser) {
        _superUserIds.add(userId);
      }
    }
  }

  // bool _matchesPreferences(PostModel post) {
  //   if (_normalizedPreferenceTags.isEmpty) return false;
  //
  //   final postTags = post.tags.map((tag) => tag.toLowerCase()).toSet();
  //
  //   return _normalizedPreferenceTags.any(
  //     postTags.contains,
  //   );
  // }

  bool _matchesPreferences(PostModel post) {
    if (_normalizedPreferenceTags.isEmpty) return false;

    final postTags = post.tags.map((tag) => tag.toLowerCase()).toSet();

   // print('🔍 DEBUG post "${post.name}": postTags=$postTags | preferenceTags=$_normalizedPreferenceTags');

    return _normalizedPreferenceTags.any(postTags.contains);
  }

  bool _isSuperUserPost(PostModel post) {
    return _superUserIds.contains(post.userId);
  }

  int _priorityScore(PostModel post) {
    final isSuper = _isSuperUserPost(post);
    final matchesPrefs = _matchesPreferences(post);

    int score = 0;

    if (isSuper && matchesPrefs) score += 400;
    else if (isSuper) score += 300;
    else if (matchesPrefs) score += 200;
    else score += 100;

    score += (post.rating * 10).round();
    score += post.reviewCount;

    return score;
  }

  List<PostModel> _rankPosts(List<PostModel> posts) {
    final ranked = [...posts];

    ranked.sort((a, b) {
      return _priorityScore(b).compareTo(_priorityScore(a));
    });

    return ranked;
  }

  String _badgeText(PostModel post) {
    final isSuper = _isSuperUserPost(post);
    final matchesPrefs = _matchesPreferences(post);

    if (isSuper && matchesPrefs) return 'Top pick for you';
    if (isSuper) return 'Super user pick';
    if (matchesPrefs) return 'Matches your style';
    return 'Explore';
  }

  @override
  Widget build(BuildContext context) {
    final postProvider = context.watch<PostProvider>();
    final rankedPosts = _rankPosts(postProvider.posts);

    final topPicks = rankedPosts.take(5).toList();
    final superUserPosts =
        rankedPosts.where((post) => _isSuperUserPost(post)).toList();
    final preferencePosts =
        rankedPosts.where((post) => _matchesPreferences(post)).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Travixy'),
        backgroundColor: _surface,
        foregroundColor: _brown,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Color.fromRGBO(86, 60, 60, 1),),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, notificationProvider, _) {
              return IconButton(
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(
                      Icons.notifications_none_rounded,
                      color: Color.fromRGBO(86, 60, 60, 1),
                      size: 30,
                    ),
                    if (notificationProvider.unreadCount > 0)
                      Positioned(
                        right: -2,
                        top: -4,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            color: Color(0xFFC9673B),
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            notificationProvider.unreadCount > 9
                                ? '9+'
                                : '${notificationProvider.unreadCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NotificationScreen(),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      drawer: const TravixyDrawer(),
      body: RefreshIndicator(
        onRefresh: _loadHomeData,
        child: _loadingRankingData && rankedPosts.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : rankedPosts.isEmpty
                ? _emptyState()
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      const Text(
                        'Explore like a local',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(86, 60, 60, 1),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Hidden gems, local tips, and trusted recommendations.',
                        style: TextStyle(color: Color.fromRGBO(86, 60, 60, 1), fontWeight: FontWeight.w600 , fontSize: 17),
                      ),
                      const SizedBox(height: 20),

                     // _sectionTitle('Recommended first'),

                      ListTile(
                          leading:  Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                              child: Text(
                                !_spontaneityMode
                                    ? 'Recommended first'
                                    : 'Spontaneity mode' ,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromRGBO(86, 60, 60, 1),
                                ),
                              ),
                            ),
                        trailing:   GestureDetector(
                          onTap: () async {
                            setState(() {
                              _spontaneityMode = !_spontaneityMode;
                              if (_spontaneityMode) {
                                // Clear immediately so UI responds before reload
                                _normalizedPreferenceTags.clear();
                                _userPreferences.clear();
                              }
                            });

                            await _loadHomeData();
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 70,
                            height: 35,
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: _spontaneityMode
                                  ? Color.fromRGBO(86, 60, 60, 1)   // ON background
                                  : const Color(0xFFE0E0E0),  // OFF background
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Align(
                              alignment:
                              _spontaneityMode ? Alignment.centerRight : Alignment.centerLeft,
                              child: Container(
                                width: 27,
                                height: 27,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFFFFF), // circle color
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                     ),

                      _horizontalPosts(topPicks),

                      if (superUserPosts.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        _sectionTitle('Super user picks'),
                        _horizontalPosts(superUserPosts.take(5).toList()),
                      ],

                      if (preferencePosts.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        _sectionTitle('Based on your preferences'),
                        _horizontalPosts(preferencePosts.take(5).toList()),
                      ],

                      const SizedBox(height: 24),
                      _sectionTitle('All local posts'),
                      const SizedBox(height: 8),

                      ...rankedPosts.map((post) {
                        return _LargePostCard(
                          post: post,
                          badge: _badgeText(post),
                        );
                      }),
                    ],
                  ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color.fromRGBO(86, 60, 60, 1),
        ),
      ),
    );
  }

  Widget _horizontalPosts(List<PostModel> posts) {
    return SizedBox(
      height: 280,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: posts.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final post = posts[index];

          return SizedBox(
            width: 190,
            child: _SmallPostCard(
              post: post,
              badge: _badgeText(post),
            ),
          );
        },
      ),
    );
  }

  Widget _emptyState() {
    return ListView(
      padding: const EdgeInsets.all(32),
      children: const [
        SizedBox(height: 120),
        Icon(Icons.place_outlined, size: 70, color: Color.fromRGBO(86, 60, 60, 1),),
        SizedBox(height: 16),
        Center(
          child: Text(
            'No posts yet',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(height: 8),
        Center(
          child: Text(
            'When users add local places, they will appear here.',
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

class _SmallPostCard extends StatelessWidget {
  final PostModel post;
  final String badge;

  const _SmallPostCard({
    required this.post,
    required this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return _PostCardShell(
      post: post,
      badge: badge,
      compact: true,
    );
  }
}

class _LargePostCard extends StatelessWidget {
  final PostModel post;
  final String badge;

  const _LargePostCard({
    required this.post,
    required this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: _PostCardShell(
        post: post,
        badge: badge,
        compact: false,
      ),
    );
  }
}

class _PostCardShell extends StatelessWidget {
  static const Color _brown = Color(0xFF775242);
  static const Color _cream = Color(0xFFF7F1EA);

  final PostModel post;
  final String badge;
  final bool compact;

  const _PostCardShell({
    required this.post,
    required this.badge,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    final imageHeight = compact ? 115.0 : 190.0;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PostDetailTab(post: post),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(18)),
              child: post.imageUrls.isNotEmpty
                  ? Image.network(
                      post.imageUrls.first,
                      height: imageHeight,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _fallbackImage(imageHeight),
                    )
                  : _fallbackImage(imageHeight),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: _cream,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      badge,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color.fromRGBO(86, 60, 60, 1),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    post.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: compact ? 14 : 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    post.location,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    post.description,
                    maxLines: compact ? 2 : 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  if (!compact)
                    Row(
                      children: [
                        const Icon(Icons.star, size: 15, color: Colors.amber),
                        const SizedBox(width: 3),
                        Text(
                          post.rating.toStringAsFixed(1),
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${post.reviewCount} reviews',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fallbackImage(double height) {
    return Container(
      height: height,
      width: double.infinity,
      color: const Color(0xFFE8DDD2),
      child: const Icon(Icons.image, color: Colors.grey, size: 40),
    );
  }
}