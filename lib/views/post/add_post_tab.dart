import 'dart:io';

import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:travixy/views/post/add_post_details_tab.dart';

import '../../providers/post_provider.dart';


class AddPostTab extends StatefulWidget {
  const AddPostTab({super.key});

  @override
  State<AddPostTab> createState() => _AddPostTabState();
}

class _AddPostTabState extends State<AddPostTab> { //

  bool _isUploading = false;

  File? selectedImage ;

  Future pickImageFromGallery() async {
    final returnedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (returnedImage == null) return;

    setState(() {
      selectedImage = File(returnedImage.path);
      _isUploading = true;
    });

    try {
      final cloudinary = CloudinaryPublic('dmfawdinr', 'travixy', cache: false);

      final response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(selectedImage!.path, resourceType: CloudinaryResourceType.Image),
      );

      final String downloadUrl = response.secureUrl;

      setState(() => _isUploading = false);

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddPostDetailsTab(imageUrl: downloadUrl),
        ),
      );

    } catch (e) {
      setState(() => _isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PostProvider>(context, listen: false).fetchAllPosts();
    });
  }

  @override
  Widget build(BuildContext context)  {

    return Scaffold(
      appBar: AppBar(title: const Text('Add Post')),
      body: Column(

          children : [
            const SizedBox(height: 48) ,

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Select & upload images from photo Library',
                textAlign: TextAlign.center,
                style: TextStyle( fontSize: 30, fontWeight: FontWeight.bold ,color: Color.fromRGBO(86, 60, 60, 1)),
              ),
            ),
            const SizedBox(height: 48) ,
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFFEBE1D2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              onPressed: pickImageFromGallery,
              child: const Icon(Icons.add, color: Colors.grey, size: 300),
            ),
          ]),
    );

     }
  }