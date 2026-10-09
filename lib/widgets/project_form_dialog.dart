import 'package:flutter/material.dart';

import '../models/project.dart';

/// Datos de un proyecto escritos en el diálogo.
typedef ProjectDraft = ({String name, String description});

/// Diálogo para crear o editar un proyecto. Devuelve null si se cancela.
Future<ProjectDraft?> showProjectFormDialog(BuildContext context, {Project? project}) {
  return showDialog<ProjectDraft>(
    context: context,
    builder: (_) => _ProjectFormDialog(project: project),
  );
}

class _ProjectFormDialog extends StatefulWidget {
  const _ProjectFormDialog({this.project});

  final Project? project;

  @override
  State<_ProjectFormDialog> createState() => _ProjectFormDialogState();
}

class _ProjectFormDialogState extends State<_ProjectFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController =
      TextEditingController(text: widget.project?.name ?? '');
  late final TextEditingController _descriptionController =
      TextEditingController(text: widget.project?.description ?? '');

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.of(context).pop((
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.project != null;
    return AlertDialog(
      title: Text(isEditing ? 'Editar proyecto' : 'Nuevo proyecto'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: 'Nombre *'),
              validator: (value) => (value ?? '').trim().isEmpty
                  ? 'El nombre es obligatorio.'
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              textCapitalization: TextCapitalization.sentences,
              maxLines: 2,
              maxLength: 120,
              decoration: const InputDecoration(labelText: 'Descripción corta'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
