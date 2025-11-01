part of 'dsi_base.dart';

// * PUBLIC ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
/// Default DSI Change notifier.
///
/// Is extend [ChangeNotifier] with litle more context data.
///
/// Strongly recommanded Use [DsiChangeNotifier] enstead of [ChangeNotifier].
class DsiChangeNotifier extends ChangeNotifier {
  /// Current Tree cursor Position in Context tree.
  ///
  /// Use to notify [DsiTreeObserver]
  @protected
  late List<BuildContext> _currentTreePositionContexts = [];

  /// Rebuild tree on notification.
  @protected
  void _shuldNotifyTree() {
    // currentEntryContext = null;
    notifyListeners();
  }
}
