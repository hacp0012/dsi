part of 'dsi_base.dart';

/// DSI Extention.
extension DsiExtention on BuildContext {
  /// Alias of [Dsi.of] to retrive DSI models.
  T? dsi<T>() => Dsi.of<T>(this);
}
