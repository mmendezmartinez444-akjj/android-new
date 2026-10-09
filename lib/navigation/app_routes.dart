import 'package:flutter/material.dart';

import '../screens/note_detail_screen.dart';
import '../screens/note_editor_screen.dart';
import '../screens/project_notes_screen.dart';
import '../screens/tags_screen.dart';

/// Todas las rutas usan Navigator.push con MaterialPageRoute.
/// Centralizarlas evita repetir la construcción de rutas en cada pantalla.
void _push(BuildContext context, Widget page) {
  Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
}

void openProjectNotes(BuildContext context, String projectId) {
  _push(context, ProjectNotesScreen(projectId: projectId));
}

void openNoteDetail(BuildContext context, String noteId) {
  _push(context, NoteDetailScreen(noteId: noteId));
}

/// Crea una nota (projectId) o edita una existente (noteId).
void openNoteEditor(BuildContext context, {String? noteId, String? projectId}) {
  _push(context, NoteEditorScreen(noteId: noteId, projectId: projectId));
}

/// Abre Etiquetas con las etiquetas indicadas ya seleccionadas.
void openTagsFiltered(BuildContext context, String tagId) {
  _push(context, TagsScreen(initialTagIds: {tagId}));
}
