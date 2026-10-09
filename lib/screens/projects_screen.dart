import 'package:flutter/material.dart';

import '../data/app_scope.dart';
import '../data/text_utils.dart';
import '../models/project.dart';
import '../navigation/app_routes.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/empty_state.dart';
import '../widgets/project_form_dialog.dart';

/// Pestaña Proyectos: lista de proyectos de investigación.
class ProjectsScreen extends StatelessWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final projects = AppScope.of(context).projects;

    return Scaffold(
      appBar: AppBar(title: const Text('Proyectos')),
      body: projects.isEmpty
          ? const EmptyState(
              icon: Icons.folder_open,
              message: 'Todavía no tienes proyectos de investigación.\n'
                  'Crea el primero con el botón "Nuevo proyecto".',
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
              itemCount: projects.length,
              itemBuilder: (context, index) => _ProjectCard(project: projects[index]),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _createProject(context),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo proyecto'),
      ),
    );
  }

  Future<void> _createProject(BuildContext context) async {
    final draft = await showProjectFormDialog(context);
    if (draft == null || !context.mounted) return;
    AppScope.of(context).addProject(name: draft.name, description: draft.description);
  }
}

enum _ProjectAction { edit, delete }

class _ProjectCard extends StatelessWidget {
  const _ProjectCard({required this.project});

  final Project project;

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final theme = Theme.of(context);
    final noteCount = store.notesCountInProject(project.id);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => openProjectNotes(context, project.id),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 4, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      project.name,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  PopupMenuButton<_ProjectAction>(
                    tooltip: 'Opciones del proyecto',
                    icon: const Icon(Icons.more_vert),
                    onSelected: (action) => _onAction(context, action),
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: _ProjectAction.edit,
                        child: ListTile(
                          leading: Icon(Icons.edit_outlined),
                          title: Text('Editar'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      PopupMenuItem(
                        value: _ProjectAction.delete,
                        child: ListTile(
                          leading: Icon(Icons.delete_outline),
                          title: Text('Eliminar'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (project.description.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Text(
                    project.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 16,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _InfoItem(
                    icon: Icons.article_outlined,
                    text: countLabel(noteCount, 'nota', 'notas'),
                  ),
                  _InfoItem(
                    icon: Icons.schedule,
                    text: 'Modificado ${formatDate(project.updatedAt)}',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onAction(BuildContext context, _ProjectAction action) async {
    switch (action) {
      case _ProjectAction.edit:
        await _edit(context);
      case _ProjectAction.delete:
        await _delete(context);
    }
  }

  Future<void> _edit(BuildContext context) async {
    final draft = await showProjectFormDialog(context, project: project);
    if (draft == null || !context.mounted) return;
    AppScope.of(context).updateProject(
      project.id,
      name: draft.name,
      description: draft.description,
    );
  }

  Future<void> _delete(BuildContext context) async {
    final store = AppScope.of(context);
    final noteCount = store.notesCountInProject(project.id);
    final confirmed = await confirmAction(
      context,
      title: 'Eliminar proyecto',
      message: '¿Eliminar "${project.name}"? Se eliminarán también sus '
          '$noteCount ${noteCount == 1 ? 'nota' : 'notas'}. '
          'Las etiquetas se conservan.',
      confirmLabel: 'Eliminar',
    );
    if (!confirmed || !context.mounted) return;
    AppScope.of(context).deleteProject(project.id);
  }
}

class _InfoItem extends StatelessWidget {
  const _InfoItem({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16),
        const SizedBox(width: 4),
        Text(text, style: Theme.of(context).textTheme.labelMedium),
      ],
    );
  }
}
