// main.dart
import 'package:flutter/material.dart';
import 'package:reactions_example/reaction_buttons.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[200],
      ),
      home: const HomePage(),
    );
  }
}

class Post {
  final int id;
  final String content;
  final String imageUrl;
  int likes;
  bool isLiked;
  Reaction reaction;

  Post(
      {required this.id,
      required this.content,
      required this.imageUrl,
      this.likes = 0,
      this.isLiked = false,
      this.reaction = Reaction.none});
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Post> posts = [
    Post(
        id: 0,
        content: '',
        imageUrl:
            'https://images.ctfassets.net/ihx0a8chifpc/2uTVCl4WzwqJP5ywFNzukO/8acb2b2cf872f3f5706c4bd63295ba31/placekitten.jpeg?w=1280&q=60&fm=webp'),
    Post(
        id: 1,
        content: '',
        imageUrl:
            'https://images.ctfassets.net/ihx0a8chifpc/4Yp1F82NF8yN9gUHXMphNz/c254302efb588196d9a607832cb24e28/lorem-picsum-1280x720.jpg?w=1920&q=60&fm=webp'),
    Post(
        id: 2,
        content: '',
        imageUrl:
            'https://images.ctfassets.net/ihx0a8chifpc/3PpcpZSv81IG4hh7Rtl9Hg/fce1efd53a8a92885bf2ca22bdf8932c/placebear-1280x720.jpg?w=1920&q=60&fm=webp'),
  ];
//   List<Post> posts = List.generate(
//     10,
//     (index) => Post(
//       id: index,
//       content: 'This is post #$index',
//       imageUrl:
//           'https://images.ctfassets.net/ihx0a8chifpc/3PpcpZSv81IG4hh7Rtl9Hg/fce1efd53a8a92885bf2ca22bdf8932c/placebear-1280x720.jpg?w=1920&q=60&fm=webp',
//     ),
//   );

  void toggleLike(int id, Reaction reaction) {
    setState(() {
      posts = posts.map((post) {
        if (post.id == id) {
          return Post(
              id: post.id,
              content: post.content,
              imageUrl: post.imageUrl,
              likes: post.isLiked ? post.likes - 1 : post.likes + 1,
              isLiked: !post.isLiked,
              reaction: reaction);
        }
        return post;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Social Media Home',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: ListView.builder(
        itemCount: posts.length,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        itemBuilder: (context, index) {
          final post = posts[index];
          return Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      post.imageUrl,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 4.0),
                            child: ReactionButton(
                              initialReaction: post.reaction,
                              key: UniqueKey(),
                              onReactionChanged: (newReaction) {
                                if (post.isLiked &&
                                    newReaction == Reaction.none) {
                                  toggleLike(post.id, newReaction);
                                }
                                if (post.isLiked) {
                                } else {
                                  toggleLike(post.id, newReaction);
                                }
                              },
                            ),
                          ),
                          Text(
                            '${post.likes} likes',
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      IconButton(
                          icon: const Icon(Icons.share, color: Colors.grey),
                          onPressed: () {}),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
