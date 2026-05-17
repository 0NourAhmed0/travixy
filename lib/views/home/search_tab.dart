import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/post_provider.dart';
import '../../models/post_model.dart';
import '../post/post_detail_tab.dart';

class SearchTab extends StatefulWidget {
  const SearchTab({super.key});

  @override
  State<SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> {
  late TextEditingController _searchController;
  String _selectedCategory = '';
  String _selectedBudget = '';
  String _selectedAtmosphere = '';

  final List<String> _categories = ['Restaurants', 'Hidden Gems', 'Experiences'];
  final List<String> _budgets = ['\$', '\$\$', '\$\$\$'];
  final List<String> _atmospheres = ['Cozy', 'Luxury', 'Casual', 'Adventurous'];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PostProvider>(context, listen: false).fetchAllPosts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<PostModel> _filterPosts(List<PostModel> allPosts) {
    String query = _searchController.text.toLowerCase();

    return allPosts.where((post) {
      // Filter by search query
      final matchesSearch = query.isEmpty ||
          post.name.toLowerCase().contains(query) ||
          post.description.toLowerCase().contains(query) ||
          post.location.toLowerCase().contains(query);

      // Filter by category
      final matchesCategory =
          _selectedCategory.isEmpty || post.tags.contains(_selectedCategory);

      // Filter by budget
      final matchesBudget =
          _selectedBudget.isEmpty || post.tags.contains(_selectedBudget);

      // Filter by atmosphere
      final matchesAtmosphere = _selectedAtmosphere.isEmpty ||
          post.tags.contains(_selectedAtmosphere.toLowerCase());

      return matchesSearch && matchesCategory && matchesBudget && matchesAtmosphere;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final postProvider = Provider.of<PostProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 12),
                // Search bar
                Row(children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {});
                      },
                      decoration: InputDecoration(
                        hintText: 'Search places, keywords, categories',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const CircleAvatar(
                    radius: 24,
                    backgroundImage: AssetImage('assets/pic3.png'),
                  ),
                ]),

                const SizedBox(height: 20),
                // Greeting
                Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Where do you', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color.fromRGBO(86, 60, 60, 1))),
                      const Text('want to go?', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color.fromRGBO(86, 60, 60, 1))),
                      const SizedBox(height: 8),
                      Text('${_filterPosts(postProvider.posts).length} places found', style: const TextStyle(fontSize: 14, color: Colors.grey)),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Category filters
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Category', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF775242))),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _categories
                            .map(
                              (category) => Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: FilterChip(
                                  label: Text(category),
                                  selected: _selectedCategory == category,
                                  onSelected: (selected) {
                                    setState(() {
                                      _selectedCategory = selected ? category : '';
                                    });
                                  },
                                  backgroundColor: const Color(0xFFEBE1D2),
                                  selectedColor: const Color(0xFF775242),
                                  labelStyle: TextStyle(
                                    color: _selectedCategory == category ? Colors.white : Colors.black,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Budget filters
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Budget', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF775242))),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _budgets
                            .map(
                              (budget) => Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: FilterChip(
                                  label: Text(budget),
                                  selected: _selectedBudget == budget,
                                  onSelected: (selected) {
                                    setState(() {
                                      _selectedBudget = selected ? budget : '';
                                    });
                                  },
                                  backgroundColor: const Color(0xFFEBE1D2),
                                  selectedColor: const Color(0xFF775242),
                                  labelStyle: TextStyle(
                                    color: _selectedBudget == budget ? Colors.white : Colors.black,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Atmosphere filters
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Atmosphere', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF775242))),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _atmospheres
                            .map(
                              (atmosphere) => Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: FilterChip(
                                  label: Text(atmosphere),
                                  selected: _selectedAtmosphere == atmosphere,
                                  onSelected: (selected) {
                                    setState(() {
                                      _selectedAtmosphere = selected ? atmosphere : '';
                                    });
                                  },
                                  backgroundColor: const Color(0xFFEBE1D2),
                                  selectedColor: const Color(0xFF775242),
                                  labelStyle: TextStyle(
                                    color: _selectedAtmosphere == atmosphere ? Colors.white : Colors.black,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Results grid
                _buildResultsGrid(postProvider),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultsGrid(PostProvider postProvider) {
    final filteredPosts = _filterPosts(postProvider.posts);

    if (filteredPosts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(
                Icons.search_off,
                size: 64,
                color: const Color(0xFF775242).withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              const Text(
                'No places found',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Try adjusting your filters or search query.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  setState(() {
                    _searchController.clear();
                    _selectedCategory = '';
                    _selectedBudget = '';
                    _selectedAtmosphere = '';
                  });
                },
                child: const Text('Clear filters'),
              ),
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 3 / 4,
      ),
      itemCount: filteredPosts.length,
      itemBuilder: (context, index) {
        final post = filteredPosts[index];

        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PostDetailTab(post: post),
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // image
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: post.imageUrls.isNotEmpty
                      ? Image.network(
                          post.imageUrls[0],
                          height: 130,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            height: 130,
                            color: Colors.grey[200],
                            child: const Icon(Icons.image, color: Colors.grey),
                          ),
                        )
                      : Container(
                          height: 130,
                          color: Colors.grey[200],
                          child: const Icon(Icons.image, color: Colors.grey),
                        ),
                ),

                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        post.description,
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 12, color: Colors.amber),
                          const SizedBox(width: 2),
                          Text('${post.rating.toStringAsFixed(1)}', style: const TextStyle(fontSize: 11)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}