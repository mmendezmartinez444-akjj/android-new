import 'package:flutter/material.dart';

/// Elige si una nota debe tener todas las etiquetas seleccionadas o al menos una.
class MatchModeSelector extends StatelessWidget {
  const MatchModeSelector({
    super.key,
    required this.matchAll,
    required this.onChanged,
  });

  final bool matchAll;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<bool>(
      showSelectedIcon: false,
      segments: const [
        ButtonSegment<bool>(value: true, label: Text('Todas')),
        ButtonSegment<bool>(value: false, label: Text('Al menos una')),
      ],
      selected: {matchAll},
      onSelectionChanged: (selection) => onChanged(selection.first),
    );
  }
}
