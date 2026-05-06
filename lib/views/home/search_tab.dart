import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/post_provider.dart';

class SearchTab extends StatefulWidget {
  const SearchTab({super.key});

  @override
  State<SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PostProvider>(context, listen: false).fetchAllPosts();
    });
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
                Row(children: [
                  Expanded(
                    child: TextField(
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

                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Hi name ,', style: TextStyle(fontSize: 22)),
                      Text('Where do you', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color.fromRGBO(86, 60, 60, 1))),
                      Text('want to go?', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color.fromRGBO(86, 60, 60, 1))),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                //posts in a grid
                if (postProvider.isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (postProvider.posts.isEmpty)
                  const Center(child: Text('No posts yet'))
                else
                  SizedBox(
                    height: 200,

                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: postProvider.posts.length,
                      itemBuilder: (context, index) {
                        final post = postProvider.posts[index];

                        return Container(
                          width: 180,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),

                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                child: post.imageUrls.isNotEmpty
                                    ? Image.network(
                                  post.imageUrls[0],
                                  height: 120,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                )

                                    : Container(
                                  height: 120,
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.image, color: Colors.grey),
                                ),
                              ),

                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children:
                                  [
                                    Text(
                                      post.name,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Row(

                                      children: [
                                        const Icon(Icons.star, size: 12, color: Colors.amber),
                                        const SizedBox(width: 2),
                                        Text('${post.rating}', style: const TextStyle(fontSize: 12)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Chip(avatar: Icon(Icons.restaurant, color: Colors.grey), label: Text('Restaurants'), backgroundColor: Color(0xFFEBE1D2)),
                      Chip(avatar: Icon(Icons.explore, color: Colors.grey), label: Text('Hidden Gems'), backgroundColor: Color(0xFFEBE1D2)),
                      Chip(avatar: Icon(Icons.hiking, color: Colors.grey), label: Text('Experiences'), backgroundColor: Color(0xFFEBE1D2)),
                      Chip(avatar: Icon(Icons.attach_money, color: Colors.grey), label: Text('Budget'), backgroundColor: Color(0xFFEBE1D2)),
                      Chip(avatar: Icon(Icons.wb_sunny, color: Colors.grey), label: Text('Atmosphere'), backgroundColor: Color(0xFFEBE1D2)),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // GridView.builder(
                //   shrinkWrap: true,
                //   physics: const NeverScrollableScrollPhysics(),
                //   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                //     crossAxisCount: 2,
                //     crossAxisSpacing: 12,
                //     mainAxisSpacing: 12,
                //     childAspectRatio: 3 / 4,
                //   ),
                //   itemCount: 10,
                //   itemBuilder: (context, index) {
                //     return Container(
                //       decoration: BoxDecoration(
                //         color: Colors.white,
                //         borderRadius: BorderRadius.circular(16),
                //       ),
                //       child: Text('Item $index'),
                //     );
                //   },
                // ),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 3 / 4,
                  ),
                  itemCount: postProvider.posts.length, // 👈 dynamic count
                  itemBuilder: (context, index) {
                    final post = postProvider.posts[index]; // 👈 get post by index
                    return Container(
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
                                    Text('${post.rating}', style: const TextStyle(fontSize: 11)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}