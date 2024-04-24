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
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _postController = TextEditingController();
  String? _imageUrl;

  void _post() async {
    try {
      final User? user = _auth.currentUser;
      if (user != null) {
        final userName = user.displayName ?? 'User';
        final text = _postController.text;

        await FirebaseFirestore.instance.collection('posts').add({
          'userId': user.uid,
          'userName': userName,
          'text': text,
          'imageUrl': _imageUrl,
          'timestamp': DateTime.now(),
        });

        // Clear text field after posting
        _postController.clear();
        setState(() {
          _imageUrl = null;
        });
      }
    } catch (e) {
      print('Error posting: $e');
    }
  }

  void _setImage(String? imageUrl) {
    setState(() {
      _imageUrl = imageUrl;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Post'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection('posts').orderBy('timestamp', descending: true).snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot document = snapshot.data!.docs[index];
                    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                    Post post = Post(
                      id: document.id,
                      userId: data['userId'],
                      userName: data['userName'],
                      text: data['text'],
                      imageUrl: data['imageUrl'],
                      timestamp: data['timestamp'].toDate(),
                    );
                    return _buildPostItem(post);
                  },
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _postController,
                    decoration: InputDecoration(hintText: 'What\'s on your mind?'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.photo),
                  onPressed: () {
                    // Add image picker functionality here
                  },
                ),
                SizedBox(width: 8.0),
                ElevatedButton(
                  onPressed: _post,
                  child: Text('Post'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostItem(Post post) {
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
                Text(post.userName),
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
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    // Add edit post functionality here
                    // You can navigate to a new screen or show a dialog for editing
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    // Delete post functionality
                    FirebaseFirestore.instance.collection('posts').doc(post.id).delete();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
