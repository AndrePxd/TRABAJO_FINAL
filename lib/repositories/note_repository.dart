// lib/repositories/note_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/note.dart';

class NoteRepository {
  final col = FirebaseFirestore.instance.collection('notes');
  Stream<List<Note>> watchAll() => col.snapshots().map(
    (s) => s.docs.map((d) => Note.fromMap(d.id, d.data())).toList(),
  );
  Future<void> add(Note n) => col.add(n.toMap());
  Future<void> remove(String id) => col.doc(id).delete();
}
