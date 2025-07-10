// lib/models/note.dart
class Note {
  final String id;
  final String text;
  final String author;

  Note({required this.id, required this.text, required this.author});

  factory Note.fromMap(String id, Map<String, dynamic> m) => Note(
    id: id,
    text: m['text'] as String,
    // si no hay author en Firestore, asigna 'anónimo'
    author: (m['author'] as String?) ?? 'anónimo',
  );

  Map<String, dynamic> toMap() => {'text': text, 'author': author};
}
