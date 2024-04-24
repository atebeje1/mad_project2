import 'package:flutter/foundation.dart';

class Post {
  final String id;
  final String userId;
  final String userName;
  final String text;
  final String? imageUrl;
  final DateTime timestamp;
  final List<String>? likes; // Define likes field

  Post({
    required this.id,
    required this.userId,
    required this.userName,
    required this.text,
    this.imageUrl,
    required this.timestamp,
    this.likes,
  });
}

class Comment {
  final String userName;
  final String text;
  final DateTime timestamp;

  Comment({
    required this.userName,
    required this.text,
    required this.timestamp,
  });
}
