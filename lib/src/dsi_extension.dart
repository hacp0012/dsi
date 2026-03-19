part of 'dsi_base.dart';

/// DSI Extension.
extension DsiExtension on BuildContext {
  /// Alias of [Dsi.of] to retrieve DSI models.
  T? dsi<T>() => Dsi.of<T>(this);
}
