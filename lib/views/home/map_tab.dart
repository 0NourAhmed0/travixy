import 'package:flutter/material.dart';
//this is just a place holder , to be completed later 
class MapTab extends StatelessWidget {
  const MapTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map View'),
      ),
      body: const Center(
        child: Text(
          'Google Maps will be here\n\n'
          'To implement:\n'
          '1. Get Google Maps API key\n'
          '2. Add to AndroidManifest.xml\n'
          '3. Enable Maps SDK in Google Cloud Console',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}