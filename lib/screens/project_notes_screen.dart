import 'package:flutter/material.dart';

import '../data/app_scope.dart';
import '../data/app_store.dart';
import '../models/note.dart';
import '../models/tag.dart';
import '../navigation/app_routes.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/empty_state.dart';
import '../widgets/match_mode_selector.dart';
import '../widgets/note_tile.dart';
import '../widgets/tag_filter_bar.dart';

/// Notas de un proyecto con búsqueda y filtro por etiquetas.
class ProjectNotesScreen extends StatefulWidget {
  const ProjectNotesScreen({super.key, required this.projectId});

  final String projectId;

  @override
  State<ProjectNotesScreen> createState() => _ProjectNotesScreenState();
}

class _ProjectNotesScreenState extends State<ProjectNotesScreen> {
  final _searchController = TextEditingController();
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
    final project = store.projectById(widget.projectId);
    if (project == null) {
      return const Scaffold(
        body: EmptyState(icon: Icons.folder_off_outlined, message: 'Este proyecto ya no existe.'),
      );
    }

    // Solo se ofrecen etiquetas presentes en las notas del proyecto.
    final projectTags = store.tagsUsedInProject(project.id);
    final activeTagIds = _selectedTagIds
        .where((id) => projectTags.any((tag) => tag.id == id))
        .toSet();
    final totalNotes = store.notesCountInProject(project.id);
    final notes = store.queryNotes(NoteQuery(
      projectId: project.id,
      text: _searchController.text,
      tagIds: activeTagIds,
      matchAll: _matchAll,
    ));

    return Scaffold(
      appBar: AppBar(title: const Text('Notas del proyecto')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => openNoteEditor(context, projectId: project.id),
        icon: const Icon(Icons.note_add_outlined),
        label: const Text('Nueva nota'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: _ProjectHeader(name: project.name, description: project.description, noteCount: totalNotes),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
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
          if (projectTags.isNotEmpty) ...[
            const SizedBox(height: 8),
            TagFilterBar(
              tags: projectTags,
              selectedIds: activeTagIds,
              onToggle: _toggleTag,
            ),
          ],
          if (activeTagIds.length > 1)
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
          const SizedBox(height: 4),
          Expanded(
            child: _buildNotes(context, notes, totalNotes),
          ),
        ],
      ),
    );
  }

  Widget _buildNotes(BuildContext context, List<Note> notes, int totalNotes) {
    if (totalNotes == 0) {
      return const EmptyState(
        icon: Icons.note_add_outlined,
        message: 'Este proyecto todavía no tiene notas.\nPulsa "Nueva nota" para empezar.',
      );
    }
    if (notes.isEmpty) {
      return const EmptyState(
        icon: Icons.search_off,
        message: 'Ninguna nota coincide con la búsqueda o los filtros.',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 96),
      itemCount: notes.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final note = notes[index];
        return NoteTile(
          note: note,
          onTap: () => openNoteDetail(context, note.id),
          onDelete: () => _deleteNote(context, note),
        );
      },
    );
  }

  Future<void> _deleteNote(BuildContext context, Note note) async {
    final confirmed = await confirmAction(
      context,
      title: 'Eliminar nota',
      message: '¿Eliminar "${note.title}"? Esta acción no se puede deshacer.',
      confirmLabel: 'Eliminar',
    );
    if (!confirmed || !context.mounted) return;
    AppScope.of(context).deleteNote(note.id);
  }
}

class _ProjectHeader extends StatelessWidget {
  const _ProjectHeader({required this.name, required this.description, required this.noteCount});

  final String name;
  final String description;
  final int noteCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        if (description.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(description, style: theme.textTheme.bodyMedium),
        ],
        const SizedBox(height: 6),
        Text(
          '$noteCount ${noteCount == 1 ? 'nota' : 'notas'} en este proyecto',
          style: theme.textTheme.labelLarge,
        ),
      ],
    );
  }
}
