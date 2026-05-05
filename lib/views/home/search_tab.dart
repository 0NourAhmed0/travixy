import 'package:flutter/material.dart';

class SearchTab extends StatelessWidget {
  const SearchTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Search places, keywords, categories',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 16),
            const Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(label: Text('Restaurants')),
                Chip(label: Text('Hidden Gems')),
                Chip(label: Text('Experiences')),
                Chip(label: Text('Budget')),
                Chip(label: Text('Atmosphere')),
              ],
            ),
            const SizedBox(height: 24),
            const Expanded(
              child: Center(
                child: Text('Search and filtering will be connected in the next split.'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
