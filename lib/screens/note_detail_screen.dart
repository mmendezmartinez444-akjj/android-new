import 'package:flutter/material.dart';

import '../data/app_scope.dart';
import '../data/text_utils.dart';
import '../models/note.dart';
import '../navigation/app_routes.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/tag_chips.dart';

/// Detalle de una nota: metadatos, etiquetas (tocables) y descripción completa.
class NoteDetailScreen extends StatelessWidget {
  const NoteDetailScreen({super.key, required this.noteId});

  final String noteId;

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final note = store.noteById(noteId);
    if (note == null) {
      // La nota se eliminó mientras estaba abierta: volvemos al listado anterior.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) Navigator.of(context).maybePop();
      });
      return const Scaffold();
    }

    final theme = Theme.of(context);
    final project = store.projectById(note.projectId);
    final tags = store.tagsOf(note);
    final hasDescription = note.description.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de nota')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              note.title,
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            _MetaLine(icon: Icons.folder_outlined, text: 'Proyecto: ${project?.name ?? 'Sin proyecto'}'),
            _MetaLine(icon: Icons.event_outlined, text: 'Creada: ${formatDate(note.createdAt)}'),
            _MetaLine(icon: Icons.update, text: 'Última modificación: ${formatDate(note.updatedAt)}'),
            const SizedBox(height: 20),
            Text('Etiquetas', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            if (tags.isEmpty)
              Text('Esta nota no tiene etiquetas.', style: theme.textTheme.bodyMedium)
            else
              TagChips(
                tags: tags,
                onTagTap: (tag) => openTagsFiltered(context, tag.id),
              ),
            const SizedBox(height: 20),
            Text('Descripción', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Container(
              height: 320,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.colorScheme.outlineVariant),
              ),
              child: hasDescription
                  ? SingleChildScrollView(
                      child: SelectableText(
                        note.description,
                        style: theme.textTheme.bodyLarge?.copyWith(height: 1.45),
                      ),
                    )
                  : Text(
                      'Sin descripción.',
                      style: theme.textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
                    ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Volver'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _delete(context, note),
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Eliminar'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () => openNoteEditor(context, noteId: note.id),
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Editar nota'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _delete(BuildContext context, Note note) async {
    final confirmed = await confirmAction(
      context,
      title: 'Eliminar nota',
      message: '¿Eliminar "${note.title}"? Esta acción no se puede deshacer.',
      confirmLabel: 'Eliminar',
    );
    if (!confirmed || !context.mounted) return;
    AppScope.of(context).deleteNote(note.id);
    Navigator.of(context).pop();
  }
}

class _MetaLine extends StatelessWidget {
  const _MetaLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: Theme.of(context).textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
