import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:video_player/video_player.dart';

import '../../models/post_model.dart';
import '../../providers/post_provider.dart';
import '../../providers/places_provider.dart';
import './tag_bottom_sheet_tab.dart';
import './location_picker_screen.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';

class AddPostDetailsTab extends StatefulWidget {
  final List<String> imageUrls;
  final String? videoUrl;

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
  final _placeNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();

  double? _selectedLatitude;
  double? _selectedLongitude;

  bool _isSaving = false;
  List<String> _selectedTags = [];

  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();

    if (widget.imageUrls.isEmpty && widget.videoUrl != null) {
      _videoController =
          VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl!))
            ..initialize().then((_) {
              if (mounted) setState(() {});
            });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _placeNameController.dispose();
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
      ),
    );
  }

  Future<void> _openLocationPicker() async {
    LatLng? initial;

    if (_selectedLatitude != null && _selectedLongitude != null) {
      initial = LatLng(_selectedLatitude!, _selectedLongitude!);
    } else if (_locationController.text.trim().isNotEmpty) {
      try {
        final locations = await locationFromAddress(_locationController.text.trim());
        if (locations.isNotEmpty) {
          final loc = locations.first;
          initial = LatLng(loc.latitude, loc.longitude);
        }
      } catch (_) {
        // ignore geocoding failures and fall back to current location in picker
      }
    }

    if (!mounted) return;

    final result = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        builder: (context) => LocationPickerScreen(initialLocation: initial),
      ),
    );

    if (result != null) {
      setState(() {
        _locationController.text = result['address'] as String;
        _selectedLatitude = (result['latitude'] as num?)?.toDouble();
        _selectedLongitude = (result['longitude'] as num?)?.toDouble();
      });
    }
  }

  Future<void> _savePost() async {
    final name = _nameController.text.trim();
    final placeName = _placeNameController.text.trim();
    final location = _locationController.text.trim();
    final description = _descriptionController.text.trim();

    if (name.isEmpty) {
      _showErrorSnackbar('Please enter a post name');
      return;
    }

    if (placeName.isEmpty) {
      _showErrorSnackbar('Please enter a place name');
      return;
    }

    if (location.isEmpty) {
      _showErrorSnackbar('Please enter a place location');
      return;
    }

    if (description.isEmpty) {
      _showErrorSnackbar('Please enter a description');
      return;
    }

    setState(() => _isSaving = true);

    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid ?? '';

    final ownerName =
        user?.displayName?.trim().isNotEmpty == true
            ? user!.displayName!.trim()
            : 'Anonymous';

    try {
      final placesProvider = context.read<PlacesProvider>();
      final postProvider = context.read<PostProvider>();

      final place = await placesProvider.findOrCreatePlace(
        placeName: placeName,
        location: location,
        description: description,
        tags: _selectedTags,
        ownerId: userId,
        ownerName: ownerName,
        coverImageUrl:
            widget.imageUrls.isNotEmpty ? widget.imageUrls.first : null,
        latitude: _selectedLatitude,
        longitude: _selectedLongitude,
      );

      final post = PostModel(
        id: '',
        userId: userId,
        name: name,
        placeId: place.id,
        location: location,
        latitude: _selectedLatitude,
        longitude: _selectedLongitude,
        imageUrls: widget.imageUrls,
        videoUrl: widget.videoUrl,
        description: description,
        postDate: DateTime.now(),
        rating: 0.0,
        reviewCount: 0,
        tags: _selectedTags,
      );

      await postProvider.createPost(post);

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
          Positioned.fill(
            child: Image.asset(
              'assets/background.png',
              fit: BoxFit.cover,
            ),
          ),

          Positioned(
            top: 48,
            left: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(
                Icons.arrow_back,
                color: Color(0xFF8B6F47),
                size: 28,
              ),
            ),
          ),

          Positioned.fill(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 100, 24, 34),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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

                  if (widget.imageUrls.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image.network(
                        widget.imageUrls.first,
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
                              aspectRatio: _videoController!.value.aspectRatio,
                              child: VideoPlayer(_videoController!),
                            )
                          : Container(
                              height: 200,
                              color: Colors.black12,
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                    ),

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
                        Icon(
                          Icons.videocam,
                          size: 14,
                          color: Color.fromRGBO(37, 24, 15, 0.5),
                        ),
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

                  _buildFieldLabel('Post Name'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _nameController,
                    hint: 'e.g. Sunset at Sahara',
                  ),
                  const SizedBox(height: 16),

                  _buildFieldLabel('Place Name'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _placeNameController,
                    hint: 'e.g. Sahara Cafe',
                  ),
                  const SizedBox(height: 16),

                  _buildFieldLabel('Location'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _locationController,
                          hint: 'e.g. Cairo, Egypt',
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: _openLocationPicker,
                        child: Container(
                          height: 56,
                          width: 56,
                          decoration: BoxDecoration(
                            color: const Color(0xFFB08968),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFF8B6F47),
                              width: 1.5,
                            ),
                          ),
                          child: const Icon(
                            Icons.location_on,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  _buildFieldLabel('Description'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _descriptionController,
                    hint: 'Tell us about this place...',
                    maxLines: 4,
                  ),

                  const SizedBox(height: 24),

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
                      onChanged: (tags) {
                        setState(() => _selectedTags = tags);
                      },
                    ),
                  ),

                  const SizedBox(height: 32),

                  _isSaving
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF8B6F47),
                          ),
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
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
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