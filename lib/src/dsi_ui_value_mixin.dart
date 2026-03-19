import 'dsi_ui_value.dart';

/// UI VALUE MIXIN
///
/// Avoids the need to call [setState] everywhere.
/// - Remember to use [late] declaration for variables. If not, you will be constrained to initialize them in
/// [initState].
///
/// ```dart
///  ...
/// class _ExampleScreenState extends State<ExampleScreen> with DsiUiValueMixin {
///   late var isLoading = uiValue(false);
///
///   @override
///   void Function(void Function() p1) get dsiStateUpdater => setState;
///   ...
/// }
/// ```
mixin DsiUiValueMixin {
  /// A setState method that will be used to update the UI.
  ///
  /// ```dart
  /// @override
  /// void Function(void Function() p1) get dsiStateUpdater => setState;
  /// ```
  void Function(void Function()) get dsiStateUpdater;

  /// Initialize value and return [DsiUiValue<T>] value.
  ///
  /// ```dart
  /// late var isLoading = uiValue(false);
  /// ```
  DsiUiValue<T> uiValue<T>(T value) => DsiUiValue<T>(dsiStateUpdater, value);

  /// Update state manually
  ///
  /// ```dart
  /// uiUpdate();
  /// // or
  /// uiUpdate(() {
  ///   isUpdated = true;
  /// });
  /// ```
  void uiUpdate([void Function()? fn]) =>
      fn != null ? dsiStateUpdater.call(fn) : dsiStateUpdater.call(() {});
}
