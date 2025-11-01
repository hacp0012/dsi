part of 'dsi_base.dart';

class DsiValue {
  /// Register new value in env instance.
  DsiInstance<T> register<T>({required T data, String? key}) {
    var dataSyncValue = DsiInstance<T>(value: data, idKey: key);

    var dataSyncSengleton = _DataSyncInterfaceSingleton.instance;
    dataSyncSengleton.addDataSyncInstanceToQueue(dataSyncValue);

    return dataSyncValue;
  }

  /// Notify a listener at anywhere.
  bool notifyTo<T>(String key, T? payload) {
    return _DataSyncInterfaceSingleton.instance.notify<T>(key, payload);
  }

  /// Subscribe a listener at anywhere.
  static StreamSubscription<String>? listenTo<T>(String key, void Function(T data) callback) {
    return _DataSyncInterfaceSingleton.instance.listen(key, callback);
  }

  /// Check whether [key] exist.
  bool hasKey(String key) {
    var inst = _DataSyncInterfaceSingleton.instance;
    for (int i = 0; i < inst.dataList.length; i++) {
      if (inst.dataList[i].key == key) return true;
    }

    return false;
  }

  /// Get datasync instance.
  ///
  /// If key not found, null will be returned.
  DsiInstance? instance(String key) {
    var inst = _DataSyncInterfaceSingleton.instance;
    for (int i = 0; i < inst.dataList.length; i++) {
      if (inst.dataList[i].key == key) return inst.dataList[i];
    }

    return null;
  }
}
