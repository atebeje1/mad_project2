import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProfilePage extends StatelessWidget {
  final User user = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              user.displayName ?? 'User',
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
