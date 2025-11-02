Synchronize and share data, callbacks and global values between widgets and models without strong coupling.

# Data Sync Interface (DSI)

<p align="center">
    <img src="assets/dsi_logo.png" width="200" alt="DSI Logo">
</p>

DSI is a small Flutter/Dart library to synchronize and share data, callbacks and global values between widgets and models without strong coupling.

## Main concepts

- Share observable models via `Dsi.registerModel`, `Dsi.of()` and `Dsi.update()`.
- Global values with `Dsi.values`.
- Named callbacks via `Dsi.callback`.
- Lightweight UI helpers via `DsiUiValue` and `DsiUiValueMixin`.

## Features

- Registration and update of models (supports extended `ChangeNotifier`).
- Automatic notifications to linked widgets.
- Management of shared values and listeners by key.
- Named callbacks for one-time communication between screens.
- Utilities to reduce `setState` calls with `DsiUiValue` and `DsiUiValueMixin`.

### Usage in example

1. From the `example` folder:

See the example main file: [example/lib/main.dart](example/lib/main.dart)

```powershell
cd example
flutter pub get
flutter run
```

### Quick usage

1) Observable models (with `DsiChangeNotifier`)

### Model example (lib/models/counter_model.dart):

```dart
import 'package:dsi/dsi.dart';

class CounterModel extends DsiChangeNotifier {
    int _count = 0;
    int get count => _count;

    void increment() {
        _count++;
        notifyListeners();
    }

    void reset() {
        _count = 0;
        notifyListeners();
    }
}
```

Model registration (e.g. in `main.dart`):

```dart
void main() {
    Dsi.register(CounterModel());
    runApp(const MyApp());
}
```

Access and update:

```dart
// Connect the app to DSI observer (important)
DsiTreeObserver(child: MaterialApp(...));

// reading
final counter = Dsi.of<CounterModel>(context);
Text('Count: ${counter?.count ?? 0}');
Text('Count: ${Dsi.of<CounterModel>(context)?.count}');
Text('Count: ${Dsi.model<CounterModel>(context)?.count}');

// via model method
counter?.increment();

// or via Dsi.update
Dsi.update<CounterModel>((m) { m.count += 1; return m; });
```

### Global values (Dsi.values)

```dart
// register a shared value
Dsi.values.register<int>(data: 0, key: 'globalCount');

// notify listeners
Dsi.values.notifyTo<int>('globalCount', 42);

// listen
var sub = Dsi.values.listenTo<int>('globalCount', (v) => print(v));
```

### Named callbacks

```dart
// register
Dsi.callback.register('my_key', (payload) => print(payload));

// call from another screen
Dsi.callback.call('my_key', payload: 'message');
```

### DsiUiValue and DsiUiValueMixin (new section)

Quick details:

- `DsiUiValue<T>` is a small wrapper for local UI state that reduces verbosity around `setState`.
- `DsiUiValueMixin` is a mixin to use on `StatefulWidget`'s `State` to easily create `DsiUiValue` using a `dsiStater` getter that must return `setState`.

Essential API (implementation in `lib/src`):

- `DsiUiValue<T>`: constructor `DsiUiValue(void Function(void Function()) setState, T initialValue)`.
    - `.value`: read/write (writing triggers `setState`).
    - `.silent`: write without triggering `setState`.
    - `.update()`: force update (calls `setState(() {})`).

- `DsiUiValueMixin`:
    - Declares abstract getter `void Function(void Function()) get dsiStater;` that `State` must implement (`=> setState`).
    - `uiValue<T>(T initial)` returns a `DsiUiValue<T>` already bound to `dsiStater`.
    - `uiUpdate([fn])` performs `setState` via `dsiStater`.

Usage example (in a `StatefulWidget`)

```dart
class SettingsScreen extends StatefulWidget {
    const SettingsScreen({Key? key}) : super(key: key);
    @override
    State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with DsiUiValueMixin {
    // Bind dsiStater to this State's setState
    @override
    void Function(void Function()) get dsiStater => setState;

    // late to initialize before initState if needed
    late final DsiUiValue<bool> isLoading = uiValue(false);
    // late var isLoading = uiValue(false);

    @override
    void initState() {
        super.initState();
        // Example: register a DSI callback
        Dsi.callback.register('onReset', (_) {
            Dsi.update<CounterModel>((m) { m.reset(); return m; });
        });
    }

    @override
    void dispose() {
        Dsi.callback.unregister('onReset');
        super.dispose();
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(title: const Text('Settings')),
            body: Center(
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                        if (isLoading.value) const CircularProgressIndicator(),
                        ElevatedButton(
                            onPressed: () async {
                                // change value and trigger rebuild
                                isLoading.value = true;
                                await Future.delayed(const Duration(seconds: 1));
                                isLoading.value = false;
                            },
                            child: const Text('Do work'),
                        ),
                    ],
                ),
            ),
        );
    }
}
```

### MaterialApp - complete example

```dart
// lib/app.dart
import 'package:flutter/material.dart';
import 'package:dsi/dsi.dart';
import 'screens/counter_screen.dart';
import 'screens/settings_screen.dart';

class MyApp extends StatelessWidget {
    const MyApp({Key? key}) : super(key: key);

    @override
    Widget build(BuildContext context) {
        return MaterialApp(
            title: 'DSI Demo',
            theme: ThemeData(primarySwatch: Colors.blue),
            initialRoute: '/',
            routes: {
                '/': (context) => const CounterScreen(),
                '/settings': (context) => const SettingsScreen(),
            },
            builder: (context, child) {
                // Example of using Dsi.values to manage a simple theme
                Dsi.values.register<bool>(data: false, key: 'isDarkMode');

                return DsiBuilder<bool>(
                    idKey: 'isDarkMode',
                    builder: (context, isDark) {
                        return Theme(
                            data: isDark ? ThemeData.dark() : ThemeData.light(),
                            child: child ?? const SizedBox.shrink(),
                        );
                    },
                );
            },
        );
    }
}

// lib/main.dart
void main() {
    Dsi.registerModel(CounterModel());
    runApp(const MyApp());
}
```

#### Useful files

- Export point: `lib/dsi.dart`
- Implementations: `lib/src/*` (e.g. `dsi_base.dart`, `dsi_change_notifier.dart`, `dsi_ui_value.dart`, `dsi_ui_value_mixin.dart`)
- Examples: `example/lib/...` (example pages and models)

#### Best practices

- Use `DsiChangeNotifier` for your models to benefit from automatic notifications.
- Use `DsiUiValue`/`DsiUiValueMixin` to reduce the surface usage of `setState` on local UI values.
- Release resources (listeners, callbacks) in `dispose()` of `StatefulWidget` when needed.

Contributing

- Open an issue or PR.
- Respect the license (see `LICENSE`) and changelog (`CHANGELOG.md`).

License

[BSD-3-Clause](./LICENSE) — see project LICENSE file.

Changelog

- See `CHANGELOG.md`

Try the example

1. Open a terminal in `example/`:

```powershell
cd example
flutter pub get
flutter run
```

2. If you added the logo, check `pubspec.yaml` and `assets/`.

Summary of changes

- Added documentation and examples for `DsiUiValue` and `DsiUiValueMixin`.
- Complete `MaterialApp` example showing DSI integration (model, values, callbacks, UI mixin).
- Indication about `dsi_logo.png` asset and `pubspec.yaml` configuration.
