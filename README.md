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
  <img src="./dsi_logo.png" width="200" alt="DSI Logo">
</p>

<h2 align="center">Data Sync Interface (DSI)</h2>

<!-- # Data Sync Interface (DSI) -->
DSI est une petite bibliothèque Flutter/Dart pour synchroniser et partager des données, des callbacks et des valeurs globales entre widgets et modèles sans couplage fort.

Principaux concepts :

- Partage de modèles observables via `Dsi` / `Dsi.register` et `Dsi.update`.
- Valeurs globales (ENV) via `Dsi.values`.
- Callbacks nommés via `Dsi.callback`.
- Instances légères observables via `DsiInstance`.

Features

- Enregistrement et mise à jour de modèles (supporte `ChangeNotifier` étendu).
- Notifier des widgets liés automatiquement.
- Gestion de valeurs partagées et écouteurs par clé.
- Callbacks nommés pour communication ponctuelle entre écrans.

Installation

1. Dans votre projet Flutter, ajoutez DSI en dépendance locale (déjà configuré pour l'exemple) :

```sh
# depuis le dossier example
cd example
flutter pub get
flutter run
```

Utilisation rapide

1) Utiliser le modèle observé (avec `DsiChangeNotifier`)

- Exemple de modèle : [example/lib/models/data_model.dart](example/lib/models/data_model.dart)  
- Classe utile : [`DsiChangeNotifier`](lib/dsi.dart) — implémentation dans [lib/src/dsi_change_notifier.dart](lib/src/dsi_change_notifier.dart)

Exemple :

```dart
// enregistrez un modèle (ex: dans main ou init)
Dsi.register(DataModel());

// lire dans un widget :
Text("Count: ${Dsi.of<DataModel>(context)?.count ?? 'Not yet'}")

// mettre à jour via Dsi :
Dsi.update<DataModel>((model) {
  model.count = (model.count ?? 0) + 1;
  return model;
});
```

### Example plus detaile

Voici un exemple complet montrant l'intégration et l'utilisation de DSI dans une application Flutter :

1 . D'abord, créez votre modèle :

```dart
// lib/models/counter_model.dart
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

2 . Initialisez DSI dans votre main ou autre endroit :

```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'package:dsi/dsi.dart';
import 'models/counter_model.dart';

void main() {
  // Enregistrez votre modèle
  Dsi.registerModel(CounterModel());
  
  // Enregistrer l'arbre dans DSI
  runApp(const MyApp());
}


// lib/my_app.dart
import 'package:flutter/material.dart';
import 'screens/counter_screen.dart';

class MyApp extends StatelessWidget {
    const MyApp({Key? key}) : super(key: key);

    @override
    Widget build(BuildContext context) {
        return MaterialApp(
            title: 'DSI Example',
            theme: ThemeData(
                primarySwatch: Colors.blue,
            ),
            // **** Tres important ****
            home: DsiTreeObserver(child: CounterScreen()),
        );
    }
}
```

3 . Créez vos écrans :

```dart
// lib/screens/counter_screen.dart
import 'package:flutter/material.dart';
import 'package:dsi/dsi.dart';
import '../models/counter_model.dart';

class CounterScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Accédez au modèle via DSI
    final counter = Dsi.of<CounterModel>(context);
    
    return Scaffold(
      appBar: AppBar(title: Text('DSI Counter Example')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Count: ${counter?.count ?? 0}',
              style: Theme.of(context).textTheme.headline4,
            ),
            ElevatedButton(
              onPressed: () {
                // Mettez à jour via DSI
                counter.increment();
                // ou
                Dsi.update<CounterModel>((model) {
                  model.count += 1;
                  return model;
                });
              },
              child: Text('Increment'),
            ),
            
            // Exemple de valeur globale
            DsiBuilder<int>(
              // Enregistrez et écoutez une valeur globale
              idKey: 'globalCount'
              builder: (context, value) {
                return Text('Global count: $value');
              },
            ),
            
            // Exemple de callback entre écrans
            ElevatedButton(
              onPressed: () {
                // Appelez un callback enregistré ailleurs
                Dsi.callback.call('onReset');
              },
              child: Text('Reset Counter'),
            ),
          ],
        ),
      ),
    );
  }
}
```

4 . Enregistrez des callbacks dans un autre écran :

```dart
// lib/screens/settings_screen.dart
class SettingsScreen extends StatefulWidget {
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    // Enregistrez un callback
    Dsi.callback.register('onReset', (_) {
      Dsi.update<CounterModel>((model) {
        model.reset();
        return model;
      });
    });
  }

  @override
  void dispose() {
    // Nettoyez le callback
    Dsi.callback.unregister('onReset');
    super.dispose();
  }
  
  // ... reste du widget
}
```

Cet exemple montre les principales fonctionnalités de DSI :

- Modèle partagé avec `DsiChangeNotifier`
- Accès au modèle via `Dsi.of()`
- Mise à jour via `Dsi.update()`
- Valeurs globales avec `Dsi.values`
- Communication entre écrans via `Dsi.callback`

Voir l'exemple complet : [example/lib/screens/dsi/dsi_page_1.dart](example/lib/screens/dsi/dsi_page_1.dart).

## 2 ) Valeurs globales (ENV)

- API : [`DsiValue`](lib/dsi.dart) et son implémentation [lib/src/dsi_value.dart](lib/src/dsi_value.dart)

Exemple :

```dart
// enregistrer une valeur partagée
Dsi.values.register<int>(data: 0, key: 'counter');

// notifier les écouteurs
Dsi.values.notifyTo<int>('counter', 42);

// écouter
var sub = Dsi.values.listenTo<int>('counter', (v) => print(v));
```

Voir : [example/lib/screens/value/value_page_1_screen.dart](example/lib/screens/value/value_page_1_screen.dart).

## 3 ) Callbacks nommés

- API : [`DsiCallback`](lib/dsi.dart)

Exemple :

```dart
// enregistrer
Dsi.callback.register('my_key', (payload) => print(payload));

// appeler depuis un autre écran
Dsi.callback.call('my_key', payload: "message");
```

Voir : [example/lib/screens/callback/callback_page_1_screen.dart](example/lib/screens/callback/callback_page_1_screen.dart) et [example/lib/screens/callback/callback_page_2_screen.dart](example/lib/screens/callback/callback_page_2_screen.dart).

API publique (exports)

- [`Dsi`](lib/dsi.dart) — point d'entrée (implémentation principale : [lib/src/dsi_base.dart](lib/src/dsi_base.dart))
- [`DsiValue`](lib/dsi.dart) — valeurs partagées ([lib/src/dsi_value.dart](lib/src/dsi_value.dart))
- [`DsiCallback`](lib/dsi.dart) — callbacks nommés
- [`DsiChangeNotifier`](lib/dsi.dart) — base pour modèles observables ([lib/src/dsi_change_notifier.dart](lib/src/dsi_change_notifier.dart))
- [`DsiInstance`](lib/src/dsi_instance.dart) — instances de valeur observables

Fichiers utiles

- Code public/export : [lib/dsi.dart](lib/dsi.dart)  
- Implémentation principale : [lib/src/dsi_base.dart](lib/src/dsi_base.dart)  
- Exemples : [example/lib/main.dart](example/lib/main.dart) et dossier [example/lib](example/lib)

Bonnes pratiques

- Utiliser `DsiChangeNotifier` pour vos modèles afin de bénéficier des notifications automatiques.
- Pour des changements silencieux (sans rebuild), utilisez les options `notify: false` lorsque disponible.
- Libérez les ressources (listeners, callbacks) dans `dispose()` des `StatefulWidget` quand nécessaire (voir [example/...callback...](example/lib/screens/callback)).

Contribuer

- Ouvrir une issue ou PR.
- Respecter la licence (voir [LICENSE](LICENSE)) et le changelog [CHANGELOG.md](CHANGELOG.md).

Licence

- Projet sous licence : [LICENSE](LICENSE)

Changelog

- Voir [CHANGELOG.md](CHANGELOG.md)

Exemples rapides et références

- Exemple complet de page DSI : [example/lib/screens/dsi/dsi_page_1.dart](example/lib/screens/dsi/dsi_page_1.dart)  
- Modèle d'exemple : [example/lib/models/data_model.dart](example/lib/models/data_model.dart)  
- Point d'export : [lib/dsi.dart](lib/dsi.dart)
