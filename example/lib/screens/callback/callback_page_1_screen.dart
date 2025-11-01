import 'package:dsi/dsi.dart';
import 'package:example/models/data_keys.dart';
import 'package:example/screens/callback/callback_page_2_screen.dart';
import 'package:flutter/material.dart';

class CallbackPage1Screen extends StatefulWidget {
  const CallbackPage1Screen({super.key});

  @override
  State<CallbackPage1Screen> createState() => _CallbackPage1ScreenState();
}

class _CallbackPage1ScreenState extends State<CallbackPage1Screen> {
  String? message;

  // VIEW ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
  @override
  void initState() {
    /// REGISTER A CALLBACK ----------------------------------------
    Dsi.callback.register(DataKeys.SAMPLE_CALLBACK_KEY, (message) => updateWith(message as String));

    super.initState();
  }

  void updateWith(String message) {
    setState(() => this.message = message);
  }

  @override
  void dispose() {
    // USAGE ------------------------------------------
    Dsi.callback.dispose(DataKeys.SAMPLE_CALLBACK_KEY);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Callback page 1")),

      // BODY.
      body: ListView(
        padding: EdgeInsets.all(12),
        children: [
          Text("Received message", style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center),
          SizedBox(height: 18),
          // USAGE --------------------------------------
          Text(
            message ?? "No received message yet",
            style: TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          FilledButton.tonalIcon(
            onPressed: () {
              // USAGE ------------------------------------------------------------------------------------
              Dsi.callback.call(DataKeys.SAMPLE_CALLBACK_KEY, payload: "Hello! i'm the message you sent.");
            },
            icon: Icon(Icons.send),
            label: Text("Send message"),
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => CallbackPage2Screen())),
            iconAlignment: IconAlignment.end,
            icon: Icon(Icons.arrow_right_alt),
            label: Text("Open send message page"),
          ),
        ],
      ),
    );
  }
}
