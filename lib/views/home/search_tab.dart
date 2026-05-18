import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/post_tags.dart';
import '../../models/post_tag.dart';
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

  final Map<String, String> _selectedTagsByCategory = {};

  Map<String, List<PostTag>> get _tagGroups => PostTags.byCategory;

  int get _activeFilterCount {
    return _selectedTagsByCategory.length;
  }

  static String _normalize(String value) => value.trim().toLowerCase();

  Set<String> _normalizedPostTags(PostModel post) {
    return post.tags.map(_normalize).toSet();
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
      final normalizedPostTags = _normalizedPostTags(post);

      final matchesSearch =
          query.isEmpty ||
          post.name.toLowerCase().contains(query) ||
          post.description.toLowerCase().contains(query) ||
          post.location.toLowerCase().contains(query) ||
          post.tags.any((tag) => tag.toLowerCase().contains(query));

      final matchesSelectedTags = _selectedTagsByCategory.values.every(
        (selectedTag) => normalizedPostTags.contains(_normalize(selectedTag)),
      );

      return matchesSearch && matchesSelectedTags;
    }).toList();
  }

  void _clearFilters() {
    setState(() {
      _selectedTagsByCategory.clear();
    });
  }

  void _toggleSelectedTag(String category, String tagLabel) {
    if (tagLabel.isEmpty) {
      _selectedTagsByCategory.remove(category);
      return;
    }

    if (_selectedTagsByCategory[category] == tagLabel) {
      _selectedTagsByCategory.remove(category);
    } else {
      _selectedTagsByCategory[category] = tagLabel;
    }
  }

  void _openFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFF6EBDD),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.82,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, modalSetState) {
            Widget filterSection(
              String title,
              String category,
              List<PostTag> options,
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
                    children: options.map((tag) {
                      final selected =
                          _selectedTagsByCategory[category] == tag.label;

                      return FilterChip(
                        label: Text(tag.label),
                        selected: selected,
                        onSelected: (_) {
                          modalSetState(() {
                            _toggleSelectedTag(
                              category,
                              selected ? '' : tag.label,
                            );
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

            return LayoutBuilder(
              builder: (context, constraints) {
                return ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: constraints.maxHeight),
                  child: SingleChildScrollView(
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
                                  _selectedTagsByCategory.clear();
                                });
                                setState(() {});
                              },
                              child: const Text('Clear'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ..._tagGroups.entries.map(
                          (entry) =>
                              filterSection(entry.key, entry.key, entry.value),
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
                  ),
                );
              },
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
                    if (_selectedTagsByCategory.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _selectedTagsByCategory.entries.map((entry) {
                          return InputChip(
                            label: Text('${entry.key}: ${entry.value}'),
                            onDeleted: () {
                              setState(() {
                                _selectedTagsByCategory.remove(entry.key);
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ],
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
                            color: Color.fromARGB(255, 173, 126, 56),
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
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final post = filteredPosts[index];
                    return _PostCard(post: post);
                  }, childCount: filteredPosts.length),
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
              color: const Color(0xFF775242).withValues(alpha: 0.5),
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
                  _selectedTagsByCategory.clear();
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
        MaterialPageRoute(builder: (_) => PostDetailTab(post: post)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
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
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
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
