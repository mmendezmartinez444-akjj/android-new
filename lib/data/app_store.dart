import 'package:flutter/foundation.dart';

import '../models/note.dart';
import '../models/project.dart';
import '../models/tag.dart';
import 'seed_data.dart';
import 'text_utils.dart';

/// Criterios para buscar notas. Todos son opcionales.
class NoteQuery {
  const NoteQuery({
    this.projectId,
    this.text = '',
    this.tagIds = const {},
    this.matchAll = false,
  });

  final String? projectId;
  final String text;
  final Set<String> tagIds;

  /// true: la nota debe tener todas las etiquetas. false: al menos una.
  final bool matchAll;
}

/// Almacén en memoria de proyectos, notas y etiquetas.
/// Notifica a los widgets que dependen de él cada vez que cambian los datos.
class AppStore extends ChangeNotifier {
  AppStore({required SeedData seed})
      : _projects = List.of(seed.projects),
        _notes = List.of(seed.notes),
        _tags = List.of(seed.tags);

  factory AppStore.withSampleData() => AppStore(seed: SeedData.create());

  final List<Project> _projects;
  final List<Note> _notes;
  final List<Tag> _tags;
  int _nextId = 1;

  // ---------------------------------------------------------------------------
  // Proyectos
  // ---------------------------------------------------------------------------

  /// Proyectos ordenados por última modificación (más reciente primero).
  List<Project> get projects => _sortProjects(_projects);

  Project? projectById(String id) => _find(_projects, (p) => p.id == id);

  int notesCountInProject(String projectId) =>
      _notes.where((n) => n.projectId == projectId).length;

  Project addProject({required String name, required String description}) {
    _requireName(name, 'El nombre del proyecto es obligatorio.');
    final now = DateTime.now();
    final project = Project(
      id: _newId('proj'),
      name: name.trim(),
      description: description.trim(),
      createdAt: now,
      updatedAt: now,
    );
    _projects.add(project);
    notifyListeners();
    return project;
  }

  void updateProject(
    String id, {
    required String name,
    required String description,
  }) {
    _requireName(name, 'El nombre del proyecto es obligatorio.');
    final index = _projects.indexWhere((p) => p.id == id);
    if (index == -1) return;
    _projects[index] = _projects[index].copyWith(
      name: name.trim(),
      description: description.trim(),
      updatedAt: DateTime.now(),
    );
    notifyListeners();
  }

  /// Elimina el proyecto y sus notas. Las etiquetas se conservan.
  void deleteProject(String id) {
    _projects.removeWhere((p) => p.id == id);
    _notes.removeWhere((n) => n.projectId == id);
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Notas
  // ---------------------------------------------------------------------------

  Note? noteById(String id) => _find(_notes, (n) => n.id == id);

  /// Notas de un proyecto, más recientes primero.
  List<Note> notesInProject(String projectId) =>
      queryNotes(NoteQuery(projectId: projectId));

  /// Busca notas en todos los proyectos según [query]. Más recientes primero.
  List<Note> queryNotes(NoteQuery query) {
    final text = normalizeText(query.text);
    final matches = _notes.where((note) {
      if (query.projectId != null && note.projectId != query.projectId) {
        return false;
      }
      if (query.tagIds.isNotEmpty) {
        final hasTags = query.matchAll
            ? query.tagIds.every(note.tagIds.contains)
            : query.tagIds.any(note.tagIds.contains);
        if (!hasTags) return false;
      }
      if (text.isEmpty) return true;
      return normalizeText(note.title).contains(text) ||
          normalizeText(note.description).contains(text);
    });
    return _sortNotes(matches);
  }

  Note createNote({
    required String projectId,
    required String title,
    required String description,
    required List<String> tagIds,
  }) {
    _requireName(title, 'El título es obligatorio.');
    final now = DateTime.now();
    final note = Note(
      id: _newId('note'),
      projectId: projectId,
      title: title.trim(),
      description: description,
      createdAt: now,
      updatedAt: now,
      tagIds: _validTagIds(tagIds),
    );
    _notes.add(note);
    notifyListeners();
    return note;
  }

  void updateNote(
    String id, {
    required String title,
    required String description,
    required List<String> tagIds,
  }) {
    _requireName(title, 'El título es obligatorio.');
    final index = _notes.indexWhere((n) => n.id == id);
    if (index == -1) return;
    _notes[index] = _notes[index].copyWith(
      title: title.trim(),
      description: description,
      updatedAt: DateTime.now(),
      tagIds: _validTagIds(tagIds),
    );
    notifyListeners();
  }

  void deleteNote(String id) {
    _notes.removeWhere((n) => n.id == id);
    notifyListeners();
  }

  /// Etiquetas de una nota, ordenadas por nombre.
  List<Tag> tagsOf(Note note) {
    final tags = note.tagIds.map(tagById).whereType<Tag>().toList();
    tags.sort((a, b) => normalizeText(a.name).compareTo(normalizeText(b.name)));
    return tags;
  }

  // ---------------------------------------------------------------------------
  // Etiquetas
  // ---------------------------------------------------------------------------

  /// Todas las etiquetas ordenadas por nombre.
  List<Tag> get tags {
    final sorted = [..._tags];
    sorted.sort((a, b) => normalizeText(a.name).compareTo(normalizeText(b.name)));
    return sorted;
  }

  Tag? tagById(String id) => _find(_tags, (t) => t.id == id);

  /// Etiquetas cuyo nombre contiene [query], ignorando mayúsculas y acentos.
  List<Tag> searchTags(String query) {
    final text = normalizeText(query);
    return tags.where((t) => normalizeText(t.name).contains(text)).toList();
  }

  /// Sugerencias para el autocompletado: contienen [query] y no están en [exclude].
  /// Las coincidencias exactas van primero, luego las que empiezan por el texto.
  List<Tag> suggestTags(String query, {Set<String> exclude = const {}}) {
    final text = normalizeText(query);
    if (text.isEmpty) return [];

    int rank(String name) {
      if (name == text) return 0;
      if (name.startsWith(text)) return 1;
      return 2;
    }

    final matches = _tags
        .where((t) => !exclude.contains(t.id) && normalizeText(t.name).contains(text))
        .toList();
    matches.sort((a, b) {
      final nameA = normalizeText(a.name);
      final nameB = normalizeText(b.name);
      final byRank = rank(nameA).compareTo(rank(nameB));
      return byRank != 0 ? byRank : nameA.compareTo(nameB);
    });
    return matches;
  }

  /// Etiqueta con el mismo nombre normalizado, si existe.
  Tag? findTagByName(String name) {
    final key = normalizeText(name);
    if (key.isEmpty) return null;
    return _find(_tags, (t) => normalizeText(t.name) == key);
  }

  /// Devuelve un mensaje de error si [name] no puede usarse como nombre de etiqueta.
  String? tagNameError(String name, {String? exceptId}) {
    if (normalizeText(name).isEmpty) {
      return 'El nombre no puede estar vacío.';
    }
    final existing = findTagByName(name);
    if (existing != null && existing.id != exceptId) {
      return 'Ya existe una etiqueta llamada "${existing.name}".';
    }
    return null;
  }

  /// Devuelve la etiqueta existente con ese nombre o crea una nueva.
  /// Nunca crea duplicados.
  Tag getOrCreateTag(String name) {
    _requireName(name, 'El nombre de la etiqueta es obligatorio.');
    final existing = findTagByName(name);
    if (existing != null) return existing;
    final tag = Tag(id: _newId('tag'), name: _cleanSpaces(name));
    _tags.add(tag);
    notifyListeners();
    return tag;
  }

  /// Número de notas que usan la etiqueta.
  int notesUsingTag(String tagId) =>
      _notes.where((n) => n.tagIds.contains(tagId)).length;

  /// Etiquetas presentes en las notas de un proyecto.
  List<Tag> tagsUsedInProject(String projectId) {
    final usedIds = _notes
        .where((n) => n.projectId == projectId)
        .expand((n) => n.tagIds)
        .toSet();
    return tags.where((t) => usedIds.contains(t.id)).toList();
  }

  /// Renombra una etiqueta. Devuelve un mensaje de error o null si se renombró.
  String? renameTag(String id, String newName) {
    final error = tagNameError(newName, exceptId: id);
    if (error != null) return error;
    final index = _tags.indexWhere((t) => t.id == id);
    if (index == -1) return null;
    _tags[index] = _tags[index].copyWith(name: _cleanSpaces(newName));
    notifyListeners();
    return null;
  }

  /// Elimina la etiqueta de todas las notas. Las notas no se borran.
  void deleteTag(String id) {
    _tags.removeWhere((t) => t.id == id);
    for (var i = 0; i < _notes.length; i++) {
      final note = _notes[i];
      if (note.tagIds.contains(id)) {
        _notes[i] = note.copyWith(
          tagIds: note.tagIds.where((tagId) => tagId != id).toList(),
        );
      }
    }
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Utilidades internas
  // ---------------------------------------------------------------------------

  String _newId(String prefix) =>
      '$prefix-${DateTime.now().microsecondsSinceEpoch}-${_nextId++}';

  List<String> _validTagIds(List<String> ids) {
    final valid = ids.where((id) => tagById(id) != null).toSet();
    return valid.toList();
  }

  static String _cleanSpaces(String name) => name.trim().replaceAll(RegExp(r'\s+'), ' ');

  static void _requireName(String value, String message) {
    if (normalizeText(value).isEmpty) throw ArgumentError(message);
  }

  static T? _find<T>(Iterable<T> items, bool Function(T) test) {
    for (final item in items) {
      if (test(item)) return item;
    }
    return null;
  }

  static List<Project> _sortProjects(Iterable<Project> items) {
    final sorted = items.toList();
    sorted.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return sorted;
  }

  static List<Note> _sortNotes(Iterable<Note> items) {
    final sorted = items.toList();
    sorted.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return sorted;
  }
}
