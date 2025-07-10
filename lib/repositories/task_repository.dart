// lib/repositories/task_repository.dart

import 'package:hive/hive.dart';
import '../models/task.dart';

class TaskRepository {
  final Box<Task> box = Hive.box<Task>('tasksBox');

  List<Task> getAll() => box.values.toList();

  Future<void> add(Task t) => box.add(t);

  Future<void> remove(Task t) => t.delete();

  Future<void> toggleDone(Task t) {
    t.done = !t.done;
    return t.save();
  }

  Future<void> updateCategory(Task t, String? categoryId) {
    t.categoryId = categoryId;
    return t.save();
  }

  Stream<List<Task>> watchAll() async* {
    yield getAll(); // Estado inicial
    yield* box.watch().map((_) => getAll()); // Cambios futuros
  }
}
