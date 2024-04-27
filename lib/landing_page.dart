import 'package:flutter/material.dart';
import 'authentication_screen.dart'; // Import the authentication screen
import 'sign_up_screen.dart'; // Import the sign-up screen

class LandingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'SocialApp',
              style: TextStyle(
                fontSize: 36, // Set the font size to 36
                fontWeight: FontWeight.bold, // Set font weight to bold
              ),
            ),
            SizedBox(height: 50), // Add space between the title and buttons
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AuthenticationScreen()),
                );
              },
              child: Text('Sign In'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignUpScreen()),
                );
              },
              child: Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}
