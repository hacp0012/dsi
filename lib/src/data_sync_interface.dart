import 'dart:async';

import 'dart:math';
import 'package:flutter/material.dart';

export '' show Dsi, DsiBuilder;

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

// * PUBLIC ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
/// __Data Sync Interface.__
///
/// You will remark that all outputs are null safe. Because you can dispose a model via [unRegisterModel]
/// of if is the value DSI, via [DsiInstance.freeIt].
///
/// __VALUE DSI__
///
/// ```dart
/// String refKey = 'MY_DSI_REF_KEY';
///
/// // First usage.
/// Dsi<int>(data: 123, key: refKey);
///
/// // Sencaond usage.
/// DsiInstance age = Dsi(data: 123, key: refKey);
/// // or ----------
/// DsiInstance age = Dsi(data: 123, key: null);
/// // Id key (ref-key) will be auto-generated.
/// // You can retrive it via [age] instance. as this :
/// refKey = age.key;
/// // -------------
///
/// // Listen 1.
/// Dsi.listenTo<int>(refKey, (age) => print(age));
///
/// // Listen 2.
/// age.listen((age) => print(age));
///
/// // Notify 1.
/// age.value = 18;
///
/// // Notify 2.
/// bool state = Dsi.notifyTo<int>(refKey, 18);
///
/// // Despose.
/// age.freeIt();
/// ```
///
/// __MODEL DSI__
///
/// ```dart
/// // First register a model.
/// Dsi.registerModel(MyModeClass());
/// Dsi.registerModel<List>([MyModeClass(), ...]);
///
/// // Optionaly register app tree observer.
/// DsiTreeObserver(
///   child: MaterialApp(...);
/// );
///
/// // use in build method:
/// // Get data:
/// int? age = Dsi.of<MyAgeModel>(context)?.age;
/// ```
class Dsi {
  /// Creates a new DataSync instance.
  ///
  /// If key is Null, key will be auto generate with 45 alphaNumeric characters.
  /*Dsi({required T data, String? key, super.onChanged}) : super(value: data, idKey: key) {
    var dataSyncSengleton = _DataSyncInterfaceSingleton.instance;

    dataSyncSengleton.addDataSyncInstanceToQueue(this);
  }*/

  // |*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*| VALUE HANDLER |*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|**|*|*|*|*|*|*|*|*|*|*|*|*
  static DsiValue get values => DsiValue();

  // |*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*| CALLBACK HANDLER |*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*
  static DsiCallback get callback => DsiCallback();

  // |*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*| MODEL HANDLER |*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|
  /// Get registred model.
  ///
  /// __Verry Strongly recommanded__:
  /// The good place to use this, is inside a build method.
  ///
  /// __Note that__: This method register a context to the tree.
  ///
  /// - It return Null when the model instance is not found.
  /// Because [Dsi] offer the possiblity to call and register model anywhere.
  static T? of<T>(BuildContext context) {
    var inst = _DataSyncInterfaceSingleton.instance;
    for (int i = 0; i < inst.modelsList.length; i++) {
      var element = inst.modelsList[i];
      if (element is T && context.mounted) {
        if (element is DsiChangeNotifier) {
          /// Tree shaka all unmounted contexts and if current context exist in tree.
          List<BuildContext> newContexts = [];
          for (int index = 0; index < element._currentTreePositionContexts.length; index++) {
            if (element._currentTreePositionContexts[index] == context ||
                element._currentTreePositionContexts[index].mounted == false) {
              continue;
            }
            newContexts.add(element._currentTreePositionContexts[index]);
          }

          /// If current context ixist in the tree, old will be replaced by new.
          newContexts.add(context);
          element._currentTreePositionContexts = newContexts;
        }
        return element;
      }
    }

    return null;
  }

  /// Get registred model without context.
  ///
  /// This is tipicaly same as [of] but it not notify tree when change occure.
  /// but some time it can acte as, if [DsiTreeObserver] is setted and [of]
  /// is used before un tree.
  ///
  /// Use this is same as you use a Singleton instance.
  ///
  /// The cool thing with this is that you can get your model without provide a
  /// context.
  static T? model<T>() {
    var inst = _DataSyncInterfaceSingleton.instance;
    for (int i = 0; i < inst.modelsList.length; i++) {
      var element = inst.modelsList[i];
      if (element is T) {
        return element;
      }
    }

    return null;
  }

  /// Update a model and notify update to the tree if necesary.
  ///
  /// __Note__ :
  /// Change notification is possible only on all contexts registred
  /// with [of].
  static bool update<T>(T Function(T model) provider) {
    var getedModel = model<T>();
    if (getedModel != null) {
      T updatedModel = provider(getedModel);

      var inst = _DataSyncInterfaceSingleton.instance;
      for (int index = 0; index < inst.modelsList.length; index++) {
        var item = inst.modelsList[index];
        if (item.runtimeType == getedModel.runtimeType) {
          inst.modelsList[index] = updatedModel;

          if (updatedModel is DsiChangeNotifier) {
            updatedModel._shuldNotifyTree();
          }

          return true;
        }
      }
    }

    return false;
  }

  /// Register instance.
  ///
  /// Register tow kinds of class types
  /// - primitive class with other extends class or not (Lazy Singleton).
  /// - Class that extend ChangeNotifier or subtype of it. It recommanded to
  /// use [DsiChangeNotifier] on your model to handle notifier. (Lazy Singleton)
  /// - singleton instance.
  ///
  /// ```dart
  /// Dsi.registerModel<MyModel1>(MyModel1());
  /// ```
  ///
  /// If a model is registred twice, old are removed. this behavior can  be prevent by
  /// [keepOld]. Keep or concervet old registred model instance. Default is false.
  /// it prevent default behavior that replace old model instance.
  static void register<T>(T model, {bool keepOld = false}) {
    /// REGISTER.
    /// If old of this model already exist in tree, remove it.
    var inst = _DataSyncInterfaceSingleton.instance;
    for (int i = 0; i < inst.modelsList.length; i++) {
      if (inst.modelsList[i].runtimeType == model.runtimeType) {
        // PREVENT REPLACEMENT OF OLD INSTANCE.
        if (keepOld) return;

        // REPLACEMENT.
        inst.modelsList.removeAt(i);
        break;
      }
    }

    /// Setting a listener for the current registred model.
    if (model is DsiChangeNotifier) {
      model.addListener(() {
        if (model._currentTreePositionContexts.isNotEmpty) {
          List<BuildContext> newContexts = [];
          for (int index = 0; index < model._currentTreePositionContexts.length; index++) {
            BuildContext context = model._currentTreePositionContexts[index];

            /// Tree shake all unmounted contexts.
            if (context.mounted) {
              _DsiInnerTreeObserver.of<DsiChangeNotifier>(context)._shuldNotifyTree();
              newContexts.add(context);
            }
          }
          model._currentTreePositionContexts = newContexts;
        }
      });
    }

    inst.modelsList.add(model);
  }

  /// Register many models instances.
  ///
  /// Register tow kinds of class types
  /// - primitive class with other extends class or not.
  /// - Class that extend ChangeNotifier or subtype of it. It recommanded to
  /// use [DsiChangeNotifier] on your model to handle notifier.
  ///
  /// ```dart
  /// Dsi.registerModels<List>([MyModel1(), ...]);
  /// ```
  static void registerModels(List models) {
    for (int index = 0; index < models.length; index++) {
      register(models[index]);
    }
  }

  /// Unregister a registred model.
  ///
  /// If model instance exist, old will be removed.
  static bool unRegisterModel<T>() {
    var inst = _DataSyncInterfaceSingleton.instance;
    for (int index = 0; index < inst.modelsList.length; index++) {
      var model = inst.modelsList[index];
      if (model is T) {
        inst.modelsList.removeAt(index);
        return true;
      }
    }

    return false;
  }

  /// Rebuild this context.
  static void rebuildThis(BuildContext context) {
    _DsiInnerTreeObserver.of<DsiChangeNotifier>(context)._shuldNotifyTree();
  }
}

class DsiValue {
  /// Register new value in env instance.
  DsiInstance<T> register<T>({required T data, String? key, Function(T?)? onChanged}) {
    var dataSyncValue = DsiInstance<T>(value: data, idKey: key, onChanged: onChanged);

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

/// DSI Extention.
extension DsiExtention on BuildContext {
  /// Alias of [Dsi.of] to retrive DSI models.
  T? dsi<T>() => Dsi.of<T>(this);
}

// ! PRIVATE |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
class _DsiInnerTreeObserver<T extends ChangeNotifier> extends InheritedNotifier<T> {
  /// Creates an [InheritedNotifier] that updates its dependents when [notifier]
  /// sends notifications.
  ///
  /// The [child] and [notifier] arguments must not be null.
  const _DsiInnerTreeObserver({super.key, required T super.notifier, required super.child});

  /// The [notifier] object from the closest instance of this class that encloses
  /// the given context.
  ///
  /// If [listen] is true (the default), the [context] will be rebuilt when
  /// the [notifier] sends a notification.
  ///
  /// If no [_DsiInnerTreeObserver] ancestor is found, this method will assert in
  /// debug mode, and throw an exception in release mode.
  @protected
  static T of<T extends ChangeNotifier>(BuildContext context, {bool listen = true}) {
    final _DsiInnerTreeObserver<T>? result = listen
        ? context.dependOnInheritedWidgetOfExactType<_DsiInnerTreeObserver<T>>()
        : context.getElementForInheritedWidgetOfExactType<_DsiInnerTreeObserver<T>>()?.widget as _DsiInnerTreeObserver<T>?;
    assert(result != null, 'No Dsi<$T> found in context');
    return result!.notifier!;
  }
}

// * PUBLIC ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
/// DSI Tree Observer.
///
/// Use to observe tree.
/// It will rebuild the depended tree when change is notified.
class DsiTreeObserver extends StatelessWidget {
  /// Use on Top of tree, may be up [MaterialApp].
  ///
  /// This observer, rebuild tree when change is notified in tree.
  ///
  /// ```dart
  /// DsiTreeObserver(
  ///   models: [...],
  ///   child: MaterialApp(...),
  /// );
  /// ```
  ///
  /// When your register a model, [keepOld] is defaultely true; This prevent to
  /// re-register registreds models (That keep or concerve ald instances).
  DsiTreeObserver({super.key, required this.models, required this.child}) {
    for (int i = 0; i < models.length; i++) {
      Dsi.register(models[i], keepOld: true);
    }
  }

  final Widget child;

  /// Observable models list.
  final List models;

  @override
  Widget build(BuildContext context) {
    return _DsiInnerTreeObserver<DsiChangeNotifier>(notifier: DsiChangeNotifier(), child: child);
  }
}

// * PUBLIC ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
/// Default DSI Change notifier.
///
/// Is extend [ChangeNotifier] with litle more context data.
///
/// Strongly recommanded Use [DsiChangeNotifier] enstead of [ChangeNotifier].
class DsiChangeNotifier extends ChangeNotifier {
  /// Current Tree cursor Position in Context tree.
  ///
  /// Use to notify [DsiTreeObserver]
  @protected
  late List<BuildContext> _currentTreePositionContexts = [];

  /// Rebuild tree on notification.
  @protected
  void _shuldNotifyTree() {
    // currentEntryContext = null;
    notifyListeners();
  }
}

// ! PRIVATE |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
/// Data Sync Instance.
class DsiInstance<T> {
  DsiInstance({required T value, required String? idKey, this.onChanged}) {
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
  bool notify(T? payload) => _inst.notify<T>(key, payload);

  /// Remove this instance on queue.
  ///
  /// This is not unsubscribe all subscribtion but remove only event on queue list.
  void freeIt() => _inst.dataList.removeWhere((element) => element.key == key);
}

// * ------------ WIDGET ---------------- * ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
/// DSI Widget.
///
/// The [idKey] must be a data ref-key.
/// Setted via [Dsi] constructor.
///
/// ```dart
/// Dsi<int>(data: 123, key: 'MY_REF_KEY');
/// ```
class DsiBuilder<T> extends StatelessWidget {
  /// Creates a widget that delegates its build to a callback.
  const DsiBuilder({super.key, required this.idKey, required this.builder});
  final String idKey;

  /// Called to obtain the child widget.
  ///
  /// This function is called whenever this widget is included in its parent's
  /// build and the old widget (if any) that it synchronizes with has a distinct
  /// object identity. Typically the parent's build method will construct
  /// a new tree of widgets and so a new Builder child will not be [identical]
  /// to the corresponding old one.
  // final WidgetBuilder builder;
  final Widget Function(BuildContext context, T? data) builder;

  @override
  Widget build(BuildContext context) {
    var dataSync = _DataSyncInterfaceSingleton.instance;

    if (Dsi.values.hasKey(idKey)) {
      return StreamBuilder(
        stream: dataSync._stream,
        builder: (context, asyncSnapshot) {
          if (asyncSnapshot.hasData && asyncSnapshot.data != null && Dsi.values.hasKey(asyncSnapshot.data!)) {
            var data = Dsi.values.instance(idKey);
            return builder(context, data?.value);
          }

          return builder(context, null);
        },
      );
    } else {
      return builder(context, null);
    }
  }
}
