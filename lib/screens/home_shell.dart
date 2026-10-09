import 'package:flutter/material.dart';

import 'projects_screen.dart';
import 'search_screen.dart';
import 'tags_screen.dart';

/// Contenedor con la BottomNavigationBar.
/// IndexedStack mantiene vivas las tres pestañas, así que cada una conserva
/// su texto de búsqueda, filtros y posición de scroll al cambiar de pestaña.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _currentIndex = 0;

  static const _tabs = [
    ProjectsScreen(),
    TagsScreen(),
    SearchScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _tabs),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.folder_outlined),
            activeIcon: Icon(Icons.folder),
            label: 'Proyectos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sell_outlined),
            activeIcon: Icon(Icons.sell),
            label: 'Etiquetas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            activeIcon: Icon(Icons.manage_search),
            label: 'Buscar',
          ),
        ],
      ),
    );
  }
}
