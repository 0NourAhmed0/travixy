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

  int get _activeFilterCount {
    int count = 0;
    if (_selectedCategory.isNotEmpty) count++;
    if (_selectedBudget.isNotEmpty) count++;
    if (_selectedAtmosphere.isNotEmpty) count++;
    return count;
  }

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
    final query = _searchController.text.toLowerCase();

    return allPosts.where((post) {
      final matchesSearch = query.isEmpty ||
          post.name.toLowerCase().contains(query) ||
          post.description.toLowerCase().contains(query) ||
          post.location.toLowerCase().contains(query);

      final matchesCategory =
          _selectedCategory.isEmpty || post.tags.contains(_selectedCategory);

      final matchesBudget =
          _selectedBudget.isEmpty || post.tags.contains(_selectedBudget);

      final matchesAtmosphere =
          _selectedAtmosphere.isEmpty || post.tags.contains(_selectedAtmosphere);

      return matchesSearch &&
          matchesCategory &&
          matchesBudget &&
          matchesAtmosphere;
    }).toList();
  }

  void _clearFilters() {
    setState(() {
      _selectedCategory = '';
      _selectedBudget = '';
      _selectedAtmosphere = '';
    });
  }

  void _openFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, modalSetState) {
            Widget filterSection(
              String title,
              List<String> options,
              String selectedValue,
              Function(String) onSelected,
            ) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF775242),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: options.map((option) {
                      final selected = selectedValue == option;

                      return FilterChip(
                        label: Text(option),
                        selected: selected,
                        onSelected: (_) {
                          modalSetState(() {
                            onSelected(selected ? '' : option);
                          });
                          setState(() {});
                        },
                        backgroundColor: const Color(0xFFEBE1D2),
                        selectedColor: const Color(0xFF775242),
                        labelStyle: TextStyle(
                          color: selected ? Colors.white : Colors.black,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                ],
              );
            }

            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 28,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 45,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      const Text(
                        'Filter places',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(86, 60, 60, 1),
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          modalSetState(() {
                            _selectedCategory = '';
                            _selectedBudget = '';
                            _selectedAtmosphere = '';
                          });
                          setState(() {});
                        },
                        child: const Text('Clear'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  filterSection(
                    'Category',
                    _categories,
                    _selectedCategory,
                    (value) => _selectedCategory = value,
                  ),
                  filterSection(
                    'Budget',
                    _budgets,
                    _selectedBudget,
                    (value) => _selectedBudget = value,
                  ),
                  filterSection(
                    'Atmosphere',
                    _atmospheres,
                    _selectedAtmosphere,
                    (value) => _selectedAtmosphere = value,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF775242),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Show results'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final postProvider = Provider.of<PostProvider>(context);
    final filteredPosts = _filterPosts(postProvider.posts);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: (_) => setState(() {}),
                            decoration: InputDecoration(
                              hintText: 'Search places...',
                              prefixIcon: const Icon(Icons.search),
                              filled: true,
                              fillColor: const Color(0xFFF7F1EA),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        InkWell(
                          onTap: _openFilters,
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFF775242),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                const Icon(Icons.tune, color: Colors.white),
                                if (_activeFilterCount > 0)
                                  Positioned(
                                    right: -8,
                                    top: -8,
                                    child: CircleAvatar(
                                      radius: 9,
                                      backgroundColor: Colors.red,
                                      child: Text(
                                        '$_activeFilterCount',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
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
                    const SizedBox(height: 22),
                    const Text(
                      'Where do you',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(86, 60, 60, 1),
                      ),
                    ),
                    const Text(
                      'want to go?',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(86, 60, 60, 1),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '${filteredPosts.length} places found',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        const Spacer(),
                        if (_activeFilterCount > 0)
                          TextButton(
                            onPressed: _clearFilters,
                            child: const Text('Clear filters'),
                          ),
                      ],
                    ),
                    const SizedBox(height: 18),
                  ],
                ),
              ),
              if (filteredPosts.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildEmptyState(),
                )
              else
                SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final post = filteredPosts[index];
                      return _PostCard(post: post);
                    },
                    childCount: filteredPosts.length,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 3 / 4,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
              child: const Text('Clear all'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  final PostModel post;

  const _PostCard({required this.post});

  @override
  Widget build(BuildContext context) {
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
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: post.imageUrls.isNotEmpty
                  ? Image.network(
                      post.imageUrls[0],
                      height: 130,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _imageFallback(),
                    )
                  : _imageFallback(),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    post.description,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 12, color: Colors.amber),
                      const SizedBox(width: 2),
                      Text(
                        post.rating.toStringAsFixed(1),
                        style: const TextStyle(fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imageFallback() {
    return Container(
      height: 130,
      width: double.infinity,
      color: Colors.grey[200],
      child: const Icon(Icons.image, color: Colors.grey),
    );
  }
}