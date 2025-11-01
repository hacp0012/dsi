import 'package:dsi/dsi.dart' show Dsi;
import 'package:example/models/data_model.dart';
import 'package:example/screens/dsi/dsi_page_2.dart';
import 'package:flutter/material.dart';

class DsiPage1 extends StatefulWidget {
  const DsiPage1({super.key});

  @override
  State<DsiPage1> createState() => _DsiPage1State();
}

class _DsiPage1State extends State<DsiPage1> {
  @override
  void dispose() {
    /// USAGE --------------------------:
    Dsi.update<DataModel>((model) {
      model.count = 0;
      return model;
    }, notify: false); // Silent change.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("DSI page 1")),

      // BDOY
      body: ListView(
        padding: EdgeInsets.all(12),
        children: [
          // USAGE.
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  Text("First case of usage", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 12),

                  /// USAGE --------------------------------------------------
                  Text(
                    "Count: ${Dsi.of<DataModel>(context)?.count ?? "Not yet"}",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      /// UPDATE --------------------
                      Dsi.update<DataModel>((model) {
                        model.count = (model.count ?? 0) + 1;
                        return model;
                      });
                    },
                    icon: Icon(Icons.add),
                    label: Text("Increment count"),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 28),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  Text("Second case of usage", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 12),

                  /// USAGE --------------------------------------------------
                  Text(
                    "Count: ${Dsi.of<DataModel>(context)?.count ?? "Not yet"}",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: 24),
                  Text("Go to second page and update counter"),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => const DsiPage2()));
                    },
                    icon: Icon(Icons.arrow_right_alt),
                    iconAlignment: IconAlignment.end,
                    label: Text("Go to Second page"),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
