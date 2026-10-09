import 'package:flutter/material.dart';

import '../data/app_scope.dart';
import '../models/tag.dart';

/// Campo para añadir etiquetas a una nota con autocompletado (RawAutocomplete).
///
/// - Sugiere etiquetas existentes que contienen el texto, sin distinguir mayúsculas ni acentos.
/// - No sugiere las etiquetas que la nota ya tiene ([assignedTagIds]).
/// - Si no hay coincidencia exacta, ofrece crear la etiqueta.
/// - Enter (o la opción resaltada) confirma; una coma confirma lo escrito antes de ella.
class TagAutocompleteField extends StatefulWidget {
  const TagAutocompleteField({
    super.key,
    required this.assignedTagIds,
    required this.onTagAdded,
  });

  final Set<String> assignedTagIds;
  final ValueChanged<Tag> onTagAdded;

  @override
  State<TagAutocompleteField> createState() => _TagAutocompleteFieldState();
}

class _TagAutocompleteFieldState extends State<TagAutocompleteField> {
  // RawAutocomplete necesita un controlador y un FocusNode propios para poder limpiar el campo
  // al seleccionar una sugerencia.
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// Asigna la etiqueta con ese nombre, reutilizando la existente si ya hay una.
  void _assign(String rawName) {
    final name = rawName.trim();
    if (name.isEmpty) return;
    final tag = AppScope.of(context).getOrCreateTag(name);
    if (!widget.assignedTagIds.contains(tag.id)) {
      widget.onTagAdded(tag);
    }
  }

  void _onSelected(_TagOption option) {
    _assign(option.label);
    _controller.clear();
  }

  void _onChanged(String text) {
    if (!text.contains(',')) return;
    final parts = text.split(',');
    for (final part in parts.take(parts.length - 1)) {
      _assign(part);
    }
    final rest = parts.last;
    _controller.value = TextEditingValue(
      text: rest,
      selection: TextSelection.collapsed(offset: rest.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);

    return RawAutocomplete<_TagOption>(
      textEditingController: _controller,
      focusNode: _focusNode,
      displayStringForOption: (option) => option.label,
      optionsBuilder: (value) {
        final text = value.text.trim();
        if (text.isEmpty) return const Iterable<_TagOption>.empty();

        final options = store
            .suggestTags(text, exclude: widget.assignedTagIds)
            .map(_TagOption.existing)
            .toList();
        if (store.findTagByName(text) == null) {
          options.add(_TagOption.create(text));
        }
        return options;
      },
      onSelected: _onSelected,
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        return TextField(
          controller: controller,
          focusNode: focusNode,
          textCapitalization: TextCapitalization.sentences,
          textInputAction: TextInputAction.done,
          onChanged: _onChanged,
          onSubmitted: (_) {
            // Si hay sugerencias, se selecciona la resaltada; si no, se asigna el texto escrito.
            onFieldSubmitted();
            _assign(controller.text);
            controller.clear();
          },
          decoration: const InputDecoration(
            labelText: 'Añadir etiqueta',
            hintText: 'Escribe para buscar o crear (Enter o coma)',
            prefixIcon: Icon(Icons.sell_outlined),
          ),
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        final highlighted = AutocompleteHighlightedOption.of(context);
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(12),
            clipBehavior: Clip.antiAlias,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 220, maxWidth: 320),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final option = options.elementAt(index);
                  final isCreate = option.tag == null;
                  return ListTile(
                    dense: true,
                    selected: index == highlighted,
                    leading: Icon(isCreate ? Icons.add_circle_outline : Icons.sell_outlined),
                    title: Text(isCreate ? 'Crear etiqueta "${option.label}"' : option.label),
                    onTap: () => onSelected(option),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Opción del desplegable: una etiqueta existente o la propuesta de crear una nueva.
/// Cada búsqueda crea objetos nuevos para que RawAutocomplete no confunda opciones repetidas.
class _TagOption {
  const _TagOption._({this.tag, this.createName = ''});

  factory _TagOption.existing(Tag tag) => _TagOption._(tag: tag);
  factory _TagOption.create(String name) => _TagOption._(createName: name);

  final Tag? tag;
  final String createName;

  String get label => tag?.name ?? createName;
}
