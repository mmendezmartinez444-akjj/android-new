import 'package:flutter/material.dart';

import '../models/tag.dart';

/// Fila horizontal de filtros por etiqueta. Permite elegir varias a la vez.
class TagFilterBar extends StatelessWidget {
  const TagFilterBar({
    super.key,
    required this.tags,
    required this.selectedIds,
    required this.onToggle,
  });

  final List<Tag> tags;
  final Set<String> selectedIds;
  final ValueChanged<Tag> onToggle;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        itemCount: tags.length,
        itemBuilder: (context, index) {
          final tag = tags[index];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(tag.name),
              selected: selectedIds.contains(tag.id),
              onSelected: (_) => onToggle(tag),
              visualDensity: VisualDensity.compact,
            ),
          );
        },
      ),
    );
  }
}
