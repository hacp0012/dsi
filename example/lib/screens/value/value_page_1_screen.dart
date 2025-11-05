import 'dart:async';

import 'package:dsi/dsi.dart';
import 'package:example/models/data_keys.dart';
import 'package:flutter/material.dart';

class ValuePage1Screen extends StatefulWidget {
  const ValuePage1Screen({super.key});

  @override
  State<ValuePage1Screen> createState() => _ValuePage1ScreenState();
}

class _ValuePage1ScreenState extends State<ValuePage1Screen> {
  int count = 0;
  StreamSubscription<String>? subscription;
  // VIEW ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
  @override
  void initState() {
    // USAGE ------------------------------------------------------
    Dsi.values.register<int>(data: 0, key: DataKeys.VALUE_ENV_KEY);

    // USAGE ------------------------------------------------------------------
    subscription = Dsi.values.get(DataKeys.VALUE_ENV_KEY)?.listen((data) {
      setState(() => count = data ?? count);
    });

    super.initState();
  }

  @override
  void dispose() {
    // USAGE --------------
    subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Value (ENV)"), centerTitle: true),

      // BODY
      body: ListView(
        padding: EdgeInsets.all(12),
        children: [
          Text("Shared value", style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center),
          SizedBox(height: 24),

          Card.filled(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  Text("Widget 1", style: Theme.of(context).textTheme.titleLarge),
                  SizedBox(height: 12),
                  // USAGE -----------------------------------------------------
                  Text("$count", style: TextStyle(fontWeight: FontWeight.bold)),
                  Text("Usage via stream listner"),
                  SizedBox(height: 12),

                  ElevatedButton(
                    onPressed: () {
                      // USAGE -------------------------------------------------------
                      Dsi.values.notifyTo<int>(
                        DataKeys.VALUE_ENV_KEY,
                        (Dsi.values.get(DataKeys.VALUE_ENV_KEY)?.value ?? 0) + 1,
                      );
                    },
                    child: Text("Increment value"),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 24),
          Card.filled(
            color: Colors.greenAccent.shade100,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  Text("Widget 2", style: Theme.of(context).textTheme.titleLarge),
                  SizedBox(height: 12),
                  // USAGE ------------------------------------------------------------------------------
                  DsiBuilder(
                    idKey: DataKeys.VALUE_ENV_KEY,
                    builder: (BuildContext context, data) {
                      return Text("${data ?? 'Not yet'}", style: TextStyle(fontWeight: FontWeight.bold));
                    },
                  ),
                  Text("Usage via a Widget Builder"),
                  SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
