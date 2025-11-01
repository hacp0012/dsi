part of 'dsi_base.dart';

// ! PRIVATE |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
class _DataSyncInterfaceSingleton {
  static _DataSyncInterfaceSingleton? _inst;
  _DataSyncInterfaceSingleton._();
  static _DataSyncInterfaceSingleton get instance {
    if (_inst != null) return _inst!;

    _inst = _DataSyncInterfaceSingleton._();
    _inst!._streameController = StreamController<String>.broadcast(onCancel: () => instance.dataList.clear());
    _inst!._stream = _inst!._streameController.stream;

    return _inst ??= _DataSyncInterfaceSingleton._();
  }
  // ============== SINGLETON ===============

  @protected
  late StreamController<String> _streameController;
  @protected
  late Stream<String> _stream;
  @protected
  List<DsiInstance> dataList = [];

  /// Add a DSI (Data Sync Instance) to queue.
  ///
  /// If DSI has same key, the old instance is remove and the new is appended;
  @protected
  void addDataSyncInstanceToQueue(DsiInstance dsi) {
    dataList.removeWhere((element) => element.key == dsi.key);
    dataList.add(dsi);
  }

  /// Notify all listeners.
  ///
  /// If key not found, noting will do.
  ///
  /// When you notify with [payload], this data will replace global value.
  ///
  /// Return true if key is matched and event treamed.
  ///
  /// If [payload] Type not match with value data type, [TypeError] Exception is throwed.
  @protected
  bool notify<T>(String key, T? payload) {
    for (int i = 0; i < dataList.length; i++) {
      if (dataList[i].key == key) {
        if (payload != null) {
          if (dataList[i].value.runtimeType == payload.runtimeType) {
            dataList[i]._value = payload;
          } else {
            throw TypeError();
          }
        }
        _streameController.sink.add(key);
        return true;
      }
    }

    return false;
  }

  /// Listen to a key.
  ///
  /// At anytime event match the key, callback will be called.
  @protected
  StreamSubscription<String>? listen<T>(String key, void Function(T data) callback) {
    // Verify key existance before.
    bool keyNotMatched = true;
    for (int i = 0; i < dataList.length; i++) {
      keyNotMatched = !(dataList[i].key == key);
    }
    if (keyNotMatched) return null;

    // Start listening.
    var streamSubscription = _stream.listen((eventKey) {
      for (int i = 0; i < dataList.length; i++) {
        if (eventKey == key && dataList[i].key == key) {
          callback(dataList[i].value);
          // return true;
        }
      }
    });

    return streamSubscription;
  }

  /// Close stream.
  @protected
  void closeStream() => _streameController.close();

  /// Clean all stream.
  @protected
  void clearAllStream() => dataList.clear();

  // |*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|
  @protected
  List modelsList = [];

  // |*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|
  @protected
  Map<String, void Function(dynamic)> callbacksList = {};
}
