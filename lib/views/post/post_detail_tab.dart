import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travixy/providers/post_provider.dart';
import 'package:video_player/video_player.dart';

import '../../models/post_model.dart';
import '../../models/review_model.dart';
import '../../providers/review_provider.dart';
import '../place/place_detail_screen.dart';
import '../profile/public_profile_screen.dart';

class PostDetailTab extends StatefulWidget {
  final PostModel post;

  const PostDetailTab({super.key, required this.post});

  @override
  State<PostDetailTab> createState() => _PostDetailTabState();
}

class _PostDetailTabState extends State<PostDetailTab> {
  static const _brown = Color.fromRGBO(86, 60, 60, 1);
  static const _cream = Color(0xFFEBE1D2);

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PostProvider>().fetchUserPost(
            widget.post.userId,
            widget.post.id,
            currentUserId: FirebaseAuth.instance.currentUser?.uid,
          );

      context.read<ReviewProvider>().fetchReviewsByPost(widget.post.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final postProvider = Provider.of<PostProvider>(context);
    final reviewProvider = Provider.of<ReviewProvider>(context);

    if (postProvider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final post = postProvider.post;

    if (post == null) {
      return const Scaffold(
        body: Center(child: Text('Post not found')),
      );
    }

    final placeId = post.placeId;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            _MediaCarousel(
              imageUrls: post.imageUrls,
              videoUrl: post.videoUrl,
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          post.name,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w600,
                            color: _brown,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                      const Icon(Icons.push_pin, color: _brown, size: 22),
                      const SizedBox(width: 4),
                      const Text(
                        'Pin',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: _brown,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  Row(
                    children: [
                      const Icon(Icons.location_pin, color: _brown, size: 18),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          post.location,
                          style: const TextStyle(
                            fontSize: 15,
                            color: _brown,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  if (placeId != null && placeId.isNotEmpty) ...[
                    SizedBox(
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
                              builder: (_) => PlaceDetailScreen(placeId: placeId),
                            ),
                          );
                        },
                        icon: const Icon(Icons.place),
                        label: const Text('View Place Details'),
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],

                  FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('users')
                        .doc(post.userId)
                        .get(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _cream,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _brown.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: const SizedBox(
                            height: 60,
                            child: Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                          ),
                        );
                      }

                      final userData =
                          snapshot.data?.data() as Map<String, dynamic>?;

                      final username =
                          userData?['username'] as String? ?? 'Anonymous';

                      final photoUrl = userData?['photoUrl'] as String?;

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  PublicProfileScreen(userId: post.userId),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _cream,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _brown.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: _brown,
                                backgroundImage:
                                    photoUrl != null ? NetworkImage(photoUrl) : null,
                                child: photoUrl == null
                                    ? const Icon(Icons.person, color: Colors.white)
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '@$username',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: _brown,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                    Text(
                                      'View profile',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: _brown.withOpacity(0.6),
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.chevron_right,
                                color: _brown.withOpacity(0.5),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: _cream,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _brown.withOpacity(0.25),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded, size: 20, color: _brown),
                        const SizedBox(width: 6),
                        Text(
                          post.reviewCount == 0
                              ? '0.0'
                              : post.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: _brown,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(${post.reviewCount} reviews)',
                          style: TextStyle(
                            fontSize: 13,
                            color: _brown.withOpacity(0.5),
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    post.description,
                    style: TextStyle(
                      fontSize: 15,
                      color: _brown.withOpacity(0.85),
                      height: 1.6,
                      fontFamily: 'Poppins',
                    ),
                  ),

                  const SizedBox(height: 20),

                  if (post.tags.isNotEmpty) ...[
                    const Text(
                      'Tags',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: _brown,
                        fontFamily: 'Poppins',
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: post.tags.map((label) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _cream,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _brown.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            label,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: _brown,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                  ],

                  const SizedBox(height: 24),

                  Divider(color: _brown.withOpacity(0.3), thickness: 1.5),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      const Text(
                        'Reviews',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: _brown,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {
                          _openReviewSheet();
                        },
                        icon: const Icon(Icons.add, size: 32),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  if (reviewProvider.isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (reviewProvider.error != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        reviewProvider.error!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.redAccent,
                        ),
                      ),
                    )
                  else if (reviewProvider.reviews.isNotEmpty)
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: reviewProvider.reviews.length,
                      itemBuilder: (context, index) {
                        final review = reviewProvider.reviews[index];
                        final currentUserId =
                            FirebaseAuth.instance.currentUser?.uid;

                        final canManageReview =
                            currentUserId != null &&
                            currentUserId == review.userId;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _cream,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _brown.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const CircleAvatar(
                                    radius: 16,
                                    backgroundColor: _brown,
                                    child: Icon(
                                      Icons.person,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    review.username,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: _brown,
                                    ),
                                  ),
                                  const Spacer(),
                                  if (canManageReview)
                                    PopupMenuButton<String>(
                                      icon: const Icon(
                                        Icons.more_vert,
                                        color: _brown,
                                      ),
                                      onSelected: (value) {
                                        if (value == 'edit') {
                                          _openReviewSheet(review: review);
                                        } else if (value == 'delete') {
                                          _confirmDeleteReview(review);
                                        }
                                      },
                                      itemBuilder: (context) => const [
                                        PopupMenuItem(
                                          value: 'edit',
                                          child: Text('Edit review'),
                                        ),
                                        PopupMenuItem(
                                          value: 'delete',
                                          child: Text('Delete review'),
                                        ),
                                      ],
                                    )
                                  else
                                    Row(
                                      children: List.generate(
                                        5,
                                        (i) => Icon(
                                          i < review.rating
                                              ? Icons.star
                                              : Icons.star_border,
                                          color: _brown,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              if (canManageReview) ...[
                                const SizedBox(height: 8),
                                Row(
                                  children: List.generate(
                                    5,
                                    (i) => Icon(
                                      i < review.rating
                                          ? Icons.star
                                          : Icons.star_border,
                                      color: _brown,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ],
                              if (review.review != null &&
                                  review.review!.isNotEmpty) ...[
                                const SizedBox(height: 10),
                                Text(
                                  review.review!,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    )
                  else
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          'No reviews yet',
                          style: TextStyle(
                            fontSize: 16,
                            color: _brown,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openReviewSheet({ReviewModel? review}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) => _ReviewSheet(
        postId: widget.post.id,
        review: review,
      ),
    );
  }

  Future<void> _confirmDeleteReview(ReviewModel review) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete review?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete != true || !mounted) return;

    await context.read<ReviewProvider>().deleteReview(
          reviewId: review.id,
          postId: widget.post.id,
        );
  }
}

class _ReviewSheet extends StatefulWidget {
  final String postId;
  final ReviewModel? review;

  const _ReviewSheet({
    required this.postId,
    this.review,
  });

  @override
  State<_ReviewSheet> createState() => _ReviewSheetState();
}

class _ReviewSheetState extends State<_ReviewSheet> {
  late int _rating;
  late final TextEditingController _reviewController;

  @override
  void initState() {
    super.initState();
    _rating = widget.review?.rating ?? 0;
    _reviewController = TextEditingController(
      text: widget.review?.review ?? '',
    );
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a rating')),
      );
      return;
    }

    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();

    final username = userDoc.data()?['username'] ?? 'Anonymous';

    if (!mounted) return;

    final reviewText = _reviewController.text.trim();

    if (widget.review == null) {
      await context.read<ReviewProvider>().addReview(
            postId: widget.postId,
            userId: userId,
            username: username,
            rating: _rating,
            review: reviewText.isEmpty ? null : reviewText,
          );

      context.read<PostProvider>().fetchUserStats(userId);
    } else {
      await context.read<ReviewProvider>().editReview(
            reviewId: widget.review!.id,
            postId: widget.postId,
            userId: userId,
            username: username,
            rating: _rating,
            review: reviewText.isEmpty ? null : reviewText,
          );
    }

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.review == null ? 'Add Review' : 'Edit Review',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          const Text(
            'Rating',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),

          const SizedBox(height: 8),

          Row(
            children: List.generate(5, (index) {
              return GestureDetector(
                onTap: () => setState(() => _rating = index + 1),
                child: Icon(
                  index < _rating ? Icons.star : Icons.star_border,
                  color: const Color.fromRGBO(86, 60, 60, 1),
                  size: 36,
                ),
              );
            }),
          ),

          const SizedBox(height: 16),

          const Text(
            'Review (optional)',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),

          const SizedBox(height: 8),

          TextField(
            controller: _reviewController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Write your review...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFFEBE1D2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: _submitReview,
              child: const Text(
                'Submit',
                style: TextStyle(
                  fontSize: 16,
                  color: Color.fromRGBO(86, 60, 60, 1),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MediaCarousel extends StatefulWidget {
  final List<String> imageUrls;
  final String? videoUrl;

  const _MediaCarousel({
    required this.imageUrls,
    this.videoUrl,
  });

  @override
  State<_MediaCarousel> createState() => _MediaCarouselState();
}

class _MediaCarouselState extends State<_MediaCarousel> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  VideoPlayerController? _videoController;

  List<String> get _allMedia => [
        ...widget.imageUrls,
        if (widget.videoUrl != null) widget.videoUrl!,
      ];

  bool _isVideo(String url) => widget.videoUrl == url;

  @override
  void initState() {
    super.initState();

    if (widget.videoUrl != null) {
      _videoController =
          VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl!))
            ..initialize().then((_) {
              if (mounted) setState(() {});
            });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_allMedia.isEmpty) {
      return SizedBox(
        height: 400,
        child: _imageFallback(),
      );
    }

    return SizedBox(
      height: 400,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _allMedia.length,
            onPageChanged: (i) {
              setState(() => _currentPage = i);

              if (!_isVideo(_allMedia[i])) {
                _videoController?.pause();
              }
            },
            itemBuilder: (context, index) {
              final url = _allMedia[index];

              if (_isVideo(url)) {
                return _videoController != null &&
                        _videoController!.value.isInitialized
                    ? GestureDetector(
                        onTap: () {
                          setState(() {
                            _videoController!.value.isPlaying
                                ? _videoController!.pause()
                                : _videoController!.play();
                          });
                        },
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            FittedBox(
                              fit: BoxFit.cover,
                              child: SizedBox(
                                width: _videoController!.value.size.width,
                                height: _videoController!.value.size.height,
                                child: VideoPlayer(_videoController!),
                              ),
                            ),
                            Center(
                              child: Icon(
                                _videoController!.value.isPlaying
                                    ? Icons.pause_circle
                                    : Icons.play_circle,
                                color: Colors.white70,
                                size: 56,
                              ),
                            ),
                          ],
                        ),
                      )
                    : const Center(child: CircularProgressIndicator());
              }

              return Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _imageFallback(),
              );
            },
          ),

          if (_allMedia.length > 1)
            Positioned(
              bottom: 12,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_allMedia.length, (i) {
                  final isVideo =
                      widget.videoUrl != null && i == _allMedia.length - 1;

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == i ? 20 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == i ? Colors.white : Colors.white54,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: isVideo && _currentPage == i
                        ? const Icon(
                            Icons.videocam,
                            size: 6,
                            color: Colors.white,
                          )
                        : null,
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }

  Widget _imageFallback() {
    return Container(
      color: const Color(0xFFE8DDD2),
      child: const Center(
        child: Icon(Icons.image, color: Colors.grey, size: 60),
      ),
    );
  }
}