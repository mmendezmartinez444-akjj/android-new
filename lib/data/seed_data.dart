import 'package:flutter/material.dart';

import '../models/note.dart';
import '../models/project.dart';
import '../models/tag.dart';

/// Datos de prueba que se cargan en memoria al iniciar la app.
///
/// Cumplen el enunciado: 3 proyectos, 15 notas (5 por proyecto), 8 etiquetas,
/// etiquetas compartidas entre proyectos, una nota sin etiquetas, una etiqueta
/// sin notas y notas con descripciones de más de 600 caracteres.
class SeedData {
  const SeedData({
    required this.projects,
    required this.notes,
    required this.tags,
  });

  final List<Project> projects;
  final List<Note> notes;
  final List<Tag> tags;

  static SeedData create() {
    final now = DateTime.now();
    DateTime daysAgo(int days, [int hours = 0]) =>
        now.subtract(Duration(days: days, hours: hours));

    // Etiquetas ----------------------------------------------------------------
    const metodologia = Tag(id: 'tag-metodologia', name: 'Metodología', color: Color(0xFFC2673A));
    const fuentes = Tag(id: 'tag-fuentes', name: 'Fuentes', color: Color(0xFFE2A546));
    const entrevistas = Tag(id: 'tag-entrevistas', name: 'Entrevistas', color: Color(0xFF8C5A3C));
    const estadistica = Tag(id: 'tag-estadistica', name: 'Estadística', color: Color(0xFFD9793B));
    const literatura = Tag(id: 'tag-literatura', name: 'Literatura', color: Color(0xFFB08968));
    const hipotesis = Tag(id: 'tag-hipotesis', name: 'Hipótesis', color: Color(0xFFCB997E));
    const etica = Tag(id: 'tag-etica', name: 'Ética', color: Color(0xFF9C6644));
    const pendiente = Tag(id: 'tag-pendiente', name: 'Pendiente de revisión', color: Color(0xFFDDB892));

    // Proyectos ----------------------------------------------------------------
    final projects = [
      Project(
        id: 'proj-1',
        name: 'Educación digital en secundaria',
        description: 'Adopción de herramientas digitales en aulas de secundaria.',
        createdAt: daysAgo(40),
        updatedAt: daysAgo(1, 3),
      ),
      Project(
        id: 'proj-2',
        name: 'Estudio de mercado local',
        description: 'Demanda y competencia para un servicio de barrio.',
        createdAt: daysAgo(25),
        updatedAt: daysAgo(2),
      ),
      Project(
        id: 'proj-3',
        name: 'Revisión bibliográfica sobre IA',
        description: 'Estado del arte sobre evaluación y sesgos de modelos de lenguaje.',
        createdAt: daysAgo(12),
        updatedAt: daysAgo(0, 5),
      ),
    ];

    // Notas --------------------------------------------------------------------
    final notes = [
      // Proyecto 1
      Note(
        id: 'note-1',
        projectId: 'proj-1',
        title: 'Marco teórico: brecha digital',
        description: _brechaDigital.trim(),
        createdAt: daysAgo(38),
        updatedAt: daysAgo(1, 3),
        tagIds: [fuentes.id, literatura.id],
      ),
      Note(
        id: 'note-2',
        projectId: 'proj-1',
        title: 'Entrevista a directora de escuela',
        description: _entrevistaDirectora.trim(),
        createdAt: daysAgo(30),
        updatedAt: daysAgo(4),
        tagIds: [entrevistas.id, etica.id],
      ),
      Note(
        id: 'note-3',
        projectId: 'proj-1',
        title: 'Diseño del cuestionario',
        description: _cuestionario.trim(),
        createdAt: daysAgo(27),
        updatedAt: daysAgo(6),
        tagIds: [metodologia.id],
      ),
      Note(
        id: 'note-4',
        projectId: 'proj-1',
        title: 'Hipótesis de trabajo',
        description: 'El uso pedagógico de las herramientas digitales depende más de la formación docente que del equipamiento disponible.',
        createdAt: daysAgo(20),
        updatedAt: daysAgo(9),
        tagIds: [hipotesis.id, metodologia.id],
      ),
      Note(
        id: 'note-5',
        projectId: 'proj-1',
        title: 'Resultados preliminares de encuesta',
        description: _resultadosEncuesta.trim(),
        createdAt: daysAgo(10),
        updatedAt: daysAgo(3),
        tagIds: [estadistica.id, entrevistas.id],
      ),

      // Proyecto 2
      Note(
        id: 'note-6',
        projectId: 'proj-2',
        title: 'Segmentación de clientes',
        description: _segmentacion.trim(),
        createdAt: daysAgo(22),
        updatedAt: daysAgo(2),
        tagIds: [metodologia.id, estadistica.id],
      ),
      Note(
        id: 'note-7',
        projectId: 'proj-2',
        title: 'Precios de competidores',
        description: _precios.trim(),
        createdAt: daysAgo(18),
        updatedAt: daysAgo(5),
        tagIds: [fuentes.id],
      ),
      Note(
        id: 'note-8',
        projectId: 'proj-2',
        title: 'Idea sin etiquetas',
        description: 'Pensar en un horario extendido los fines de semana. Revisar con el dueño del local.',
        createdAt: daysAgo(8),
        updatedAt: daysAgo(7),
        tagIds: const [],
      ),
      Note(
        id: 'note-9',
        projectId: 'proj-2',
        title: 'Ética en el uso de datos de clientes',
        description: _eticaDatos.trim(),
        createdAt: daysAgo(15),
        updatedAt: daysAgo(11),
        tagIds: [etica.id],
      ),
      Note(
        id: 'note-10',
        projectId: 'proj-2',
        title: 'Hallazgos del grupo focal',
        description: 'Los participantes valoran la cercanía y el trato personal más que el precio. Dos personas pidieron opciones sin azúcar.',
        createdAt: daysAgo(6),
        updatedAt: daysAgo(2, 6),
        tagIds: [entrevistas.id],
      ),

      // Proyecto 3
      Note(
        id: 'note-11',
        projectId: 'proj-3',
        title: 'Artículos fundacionales',
        description: _articulos.trim(),
        createdAt: daysAgo(11),
        updatedAt: daysAgo(0, 5),
        tagIds: [fuentes.id, literatura.id],
      ),
      Note(
        id: 'note-12',
        projectId: 'proj-3',
        title: 'Métricas de evaluación',
        description: _metricas.trim(),
        createdAt: daysAgo(9),
        updatedAt: daysAgo(3),
        tagIds: [estadistica.id],
      ),
      Note(
        id: 'note-13',
        projectId: 'proj-3',
        title: 'Sesgos en modelos de lenguaje',
        description: _sesgos.trim(),
        createdAt: daysAgo(7),
        updatedAt: daysAgo(1),
        tagIds: [etica.id, fuentes.id],
      ),
      Note(
        id: 'note-14',
        projectId: 'proj-3',
        title: 'Hipótesis sobre transferencia',
        description: 'Los modelos entrenados en inglés podrían transferir peor a textos en español académico.',
        createdAt: daysAgo(4),
        updatedAt: daysAgo(4),
        tagIds: [hipotesis.id, literatura.id],
      ),
      Note(
        id: 'note-15',
        projectId: 'proj-3',
        title: 'Notas de lectura de la semana',
        description: 'Capítulo 3 del libro de referencia: resumir el argumento sobre datos de entrenamiento y anotar dudas para la tutoría.',
        createdAt: daysAgo(2),
        updatedAt: daysAgo(2),
        tagIds: [literatura.id],
      ),
    ];

    return SeedData(
      projects: projects,
      notes: notes,
      tags: const [
        metodologia,
        fuentes,
        entrevistas,
        estadistica,
        literatura,
        hipotesis,
        etica,
        pendiente,
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// Textos largos de prueba (más de 600 caracteres cada uno)
// -----------------------------------------------------------------------------

const _brechaDigital = '''
La brecha digital en la educación secundaria no se limita al acceso a equipos. Las fuentes revisadas distinguen al menos tres niveles: la disponibilidad de dispositivos y conectividad, las competencias digitales de docentes y estudiantes, y los usos pedagógicos que finalmente se hacen de la tecnología. Cada nivel requiere indicadores distintos y, por tanto, instrumentos de medición diferentes.

Uno de los modelos revisados propone una lectura por fases que resulta útil para organizar el marco teórico. Según ese modelo, primero se cierra la brecha de acceso, después la de habilidades y finalmente la de resultados. En contextos donde el acceso todavía es limitado, la discusión sobre competencias puede resultar prematura, por lo que conviene documentar el punto de partida de cada centro antes de comparar.

Pendiente: confirmar la traducción de la cita principal y buscar una edición más reciente con datos posteriores a la pandemia.
''';

const _entrevistaDirectora = '''
Entrevista realizada en la sala de profesores, con una duración aproximada de cuarenta minutos. La directora explicó que la llegada de los equipos fue rápida, pero la planificación de su uso en clase llevó casi un año. Señaló que los docentes con más experiencia adoptaron las herramientas con cautela y que los más jóvenes pidieron capacitación antes de usarlas con grupos completos.

Al preguntarle por la privacidad de los datos de los estudiantes, respondió que el centro aún no tiene un protocolo escrito. Mencionó que cada profesor decide qué plataformas usar y que eso genera dudas sobre quién guarda las calificaciones y los trabajos. Este punto debe tratarse con cuidado en el informe, porque toca un tema ético sensible.

Acordamos enviarle un resumen de la transcripción para que pueda corregir citas y precisar fechas. Queda pendiente pedir autorización para citar su nombre o usar un seudónimo.
''';

const _cuestionario = '''
El cuestionario tiene cuarenta preguntas divididas en cinco bloques: datos generales, acceso a equipos, formación docente, usos en el aula y percepción de los estudiantes. Las preguntas de escala usan cinco niveles, desde «nunca» hasta «siempre», para facilitar el análisis estadístico posterior.

Se añadieron tres preguntas abiertas al final de cada bloque para recoger matices que las escalas no capturan. Durante la prueba piloto, con doce docentes, se detectó que dos preguntas de formación se entendían de forma distinta según la antigüedad del profesor, por lo que se reformularon con ejemplos concretos.

La versión final debe revisarse con el tutor antes de aplicarla. También falta decidir si el cuestionario se responde en papel o en línea, y cómo se garantiza el anonimato cuando el grupo es pequeño.
''';

const _resultadosEncuesta = '''
Los primeros resultados provienen de 84 respuestas válidas. El ochenta por ciento de los docentes reporta usar herramientas digitales al menos una vez por semana, pero solo cerca de un tercio dice hacerlo para actividades de evaluación. La diferencia es notable y sugiere que el uso se concentra en la presentación de contenidos.

Al cruzar los datos con la antigüedad docente, la tendencia se invierte ligeramente: los profesores con más de quince años de experiencia reportan mayor uso en evaluación que los más jóvenes. Esto contradice la hipótesis inicial y merece una revisión de la muestra antes de sacar conclusiones.

Las entrevistas de seguimiento deben enfocarse en esta diferencia. Conviene preguntar por las razones del uso limitado en evaluación y por las experiencias previas con plataformas de calificación.
''';

const _segmentacion = '''
Se propusieron tres segmentos a partir de la encuesta de frecuencia de compra: vecinos que compran a diario, oficinistas que compran en horario de almuerzo y familias que compran los fines de semana. Cada segmento tiene necesidades distintas en tiempo de espera, variedad y precio.

Para validar la segmentación se revisaron los tickets de compra de dos semanas. El segmento de oficinistas concentra el mayor gasto por visita, aunque el segmento de vecinos es el más numeroso. Esto sugiere que la oferta de almuerzo rápido podría ser más rentable que una carta amplia.

Queda pendiente comprobar si los tres segmentos se mantienen en temporada baja y si la frecuencia de compra cambia con el precio. Para eso conviene repetir la encuesta dentro de dos meses.
''';

const _precios = '''
Se recopilaron los precios de seis establecimientos cercanos para las bebidas y los postres más vendidos. La diferencia promedio entre el local más barato y el más caro supera el cuarenta por ciento, lo que indica un mercado con espacio para distintas propuestas de valor.

Dos competidores ofrecen promociones de lunes a jueves que no aparecen en sus carteles. Hay que confirmarlas en persona antes de incluirlas en el análisis, porque podrían ser temporales.

Los precios se registraron con fotografías y se anotaron en la hoja de cálculo del proyecto. Cada precio tiene fecha y hora para poder compararlos en el tiempo.
''';

const _eticaDatos = '''
Antes de guardar datos de clientes, como nombres, teléfonos o historial de compras, hay que informar el propósito del registro y pedir consentimiento explícito. La información debe usarse solo para el estudio y eliminarse al terminar el proyecto.

El estudio no debe identificar a personas en los informes. Se usarán códigos y rangos de edad en lugar de nombres. Si alguna respuesta incluye datos sensibles, se descartará o se anonimizará de inmediato.

Este criterio debe incluirse en el documento de consentimiento que se entrega a los participantes del grupo focal.
''';

const _articulos = '''
La revisión inicial identificó doce artículos que se citan con frecuencia en los trabajos recientes sobre evaluación de modelos de lenguaje. Se seleccionaron cinco por su impacto y por proponer métodos reproducibles. Cada artículo se resumió con su pregunta de investigación, los datos usados y las limitaciones que sus autores reconocen.

Varios trabajos comparten un supuesto común: que las pruebas de referencia miden la capacidad general del modelo. Algunos autores cuestionan esa suposición y muestran que pequeños cambios en el formato de la pregunta alteran los resultados de forma importante.

Pendiente: verificar que las versiones descargadas sean las publicadas y anotar la fecha de consulta en la bibliografía.
''';

const _metricas = '''
Se comparan tres familias de métricas: precisión sobre respuestas cerradas, evaluación de coherencia en textos largos y medidas de robustez frente a cambios de formato. Cada familia tiene ventajas claras y costos de cálculo distintos.

La precisión es fácil de interpretar, pero puede ocultar errores graves cuando el conjunto de prueba es pequeño. Las métricas de coherencia requieren evaluadores humanos o modelos auxiliares, lo que introduce su propio sesgo.
''';

const _sesgos = '''
Los sesgos en modelos de lenguaje pueden aparecer en los datos de entrenamiento, en el proceso de ajuste fino o en la forma de evaluarlos. Este trabajo se concentra en los dos primeros, porque la literatura reciente ha documentado más casos en esas etapas.

Algunos estudios muestran que las respuestas cambian según el género o la procedencia que se atribuye a un nombre en el enunciado. Otros reportan que el idioma de la consulta modifica el tono de la respuesta, aunque el contenido sea equivalente.

Hay que decidir cómo presentar estos hallazgos sin caer en generalizaciones. La discusión debe distinguir entre los sesgos medidos en un modelo concreto y los patrones que se repiten en varios modelos.
''';
