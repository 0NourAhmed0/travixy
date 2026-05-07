import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travixy/providers/post_provider.dart';

import '../../models/post_model.dart';
import '../../providers/review_provider.dart';

class PostDetailTab extends StatefulWidget {
  final PostModel post;

  const PostDetailTab({super.key, required this.post});

  @override
  State<PostDetailTab> createState() => _PostDetailTabState();
}

class _PostDetailTabState extends State<PostDetailTab> {

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PostProvider>().fetchUserPost(
        widget.post.userId,  // userId from the passed post
        widget.post.id,      // postId from the passed post
      );
      context.read<ReviewProvider>().fetchReviewsByPost(
        widget.post.id,
      ).then((_) {
        print('post id being used: ${widget.post.id}');
        print('reviews count: ${context.read<ReviewProvider>().reviews.length}');
      }).catchError((e) {
        print('error fetching reviews: $e'); // 👈
      });
    });
  }

  @override
  Widget build(BuildContext context) {

    final postProvider = Provider.of<PostProvider>(context);
    final reviewProvider = Provider.of<ReviewProvider>(context);

    if (postProvider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final post = postProvider.post;

    if (post == null) {
      return const Scaffold(
        body: Center(child: Text('Post not found')),
      );
    }

    return Scaffold(

        body:
        SingleChildScrollView( child: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //image

              SizedBox(
                width: MediaQuery.widthOf(context),
                height: 400,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),


                child: Image.network(
                          widget.post.imageUrls.isNotEmpty ? widget.post.imageUrls[0] : '',
                          fit: BoxFit.cover,
                        ),
              ),
              // Row(
              //   children: [
              //
              //   ]
              // ),

            ),
              const SizedBox(height: 10),

              Row( children: [
                const SizedBox(width: 25),

                Text(postProvider.post?.name ?? '', textAlign: TextAlign.left,

                  style: TextStyle(fontSize: 33, fontWeight: FontWeight.w500, color: Color.fromRGBO(86, 60, 60, 1)),),
                  //IconButton(onPressed: onPressed:({}) //NEED TO ADD WHEN PRESSED IT PINS ( CREATE A NEW PIN FOR USER)
                const SizedBox(width: 70),
                Icon(Icons.push_pin , color: Color.fromRGBO(86, 60, 60, 1)),
                Text ( 'Pin' ,style: TextStyle(fontSize: 33, fontWeight: FontWeight.w500, color: Color.fromRGBO(86, 60, 60, 1))),
                const SizedBox(width: 25),
             ] ) ,
              Row (
                children: [
                  const SizedBox(width: 25),
                  Icon(Icons.location_pin , color: Color.fromRGBO(86, 60, 60, 1)),
                  Text ( postProvider.post?.location??'' ,style: TextStyle(fontSize:20, fontWeight: FontWeight.w500, color: Color.fromRGBO(86, 60, 60, 1))),
                  const SizedBox(width: 25),
                ],
              ),
              const SizedBox(height: 25),
              Row (
                children: [
                  const SizedBox(width: 30),
                  Icon(Icons.star , size: 35, color: Color.fromRGBO(86, 60, 60, 1) ),
                  const SizedBox(width: 10),
                  Column (
                  children: [
                    //RATING WILL AVERAGE TOTAL RATING FOR A POST
                    Text ( 'Rating' ,style: TextStyle(fontSize:20, fontWeight: FontWeight.w500, color: Color.fromRGBO(86, 60, 60, 1))),
                    const SizedBox(height: 5),
                    Text ( widget.post.reviewCount == 0
                        ? '5.0'
                        : '${widget.post.rating.toStringAsFixed(1)}' , style: TextStyle(fontSize:20, fontWeight: FontWeight.w500, color: Color.fromRGBO(86, 60, 60, 1))),

                  ],
                  ),

                ],
              ),



              const SizedBox(height: 25),
              Text ( postProvider.post?.description??'' ,textAlign: TextAlign.center ,style: TextStyle(fontSize:25, fontWeight: FontWeight.w500, color: Color.fromRGBO(86, 60, 60, 1))),

              const SizedBox(height: 25),
              Center(
                child: Container(
                  width: 400,   // control line length
                  height: 2,
                  color: Colors.brown,
                ),
              ),

              //Review section

              Row(
                  children: [
                    const SizedBox(width: 25),
                    Text(
                      'Reviews',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 33,
                        fontWeight: FontWeight.w500,
                        color: Color.fromRGBO(86, 60, 60, 1),
                      ),
                    ),
                    //Add Review button
                    const SizedBox(width: 180),
                    IconButton(
                      style: TextButton.styleFrom(
                       // backgroundColor: const Color(0xFFEBE1D2),
                        //foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true, // allows sheet to resize when keyboard opens
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                          ),
                          builder: (context) => _AddReviewSheet(postId: widget.post.id),
                        );
                      },
                       icon: Icon(Icons.add , size: 40,),
                     // child:  const Text('Add Review', style: TextStyle(fontSize: 16, color: Color.fromRGBO(86, 60, 60, 1))),
                    ),
                  ],
                ),
              const SizedBox(height: 25),

              (reviewProvider.reviews.isNotEmpty)
                    ? ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: reviewProvider.reviews.length,
                  itemBuilder: (context, index) {
                    final review = reviewProvider.reviews[index];
                    // return ListTile(
                    //   leading: const Icon(Icons.person),
                    //   subtitle: Text(review.userId),
                    //   trailing: Text('${review.rating} ⭐'),
                    // );
                    return Column(
                      children: [
                       // Row(
                       //   children: [
                       //     Icon(Icons.person , size: 40),
                       //     Text(review.userId ,style: TextStyle(fontSize: 20),)
                       // ]),
                       //  Row(
                       //      children: [
                       //        Icon(Icons.star , size: 40),
                       //        Text('${review.rating} ',style: TextStyle(fontSize: 20),)
                       //      ]),
                       //
                       //  Container(
                       //      width: 400,   // control line length
                       //      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                       //      decoration: BoxDecoration(
                       //          color: Color(0xFFEBE1D2),
                       //          borderRadius: BorderRadius.circular(12),
                       //          border: Border.all(
                       //          color: Color.fromRGBO(86, 60, 60, 1), // 👈 brown outline
                       //          width: 1.5,
                       //      )
                       //    ),
                       //      child:Text('${review.review}' ,style: TextStyle(fontSize: 20)) )
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Color(0xFFEBE1D2),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Color.fromRGBO(86, 60, 60, 1),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // user row
                              Row(
                                children: [
                                  const CircleAvatar(
                                    radius: 16,
                                    backgroundColor: Color.fromRGBO(86, 60, 60, 1),
                                    child: Icon(Icons.person, color: Colors.white, size: 18),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    review.userId,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: Color.fromRGBO(86, 60, 60, 1),
                                    ),
                                  ),
                                  const Spacer(),
                                  // stars on the right
                                  Row(
                                    children: List.generate(5, (i) => Icon(
                                      i < review.rating ? Icons.star : Icons.star_border,
                                      color: Color.fromRGBO(86, 60, 60, 1),
                                      size: 16,
                                    )),
                                  ),
                                ],
                              ),
                              if (review.review != null) ...[
                                const SizedBox(height: 10),
                                Text(
                                  review.review!,
                                  style: const TextStyle(fontSize: 20, color: Colors.black87),
                                ),
                              ],
                            ],
                          ),
                        )

                      ],
                    );
                  },
                )
                :
                  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
             // const SizedBox(width: 50),

              const Text('No reviews yet'
                    , textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Color.fromRGBO(86, 60, 60, 1)) ),
                    ]) ,
              SizedBox(height: 10),


            ],
          ),
        ),
     );
  }
}


class _AddReviewSheet extends StatefulWidget {
  final String postId;
  const _AddReviewSheet({required this.postId});

  @override
  State<_AddReviewSheet> createState() => _AddReviewSheetState();
}

class _AddReviewSheetState extends State<_AddReviewSheet> {
  int _rating = 0;
  final TextEditingController _reviewController = TextEditingController();

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24, // moves up when keyboard opens
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Add Review', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),

          // star rating
          const Text('Rating', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Row(
            children: List.generate(5, (index) {
              return GestureDetector(
                onTap: () => setState(() => _rating = index + 1),
                child: Icon(
                  index < _rating ? Icons.star : Icons.star_border,
                  color: const Color.fromRGBO(86, 60, 60, 1),
                  size: 36,
                ),
              );
            }),
          ),
          const SizedBox(height: 16),

          // optional review text
          const Text('Review (optional)', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          TextField(
            controller: _reviewController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Write your review...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 16),

          // submit button
          SizedBox(
            width: double.infinity,
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFFEBE1D2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () {
                if (_rating == 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please select a rating')),
                  );
                  return;
                }

                final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
                context.read<ReviewProvider>().addReview(
                  postId: widget.postId,
                  userId: userId,
                  rating: _rating,
                  review: _reviewController.text.isEmpty ? null : _reviewController.text,
                );

                Navigator.pop(context); // close sheet
              },
              child: const Text('Submit', style: TextStyle(fontSize: 16, color: Color.fromRGBO(86, 60, 60, 1))),
            ),
          ),
        ],
      ),
    );
  }
}

