import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category.dart';
import '../models/task.dart';
import '../providers.dart';

class CategoryTasksScreen extends ConsumerWidget {
  final Category category;
  const CategoryTasksScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(tasksProvider);
    final catId = category.key.toString();

    final accent = Colors
        .primaries[category.name.hashCode % Colors.primaries.length]
        .shade500;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text('Tareas: ${category.name}'),
        backgroundColor: accent,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: tasksAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (allTasks) {
          if (allTasks.isEmpty) {
            return const Center(
              child: Text(
                'Aún no hay tareas',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: allTasks.length,
            itemBuilder: (_, i) {
              final t = allTasks[i];
              final inThis = t.categoryId == catId;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border(left: BorderSide(color: accent, width: 4)),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: CheckboxListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 16,
                  ),
                  activeColor: accent,
                  title: Text(
                    t.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      decoration: t.done ? TextDecoration.lineThrough : null,
                      color: t.done ? Colors.grey.shade600 : Colors.black87,
                    ),
                  ),
                  value: inThis,
                  controlAffinity: ListTileControlAffinity.leading,
                  secondary: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    color: Colors.red.shade400,
                    onPressed: () => ref.read(taskRepoProvider).remove(t),
                  ),
                  onChanged: (checked) {
                    ref
                        .read(taskRepoProvider)
                        .updateCategory(t, checked! ? catId : null);
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'category_fab_${category.key}',
        backgroundColor: accent,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => _showAddForCategory(context, ref),
      ),
    );
  }

  Future<void> _showAddForCategory(BuildContext context, WidgetRef ref) {
    final ctrl = TextEditingController();
    final accent = Colors
        .primaries[category.name.hashCode % Colors.primaries.length]
        .shade500;

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: ctrl,
              decoration: InputDecoration(
                labelText: 'Título de la tarea',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: const Color(0xFFF9F9F9),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.check_circle_outline),
                label: Text('Crear en "${category.name}"'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  final text = ctrl.text.trim();
                  if (text.isNotEmpty) {
                    ref
                        .read(taskRepoProvider)
                        .add(
                          Task(
                            title: text,
                            categoryId: category.key.toString(),
                          ),
                        );
                    Navigator.pop(context);
                  }
                },
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
