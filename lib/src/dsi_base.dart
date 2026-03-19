import 'dart:async';

import 'dart:math';
import 'package:flutter/material.dart';

// Privates
part 'core_data_sync_interface_singleton.dart';
part 'dsi_value_instance.dart';
part 'dsi_tree_observer.dart';

// Publics
part 'dsi_builder.dart';
part 'dsi_change_notifier.dart';
part 'dsi_extension.dart';
part 'dsi_callback.dart';
part 'dsi_value.dart';

// * PUBLIC ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
/// __Data Sync Interface.__
///
/// All outputs are null safe, because you can dispose a model via [unregister]
/// or if it is the value DSI, via [DsiValueInstance.freeIt].
///
/// __VALUE DSI__
///
/// ```dart
/// String refKey = 'MY_DSI_REF_KEY';
///
/// // First usage.
/// Dsi<int>(data: 123, key: refKey);
///
/// // Second usage.
/// DsiValueInstance age = Dsi(data: 123, key: refKey);
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
  Dsi._();

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
  /// Get registered model.
  ///
  /// __Strongly recommended__:
  /// The best place to use this is inside a build method.
  ///
  /// __Note that__: This method register a context to the tree.
  ///
  /// - It return Null when the model instance is not found.
  /// Because [Dsi] offer the possiblity to call and register model anywhere.
  ///
  /// - All data provided by [of] are in readOnly, try to update it's has no effect.
  static T? of<T>(BuildContext context) {
    var inst = _DataSyncInterfaceSingleton.instance;
    var element = inst.modelsMap[T];
    if (element != null && context.mounted) {
      if (element is DsiChangeNotifier) {
        element._registerContext(context);
      }
      return element as T;
    }

    // Fallback: search by type if exact type parameter wasn't used correctly
    for (var model in inst.modelsMap.values) {
      if (model is T && context.mounted) {
        if (model is DsiChangeNotifier) {
          model._registerContext(context);
        }
        return model;
      }
    }

    return null;
  }

  /// Get registered model without context.
  ///
  /// This is similar to [of] but it does not notify the tree when a change occurs.
  /// It can act similarly if [DsiTreeObserver] is set and [of] is used before in the tree.
  ///
  /// Using this is the same as using a Singleton instance.
  ///
  /// The cool thing with this is that you can get your model without providing a context.
  static T? model<T>() {
    var inst = _DataSyncInterfaceSingleton.instance;
    if (inst.modelsMap.containsKey(T)) {
      return inst.modelsMap[T] as T?;
    }

    // Fallback search
    for (var model in inst.modelsMap.values) {
      if (model is T) {
        return model;
      }
    }

    return null;
  }

  /// Update a model and notify update to the tree if necesary.
  ///
  /// If [notify] is false, it will not notify tree.
  ///
  /// __Note__ :
  /// Change notification is possible only on all contexts registred
  /// with [of].
  static bool update<T>(T Function(T model) provider, {bool notify = true}) {
    var getedModel = model<T>();
    if (getedModel != null) {
      T updatedModel = provider(getedModel);

      var inst = _DataSyncInterfaceSingleton.instance;

      // Update in map based on actual key
      dynamic keyToUpdate;
      for (var key in inst.modelsMap.keys) {
        if (inst.modelsMap[key] == getedModel) {
          keyToUpdate = key;
          break;
        }
      }

      if (keyToUpdate != null) {
        inst.modelsMap[keyToUpdate] = updatedModel;
        // Notify tree
        if ((updatedModel is DsiChangeNotifier) && notify) {
          updatedModel._shouldNotifyTree();
        }
        return true;
      }
    }

    return false;
  }

  /// Register instance.
  ///
  /// Registers two kinds of class types:
  /// - Primitive class with other extends class or not (Lazy Singleton).
  /// - Class that extends ChangeNotifier or subtype of it. It's recommended to
  ///   use [DsiChangeNotifier] on your model to handle notifications.
  ///
  /// ```dart
  /// Dsi.register<MyModel1>(MyModel1());
  /// ```
  ///
  /// If a model is registered twice, the old one will be removed. This behavior can be prevented by
  /// setting [keepOld] to true. The default is false.
  static void register<T>(T model, {bool keepOld = false}) {
    var inst = _DataSyncInterfaceSingleton.instance;
    Type key = T == dynamic ? model.runtimeType : T;

    if (inst.modelsMap.containsKey(key)) {
      if (keepOld) return;
    } else {
      for (var existingKey in inst.modelsMap.keys) {
        if (inst.modelsMap[existingKey].runtimeType == model.runtimeType) {
          if (keepOld) return;
          key = existingKey;
          break;
        }
      }
    }

    inst.modelsMap[key] = model;
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

  /// Unregister a registered model.
  ///
  /// If the model instance exists, it will be removed.
  static bool unregister<T>() {
    var inst = _DataSyncInterfaceSingleton.instance;
    if (inst.modelsMap.containsKey(T)) {
      inst.modelsMap.remove(T);
      return true;
    }

    var keysToRemove = [];
    for (var key in inst.modelsMap.keys) {
      if (inst.modelsMap[key] is T) {
        keysToRemove.add(key);
      }
    }

    if (keysToRemove.isNotEmpty) {
      for (var key in keysToRemove) {
        inst.modelsMap.remove(key);
      }
      return true;
    }

    return false;
  }

  /// Rebuild this context if it's subscribed.
  static void rebuildThis(BuildContext context) {
    if (context is Element) {
      context.markNeedsBuild();
    }
  }
}
