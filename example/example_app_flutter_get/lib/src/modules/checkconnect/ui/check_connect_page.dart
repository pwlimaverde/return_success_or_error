import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'check_connect_controller.dart';

final class CheckConnectPage extends GetView<CheckConnectController> {
  const CheckConnectPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Check Connect"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Obx(
              () => Text(
                controller.checarConeccaoState ?? "Click in Check conect!",
                style: Theme.of(context).textTheme.headlineMedium,
              ),
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
            Obx(
              () => Text(
                controller.twoPlusTowState == null
                    ? "Click in Check sum two Plus Tow!"
                    : controller.twoPlusTowState.toString(),
                style: Theme.of(context).textTheme.headlineMedium,
              ),
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
    );
  }
}
