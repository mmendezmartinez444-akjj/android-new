import 'package:flutter/material.dart';

import '../data/app_scope.dart';
import '../data/app_store.dart';
import '../models/tag.dart';
import '../navigation/app_routes.dart';
import '../widgets/empty_state.dart';
import '../widgets/match_mode_selector.dart';
import '../widgets/note_tile.dart';
import '../widgets/tag_filter_bar.dart';

/// Pestaña Buscar: búsqueda global por título o contenido, con filtros de proyecto y etiquetas.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  String? _projectId;
  final _selectedTagIds = <String>{};
  bool _matchAll = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleTag(Tag tag) {
    setState(() {
      if (!_selectedTagIds.remove(tag.id)) _selectedTagIds.add(tag.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final projects = store.projects;
    final tags = store.tags;

    // Descarta filtros que apuntan a proyectos o etiquetas ya eliminados.
    final projectId = projects.any((p) => p.id == _projectId) ? _projectId : null;
    final selectedTagIds = _selectedTagIds.where((id) => store.tagById(id) != null).toSet();

    final notes = store.queryNotes(NoteQuery(
      projectId: projectId,
      text: _searchController.text,
      tagIds: selectedTagIds,
      matchAll: _matchAll,
    ));

    return Scaffold(
      appBar: AppBar(title: const Text('Buscar')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Buscar por título o contenido',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Limpiar búsqueda',
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      ),
              ),
            ),
          ),
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              itemCount: projects.length + 1,
              itemBuilder: (context, index) {
                final isAll = index == 0;
                final project = isAll ? null : projects[index - 1];
                final selected = isAll ? projectId == null : projectId == project!.id;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(isAll ? 'Todos los proyectos' : project!.name),
                    selected: selected,
                    visualDensity: VisualDensity.compact,
                    onSelected: (_) => setState(() => _projectId = project?.id),
                  ),
                );
              },
            ),
          ),
          if (tags.isNotEmpty) ...[
            const SizedBox(height: 4),
            TagFilterBar(
              tags: tags,
              selectedIds: selectedTagIds,
              onToggle: _toggleTag,
            ),
          ],
          if (selectedTagIds.length > 1)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: MatchModeSelector(
                  matchAll: _matchAll,
                  onChanged: (value) => setState(() => _matchAll = value),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text(
              '${notes.length} ${notes.length == 1 ? 'resultado' : 'resultados'}',
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
          Expanded(
            child: notes.isEmpty
                ? const EmptyState(
                    icon: Icons.search_off,
                    message: 'No se encontraron notas con esos criterios.',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: notes.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final note = notes[index];
                      return NoteTile(
                        note: note,
                        showProject: true,
                        onTap: () => openNoteDetail(context, note.id),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
