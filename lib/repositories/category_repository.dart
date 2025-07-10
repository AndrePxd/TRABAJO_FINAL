// lib/repositories/category_repository.dart
import 'package:hive/hive.dart';
import '../models/category.dart';

class CategoryRepository {
  final Box<Category> _box = Hive.box<Category>('categoriesBox');
  List<Category> getAll() => _box.values.toList();
  Future<void> add(Category c) => _box.add(c);
  Future<void> remove(Category c) => c.delete();

  Stream<List<Category>> watchAll() async* {
    yield getAll(); // Estado inicial
    yield* _box.watch().map((_) => getAll()); // Cambios futuros
  }
}
