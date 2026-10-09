import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../data/app_scope.dart';
import '../models/tag.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/tag_autocomplete_field.dart';
import '../widgets/tag_chips.dart';

/// Editor para crear una nota (projectId) o editar una existente (noteId).
/// Mantiene un borrador local y avisa si se intenta salir con cambios sin guardar.
class NoteEditorScreen extends StatefulWidget {
  const NoteEditorScreen({super.key, this.noteId, this.projectId})
      : assert(noteId != null || projectId != null, 'Se necesita noteId o projectId.');

  final String? noteId;
  final String? projectId;

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  // Valores originales, para saber si hay cambios sin guardar.
  late final String _originalTitle;
  late final String _originalDescription;
  late final List<String> _originalTagIds;

  // Borrador de etiquetas en edición.
  late List<String> _tagIds;

  bool get _isEditing => widget.noteId != null;

  bool get _hasChanges {
    return _titleController.text != _originalTitle ||
        _descriptionController.text != _originalDescription ||
        !setEquals(_tagIds.toSet(), _originalTagIds.toSet());
  }

  @override
  void initState() {
    super.initState();
    final store = AppScope.read(context);
    final note = widget.noteId == null ? null : store.noteById(widget.noteId!);

    _originalTitle = note?.title ?? '';
    _originalDescription = note?.description ?? '';
    _originalTagIds = note?.tagIds ?? const [];
    _tagIds = [..._originalTagIds];

    _titleController = TextEditingController(text: _originalTitle)..addListener(_refresh);
    _descriptionController = TextEditingController(text: _originalDescription)..addListener(_refresh);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _refresh() => setState(() {});

  void _addTag(Tag tag) {
    if (_tagIds.contains(tag.id)) return;
    setState(() => _tagIds.add(tag.id));
  }

  void _removeTag(Tag tag) {
    setState(() => _tagIds.remove(tag.id));
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final store = AppScope.of(context);
    final title = _titleController.text;
    final description = _descriptionController.text;

    if (_isEditing) {
      store.updateNote(
        widget.noteId!,
        title: title,
        description: description,
        tagIds: _tagIds,
      );
    } else {
      store.createNote(
        projectId: widget.projectId!,
        title: title,
        description: description,
        tagIds: _tagIds,
      );
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final assignedTags = _tagIds.map(store.tagById).whereType<Tag>().toList();

    return PopScope(
      canPop: !_hasChanges,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final discard = await confirmAction(
          context,
          title: 'Descartar cambios',
          message: 'Tienes cambios sin guardar. ¿Quieres salir sin guardarlos?',
          confirmLabel: 'Descartar',
        );
        if (discard && context.mounted) Navigator.of(context).pop();
      },
      child: Scaffold(
        appBar: AppBar(title: Text(_isEditing ? 'Editar nota' : 'Nueva nota')),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _titleController,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.next,
                  maxLength: 120,
                  decoration: const InputDecoration(
                    labelText: 'Título *',
                    prefixIcon: Icon(Icons.title),
                  ),
                  validator: (value) => (value ?? '').trim().isEmpty
                      ? 'El título es obligatorio.'
                      : null,
                ),
                const SizedBox(height: 16),
                Text(
                  'Descripción',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                // Altura fija con un TextField expandido: el texto largo hace scroll dentro del campo.
                SizedBox(
                  height: 280,
                  child: TextField(
                    controller: _descriptionController,
                    expands: true,
                    maxLines: null,
                    minLines: null,
                    keyboardType: TextInputType.multiline,
                    textCapitalization: TextCapitalization.sentences,
                    textAlignVertical: TextAlignVertical.top,
                    decoration: const InputDecoration(
                      hintText: 'Escribe aquí el contenido de la nota…',
                      alignLabelWithHint: true,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Etiquetas',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                if (assignedTags.isEmpty)
                  Text(
                    'Esta nota no tiene etiquetas. Añade una abajo.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  )
                else
                  TagChips(tags: assignedTags, onTagDelete: _removeTag),
                const SizedBox(height: 12),
                TagAutocompleteField(
                  assignedTagIds: _tagIds.toSet(),
                  onTagAdded: _addTag,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _save,
                        icon: const Icon(Icons.save_outlined),
                        label: const Text('Guardar'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
