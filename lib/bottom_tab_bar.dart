import 'package:flutter/material.dart';
import 'user_post_page.dart';
import 'user_profile_page.dart';
import 'chat_page.dart'; // Import the chat page

class BottomTabBarScreen extends StatefulWidget {
  @override
  _BottomTabBarScreenState createState() => _BottomTabBarScreenState();
}

class _BottomTabBarScreenState extends State<BottomTabBarScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    UserPostPage(),
    UserProfilePage(),
    ChatPage(), // Add the chat page
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'User Post',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'User Profile',
          ),
          BottomNavigationBarItem( // Add the chat icon
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
        ],
      ),
    );
  }
}
