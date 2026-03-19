part of 'dsi_base.dart';

// * PUBLIC ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
/// DSI Tree Observer. Use on Top of tree, may be up [MaterialApp].
///
/// This observer was originally used to rebuild the tree when a change is notified.
/// Now it simply acts as an entry point to seamlessly register multiple models globally.
///
/// ```dart
/// DsiTreeObserver(
///   models: [...],
///   child: MaterialApp(...),
/// );
/// ```
///
/// When you register a model, [keepOld] is by default true; This prevents
/// re-registering existing models (That keeps or conserves old instances).
class DsiTreeObserver extends StatelessWidget {
  /// DSI Tree Observer.
  ///
  /// Use to register multiple default models efficiently at the root of the app.
  ///
  /// > Use with [Dsi] model.
  DsiTreeObserver({super.key, this.models, required this.child}) {
    if (models != null) {
      for (int i = 0; i < models!.length; i++) {
        Dsi.register(models![i], keepOld: true);
      }
    }
  }

  final Widget child;

  /// Observable models list.
  final List? models;

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
