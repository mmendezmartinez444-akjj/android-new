import 'package:flutter/material.dart';

import '../data/app_scope.dart';

/// Diálogo para crear o renombrar una etiqueta.
/// Rechaza nombres vacíos o que ya existan (ignorando mayúsculas y acentos).
/// Devuelve el nombre escrito o null si se cancela.
Future<String?> showTagNameDialog(
  BuildContext context, {
  required String title,
  String initialName = '',
  String? excludeTagId,
}) {
  return showDialog<String>(
    context: context,
    builder: (_) => _TagNameDialog(
      title: title,
      initialName: initialName,
      excludeTagId: excludeTagId,
    ),
  );
}

class _TagNameDialog extends StatefulWidget {
  const _TagNameDialog({
    required this.title,
    required this.initialName,
    this.excludeTagId,
  });

  final String title;
  final String initialName;
  final String? excludeTagId;

  @override
  State<_TagNameDialog> createState() => _TagNameDialogState();
}

class _TagNameDialogState extends State<_TagNameDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller =
      TextEditingController(text: widget.initialName);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.of(context).pop(_controller.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(labelText: 'Nombre de la etiqueta'),
          validator: (value) => AppScope.of(context)
              .tagNameError(value ?? '', exceptId: widget.excludeTagId),
          onFieldSubmitted: (_) => _submit(),
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
