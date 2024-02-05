import 'package:flutter/material.dart';
import 'package:rx_notifier/rx_notifier.dart';

import 'check_connect_state.dart';

final class CheckConnectPage extends StatefulWidget {
  const CheckConnectPage({super.key});

  @override
  State<CheckConnectPage> createState() => _CheckConnectPageState();
}

final class _CheckConnectPageState extends State<CheckConnectPage> {
  @override
  Widget build(BuildContext context) {
    final conn = context.select(() => checarConeccaoState.value);
    final sum = context.select(() => twoPlusTowState.value);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Check Connect"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              conn ?? "Click in Check conect!",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(
              height: 10,
            ),
            ElevatedButton(
              onPressed: checarConnecaoAction,
              child: const Text(
                'Check conect!',
              ),
            ),
            const SizedBox(
              height: 60,
            ),
            Text(
              sum == null ? "Click in Check sum two Plus Tow!" : sum.toString(),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(
              height: 10,
            ),
            ElevatedButton(
              onPressed: twoPlusTowAction,
              child: const Text(
                'Click in Check two Plus Tow!',
              ),
            )
          ],
        ),
      ),
    );
  }
}
