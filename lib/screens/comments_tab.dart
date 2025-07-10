/*
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';
import '../models/comment.dart';

class CommentsTab extends ConsumerStatefulWidget {
  const CommentsTab({super.key});

  @override
  ConsumerState<CommentsTab> createState() => _CommentsTabState();
}

class _CommentsTabState extends ConsumerState<CommentsTab> {
  final _ctrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final commentsAsync = ref.watch(commentsProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _ctrl,
                  decoration: const InputDecoration(
                    labelText: 'Nuevo comentario',
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  final text = _ctrl.text.trim();
                  if (text.isNotEmpty) {
                    final c = Comment(id: '', text: text);
                    ref.read(commentRepoProvider).add(c);
                    _ctrl.clear();
                  }
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: commentsAsync.when(
            data: (list) => ListView(
              children: list
                  .map(
                    (c) => ListTile(
                      title: Text(c.text),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () =>
                            ref.read(commentRepoProvider).remove(c.id),
                      ),
                    ),
                  )
                  .toList(),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
          ),
        ),
      ],
    );
  }
}
*/
