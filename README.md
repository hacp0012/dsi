# Data Sync Interface (DSI)

<p align="center">
    <img src="./assets/dsi_logo.png" width="200" alt="DSI Logo">
</p>

DSI (Data Sync Interface) is a powerful, lightweight, and professional State Manager library for Flutter. It allows you to synchronize and share observable models, global values, and event callbacks between widgets seamlessly.

With `DSI`, you can significantly reduce boilerplate code, avoid memory leaks natively, and minimize repetitive `setState` logic, all without strong coupling.

---

## 🌟 Key Features

1. **Observable Models**: Register and update globally shared models with `DsiChangeNotifier` yielding surgical optimizations (O(1) memory caching).
2. **Context Extension**: Use `context.dsi<Model>()` directly to access and listen to state changes effortlessly.
3. **Global Value Tracking**: Reactive global scopes using `Dsi.values` and listening efficiently inside `DsiBuilder`.
4. **Event Bus (Callbacks)**: Dispatch named events and callbacks anywhere in your app via `Dsi.callback`.
5. **Smart Local UI State**: Stop writing tedious boilerplate for local logic by leveraging `DsiUiValueMixin` and `uiValue`.

---

## 📖 Table of Contents

- [Data Sync Interface (DSI)](#data-sync-interface-dsi)
  - [🌟 Key Features](#-key-features)
  - [📖 Table of Contents](#-table-of-contents)
  - [🚀 Getting Started (Initialization)](#-getting-started-initialization)
  - [🧰 1. Observable Models (Core State)](#-1-observable-models-core-state)
    - [Defining a Model](#defining-a-model)
    - [Registering & Accessing](#registering--accessing)
    - [Updating Models Remotely](#updating-models-remotely)
  - [🌐 2. Global Scoped Values (`Dsi.values`)](#-2-global-scoped-values-dsivalues)
  - [⚡ 3. Unified Callbacks (`Dsi.callback`)](#-3-unified-callbacks-dsicallback)
  - [🎯 4. Smart Local State (`DsiUiValueMixin`)](#-4-smart-local-state-dsiuivaluemixin)
  - [💡 Best Practices](#-best-practices)

---

## 🚀 Getting Started (Initialization)

To use DSI throughout your application, you should utilize the **`DsiTreeObserver`** widget at the root of your app. This widget acts as an entry point for initializing global models effectively.

```dart
import 'package:flutter/material.dart';
import 'package:dsi/dsi.dart';

void main() {
  runApp(
    // Optionally pre-register multiple models efficiently:
    DsiTreeObserver(
      models: [ ThemeController(), AuthModel() ], // Registration
      child: const MyApp(),
    ),
  );
}
```

---

## 🧰 1. Observable Models (Core State)

Instead of using Flutter's traditional `ChangeNotifier`, DSI introduces a highly optimized **`DsiChangeNotifier`**. It automatically handles context subscriptions and garbage collection (ignoring unmounted widgets) internally native through a highly efficient `Set<BuildContext>`.

### Defining a Model

```dart
import 'package:dsi/dsi.dart';

// 1. Extend the professional DsiChangeNotifier
class CounterModel extends DsiChangeNotifier {
  int _count = 0;
  int get count => _count;

  void increment() {
    _count++;
    
    // 2. Call trigger to rebuild ONLY dependent widgets!
    notifyListeners(); 
  }
}
```

### Registering & Accessing

Models must be registered so they can be available from anywhere.
You can register it at the application root using `DsiTreeObserver` (as seen above) or manually via `Dsi.register()`.

```dart
// Register manually inside an initialization phase
Dsi.register(CounterModel());
```

In your widgets, you have two ways to retrieve the data safely:

```dart
@override
Widget build(BuildContext context) {
  // Option A (Cleanest): Use the DsiExtension directly on the context
  final counter = context.dsi<CounterModel>();

  // Option B: Query DSI natively 
  final sameCounter = Dsi.of<CounterModel>(context);

  return Scaffold(
    body: Center(
      child: Text('Count: ${counter?.count ?? 0}'),
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: () => counter?.increment(),
      child: const Icon(Icons.add),
    ),
  );
}
```

### Updating Models Remotely

If you are inside a function where you **don't have access to your UI context**, you can still update your models globally using `Dsi.update<T>()`. This will automatically trigger rebuilds on contexts listening to it across the app.

```dart
void performBackgroundSync() {
  // Fetch data natively and update UI listeners seamlessly
  Dsi.update<CounterModel>((model) {
     model.increment(); 
     return model;
  });
}
```

---

## 🌐 2. Global Scoped Values (`Dsi.values`)

Sometimes you just want to track a simple variable (a string, a boolean, or an int) across the app without constructing an entire Model Class. `Dsi.values` behaves like a Key-Value pair store that offers robust streaming!

**Register & Use with DsiBuilder:**
```dart
// 1. Register a value globally via key
Dsi.values.register<bool>(data: false, key: 'isDarkMode');

// 2. Build reactive UIs using DsiBuilder corresponding to the target key
Widget build(BuildContext context) {
  return DsiBuilder<bool>(
    idKey: 'isDarkMode',
    builder: (context, isDark) {
      return MaterialApp(
        theme: isDark == true ? ThemeData.dark() : ThemeData.light(),
        home: const Home(),
      );
    },
  );
}
```

**Modifying the value from anywhere:**
```dart
// Change the value - This will automatically trigger DsiBuilder to build again!
Dsi.values.notifyTo<bool>('isDarkMode', true);
```

---

## ⚡ 3. Unified Callbacks (`Dsi.callback`)

DSI allows you to map named callback events globally. This prevents deep "prop-drilling" of callback functions traversing across numerous constructor arguments.

```dart
// Register an event callback in Widget A:
Dsi.callback.register('onUserLogout', (payload) {
   print('User Logged Out with message: $payload');
});

// Trigger the event safely from Widget B:
Dsi.callback.call('onUserLogout', payload: 'Session Expired!');
```

---

## 🎯 4. Smart Local State (`DsiUiValueMixin`)

Are you tired of maintaining a verbose amount of `setState(() {})` calls for local states like `isLoading` or `isExpanded`? The implementation of `DsiUiValueMixin` drastically accelerates simple local UI reactivity. 

**Quick implementation rules:**
1. Extend `with DsiUiValueMixin` in your `State` class.
2. Override `dsiStateUpdater` property, hooking it natively to `setState`.
3. Track properties cleanly with `uiValue<T>(initial)`.

```dart
class SettingsScreen extends StatefulWidget {
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with DsiUiValueMixin {
  
  // 1. Delegate DSI Updater to Flutter's native setState handler
  @override
  void Function(void Function()) get dsiStateUpdater => setState;

  // 2. Define reactive values cleanly (Use late syntax)
  late final DsiUiValue<bool> isLoading = uiValue(false);
  late final DsiUiValue<String> userStatus = uiValue('Active');

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (isLoading.value) const CircularProgressIndicator(),
        
        Text("Status: ${userStatus.value}"), // Reactive text
        
        ElevatedButton(
          onPressed: () async {
            // 3. Mutating the .value directly invokes setState securely!
            isLoading.value = true;
            userStatus.value = "Processing...";
            
            await Future.delayed(const Duration(seconds: 2));
            
            isLoading.value = false;
            userStatus.value = "Finished";
          },
          child: const Text('Simulate Load'),
        ),
      ],
    );
  }
}
```

---

## 💡 Best Practices

1. **Clean up manual listeners**: `DsiChangeNotifier` natively prevents memory leaks automatically. However, if you explicitly attach subscriptions using raw `listen()` logic inside `initState`, always drop them via `freeIt()` in your `dispose()`.
2. **One Ideology**: Ensure to use `DsiChangeNotifier` explicitly instead of Flutter's stock `ChangeNotifier`. Internal implementations depend heavily on targeted Context-mapping.
3. **Optimized Lookup**: DSI performs state searches instantly natively mapped in `O(1)` Hash Maps. Name your `Keys` distinctly.

*(License references and package data belong to their respective proprietary authors).*
