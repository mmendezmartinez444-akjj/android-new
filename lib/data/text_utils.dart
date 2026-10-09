const _accentMap = {
  'á': 'a', 'à': 'a', 'ä': 'a', 'â': 'a',
  'é': 'e', 'è': 'e', 'ë': 'e', 'ê': 'e',
  'í': 'i', 'ì': 'i', 'ï': 'i', 'î': 'i',
  'ó': 'o', 'ò': 'o', 'ö': 'o', 'ô': 'o',
  'ú': 'u', 'ù': 'u', 'ü': 'u', 'û': 'u',
  'ñ': 'n', 'ç': 'c',
};

/// Clave de comparación: ignora mayúsculas, acentos y espacios sobrantes.
/// "  Metodología " y "metodologia" dan la misma clave.
String normalizeText(String input) {
  final buffer = StringBuffer();
  for (final char in input.toLowerCase().split('')) {
    buffer.write(_accentMap[char] ?? char);
  }
  return buffer.toString().replaceAll(RegExp(r'\s+'), ' ').trim();
}

/// Extracto de una descripción larga, en una sola línea.
String excerpt(String text, {int maxLength = 140}) {
  final flat = text.replaceAll(RegExp(r'\s+'), ' ').trim();
  if (flat.length <= maxLength) return flat;
  return '${flat.substring(0, maxLength).trimRight()}…';
}

/// Fecha en formato dd/mm/aaaa hh:mm.
String formatDate(DateTime date) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(date.day)}/${two(date.month)}/${date.year} '
      '${two(date.hour)}:${two(date.minute)}';
}

String countLabel(int count, String singular, String plural) {
  return '$count ${count == 1 ? singular : plural}';
}
