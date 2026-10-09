# ReNotes — Notas de investigación

Aplicación Flutter para Android que organiza el trabajo de investigación en **proyectos**, permite escribir **notas largas** dentro de cada proyecto y clasificarlas con **etiquetas** globales que el usuario crea y reutiliza.

Proyecto práctico de la asignatura *Programación para Dispositivos Móviles*.

## Requisitos

- Flutter 3.x (probado con Flutter 3.47.5, canal stable). Dart SDK ^3.13.4.
- Android SDK y un emulador o dispositivo Android con depuración USB activa.

## Cómo inicializar y ejecutar

```bash
git clone <url-del-repositorio>
cd renotes
flutter pub get
flutter run            # con un emulador o dispositivo Android conectado
```

Para generar el APK de depuración:

```bash
flutter build apk --debug
# salida: build/app/outputs/flutter-apk/app-debug.apk
```

Para ejecutar los tests unitarios (modelo de datos, etiquetas y búsqueda):

```bash
flutter test
```

## Características

| Pantalla | Qué permite |
|---|---|
| **Proyectos** | Lista de proyectos con nombre, descripción corta, número de notas y última modificación. Crear, editar y eliminar (con confirmación; se eliminan sus notas, las etiquetas se conservan). |
| **Notas del proyecto** | Notas del proyecto con extracto, etiquetas y fecha. Búsqueda por título o contenido, filtro por etiquetas del proyecto (todas o al menos una), crear, eliminar. |
| **Editor de nota** | Crear o editar. Título obligatorio con validación, descripción de texto largo con scroll interno, chips de etiquetas con opción de quitar, aviso al salir con cambios sin guardar. |
| **Detalle de nota** | Título, proyecto, fechas, etiquetas (al tocar una se abre *Etiquetas* filtrada) y descripción completa. Botones para editar, eliminar y volver. |
| **Etiquetas** | Todas las etiquetas con su número de notas. Crear, renombrar (se refleja en todas las notas) y eliminar (con aviso de cuántas notas afecta). Búsqueda por nombre. Selección de varias etiquetas para ver notas de todos los proyectos con modo *todas* o *al menos una*. |
| **Buscar** | Búsqueda global por título o contenido con filtros opcionales de proyecto y etiquetas. |

### Autocompletado de etiquetas

En el editor, el campo de etiquetas usa `RawAutocomplete` del SDK de Flutter:

- Sugiere etiquetas existentes que **contengan** el texto escrito, sin distinguir mayúsculas, minúsculas ni acentos (`metodo` encuentra `Metodología`).
- Busca en etiquetas de **cualquier proyecto**.
- No sugiere las etiquetas que la nota ya tiene.
- Al elegir una sugerencia, la etiqueta se asigna y el campo se limpia.
- Si no hay coincidencia exacta, ofrece **crear** la etiqueta.
- Enter confirma la opción resaltada (o lo escrito); una coma confirma el texto anterior.
- Nunca crea duplicados: si el nombre ya existe (ignorando mayúsculas y acentos), reutiliza la existente.

## Arquitectura

```
lib/
├── main.dart                  # Arranque de la app y carga de datos de prueba
├── app_theme.dart             # Paleta cálida e iconos oscuros
├── models/                    # Project, Note, Tag (datos puros, sin dependencias de UI)
├── data/
│   ├── app_store.dart         # Almacén en memoria: reglas de negocio y consultas
│   ├── app_scope.dart         # Acceso al store con InheritedNotifier (SDK)
│   ├── seed_data.dart         # Datos de prueba
│   └── text_utils.dart        # Normalización de texto, extractos, formato de fechas
├── navigation/
│   └── app_routes.dart        # Funciones de navegación (Navigator.push)
├── screens/                   # Una clase por pantalla
└── widgets/                   # Componentes reutilizables (chips, tarjetas, diálogos, autocompletado)
```

- **Estado**: solo las herramientas del SDK. `ChangeNotifier` para el almacén e `InheritedNotifier` para repartirlo por el árbol de widgets. No se usa ningún paquete de gestión de estado.
- **Datos**: en memoria. Al iniciar se cargan 3 proyectos, 15 notas y 8 etiquetas de prueba. No hay base de datos ni almacenamiento local.
- **Navegación**: solo `Navigator.push` con `MaterialPageRoute`, centralizado en `navigation/app_routes.dart`. No se usa `go_router` ni `pushNamed`.
- **Pestañas**: `IndexedStack` mantiene vivas las tres pestañas, así que cada una conserva su búsqueda, filtros y posición de scroll al cambiar de pestaña.

### Modelo de datos

- Un **proyecto** tiene cero o muchas **notas**. Una nota pertenece a un solo proyecto.
- Una **nota** tiene cero o muchas **etiquetas**, y una etiqueta puede estar en notas de cualquier proyecto (muchos a muchos).
- Las **etiquetas** son globales. El nombre es único tras normalizar (sin mayúsculas, acentos ni espacios sobrantes).

## Capturas de pantalla

Las capturas están en [`docs/screenshots/`](docs/screenshots/):

| Archivo | Pantalla |
|---|---|
| `01-proyectos.png` | Proyectos |
| `02-notas-proyecto.png` | Notas del proyecto |
| `03-editor-nota.png` | Editor de nota |
| `04-autocompletado.png` | Autocompletado de etiquetas en funcionamiento |
| `05-detalle-nota.png` | Detalle de nota |
| `06-etiquetas.png` | Etiquetas |
| `07-buscar.png` | Buscar |

## Tests

`test/app_store_test.dart` comprueba las reglas del enunciado: unicidad de etiquetas, normalización de mayúsculas y acentos, renombrado y borrado que se reflejan en todas las notas, borrado en cascada de notas al eliminar un proyecto, filtros por una o varias etiquetas, texto largo sin pérdida, y los requisitos de los datos de prueba.
