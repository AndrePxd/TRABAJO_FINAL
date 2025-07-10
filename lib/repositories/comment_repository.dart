// lib/repositories/comment_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/comment.dart';

class CommentRepository {
  final col = FirebaseFirestore.instance.collection('comments');

  Stream<List<Comment>> watchByNote(String noteId) {
    return col
        .where('noteId', isEqualTo: noteId)
        .orderBy('timestamp', descending: false) // ASC: más antiguo primero
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((d) => Comment.fromMap(d.id, d.data())).toList(),
        );
  }

  Future<void> add(Comment c) => col.add(c.toMap());
  Future<void> remove(String id) => col.doc(id).delete();
}
