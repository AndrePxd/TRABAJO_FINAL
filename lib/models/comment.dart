// lib/models/comment.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String id;
  final String text;
  final String author;
  final String noteId;
  final DateTime timestamp;

  Comment({
    required this.id,
    required this.text,
    required this.author,
    required this.noteId,
    required this.timestamp,
  });

  factory Comment.fromMap(String id, Map<String, dynamic> data) {
    final ts = data['timestamp'];
    return Comment(
      id: id,
      text: data['text'] as String? ?? '',
      author: data['author'] as String? ?? '',
      noteId: data['noteId'] as String? ?? '',
      timestamp: ts is Timestamp ? ts.toDate() : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'author': author,
      'noteId': noteId,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }
}
