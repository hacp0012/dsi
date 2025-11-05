part of 'dsi_base.dart';

// * PUBLIC ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
/// DSI Tree Observer. Use on Top of tree, may be up [MaterialApp].
///
/// This observer, rebuild tree when change is notified in tree.
///
/// ```dart
/// DsiTreeObserver(
///   models: [...],
///   child: MaterialApp(...),
/// );
/// ```
///
/// When your register a model, [keepOld] is defaultely true; This prevent to
/// re-register registreds models (That keep or concerve ald instances).
///
/// > If forgoted, an assert will be thrown.
///
class DsiTreeObserver extends StatelessWidget {
  /// DSI Tree Observer.
  ///
  /// Use to observe tree.
  /// It will rebuild the depended tree when change is notified.
  ///
  /// > Use with [Dsi] model.
  ///
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
    return _DsiInnerTreeObserver<DsiChangeNotifier>(notifier: DsiChangeNotifier(), child: child);
  }
}
