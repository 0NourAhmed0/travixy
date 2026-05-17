import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travixy/providers/post_provider.dart';

import '../../models/post_model.dart';
import '../../providers/review_provider.dart';
import '../place/place_detail_screen.dart';

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

            SizedBox(
              width: MediaQuery.widthOf(context),
              height: 400,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: post.imageUrls.isNotEmpty
                    ? Image.network(
                        post.imageUrls[0],
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _imageFallback(),
                      )
                    : _imageFallback(),
              ),
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
                              ? '5.0'
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
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(20),
                              ),
                            ),
                            builder: (context) =>
                                _AddReviewSheet(postId: post.id),
                          );
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

  Widget _imageFallback() {
    return Container(
      color: const Color(0xFFE8DDD2),
      child: const Center(
        child: Icon(Icons.image, color: Colors.grey, size: 60),
      ),
    );
  }
}

class _AddReviewSheet extends StatefulWidget {
  final String postId;

  const _AddReviewSheet({required this.postId});

  @override
  State<_AddReviewSheet> createState() => _AddReviewSheetState();
}

class _AddReviewSheetState extends State<_AddReviewSheet> {
  int _rating = 0;
  final TextEditingController _reviewController = TextEditingController();

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

    await context.read<ReviewProvider>().addReview(
          postId: widget.postId,
          userId: userId,
          username: username,
          rating: _rating,
          review: _reviewController.text.trim().isEmpty
              ? null
              : _reviewController.text.trim(),
        );

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
          const Text(
            'Add Review',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                  color: Color.fromRGBO(86, 60, 60, 1),
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
                backgroundColor: Color(0xFFEBE1D2),
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