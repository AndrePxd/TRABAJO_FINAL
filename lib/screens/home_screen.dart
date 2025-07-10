import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';
import 'tasks_tab.dart';
import 'categories_tab.dart';
import 'notes_tab.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  late final TabController _tabController;

  final List<Map<String, dynamic>> _tabs = [
    {'label': 'Tareas', 'icon': Icons.checklist},
    {'label': 'Categorías', 'icon': Icons.category_outlined},
    {'label': 'Notas', 'icon': Icons.note_alt_outlined},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          'GESTOR DE TAREAS',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: () => ref.read(authRepoProvider).signOut(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: primaryColor,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600),
          tabs: _tabs
              .map((tab) => Tab(icon: Icon(tab['icon']), text: tab['label']))
              .toList(),

          onTap: (_) => setState(() {}), // actualiza el índice
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(),
        children: const [TasksTab(), CategoriesTab(), NotesTab()],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_main',
        backgroundColor: primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          switch (_tabController.index) {
            case 0:
              TasksTab.showAddDialog(context, ref);
              break;
            case 1:
              CategoriesTab.showAddDialog(context, ref);
              break;
            case 2:
              NotesTab.showAddDialog(context, ref);
              break;
          }
        },
      ),
    );
  }
}
