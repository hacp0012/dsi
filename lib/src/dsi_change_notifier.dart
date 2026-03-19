part of 'dsi_base.dart';

// * PUBLIC ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
/// Default DSI Change notifier.
///
/// It extends [ChangeNotifier] with a little more context data.
///
/// Strongly recommended: Use [DsiChangeNotifier] instead of [ChangeNotifier].
class DsiChangeNotifier extends ChangeNotifier {
  /// Track contexts efficiently using a Set to prevent duplicates.
  @protected
  final Set<BuildContext> _contexts = {};

  /// Registers a context to be rebuilt when notifyListeners is called.
  @protected
  void _registerContext(BuildContext context) {
    _contexts.removeWhere((ctx) => !ctx.mounted);
    _contexts.add(context);
  }

  /// Triggers a rebuild of all registered contexts.
  @protected
  void _shouldNotifyTree() {
    notifyListeners();
  }

  @override
  void notifyListeners() {
    super.notifyListeners();
    _contexts.removeWhere((ctx) => !ctx.mounted);
    for (var context in _contexts) {
      if (context is Element && context.mounted) {
        context.markNeedsBuild();
      }
    }
  }
}
