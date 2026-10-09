import 'package:flutter/material.dart';

import '../data/app_scope.dart';
import '../data/text_utils.dart';
import '../models/note.dart';
import 'tag_chips.dart';

/// Fila de una nota: título, proyecto (opcional), extracto, etiquetas y fecha.
class NoteTile extends StatelessWidget {
  const NoteTile({
    super.key,
    required this.note,
    required this.onTap,
    this.showProject = false,
    this.onDelete,
  });

  final Note note;
  final VoidCallback onTap;
  final bool showProject;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final theme = Theme.of(context);
    final project = showProject ? store.projectById(note.projectId) : null;
    final tags = store.tagsOf(note);
    final hasDescription = note.description.trim().isNotEmpty;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 4, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    note.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  if (project != null) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.folder_outlined, size: 14),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            project.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelMedium,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (hasDescription) ...[
                    const SizedBox(height: 6),
                    Text(
                      excerpt(note.description),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                  if (tags.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    TagChips(tags: tags, compact: true),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    'Modificada ${formatDate(note.updatedAt)}',
                    style: theme.textTheme.labelSmall,
                  ),
                ],
              ),
            ),
            if (onDelete != null)
              IconButton(
                tooltip: 'Eliminar nota',
                icon: const Icon(Icons.delete_outline),
                onPressed: onDelete,
              ),
          ],
        ),
      ),
    );
  }
}
