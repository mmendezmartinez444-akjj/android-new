import 'package:flutter/widgets.dart';

import 'app_store.dart';

/// Expone el [AppStore] a todo el árbol de widgets con InheritedNotifier del SDK.
/// Los widgets que llaman a [of] se reconstruyen cuando cambian los datos.
class AppScope extends InheritedNotifier<AppStore> {
  const AppScope({super.key, required AppStore store, required super.child})
      : super(notifier: store);

  /// Obtiene el store y registra la dependencia (usar dentro de build).
  static AppStore of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'No se encontró AppScope en el árbol de widgets.');
    return scope!.notifier!;
  }

  /// Obtiene el store sin registrar dependencia (usar en initState).
  static AppStore read(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'No se encontró AppScope en el árbol de widgets.');
    return scope!.notifier!;
  }
}
