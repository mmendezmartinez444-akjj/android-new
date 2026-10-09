import 'package:flutter/material.dart';

/// Etiqueta global. No pertenece a ningún proyecto y puede usarse en notas de cualquier proyecto.
class Tag {
  const Tag({required this.id, required this.name, this.color});

  final String id;
  final String name;

  /// Color opcional, usado solo como indicador visual.
  final Color? color;

  Tag copyWith({String? name}) => Tag(id: id, name: name ?? this.name, color: color);
}
