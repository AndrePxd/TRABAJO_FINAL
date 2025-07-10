// lib/models/task.dart
import 'package:hive/hive.dart';
part 'task.g.dart';

@HiveType(typeId: 0)
class Task extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  bool done;

  @HiveField(2)
  String? categoryId;

  Task({required this.title, this.done = false, this.categoryId});
}
