import 'package:flutter/material.dart';

class SearchTab extends StatelessWidget {
  const SearchTab({super.key});

  @override
  Widget build(BuildContext context) {
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
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: const Text('Post Image'),
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

                //  removed Expanded, added shrinkWrap and NeverScrollableScrollPhysics
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 3 / 4,
                  ),
                  itemCount: 10,
                  itemBuilder: (context, index) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text('Item $index'),
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