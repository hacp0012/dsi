import 'package:dsi/dsi.dart';
import 'package:example/models/data_keys.dart';
import 'package:flutter/material.dart';

class CallbackPage2Screen extends StatefulWidget {
  const CallbackPage2Screen({super.key});

  @override
  State<CallbackPage2Screen> createState() => _CallbackPage2ScreenState();
}

class _CallbackPage2ScreenState extends State<CallbackPage2Screen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Callback page 2")),

      // BODY.
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Send message", style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                // USAGE -----------------------------------------------------------------------------------------------------
                bool isSent = Dsi.callback.call(DataKeys.SAMPLE_CALLBACK_KEY, payload: "This message come from closed page.");
                if (isSent) {
                  _showSnackbar();
                }
              },
              iconAlignment: IconAlignment.end,
              icon: Icon(Icons.send),
              label: Text("Send to the back Page 1"),
            ),

            SizedBox(height: 24),
            TextButton.icon(onPressed: () => Navigator.pop(context), icon: Icon(Icons.arrow_back), label: Text("Back")),
          ],
        ),
      ),
    );
  }

  // METHODS -----------------------------------------------------------------------------------------------------------------
  void _showSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Message sent")));
  }
}
