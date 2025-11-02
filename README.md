<!-- 
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/tools/pub/writing-package-pages). 

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/to/develop-packages). 
-->

# Data Sync Interface (DSI)

Synchroniser et partager des données, des callbacks et des valeurs globales entre widgets et modèles sans couplage fort.

<p align="center">
  <img src="assets/dsi_logo.png" width="200" alt="DSI Logo">
</p>

DSI est une petite bibliothèque Flutter/Dart pour synchroniser et partager des données, des callbacks et des valeurs globales entre widgets et modèles sans couplage fort.

## Principaux concepts

- Partage de modèles observables via `Dsi.registerModel`, `Dsi.of()` et `Dsi.update()`.
- Valeurs globales avec `Dsi.values`.
- Callbacks nommés via `Dsi.callback`.
- Helpers UI légers via `DsiUiValue` et `DsiUiValueMixin`.

## Fonctionnalités

- Enregistrement et mise à jour de modèles (supporte `ChangeNotifier` étendu).
- Notifications automatiques des widgets liés.
- Gestion de valeurs partagées et écouteurs par clé.
- Callbacks nommés pour communication ponctuelle entre écrans.
- Utilitaires pour réduire les appels `setState` avec `DsiUiValue` et `DsiUiValueMixin`.

### Utilisation dans example

1. Depuis le dossier `example` :

Voir le fichier main de l'exemple : [example/lib/main.dart](example/lib/main.dart)

```powershell
cd example
flutter pub get
flutter run
```

### Utilisation rapide

1) Modèles observables (avec `DsiChangeNotifier`)

### Exemple de modèle (lib/models/counter_model.dart) :

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

Enregistrement du modele (par ex. dans `main.dart`) :

```dart
void main() {
  Dsi.register(CounterModel());
  runApp(const MyApp());
}
```

Accès et mise à jour :

```dart
// Connecter l'app a l'observateur DSI (important)
DsiTreeObserver(child: MaterialApp(...));

// lecture
final counter = Dsi.of<CounterModel>(context);
Text('Count: ${counter?.count ?? 0}');
Text('Count: ${Dsi.of<CounterModel>(context)?.count}');
Text('Count: ${Dsi.model<CounterModel>(context)?.count}');

// via la méthode du modèle
counter?.increment();

// ou via Dsi.update
Dsi.update<CounterModel>((m) { m.count += 1; return m; });
```

### Valeurs globales (Dsi.values)

```dart
// enregistrer une valeur partagée
Dsi.values.register<int>(data: 0, key: 'globalCount');

// notifier les écouteurs
Dsi.values.notifyTo<int>('globalCount', 42);

// écouter
var sub = Dsi.values.listenTo<int>('globalCount', (v) => print(v));
```

### Callbacks nommés

```dart
// enregistrer
Dsi.callback.register('my_key', (payload) => print(payload));

// appeler depuis un autre écran
Dsi.callback.call('my_key', payload: 'message');
```

### DsiUiValue et DsiUiValueMixin (nouvelle section)

Détails rapides :

- `DsiUiValue<T>` est un petit wrapper pour un état local UI qui réduit la verbosité autour de `setState`.
- `DsiUiValueMixin` est un mixin à utiliser sur la `State` d'un `StatefulWidget` pour créer facilement des `DsiUiValue` en utilisant un getter `dsiStater` qui doit renvoyer `setState`.

API essentielle (implémentation dans `lib/src`):

- `DsiUiValue<T>` : constructeur `DsiUiValue(void Function(void Function()) setState, T initialValue)`.
  - `.value` : lecture/écriture (écriture déclenche `setState`).
  - `.silent` : écrire sans déclencher `setState`.
  - `.update()` : forcer une mise à jour (appelle `setState(() {})`).

- `DsiUiValueMixin` :
  - Déclare le getter abstrait `void Function(void Function()) get dsiStater;` que la `State` doit implémenter (`=> setState`).
  - `uiValue<T>(T initial)` renvoie un `DsiUiValue<T>` déjà lié au `dsiStater`.
  - `uiUpdate([fn])` effectue un `setState` via `dsiStater`.

Exemple d'utilisation (dans un `StatefulWidget`)

```dart
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with DsiUiValueMixin {
  // Bind le dsiStater au setState de ce State
  @override
  void Function(void Function()) get dsiStater => setState;

  // late pour pouvoir l'initialiser avant initState si nécessaire
  late final DsiUiValue<bool> isLoading = uiValue(false);
  // late var isLoading = uiValue(false);

  @override
  void initState() {
    super.initState();
    // Exemple : enregistrer un callback DSI
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
                // changer la valeur et déclencher rebuild
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

### MaterialApp - exemple complet

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
        // Exemple d'utilisation de Dsi.values pour gérer un thème simple
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

#### Fichiers utiles

- Point d'export : `lib/dsi.dart`
- Implémentations : `lib/src/*` (ex: `dsi_base.dart`, `dsi_change_notifier.dart`, `dsi_ui_value.dart`, `dsi_ui_value_mixin.dart`)
- Exemples : `example/lib/...` (pages et modèles d'exemple)

#### Bonnes pratiques

- Utiliser `DsiChangeNotifier` pour vos modèles afin de bénéficier des notifications automatiques.
- Utiliser `DsiUiValue`/`DsiUiValueMixin` pour réduire la surface d'utilisation de `setState` sur des valeurs UI locales.
- Libérez les ressources (listeners, callbacks) dans `dispose()` des `StatefulWidget` quand nécessaire.

Contribuer

- Ouvrir une issue ou PR.
- Respecter la licence (voir `LICENSE`) et le changelog (`CHANGELOG.md`).

Licence

[BS2](./LICENSE) — voir le fichier LICENSE du projet.

Changelog

- Voir `CHANGELOG.md`

Essayer l'exemple

1. Ouvrez un terminal dans `example/` :

```powershell
cd example
flutter pub get
flutter run
```

2. Si vous avez ajouté le logo, vérifiez `pubspec.yaml` et `assets/`.

Résumé des changements

- Ajout de la documentation et d'exemples pour `DsiUiValue` et `DsiUiValueMixin`.
- Exemple `MaterialApp` complet montrant l'intégration DSI (modèle, valeurs, callbacks, UI mixin).
- Indication sur l'asset `dsi_logo.png` et la configuration `pubspec.yaml`.
