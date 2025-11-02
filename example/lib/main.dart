import 'package:example/models/data_model.dart';
import 'package:example/screens/callback/callback_page_1_screen.dart';
import 'package:example/screens/dsi/dsi_page_1.dart';
import 'package:example/screens/value/value_page_1_screen.dart';
import 'package:flutter/material.dart';
import 'package:dsi/dsi.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DsiTreeObserver(
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          // This is the theme of your application.
          //
          // TRY THIS: Try running your application with "flutter run". You'll see
          // the application has a purple toolbar. Then, without quitting the app,
          // try changing the seedColor in the colorScheme below to Colors.green
          // and then invoke "hot reload" (save your changes or press the "hot
          // reload" button in a Flutter-supported IDE, or press "r" if you used
          // the command line to start the app).
          //
          // Notice that the counter didn't reset back to zero; the application
          // state is not lost during the reload. To reset the state, use hot
          // restart instead.
          //
          // This works for code too, not just values: Most code changes can be
          // tested with just a hot reload.
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home: const DemoHomePage(),
      ),
    );
  }
}

class DemoHomePage extends StatefulWidget {
  const DemoHomePage({super.key});

  @override
  State<DemoHomePage> createState() => _DemoHomePageState();
}

class _DemoHomePageState extends State<DemoHomePage> with DsiUiValueMixin {
  late var simpleCount = uiValue<int>(0);

  // VIEW ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
  @override
  void initState() {
    /// Initialize | Register a data model.
    Dsi.register<DataModel>(DataModel());

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("DSI Example"), centerTitle: true),

      body: ListView(
        children: [
          Text("Data Synchronizer Interface", textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge),
          Text("Concepts demonstractions", textAlign: TextAlign.center, style: Theme.of(context).textTheme.labelLarge),

          SizedBox(height: 63),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // DSI
              Text("DSI", style: TextStyle(fontWeight: FontWeight.bold)),
              Text("Handle Data Sync Interface"),
              ElevatedButton.icon(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const DsiPage1())),
                icon: Icon(Icons.open_in_browser),
                label: Text("Open demo view"),
                style: ButtonStyle(iconAlignment: IconAlignment.end),
              ),

              // CALLBACK
              SizedBox(height: 38),
              Text("DSI CALLBACK", style: TextStyle(fontWeight: FontWeight.bold)),
              Text("Test DSI callbacks system"),
              ElevatedButton.icon(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => CallbackPage1Screen())),
                icon: Icon(Icons.open_in_browser),
                label: Text("Open demo view"),
                style: ButtonStyle(iconAlignment: IconAlignment.end),
              ),

              // VALUE
              SizedBox(height: 38),
              Text("DSI VALUE", style: TextStyle(fontWeight: FontWeight.bold)),
              Text("Test env value"),
              ElevatedButton.icon(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => ValuePage1Screen())),
                icon: Icon(Icons.open_in_browser),
                label: Text("Open demo view"),
                style: ButtonStyle(iconAlignment: IconAlignment.end),
              ),

              // UI VALUE
              SizedBox(height: 38),
              Text("DSI UI VALUE", style: TextStyle(fontWeight: FontWeight.bold)),
              Text("Test for UI value: simplify the call of setState"),
              // USAGE -----------------------------------------------------------------------------------------------
              Text("${simpleCount.value}", style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center),
              ElevatedButton.icon(
                onPressed: () => simpleCount.value += 1,
                icon: Icon(Icons.add),
                label: Text("Increment counter"),
                style: ButtonStyle(iconAlignment: IconAlignment.end),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void Function(void Function() p1) get dsiStater => setState;
}
