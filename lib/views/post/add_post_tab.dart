import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:travixy/views/post/add_post_details_tab.dart';
import '../../providers/post_provider.dart';

class AddPostTab extends StatefulWidget {
  const AddPostTab({super.key});

  @override
  State<AddPostTab> createState() => _AddPostTabState();
}

class _AddPostTabState extends State<AddPostTab> {
  static const _brown = Color.fromRGBO(86, 60, 60, 1);
  static const _cream = Color(0xFFEBE1D2);

  final ImagePicker _picker = ImagePicker();
  final CloudinaryPublic _cloudinary =
  CloudinaryPublic('dmfawdinr', 'travixy', cache: false);

  List<File> _selectedImages = [];
  File? _selectedVideo;
  VideoPlayerController? _videoController;

  bool _isUploading = false;
  String _uploadStatus = '';
  int _uploadedCount = 0;
  int _totalCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PostProvider>(context, listen: false).fetchAllPosts();
    });
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  // ── Pick multiple images (up to 5) ──────────────────────────
  Future<void> _pickImages() async {
    final List<XFile> picked = await _picker.pickMultiImage();
    if (picked.isEmpty) return;

    // merge with existing instead of replacing
    final combined = [
      ..._selectedImages,
      ...picked.map((x) => File(x.path)),
    ];
    final limited = combined.take(5).toList();

    setState(() {
      _selectedImages = limited;
    });
  }

  // ── Pick video (enforces 30 sec max) ────────────────────────
  Future<void> _pickVideo() async {
    final XFile? picked = await _picker.pickVideo(
      source: ImageSource.gallery,
      maxDuration: const Duration(seconds: 30),
    );
    if (picked == null) return;

    final file = File(picked.path);

    final controller = VideoPlayerController.file(file);
    await controller.initialize();
    final duration = controller.value.duration;
    await controller.dispose();

    if (duration.inSeconds > 30) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Video must be 30 seconds or less')),
      );
      return;
    }

    final previewController = VideoPlayerController.file(file);
    await previewController.initialize();

    setState(() {
      _selectedVideo = file;
      _videoController?.dispose();
      _videoController = previewController;
    });
  }

  void _removeImage(int index) {
    setState(() => _selectedImages.removeAt(index));
  }

  void _removeVideo() {
    _videoController?.dispose();
    setState(() {
      _selectedVideo = null;
      _videoController = null;
    });
  }

  // ── Show bottom sheet to pick image or video ─────────────────
  void _showMediaPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: _cream,
                  child: Icon(Icons.photo_library, color: _brown),
                ),
                title: const Text(
                  'Add Photos',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                    color: _brown,
                  ),
                ),
                subtitle: Text(
                  '${_selectedImages.length}/5 selected',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: _brown.withOpacity(0.5),
                  ),
                ),
                onTap: _selectedImages.length >= 5
                    ? null
                    : () {
                  Navigator.pop(context);
                  _pickImages();
                },
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: _cream,
                  child: Icon(Icons.videocam, color: _brown),
                ),
                title: const Text(
                  'Add Video',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                    color: _brown,
                  ),
                ),
                subtitle: Text(
                  _selectedVideo == null ? 'None selected' : '1 video selected',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: _brown.withOpacity(0.5),
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickVideo();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Upload everything and navigate ───────────────────────────
  Future<void> _upload() async {
    if (_selectedImages.isEmpty && _selectedVideo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select at least one image or video')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadedCount = 0;
      _totalCount =
          _selectedImages.length + (_selectedVideo != null ? 1 : 0);
    });

    try {
      final List<String> imageUrls = [];
      for (int i = 0; i < _selectedImages.length; i++) {
        setState(() =>
        _uploadStatus = 'Uploading image ${i + 1} of ${_selectedImages.length}...');
        final response = await _cloudinary.uploadFile(
          CloudinaryFile.fromFile(
            _selectedImages[i].path,
            resourceType: CloudinaryResourceType.Image,
          ),
        );
        imageUrls.add(response.secureUrl);
        setState(() => _uploadedCount++);
      }

      String? videoUrl;
      if (_selectedVideo != null) {
        setState(() => _uploadStatus = 'Uploading video...');
        final response = await _cloudinary.uploadFile(
          CloudinaryFile.fromFile(
            _selectedVideo!.path,
            resourceType: CloudinaryResourceType.Video,
          ),
        );
        videoUrl = response.secureUrl;
        setState(() => _uploadedCount++);
      }

      setState(() => _isUploading = false);
      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddPostDetailsTab(
            imageUrls: imageUrls,
            videoUrl: videoUrl,
          ),
        ),
      );
    } catch (e) {
      setState(() => _isUploading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: $e')),
      );
    }
  }

  bool get _hasMedia => _selectedImages.isNotEmpty || _selectedVideo != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Post'),
        backgroundColor: _cream,
        foregroundColor: _brown,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [

                  const SizedBox(height: 16),

                  // ── Big add media button ─────────────────────
                  GestureDetector(
                    onTap: _showMediaPicker,
                    child: Container(
                      width: double.infinity,
                      height: 220,
                      decoration: BoxDecoration(
                        color: _cream,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: _brown.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add,
                            size: 72,
                            color: _brown.withOpacity(0.5),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Select photos or video',
                            style: TextStyle(
                              fontSize: 14,
                              color: _brown.withOpacity(0.5),
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── Media thumbnails ─────────────────────────
                  if (_hasMedia) ...[
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        // Image thumbnails
                        ..._selectedImages.asMap().entries.map((entry) {
                          return Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.file(
                                  entry.value,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 3,
                                right: 3,
                                child: GestureDetector(
                                  onTap: () => _removeImage(entry.key),
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.close,
                                        color: Colors.white, size: 16),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }),

                        // Video thumbnail
                        if (_selectedVideo != null)
                          Stack(
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Colors.black87,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: _videoController != null &&
                                    _videoController!.value.isInitialized
                                    ? ClipRRect(
                                  borderRadius:
                                  BorderRadius.circular(10),
                                  child: FittedBox(
                                    fit: BoxFit.cover,
                                    child: SizedBox(
                                      width: _videoController!
                                          .value.size.width,
                                      height: _videoController!
                                          .value.size.height,
                                      child: VideoPlayer(
                                          _videoController!),
                                    ),
                                  ),
                                )
                                    : const Center(
                                  child: Icon(Icons.videocam,
                                      color: Colors.white, size: 28),
                                ),
                              ),
                              Positioned(
                                top: 3,
                                right: 3,
                                child: GestureDetector(
                                  onTap: _removeVideo,
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.close,
                                        color: Colors.white, size: 16),
                                  ),
                                ),
                              ),
                              const Positioned(
                                bottom: 4,
                                left: 4,
                                child: Icon(Icons.play_circle,
                                    color: Colors.white70, size: 18),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),

          // ── Bottom upload button / progress ──────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(
                24, 12, 24, MediaQuery.of(context).padding.bottom + 16),
            child: _isUploading
                ? Column(
              children: [
                LinearProgressIndicator(
                  value: _totalCount > 0
                      ? _uploadedCount / _totalCount
                      : null,
                  color: _brown,
                  backgroundColor: _cream,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 10),
                Text(
                  _uploadStatus,
                  style: const TextStyle(
                    color: _brown,
                    fontFamily: 'Poppins',
                    fontSize: 13,
                  ),
                ),
              ],
            )
                : SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _hasMedia ? _upload : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _brown,
                  disabledBackgroundColor: _brown.withOpacity(0.3),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}