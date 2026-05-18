// lib/views/post/add_post_details_tab.dart
//
// Changes from original:
//  1. Constructor: imageUrl (String) → imageUrls (List<String>) + videoUrl (String?)
//  2. Image preview: shows first image (or video thumbnail if no images)
//  3. PostModel creation: passes imageUrls and videoUrl
//  ALL other fields, logic, styling, tag picker — completely unchanged

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:video_player/video_player.dart';
import '../../models/post_model.dart';
import '../../providers/post_provider.dart';
import './tag_bottom_sheet_tab.dart';

class AddPostDetailsTab extends StatefulWidget {
  final List<String> imageUrls; // ← changed from single imageUrl
  final String? videoUrl;       // ← NEW

  const AddPostDetailsTab({
    super.key,
    required this.imageUrls,
    this.videoUrl,
  });

  @override
  State<AddPostDetailsTab> createState() => _AddPostDetailsTabState();
}

class _AddPostDetailsTabState extends State<AddPostDetailsTab> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  bool _isSaving = false;
  List<String> _selectedTags = [];

  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    // Init video preview if no images but video exists
    if (widget.imageUrls.isEmpty && widget.videoUrl != null) {
      _videoController =
      VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl!))
        ..initialize().then((_) => setState(() {}));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _savePost() async {
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();

    if (name.isEmpty) {
      _showErrorSnackbar('Please enter a post name');
      return;
    }
    if (description.isEmpty) {
      _showErrorSnackbar('Please enter a description');
      return;
    }

    setState(() => _isSaving = true);

    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    final post = PostModel(
      id: '',
      userId: userId,
      name: name,
      location: _locationController.text.trim(),
      imageUrls: widget.imageUrls,   // ← list of uploaded image URLs
      videoUrl: widget.videoUrl,     // ← optional video URL
      description: description,
      postDate: DateTime.now(),
      rating: 0.0,
      reviewCount: 0,
      tags: _selectedTags,
    );

    try {
      await context.read<PostProvider>().createPost(post);
      if (!mounted) return;
      Navigator.popUntil(context, (route) => route.isFirst);
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackbar('Failed to save post: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // background image — unchanged
          Positioned.fill(
            child: Image.asset(
              'assets/background.png',
              fit: BoxFit.cover,
            ),
          ),

          // back button — unchanged
          Positioned(
            top: 48,
            left: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(Icons.arrow_back,
                  color: Color(0xFF8B6F47), size: 28),
            ),
          ),

          Positioned.fill(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 100, 24, 34),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // title — unchanged
                  const Text(
                    'Post Details',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w500,
                      color: Color.fromRGBO(37, 24, 15, 1),
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Fill in the details for your post',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color.fromRGBO(37, 24, 15, 0.6),
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Media preview ────────────────────────────
                  // Shows first image, or video if no images
                  if (widget.imageUrls.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image.network(
                        widget.imageUrls[0],
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    )
                  else if (widget.videoUrl != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: _videoController != null &&
                          _videoController!.value.isInitialized
                          ? AspectRatio(
                        aspectRatio:
                        _videoController!.value.aspectRatio,
                        child: VideoPlayer(_videoController!),
                      )
                          : Container(
                        height: 200,
                        color: Colors.black12,
                        child: const Center(
                            child: CircularProgressIndicator()),
                      ),
                    ),

                  // Image count badge
                  if (widget.imageUrls.length > 1) ...[
                    const SizedBox(height: 8),
                    Text(
                      '+ ${widget.imageUrls.length - 1} more photo${widget.imageUrls.length > 2 ? 's' : ''}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color.fromRGBO(37, 24, 15, 0.5),
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],

                  if (widget.videoUrl != null && widget.imageUrls.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    const Row(
                      children: [
                        Icon(Icons.videocam,
                            size: 14,
                            color: Color.fromRGBO(37, 24, 15, 0.5)),
                        SizedBox(width: 4),
                        Text(
                          '1 video attached',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color.fromRGBO(37, 24, 15, 0.5),
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 24),

                  // post name — unchanged
                  _buildFieldLabel('Post Name'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _nameController,
                    hint: 'e.g. Sunset at Sahara',
                  ),
                  const SizedBox(height: 16),

                  // location — unchanged
                  _buildFieldLabel('Location'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _locationController,
                    hint: 'e.g. Cairo, Egypt',
                  ),
                  const SizedBox(height: 16),

                  // description — unchanged
                  _buildFieldLabel('Description'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _descriptionController,
                    hint: 'Tell us about this place...',
                    maxLines: 4,
                  ),
                  const SizedBox(height: 24),

                  // tag picker — unchanged
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(205, 189, 175, 0.3),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: const Color.fromRGBO(119, 82, 66, 0.22),
                        width: 1.2,
                      ),
                    ),
                    child: PostTagPicker(
                      selectedTags: _selectedTags,
                      onChanged: (tags) =>
                          setState(() => _selectedTags = tags),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // save button — unchanged
                  _isSaving
                      ? const Center(
                    child: CircularProgressIndicator(
                        color: Color(0xFF8B6F47)),
                  )
                      : SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _savePost,
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
                        elevation: 0,
                      ),
                      child: const Text(
                        'Share Post',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Color.fromRGBO(37, 24, 15, 0.8),
        fontFamily: 'Poppins',
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    String hint = '',
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromRGBO(205, 189, 175, 0.4),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color.fromRGBO(119, 82, 66, 0.32),
          width: 1.2,
        ),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            color: Color.fromRGBO(37, 24, 15, 0.3),
            fontFamily: 'Poppins',
          ),
          border: InputBorder.none,
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14,
          color: Color.fromRGBO(37, 24, 15, 1),
        ),
      ),
    );
  }
}