part of 'dsi_base.dart';

/// Named callback hangler.
class DsiCallback {
  /// Register a callback that we can call any way to notify change or action.
  ///
  /// Usefull to manualy update change.
  ///
  /// [ref] is a reference key. It must be UNIQUE KEY.
  ///
  /// if on registring new callback with a same ref that match a registred ref,
  /// the old are replaced with new Callback.
  void register(String ref, void Function(dynamic) callback) {
    var list = _DataSyncInterfaceSingleton.instance.callbacksList;

    list[ref] = callback;
    _DataSyncInterfaceSingleton.instance.callbacksList = list;
  }

  /// Call registred callback.
  ///
  /// If [ref] match with a registred callback [ref] that callback are called.
  /// - __Attention__ ref must be of type [String] or [List] of Strings only. if not
  /// registraction will be rejected.
  ///
  /// Return false when ref key not match.
  bool call(dynamic ref, {dynamic payload, bool reThrowException = true}) {
    var list = _DataSyncInterfaceSingleton.instance.callbacksList;

    void Function(dynamic)? callback;
    // CALL FOR MAY.
    if (ref is List<String>) {
      bool returnState = false;

      for (String key in ref) {
        callback = list[key];

        if (callback != null) {
          try {
            callback.call(payload);
          } catch (e) {
            if (reThrowException) rethrow;
          }

          returnState = true;
        }
      }

      return returnState;
    }
    // CALL SINGLE.
    else if (ref is String) {
      callback = list[ref];

      if (callback != null) {
        try {
          callback.call(payload);
        } catch (e) {
          if (reThrowException) rethrow;
        }

        return true;
      }
    }

    return false;
  }

  /// Dispose registred callback.
  ///
  /// __To avoid call error__ :
  /// It is necessary to dispose a callback when you know that
  /// it [Widget] container are disposed. That mean, method callback
  /// are not exist. (Disposed with mather)
  void dispose(String ref) {
    _DataSyncInterfaceSingleton.instance.callbacksList.removeWhere((key, value) => key == ref);
  }
}
