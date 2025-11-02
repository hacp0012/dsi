import 'dart:async';

import 'dart:math';
import 'package:flutter/material.dart';

// Privates
part 'core_data_sync_interface_singleton.dart';
part 'dsi_instance.dart';
part 'dsi_tree_observer.dart';
part 'dsi_inner_tree_observer.dart';

// Publics
part 'dsi_builder.dart';
part 'dsi_change_notifier.dart';
part 'dsi_extention.dart';
part 'dsi_callback.dart';
part 'dsi_value.dart';

// * PUBLIC ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
/// __Data Sync Interface.__
///
/// You will remark that all outputs are null safe. Because you can dispose a model via [unregister]
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
  /// Get registred model.
  ///
  /// __Verry Strongly recommanded__:
  /// The good place to use this, is inside a build method.
  ///
  /// __Note that__: This method register a context to the tree.
  ///
  /// - It return Null when the model instance is not found.
  /// Because [Dsi] offer the possiblity to call and register model anywhere.
  ///
  /// - All data provided by [of] are in readOnly, try to update it's has no effect.
  static T? of<T>(BuildContext context) {
    var inst = _DataSyncInterfaceSingleton.instance;
    for (int i = 0; i < inst.modelsList.length; i++) {
      var element = inst.modelsList[i];
      if (element is T && context.mounted) {
        if (element is DsiChangeNotifier) {
          /// Tree shake all unmounted contexts and if current context exist in tree.
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
      for (int index = 0; index < inst.modelsList.length; index++) {
        var item = inst.modelsList[index];
        if (item.runtimeType == getedModel.runtimeType) {
          inst.modelsList[index] = updatedModel;

          // Notifiy tree.
          if ((updatedModel is DsiChangeNotifier) && notify) updatedModel._shuldNotifyTree();

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
  static bool unregister<T>() {
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
  ///
  /// Can be used to rebuid (update) provided (ui) context.
  static void rebuildThis(BuildContext context) {
    _DsiInnerTreeObserver.of<DsiChangeNotifier>(context)._shuldNotifyTree();
  }
}
