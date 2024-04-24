import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'post_model.dart';

class UserPostPage extends StatefulWidget {
  @override
  _UserPostPageState createState() => _UserPostPageState();
}

class _UserPostPageState extends State<UserPostPage> {
  final TextEditingController _postController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();

  void _post() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final postText = _postController.text.trim();

    if (postText.isNotEmpty) {
      await FirebaseFirestore.instance.collection('posts').add({
        'userId': currentUser?.uid,
        'userName': currentUser?.email?.split('@')[0], // Use username from email
        'text': postText,
        'timestamp': Timestamp.now(),
      });

      _postController.clear();
    }
  }

  void _likePost(Post post) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final liked = post.likes?.contains(currentUser?.uid) ?? false;

    if (liked) {
      await FirebaseFirestore.instance.collection('posts').doc(post.id).update({
        'likes': FieldValue.arrayRemove([currentUser?.uid]),
      });
    } else {
      await FirebaseFirestore.instance.collection('posts').doc(post.id).update({
        'likes': FieldValue.arrayUnion([currentUser?.uid]),
      });
    }
  }

  void _addComment(Post post) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final commentText = _commentController.text.trim();

    if (commentText.isNotEmpty) {
      await FirebaseFirestore.instance.collection('comments').add({
        'postId': post.id,
        'userId': currentUser?.uid,
        'userName': currentUser?.email?.split('@')[0], // Use username from email
        'text': commentText,
        'timestamp': Timestamp.now(),
      });

      _commentController.clear();
    }
  }

  Widget _buildPostItem(Post post) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final liked = post.likes?.contains(currentUser?.uid) ?? false;

    return Card(
      margin: EdgeInsets.all(8.0),
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(post.userName ?? ''),
                Text(DateFormat('EEE, MMM d, ' 'h:mm a').format(post.timestamp)),
              ],
            ),
            SizedBox(height: 8.0),
            if (post.imageUrl != null) ...[
              Image.network(post.imageUrl!),
              SizedBox(height: 8.0),
            ],
            Text(post.text),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (post.userId == currentUser?.uid) ...[
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      FirebaseFirestore.instance.collection('posts').doc(post.id).delete();
                    },
                  ),
                ],
                IconButton(
                  icon: Icon(Icons.comment),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) {
                        return Container(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              TextField(
                                controller: _commentController,
                                decoration: InputDecoration(hintText: 'Add a comment'),
                              ),
                              SizedBox(height: 8.0),
                              ElevatedButton(
                                onPressed: () => _addComment(post),
                                child: Text('Comment'),
                              ),
                              SizedBox(height: 16.0),
                              Divider(), // Boundary
                              SizedBox(height: 16.0),
                              Text(
                                'Comments',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 8.0),
                              StreamBuilder(
                                stream: FirebaseFirestore.instance
                                    .collection('comments')
                                    .where('postId', isEqualTo: post.id)
                                    .orderBy('timestamp')
                                    .snapshots(),
                                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                                  if (snapshot.hasError) {
                                    return Text('Error: ${snapshot.error}');
                                  }
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return CircularProgressIndicator();
                                  }
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: snapshot.data!.docs.map((DocumentSnapshot document) {
                                      final data = document.data() as Map<String, dynamic>;
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(data['userName']),
                                            SizedBox(height: 4.0),
                                            Text(data['text']),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
                IconButton(
                  icon: Icon(Icons.favorite),
                  onPressed: () => _likePost(post),
                  color: liked ? Colors.red : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Posts'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection('posts').orderBy('timestamp', descending: true).snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final document = snapshot.data!.docs[index];
                    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                    final post = Post(
                      id: document.id,
                      userId: data['userId'],
                      userName: data['userName'],
                      text: data['text'],
                      imageUrl: data['imageUrl'],
                      timestamp: data['timestamp'].toDate(),
                      likes: List<String>.from(data['likes'] ?? []),
                    );
                    return _buildPostItem(post);
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _postController,
                    decoration: InputDecoration(
                      hintText: 'What\'s on your mind?',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 8.0),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _post,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

