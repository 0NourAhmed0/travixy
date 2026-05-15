import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:travixy/views/post/tag_bottom_sheet_tab.dart';
import '../../models/post_model.dart';
import '../../providers/post_provider.dart';

class AddPostDetailsTab extends StatefulWidget {
  final String imageUrl;

  const AddPostDetailsTab({super.key, required this.imageUrl});

  @override
  State<AddPostDetailsTab> createState() => _AddPostDetailsTabState();
}

class _AddPostDetailsTabState extends State<AddPostDetailsTab> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  bool _isSaving = false;

  List<String> _selectedTags = [];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
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
      imageUrls: [widget.imageUrl],
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
          // background image
          Positioned.fill(
            child: Image.asset(
              'assets/background.png',
              fit: BoxFit.cover,
            ),
          ),

          // back button
          Positioned(
            top: 48,
            left: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(Icons.arrow_back, color: Color(0xFF8B6F47), size: 28),
            ),
          ),

          Positioned.fill(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 100, 24, 34),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // title
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

                  // uploaded image preview
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Image.network(
                      widget.imageUrl,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // post name
                  _buildFieldLabel('Post Name'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _nameController,
                    hint: 'e.g. Sunset at Sahara',
                  ),
                  const SizedBox(height: 16),

                  _buildFieldLabel('Location'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _locationController,
                    hint: 'e.g. Cairo, Egypt',
                  ),
                  const SizedBox(height: 16),

                  // description
                  _buildFieldLabel('Description'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _descriptionController,
                    hint: 'Tell us about this place...',
                    maxLines: 4,
                  ),
                  const SizedBox(height: 32),

                  // Tag picker
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
                  //
                  // save button
                  _isSaving
                      ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF8B6F47)),
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
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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