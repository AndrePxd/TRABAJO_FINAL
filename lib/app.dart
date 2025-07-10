// lib/app.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authStateProvider);

    return MaterialApp(
      title: 'Trabajo Final',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: auth.when(
        data: (user) {
          if (user == null) {
            return const AuthScreen();
          } else {
            // Si HomeScreen usa TabBar, ponlo dentro de DefaultTabController
            return const DefaultTabController(length: 3, child: HomeScreen());
          }
        },
        loading: () =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
      ),
    );
  }
}
