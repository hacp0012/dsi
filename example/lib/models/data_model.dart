// import 'package:dsi/dsi.dart';

import 'package:dsi/dsi.dart' show DsiChangeNotifier;

class DataModel extends DsiChangeNotifier {
  int? count;

  void increment() {
    count ??= 0;
    count = count! + 1;

    /// Notifies listeners of the change.
    notifyListeners();
  }
}
