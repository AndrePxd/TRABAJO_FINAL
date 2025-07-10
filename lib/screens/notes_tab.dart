import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/note.dart';
import '../providers.dart';
import 'note_detail_screen.dart';

class NotesTab extends ConsumerWidget {
  const NotesTab({super.key});

  static Future<void> showAddDialog(BuildContext context, WidgetRef ref) async {
    final ctrl = TextEditingController();
    final text = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Nueva nota',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: ctrl,
          decoration: InputDecoration(
            labelText: 'Texto',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: const Color(0xFFF9F9F9),
          ),
          maxLines: 3,
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurpleAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            onPressed: () => Navigator.pop(context, ctrl.text.trim()),
            child: const Text('CREAR'),
          ),
        ],
      ),
    );

    if (text != null && text.isNotEmpty) {
      final user = ref.read(authStateProvider).value!;
      ref
          .read(noteRepoProvider)
          .add(Note(id: '', text: text, author: user.email ?? 'anónimo'));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(notesProvider);
    final query = ref.watch(noteSearchQueryProvider);
    final filter = ref.watch(noteFilterTypeProvider);
    final myEmail = ref.read(authStateProvider).value?.email ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (value) =>
                        ref.read(noteSearchQueryProvider.notifier).state =
                            value,
                    decoration: InputDecoration(
                      hintText: 'Buscar por título...',
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                DropdownButton<String>(
                  value: filter,
                  items: const [
                    DropdownMenuItem(value: 'Todas', child: Text('Todas')),
                    DropdownMenuItem(value: 'Mis notas', child: Text('Mías')),
                    DropdownMenuItem(value: 'Otras', child: Text('Otras')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      ref.read(noteFilterTypeProvider.notifier).state = value;
                    }
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: notesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (list) {
                // Aplicar búsqueda y filtro
                var filtered = list.where(
                  (n) => n.text.toLowerCase().contains(query.toLowerCase()),
                );

                if (filter == 'Mis notas') {
                  filtered = filtered.where((n) => n.author == myEmail);
                } else if (filter == 'Otras') {
                  filtered = filtered.where((n) => n.author != myEmail);
                }

                final finalList = filtered.toList();

                if (finalList.isEmpty) {
                  return const Center(
                    child: Text(
                      'No se encontraron notas',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: finalList.length,
                  itemBuilder: (_, i) {
                    final n = finalList[i];
                    final accent = Colors
                        .primaries[n.author.hashCode % Colors.primaries.length]
                        .shade400;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                        border: Border(
                          left: BorderSide(color: accent, width: 4),
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => NoteDetailScreen(note: n),
                          ),
                        ),
                        title: Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            n.text,
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        subtitle: Text(
                          'Por: ${n.author}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        trailing: myEmail == n.author
                            ? IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () =>
                                    ref.read(noteRepoProvider).remove(n.id),
                                color: Colors.red.shade400,
                              )
                            : null,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAddDialog(context, ref),
        backgroundColor: Colors.deepPurpleAccent,
        child: const Icon(Icons.note_add_rounded, color: Colors.white),
      ),
    );
  }
}
