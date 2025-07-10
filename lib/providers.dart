// lib/providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'models/task.dart';
import 'models/category.dart';
import 'models/note.dart';
import 'models/comment.dart';

import 'repositories/note_repository.dart';
import 'repositories/task_repository.dart';
import 'repositories/category_repository.dart';
import 'repositories/comment_repository.dart';
import 'repositories/auth_repository.dart';

/// Hive
final taskRepoProvider = Provider((_) => TaskRepository());
final tasksProvider = StreamProvider.autoDispose<List<Task>>(
  (ref) => ref.watch(taskRepoProvider).watchAll(),
);

final categoryRepoProvider = Provider((_) => CategoryRepository());
final categoriesProvider = StreamProvider.autoDispose<List<Category>>(
  (ref) => ref.watch(categoryRepoProvider).watchAll(),
);

/// Firestore
final noteRepoProvider = Provider((_) => NoteRepository());
final notesProvider = StreamProvider.autoDispose<List<Note>>(
  (ref) => ref.watch(noteRepoProvider).watchAll(),
);
final commentRepoProvider = Provider((_) => CommentRepository());

final commentsByNoteProvider = StreamProvider.autoDispose
    .family<List<Comment>, String>((ref, noteId) {
      return ref.read(commentRepoProvider).watchByNote(noteId);
    });

/// Auth
final authRepoProvider = Provider((_) => AuthRepository());
final authStateProvider = StreamProvider<User?>(
  (ref) => ref.watch(authRepoProvider).authStateChanges(),
);

final noteSearchQueryProvider = StateProvider<String>((ref) => '');
final noteFilterTypeProvider = StateProvider<String>((ref) => 'Todas');
