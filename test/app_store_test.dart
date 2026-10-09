import 'package:flutter_test/flutter_test.dart';
import 'package:renotes/data/app_store.dart';
import 'package:renotes/data/seed_data.dart';
import 'package:renotes/data/text_utils.dart';

void main() {
  group('normalizeText', () {
    test('ignora mayúsculas, acentos y espacios sobrantes', () {
      expect(normalizeText('  Metodología '), 'metodologia');
      expect(normalizeText('metodologia'), 'metodologia');
      expect(normalizeText('METODOLOGIA'), 'metodologia');
      expect(normalizeText('Ética  aplicada'), 'etica aplicada');
    });
  });

  group('datos de prueba', () {
    final seed = SeedData.create();

    test('3 proyectos, 15 notas con al menos 4 por proyecto y 8 etiquetas', () {
      expect(seed.projects.length, 3);
      expect(seed.notes.length, 15);
      expect(seed.tags.length, 8);
      for (final project in seed.projects) {
        final count = seed.notes.where((n) => n.projectId == project.id).length;
        expect(count, greaterThanOrEqualTo(4), reason: project.name);
      }
    });

    test('al menos 5 notas con descripción de más de 600 caracteres', () {
      final long = seed.notes.where((n) => n.description.length > 600).length;
      expect(long, greaterThanOrEqualTo(5));
    });

    test('hay una nota sin etiquetas y una etiqueta sin notas', () {
      expect(seed.notes.any((n) => n.tagIds.isEmpty), isTrue);
      final used = seed.notes.expand((n) => n.tagIds).toSet();
      expect(seed.tags.any((t) => !used.contains(t.id)), isTrue);
    });

    test('al menos 3 etiquetas se usan en proyectos distintos', () {
      var shared = 0;
      for (final tag in seed.tags) {
        final projects = seed.notes
            .where((n) => n.tagIds.contains(tag.id))
            .map((n) => n.projectId)
            .toSet();
        if (projects.length >= 2) shared++;
      }
      expect(shared, greaterThanOrEqualTo(3));
    });
  });

  group('AppStore', () {
    late AppStore store;

    setUp(() => store = AppStore(seed: SeedData.create()));

    test('autocompletado: contiene el texto, sin acentos, excluye asignadas', () {
      final ids = store.suggestTags('etica').map((t) => t.name);
      expect(ids, contains('Ética'));

      final excluded = store.findTagByName('Ética')!.id;
      final suggestions = store.suggestTags('ét', exclude: {excluded});
      expect(suggestions.any((t) => t.id == excluded), isFalse);
    });

    test('autocompletado: busca en cualquier parte del nombre', () {
      final names = store.suggestTags('dolog').map((t) => t.name);
      expect(names, contains('Metodología'));
    });

    test('getOrCreateTag reutiliza etiquetas existentes (sin duplicados)', () {
      final before = store.tags.length;
      final existing = store.getOrCreateTag('  METODOLOGIA ');
      expect(existing.name, 'Metodología');
      expect(store.tags.length, before);

      store.getOrCreateTag('Nueva etiqueta');
      expect(store.tags.length, before + 1);
    });

    test('renombrar rechaza nombres duplicados ignorando mayúsculas y acentos', () {
      final fuentes = store.findTagByName('Fuentes')!;
      final error = store.renameTag(fuentes.id, 'metodologia');
      expect(error, isNotNull);
      expect(store.findTagByName('Fuentes')!.name, 'Fuentes');
    });

    test('renombrar se refleja en todas las notas que la usan', () {
      final fuentes = store.findTagByName('Fuentes')!;
      store.renameTag(fuentes.id, 'Bibliografía');
      final notes = store.queryNotes(NoteQuery(tagIds: {fuentes.id}));
      expect(notes, isNotEmpty);
      for (final note in notes) {
        expect(store.tagsOf(note).map((t) => t.name), contains('Bibliografía'));
      }
    });

    test('eliminar etiqueta la quita de las notas sin borrarlas', () {
      final notesBefore = store.queryNotes(const NoteQuery()).length;
      final tag = store.findTagByName('Literatura')!;
      final usage = store.notesUsingTag(tag.id);
      expect(usage, greaterThan(0));

      store.deleteTag(tag.id);

      expect(store.tagById(tag.id), isNull);
      expect(store.queryNotes(const NoteQuery()).length, notesBefore);
    });

    test('eliminar proyecto borra sus notas pero conserva las etiquetas', () {
      final tagsBefore = store.tags.length;
      store.deleteProject('proj-1');
      expect(store.projectById('proj-1'), isNull);
      expect(store.notesInProject('proj-1'), isEmpty);
      expect(store.tags.length, tagsBefore);
    });

    test('filtro por varias etiquetas: todas o al menos una', () {
      final metodologia = store.findTagByName('Metodología')!.id;
      final estadistica = store.findTagByName('Estadística')!.id;

      final any = store.queryNotes(NoteQuery(tagIds: {metodologia, estadistica}));
      final all = store.queryNotes(NoteQuery(
        tagIds: {metodologia, estadistica},
        matchAll: true,
      ));

      expect(all.length, lessThan(any.length));
      for (final note in all) {
        expect(note.tagIds, containsAll([metodologia, estadistica]));
      }
    });

    test('búsqueda por texto ignora acentos y mayúsculas en título o contenido', () {
      final results = store.queryNotes(const NoteQuery(text: 'CUESTIONARIO'));
      expect(results.any((n) => n.title == 'Diseño del cuestionario'), isTrue);

      final accents = store.queryNotes(const NoteQuery(text: 'SEGMENTACION'));
      expect(accents.any((n) => n.title == 'Segmentación de clientes'), isTrue);
    });

    test('crear y editar nota no pierde el texto largo', () {
      final long = 'párrafo de prueba. ' * 400; // más de 7000 caracteres
      final note = store.createNote(
        projectId: 'proj-2',
        title: 'Prueba',
        description: long,
        tagIds: const [],
      );
      expect(store.noteById(note.id)!.description, long);

      store.updateNote(note.id, title: 'Prueba 2', description: long, tagIds: const []);
      expect(store.noteById(note.id)!.description, long);
      expect(store.noteById(note.id)!.title, 'Prueba 2');
    });

    test('el título de la nota es obligatorio', () {
      expect(
        () => store.createNote(
          projectId: 'proj-1',
          title: '   ',
          description: '',
          tagIds: const [],
        ),
        throwsArgumentError,
      );
    });
  });
}
