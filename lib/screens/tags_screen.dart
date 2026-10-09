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
import '../widgets/tag_name_dialog.dart';

/// Pantalla Etiquetas: gestiona etiquetas y agrupa las notas de todos los proyectos por ellas.
/// Se usa como pestaña y también abierta desde el detalle de una nota con [initialTagIds].
class TagsScreen extends StatefulWidget {
  const TagsScreen({super.key, this.initialTagIds = const {}});

  final Set<String> initialTagIds;

  @override
  State<TagsScreen> createState() => _TagsScreenState();
}

class _TagsScreenState extends State<TagsScreen> {
  final _searchController = TextEditingController();
  late final Set<String> _selectedTagIds = {...widget.initialTagIds};
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

  Future<void> _createTag() async {
    final name = await showTagNameDialog(context, title: 'Nueva etiqueta');
    if (name == null || !mounted) return;
    AppScope.of(context).getOrCreateTag(name);
  }

  Future<void> _renameTag(Tag tag) async {
    final name = await showTagNameDialog(
      context,
      title: 'Renombrar etiqueta',
      initialName: tag.name,
      excludeTagId: tag.id,
    );
    if (name == null || !mounted) return;
    final error = AppScope.of(context).renameTag(tag.id, name);
    if (error != null) _showMessage(error);
  }

  Future<void> _deleteTag(Tag tag) async {
    final store = AppScope.of(context);
    final noteCount = store.notesUsingTag(tag.id);
    final message = noteCount == 0
        ? 'La etiqueta "${tag.name}" no está en ninguna nota.'
        : 'La etiqueta "${tag.name}" se quitará de $noteCount '
            '${noteCount == 1 ? 'nota' : 'notas'}. Las notas no se borrarán.';
    final confirmed = await confirmAction(
      context,
      title: 'Eliminar etiqueta',
      message: message,
      confirmLabel: 'Eliminar',
    );
    if (!confirmed || !mounted) return;
    setState(() => _selectedTagIds.remove(tag.id));
    AppScope.of(context).deleteTag(tag.id);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final visibleTags = store.searchTags(_searchController.text);
    final allTagsEmpty = store.tags.isEmpty;

    // Ignora etiquetas seleccionadas que ya no existen.
    final selected = _selectedTagIds.where((id) => store.tagById(id) != null).toSet();
    final notes = store.queryNotes(NoteQuery(tagIds: selected, matchAll: _matchAll));

    return Scaffold(
      appBar: AppBar(title: const Text('Etiquetas')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createTag,
        icon: const Icon(Icons.add),
        label: const Text('Nueva etiqueta'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Buscar etiqueta por nombre',
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
          Expanded(
            flex: 2,
            child: allTagsEmpty
                ? const EmptyState(
                    icon: Icons.sell_outlined,
                    message: 'No hay etiquetas todavía.\nCrea una con el botón "Nueva etiqueta".',
                  )
                : visibleTags.isEmpty
                    ? const EmptyState(
                        icon: Icons.search_off,
                        message: 'Ninguna etiqueta coincide con la búsqueda.',
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 8),
                        itemCount: visibleTags.length,
                        itemBuilder: (context, index) {
                          final tag = visibleTags[index];
                          return _TagRow(
                            tag: tag,
                            selected: selected.contains(tag.id),
                            onToggle: () => _toggleTag(tag),
                            onRename: () => _renameTag(tag),
                            onDelete: () => _deleteTag(tag),
                          );
                        },
                      ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 8, 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    selected.isEmpty
                        ? 'Selecciona etiquetas para agrupar notas'
                        : '${notes.length} ${notes.length == 1 ? 'nota' : 'notas'} encontradas',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
                if (selected.isNotEmpty)
                  TextButton(
                    onPressed: () => setState(_selectedTagIds.clear),
                    child: const Text('Limpiar'),
                  ),
              ],
            ),
          ),
          if (selected.length > 1)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: MatchModeSelector(
                  matchAll: _matchAll,
                  onChanged: (value) => setState(() => _matchAll = value),
                ),
              ),
            ),
          Expanded(
            flex: 3,
            child: _buildNotes(context, selected, notes),
          ),
        ],
      ),
    );
  }

  Widget _buildNotes(BuildContext context, Set<String> selected, List<Note> notes) {
    if (selected.isEmpty) {
      return const EmptyState(
        icon: Icons.touch_app_outlined,
        message: 'Toca una o más etiquetas para ver las notas que las tienen, de todos los proyectos.',
      );
    }
    if (notes.isEmpty) {
      return const EmptyState(
        icon: Icons.search_off,
        message: 'Ninguna nota tiene las etiquetas seleccionadas.',
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
          showProject: true,
          onTap: () => openNoteDetail(context, note.id),
        );
      },
    );
  }
}

class _TagRow extends StatelessWidget {
  const _TagRow({
    required this.tag,
    required this.selected,
    required this.onToggle,
    required this.onRename,
    required this.onDelete,
  });

  final Tag tag;
  final bool selected;
  final VoidCallback onToggle;
  final VoidCallback onRename;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final noteCount = store.notesUsingTag(tag.id);

    return ListTile(
      selected: selected,
      selectedTileColor: Theme.of(context).colorScheme.secondaryContainer,
      onTap: onToggle,
      leading: Checkbox(value: selected, onChanged: (_) => onToggle()),
      title: Row(
        children: [
          if (tag.color != null) ...[
            CircleAvatar(radius: 5, backgroundColor: tag.color),
            const SizedBox(width: 8),
          ],
          Flexible(child: Text(tag.name, overflow: TextOverflow.ellipsis)),
        ],
      ),
      subtitle: Text('$noteCount ${noteCount == 1 ? 'nota' : 'notas'}'),
      trailing: PopupMenuButton<String>(
        tooltip: 'Opciones de la etiqueta',
        icon: const Icon(Icons.more_vert),
        onSelected: (value) => value == 'rename' ? onRename() : onDelete(),
        itemBuilder: (_) => const [
          PopupMenuItem(
            value: 'rename',
            child: ListTile(
              leading: Icon(Icons.edit_outlined),
              title: Text('Renombrar'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
          PopupMenuItem(
            value: 'delete',
            child: ListTile(
              leading: Icon(Icons.delete_outline),
              title: Text('Eliminar'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}
