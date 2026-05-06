import 'package:flutter/material.dart';

class AddPostTab extends StatelessWidget {
  const AddPostTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Post')),
      body: const Center(child: Text('Post')),
    );
  }
}