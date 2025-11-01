part of 'dsi_base.dart';

// ! PRIVATE |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
class _DsiInnerTreeObserver<T extends ChangeNotifier> extends InheritedNotifier<T> {
  /// Creates an [InheritedNotifier] that updates its dependents when [notifier]
  /// sends notifications.
  ///
  /// The [child] and [notifier] arguments must not be null.
  const _DsiInnerTreeObserver({super.key, required T super.notifier, required super.child});

  /// The [notifier] object from the closest instance of this class that encloses
  /// the given context.
  ///
  /// If [listen] is true (the default), the [context] will be rebuilt when
  /// the [notifier] sends a notification.
  ///
  /// If no [_DsiInnerTreeObserver] ancestor is found, this method will assert in
  /// debug mode, and throw an exception in release mode.
  @protected
  static T of<T extends ChangeNotifier>(BuildContext context, {bool listen = true}) {
    final _DsiInnerTreeObserver<T>? result = listen
        ? context.dependOnInheritedWidgetOfExactType<_DsiInnerTreeObserver<T>>()
        : context.getElementForInheritedWidgetOfExactType<_DsiInnerTreeObserver<T>>()?.widget as _DsiInnerTreeObserver<T>?;
    assert(result != null, 'No Dsi<$T> found in context');
    return result!.notifier!;
  }
}
