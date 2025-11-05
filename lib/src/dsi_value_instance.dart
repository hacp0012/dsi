part of 'dsi_base.dart';

// ! PRIVATE |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
/// Data Sync Instance.
class DsiValueInstance<T> {
  DsiValueInstance({required T value, required String? idKey, this.onChanged}) {
    _value = value;
    idKey ??= _randomStringGen(9 * 8);
    key = idKey;
  }

  @protected
  String _randomStringGen(int length) {
    const chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    Random rnd = Random();
    return String.fromCharCodes(Iterable.generate(length, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
  }

  /// Listener instance key.
  ///
  /// If you omit to specify [idKey] in contructor, by default, this key is auto-genereated to a random
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

  /// Called anytime value changed.
  ///
  /// [notify] not
  Function(T data)? onChanged;

  /// Data value. But only set data without update listeners.
  set onlySetValue(T value) => _value = value;

  @protected
  final _DataSyncInterfaceSingleton _inst = _DataSyncInterfaceSingleton.instance;

  /// Listen for it value change.
  ///
  /// At anytime event match the key, callback will be called.
  StreamSubscription<String>? listen(void Function(T data) callback) => _inst.listen<T>(key, callback);

  /// Notify all listeners subscribed to this instance.
  ///
  /// If key not found, noting will do.
  ///
  /// When you notify with [payload], this data will replace global value.
  ///
  /// Return true if key is matched and event treamed.
  ///
  /// If [payload] Type not match with value data type, [TypeError] Exception is throwed.
  bool notify(T? payload) {
    bool state = _inst.notify<T>(key, payload);
    if (state && payload != null) onChanged?.call(payload);
    return state;
  }

  /// Remove this instance on queue.
  ///
  /// This is not unsubscribe all subscribtion but remove only event on queue list.
  void freeIt() => _inst.dataList.removeWhere((element) => element.key == key);
}
