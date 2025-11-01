import 'package:dsi/dsi.dart';
import 'package:example/models/data_model.dart';
import 'package:flutter/material.dart';

class DsiPage2 extends StatefulWidget {
  const DsiPage2({super.key});

  @override
  State<DsiPage2> createState() => _DsiPage2State();
}

class _DsiPage2State extends State<DsiPage2> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Dsi page 2")),
      // Body
      body: ListView(
        padding: EdgeInsets.all(12),
        children: [
          SizedBox(height: 12),

          /// Display counts. ---------------------------------------
          Text(
            "Clicks count: ${Dsi.of<DataModel>(context)?.count ?? 0}",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),

          SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(onPressed: () => Navigator.pop(context), icon: Icon(Icons.arrow_left), label: Text("Back")),
              SizedBox(width: 24),
              ElevatedButton.icon(
                /// Increment count. -----------------------------------
                onPressed: () => Dsi.of<DataModel>(context)?.increment(),
                icon: Icon(Icons.add),
                label: Text("Increment"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
