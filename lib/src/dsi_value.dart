part of 'dsi_base.dart';

/// Global value handler.
class DsiValue {
  /// Register new value in env instance.
  DsiValueInstance<T> register<T>({required T data, String? key}) {
    var dataSyncValue = DsiValueInstance<T>(value: data, idKey: key);

    var dataSyncSingleton = _DataSyncInterfaceSingleton.instance;
    dataSyncSingleton.addDataSyncInstanceToQueue(dataSyncValue);

    return dataSyncValue;
  }

  /// Notify a listener at anywhere.
  bool notifyTo<T>(String key, T? payload) {
    return _DataSyncInterfaceSingleton.instance.notify<T>(key, payload);
  }

  /// Subscribe a listener at anywhere.
  static StreamSubscription<String>? listenTo<T>(
    String key,
    void Function(T data) callback,
  ) {
    return _DataSyncInterfaceSingleton.instance.listen(key, callback);
  }

  /// Check whether [key] exist.
  bool hasKey(String key) {
    var inst = _DataSyncInterfaceSingleton.instance;
    return inst.dataMap.containsKey(key);
  }

  /// Get datasync value instance.
  ///
  /// If key not found, null will be returned.
  DsiValueInstance<T>? get<T>(String key) {
    var inst = _DataSyncInterfaceSingleton.instance;
    if (inst.dataMap.containsKey(key)) {
      return inst.dataMap[key] as DsiValueInstance<T>;
    }
    return null;
  }
}
