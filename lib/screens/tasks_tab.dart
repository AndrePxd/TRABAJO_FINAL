import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task.dart';
import '../models/category.dart';
import '../providers.dart';

final searchProvider = StateProvider<String>((_) => '');
final selectedCategoryProvider = StateProvider<String?>((_) => null);

class TasksTab extends ConsumerWidget {
  const TasksTab({super.key});

  static Future<void> showAddDialog(BuildContext context, WidgetRef ref) {
    final cats = ref.read(categoriesProvider).value ?? [];
    return const TasksTab()._showAddSheet(context, ref, cats);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(tasksProvider);
    final cats = ref.watch(categoriesProvider).value ?? [];
    final search = ref.watch(searchProvider);
    final selectedCatId = ref.watch(selectedCategoryProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: tasksAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (tasks) {
          final filtered = tasks.where((t) {
            final matchTitle = t.title.toLowerCase().contains(
              search.toLowerCase(),
            );
            final matchCat =
                selectedCatId == null || t.categoryId == selectedCatId;
            return matchTitle && matchCat;
          }).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Buscar tarea...',
                    prefixIcon: Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) =>
                      ref.read(searchProvider.notifier).state = value,
                ),
              ),
              if (cats.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: DropdownButtonFormField<String?>(
                    value: selectedCatId,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      hintText: 'Filtrar por categoría',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                    ),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('Todas las categorías'),
                      ),
                      ...cats.map((c) {
                        final color = Colors
                            .primaries[c.name.hashCode %
                                Colors.primaries.length]
                            .shade500;
                        return DropdownMenuItem<String?>(
                          value: c.key.toString(),
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Text(c.name),
                            ],
                          ),
                        );
                      }),
                    ],
                    onChanged: (v) =>
                        ref.read(selectedCategoryProvider.notifier).state = v,
                  ),
                ),
              const SizedBox(height: 12),
              if (filtered.isEmpty)
                const Expanded(
                  child: Center(child: Text('No hay tareas que coincidan.')),
                ),
              if (filtered.isNotEmpty)
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) {
                      final t = filtered[i];
                      final cat = cats.firstWhere(
                        (c) => c.key.toString() == t.categoryId,
                        orElse: () => Category(name: 'Sin categoría'),
                      );

                      final accent = Colors
                          .primaries[cat.name.hashCode %
                              Colors.primaries.length]
                          .shade500;

                      return Material(
                        color: Colors.white,
                        elevation: 3,
                        borderRadius: BorderRadius.circular(16),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () => ref.read(taskRepoProvider).toggleDone(t),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border(
                                left: BorderSide(color: accent, width: 5),
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 20,
                            ),
                            child: Row(
                              children: [
                                Checkbox(
                                  value: t.done,
                                  onChanged: (_) =>
                                      ref.read(taskRepoProvider).toggleDone(t),
                                  activeColor: accent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    t.title,
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w500,
                                      decoration: t.done
                                          ? TextDecoration.lineThrough
                                          : null,
                                      color: t.done
                                          ? Colors.grey.shade500
                                          : Colors.black87,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: accent.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    cat.name,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontStyle: FontStyle.italic,
                                      color: accent,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  color: Colors.red.shade400,
                                  onPressed: () =>
                                      ref.read(taskRepoProvider).remove(t),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF7C4DFF),
        onPressed: () => showAddDialog(context, ref),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Future<void> _showAddSheet(
    BuildContext context,
    WidgetRef ref,
    List<Category> cats,
  ) {
    final titleCtrl = TextEditingController();
    String? selectedCat;

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
          left: 24,
          right: 24,
          top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: InputDecoration(
                labelText: 'Título de la tarea',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: const Color(0xFFF9F9F9),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Categoría (opcional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: const Color(0xFFF9F9F9),
              ),
              value: selectedCat,
              items: [
                const DropdownMenuItem(value: null, child: Text('— Ninguna —')),
                ...cats.map(
                  (c) => DropdownMenuItem(
                    value: c.key.toString(),
                    child: Text(c.name),
                  ),
                ),
              ],
              onChanged: (v) => selectedCat = v,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Crear tarea'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C4DFF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  final text = titleCtrl.text.trim();
                  if (text.isNotEmpty) {
                    ref
                        .read(taskRepoProvider)
                        .add(Task(title: text, categoryId: selectedCat));
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
