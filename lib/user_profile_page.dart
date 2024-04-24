import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProfilePage extends StatelessWidget {
  final User user = FirebaseAuth.instance.currentUser!;

  String _extractUserName(String email) {
    return email.split('@')[0]; // Extracting username from email
  }

  @override
  Widget build(BuildContext context) {
    final String userName = _extractUserName(user.email!); // Extracting username

    return Scaffold(
      appBar: AppBar(
        title: Text('User Profile'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(user.photoURL ?? ''),
            ),
            SizedBox(height: 20),
            Text(
              userName.isNotEmpty ? userName : 'User', // Using extracted username
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
                Navigator.pop(context);
              },
              child: Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}

