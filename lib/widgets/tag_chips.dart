import 'package:flutter/material.dart';

import '../models/tag.dart';

/// Etiquetas en filas que saltan de línea (Wrap).
/// Con [onTagDelete] cada chip muestra una X para quitar la etiqueta.
/// Con [onTagTap] cada chip se puede tocar.
class TagChips extends StatelessWidget {
  const TagChips({
    super.key,
    required this.tags,
    this.onTagTap,
    this.onTagDelete,
    this.compact = false,
  });

  final List<Tag> tags;
  final ValueChanged<Tag>? onTagTap;
  final ValueChanged<Tag>? onTagDelete;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [for (final tag in tags) _buildChip(tag)],
    );
  }

  Widget _buildChip(Tag tag) {
    final label = Text(tag.name);
    final avatar = tag.color == null
        ? null
        : CircleAvatar(radius: 5, backgroundColor: tag.color);
    final density = compact ? VisualDensity.compact : VisualDensity.standard;

    if (onTagDelete != null) {
      return InputChip(
        label: label,
        avatar: avatar,
        visualDensity: density,
        onPressed: onTagTap == null ? null : () => onTagTap!(tag),
        onDeleted: () => onTagDelete!(tag),
        deleteIconColor: const Color(0xFF1A1714),
        tooltip: 'Quitar etiqueta',
      );
    }
    if (onTagTap != null) {
      return ActionChip(
        label: label,
        avatar: avatar,
        visualDensity: density,
        onPressed: () => onTagTap!(tag),
      );
    }
    return Chip(label: label, avatar: avatar, visualDensity: density);
  }
}
