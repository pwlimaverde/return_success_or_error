import 'package:flutter/material.dart';
import 'package:rx_notifier/rx_notifier.dart';

import 'check_connect_state.dart';

class CheckConnectPage extends StatefulWidget {
  const CheckConnectPage({super.key});

  @override
  State<CheckConnectPage> createState() => _CheckConnectPageState();
}

class _CheckConnectPageState extends State<CheckConnectPage> {
  @override
  Widget build(BuildContext context) {
    final conn = context.select(() => checarConeccaoState.value);
    final type = context.select(() => typeConeccaoState.value);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Check Connect"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Connection query result:',
            ),
            Text(
              conn ?? "Click in Check conect!",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            conn == null
                ? const SizedBox()
                : Column(
                    children: [
                      const Text(
                        'Connection type result:',
                      ),
                      Text(
                        type ?? "Connection lost...",
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ],
                  ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          checarConnecaoAction();
          // _checkTypeConnection();
          // setState(() {});
        },
        tooltip: 'Increment',
        child: const Icon(Icons.analytics),
      ),
    );
  }
}
