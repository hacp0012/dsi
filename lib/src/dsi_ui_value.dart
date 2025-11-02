/// HANDLE UI STATE
///
/// Use less set state [setState] in codes.
///
/// ```dart
/// // Use as this: if yout use it in a method.
/// DsiUiValue<bool> value = DsiUiValue(setState, true);
///
/// // Use as this: if you use it in a class.
/// late DsiUiValue<bool> value = DsiUiValue(setState, true);
/// ```
class DsiUiValue<T> {
  DsiUiValue(this.setState, T value) : _value = value;

  void Function(void Function()) setState;

  T _value;

  /// [T] Value of type.
  T get value => _value;
  set value(T data) => setState.call(() => _value = data);

  /// Set a value silently without update UI.
  set silent(T data) => _value = data;

  /// Manuely update view (ShortCut).
  void update() => setState.call(() {});
}
