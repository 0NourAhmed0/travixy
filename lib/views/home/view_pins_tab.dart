import 'package:flutter/material.dart';

class ViewPinsPage extends StatelessWidget {
  const ViewPinsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Pins')),
      body: const Center(child: Text('View Pins')),
    );
  }
}