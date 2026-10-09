import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'data/app_scope.dart';
import 'data/app_store.dart';
import 'screens/home_shell.dart';

void main() {
  runApp(const ReNotesApp());
}

class ReNotesApp extends StatefulWidget {
  const ReNotesApp({super.key});

  @override
  State<ReNotesApp> createState() => _ReNotesAppState();
}

class _ReNotesAppState extends State<ReNotesApp> {
  // Se crea una sola vez: los datos viven en memoria mientras la app está abierta.
  final AppStore _store = AppStore.withSampleData();

  @override
  void dispose() {
    _store.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      store: _store,
      child: MaterialApp(
        title: 'ReNotes',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        home: const HomeShell(),
      ),
    );
  }
}
