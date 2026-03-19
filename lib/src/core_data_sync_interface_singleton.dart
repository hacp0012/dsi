part of 'dsi_base.dart';

// ! PRIVATE |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
class _DataSyncInterfaceSingleton {
  static _DataSyncInterfaceSingleton? _inst;
  _DataSyncInterfaceSingleton._();

  static _DataSyncInterfaceSingleton get instance {
    if (_inst != null) return _inst!;

    _inst = _DataSyncInterfaceSingleton._();
    _inst!._streamController = StreamController<String>.broadcast(
      onCancel: () => instance.dataMap.clear(),
    );
    _inst!._stream = _inst!._streamController.stream;

    return _inst ??= _DataSyncInterfaceSingleton._();
  }
  // ============== SINGLETON ===============

  @protected
  late StreamController<String> _streamController;

  @protected
  late Stream<String> _stream;

  @protected
  Map<String, DsiValueInstance> dataMap = {};

  /// Add a DSI (Data Sync Instance) to queue.
  ///
  /// If DSI has the same key, the old instance is replaced.
  @protected
  void addDataSyncInstanceToQueue(DsiValueInstance dsi) {
    dataMap[dsi.key] = dsi;
  }

  /// Notify all listeners.
  ///
  /// If key not found, nothing will happen.
  ///
  /// When you notify with [payload], this data will replace the global value.
  ///
  /// Return true if key is matched and event streamed.
  ///
  /// If [payload] runtimeType doesn't match the value data type, [TypeError] Exception is thrown.
  @protected
  bool notify<T>(String key, T? payload) {
    if (!dataMap.containsKey(key)) return false;

    var instance = dataMap[key]!;
    if (payload != null) {
      if (instance.value.runtimeType == payload.runtimeType ||
          instance.value is T?) {
        instance._value = payload;
      } else {
        throw TypeError();
      }
    }
    _streamController.sink.add(key);
    return true;
  }

  /// Listen to a key.
  ///
  /// At any time an event matches the key, the callback will be called.
  @protected
  StreamSubscription<String>? listen<T>(
    String key,
    void Function(T data) callback,
  ) {
    if (!dataMap.containsKey(key)) return null;

    // Start listening.
    return _stream.listen((eventKey) {
      if (eventKey == key && dataMap.containsKey(key)) {
        var instance = dataMap[key]!;
        callback(instance.value as T);
      }
    });
  }

  /// Close stream.
  @protected
  void closeStream() => _streamController.close();

  /// Clean all stream.
  @protected
  void clearAllStream() => dataMap.clear();

  // |*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|
  @protected
  Map<Type, dynamic> modelsMap = {};

  // |*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|
  @protected
  Map<String, void Function(dynamic)> callbacksList = {};
}
