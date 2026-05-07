import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _descriptionController = TextEditingController();
  File? _selectedImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // prefill username from authProvider immediately
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _usernameController.text = authProvider.username ?? '';

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
      await context.read<ProfileProvider>().fetchUserProfile(userId);

      // prefill email and description after fetch
      final user = context.read<ProfileProvider>().user;
      _emailController.text = user?.email ?? '';
      _descriptionController.text = user?.profileDescription ?? '';
      setState(() {});
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _selectedImage = File(picked.path));
    }
  }

  Future<void> _save() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final profileProvider = context.read<ProfileProvider>();
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final newUsername = _usernameController.text.trim();

    if (newUsername.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username cannot be empty')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // update username if changed
      if (newUsername != authProvider.username) {
        final result = await authProvider.updateUsername(newUsername);
        if (result != 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $result')),
          );
          setState(() => _isLoading = false);
          return;
        }
      }

      // upload photo if selected
      if (_selectedImage != null) {
        await profileProvider.updateProfilePhoto(userId, _selectedImage!);
      }

      // update email and description
      await profileProvider.updateProfile(
        userId: userId,
        email: _emailController.text,
        profileDescription: _descriptionController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(context);
    final user = profileProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: const Color(0xFFEBE1D2),
        foregroundColor: const Color.fromRGBO(86, 60, 60, 1),
      ),
      body: profileProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            // profile photo
            GestureDetector(
              onTap: _pickImage,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 55,
                    backgroundColor: const Color.fromRGBO(86, 60, 60, 1),
                    backgroundImage: _selectedImage != null
                        ? FileImage(_selectedImage!)
                        : (user?.photoUrl != null
                        ? NetworkImage(user!.photoUrl!) as ImageProvider
                        : null),
                    child: _selectedImage == null && user?.photoUrl == null
                        ? const Icon(Icons.person, size: 55, color: Colors.white)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: const Color.fromRGBO(86, 60, 60, 1),
                      child: const Icon(Icons.edit, size: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tap to change photo',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 32),

            // username field
            _buildField(
              controller: _usernameController,
              label: 'Username',
              icon: Icons.person_outline,
              prefixText: '@',
            ),
            const SizedBox(height: 8),
            const Text(
              'Username will appear as @yourname on your profile',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 16),

            // email field
            _buildField(
              controller: _emailController,
              label: 'Email',
              icon: Icons.email_outlined,
            ),
            const SizedBox(height: 16),

            // description field
            _buildField(
              controller: _descriptionController,
              label: 'Profile Description',
              icon: Icons.info_outline,
              maxLines: 4,
            ),
            const SizedBox(height: 32),

            // save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEBE1D2),
                  foregroundColor: const Color.fromRGBO(86, 60, 60, 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: const BorderSide(
                      color: Color.fromRGBO(86, 60, 60, 1),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _isLoading ? null : _save,
                child: _isLoading
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color.fromRGBO(86, 60, 60, 1),
                  ),
                )
                    : const Text(
                  'Save Changes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    String? prefixText,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color.fromRGBO(86, 60, 60, 1)),
        prefixText: prefixText,
        prefixStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Color.fromRGBO(86, 60, 60, 1),
        ),
        labelStyle: const TextStyle(color: Color.fromRGBO(86, 60, 60, 1)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFB08968), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color.fromRGBO(86, 60, 60, 1), width: 2),
        ),
      ),
    );
  }
}