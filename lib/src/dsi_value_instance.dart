part of 'dsi_base.dart';

// ! PRIVATE |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
/// Data Sync Instance.
class DsiValueInstance<T> {
  DsiValueInstance({required T value, required String? idKey, this.onChanged}) {
    _value = value;
    idKey ??= _randomStringGen(45);
    key = idKey;
  }

  @protected
  String _randomStringGen(int length) {
    const chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    Random rnd = Random();
    return String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => chars.codeUnitAt(rnd.nextInt(chars.length)),
      ),
    );
  }

  /// Listener instance key.
  ///
  /// If you omit to specify [idKey] in constructor, by default, this key is auto-generated to a random
  /// string of default length 45 (alphaNumeric characters).
  late String key; // auto-generated | fix-value

  /// Data.
  @protected
  late T _value;

  /// Data value.
  ///
  /// If changed, all listeners will be notified.
  T get value => _value;
  set value(T value) {
    _value = value;
    notify(value);
    onChanged?.call(value);
  }

  /// Called any time value changed.
  Function(T data)? onChanged;

  /// Data value. But only set data without updating listeners.
  set onlySetValue(T value) => _value = value;

  @protected
  final _DataSyncInterfaceSingleton _inst =
      _DataSyncInterfaceSingleton.instance;

  /// Listen for its value change.
  ///
  /// At any time an event matches the key, the callback will be called.
  StreamSubscription<String>? listen(void Function(T data) callback) =>
      _inst.listen<T>(key, callback);

  /// Notify all listeners subscribed to this instance.
  ///
  /// If key not found, nothing will happen.
  ///
  /// When you notify with [payload], this data will replace the global value.
  ///
  /// Return true if key is matched and event streamed.
  ///
  /// If [payload] runtimeType doesn't match the value data type, [TypeError] Exception is thrown.
  bool notify(T? payload) {
    bool state = _inst.notify<T>(key, payload);
    if (state && payload != null) onChanged?.call(payload);
    return state;
  }

  /// Remove this instance from the queue.
  ///
  /// This does not unsubscribe all subscriptions but removes only the event from the tracking map.
  void freeIt() => _inst.dataMap.remove(key);
}
