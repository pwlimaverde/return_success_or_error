import 'package:flutter/material.dart';
import 'package:flutter_getit/flutter_getit.dart';
import 'package:signals_flutter/signals_flutter.dart';

import 'check_connect_controller.dart';

final class CheckConnectPage extends StatefulWidget {
  const CheckConnectPage({super.key});

  @override
  State<CheckConnectPage> createState() => _CheckConnectPageState();
}

final class _CheckConnectPageState extends State<CheckConnectPage> {
  final controller = Injector.get<CheckConnectController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text("Check Connect"),
        ),
        body: Watch(
          (context) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  controller.checarConeccaoState ?? "Click in Check conect!",
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(
                  height: 10,
                ),
                ElevatedButton(
                  onPressed: controller.checkConnect,
                  child: const Text(
                    'Check conect!',
                  ),
                ),
                const SizedBox(
                  height: 60,
                ),
                Text(
                  controller.twoPlusTowState == null
                      ? "Click in Check sum two Plus Tow!"
                      : controller.twoPlusTowState.toString(),
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(
                  height: 10,
                ),
                ElevatedButton(
                  onPressed: controller.twoPlusTow,
                  child: const Text(
                    'Click in Check two Plus Tow!',
                  ),
                )
              ],
            ),
          ),
        ));
  }
}
