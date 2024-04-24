import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'bottom_tab_bar.dart'; // Import the bottom tab bar screen

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _signUp(BuildContext context) async {
    try {
      final String email = _emailController.text;
      final String password = _passwordController.text;

      // Implement sign-up logic with email and password
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Navigate to bottom tab bar screen upon successful sign-up
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => BottomTabBarScreen()),
      );
    } catch (e) {
      // Handle sign-up errors
      print('Error signing up: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _signUp(context),
              child: Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}
