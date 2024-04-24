import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection('conversations').doc('conversation_id_1').collection('messages').orderBy('timestamp').snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final messages = snapshot.data!.docs.reversed.toList(); // Reverse the message list
                return ListView.builder(
                  reverse: true, // Display messages from bottom to top
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> data = messages[index].data() as Map<String, dynamic>;
                    return _buildMessageItem(data);
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
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 8.0),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    _sendMessage();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageItem(Map<String, dynamic> message) {
    final String senderId = message['sender_id'];
    final String messageText = message['text'];

    return ListTile(
      title: Text(messageText),
      subtitle: Text(senderId), // Display sender ID (username) as subtitle
    );
  }

  void _sendMessage() async {
    final messageText = _messageController.text.trim();
    if (messageText.isNotEmpty) {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final conversationId = 'conversation_id_1'; // Replace with the conversation ID

        await FirebaseFirestore.instance.collection('conversations').doc(conversationId).collection('messages').add({
          'sender_id': currentUser.email?.split('@')[0], // Use username extracted from email as sender_id
          'text': messageText,
          'timestamp': Timestamp.now(),
        });

        _messageController.clear();
      }
    }
  }
}
