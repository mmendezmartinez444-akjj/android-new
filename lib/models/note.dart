/// Nota de investigación. Pertenece a un solo proyecto y puede tener varias etiquetas.
class Note {
  const Note({
    required this.id,
    required this.projectId,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
    required this.tagIds,
  });

  final String id;
  final String projectId;
  final String title;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Identificadores de las etiquetas asignadas, sin duplicados.
  final List<String> tagIds;

  Note copyWith({
    String? title,
    String? description,
    DateTime? updatedAt,
    List<String>? tagIds,
  }) {
    return Note(
      id: id,
      projectId: projectId,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tagIds: tagIds ?? this.tagIds,
    );
  }
}
