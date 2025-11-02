import 'dsi_ui_value.dart';

/// UI VALUE MIXIN
///
/// Use only on [State]. Is avoid you to use more [setState], use less [setState]
/// - Remember to use [late] declaration. If not you will be constrained to initialize its in
/// [initState].
///
/// ```dart
///  ...
/// class _ExemplScreenState extends State<ExemplScreen> with DsiUiValueMixin {
///   late var isLoading = uiValue(false);
///
///   @ovarride
///   void Function(void Function() p1) get dsiStater => setState;
///   ...
/// }
/// ```
mixin DsiUiValueMixin {
  /// A setState method that will be used to update the UI.
  ///
  /// ```dart
  /// @override
  /// void Function(void Function() p1) get dsiStater => setState;
  /// ```
  void Function(void Function()) get dsiStater;

  /// Initize value and return [UiValue<T>] value.
  ///
  /// ```dart
  /// late var isLoading = uiValue(false);
  /// ```
  DsiUiValue<T> uiValue<T>(T value) => DsiUiValue<T>(dsiStater, value);

  /// Update state by calling [uiSetState]
  ///
  /// ```dart
  /// uiUpdate();
  /// // or
  /// uiUpdate(() {
  ///   isUpdated = true;
  /// });
  /// ```
  void uiUpdate([void Function()? fn]) => fn != null ? dsiStater.call(fn) : dsiStater.call(() {});
}
