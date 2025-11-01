part of 'dsi_base.dart';

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
